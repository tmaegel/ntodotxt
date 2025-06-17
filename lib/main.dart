import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:ntodotxt/common/bloc_observer.dart' show GenericBlocObserver;
import 'package:ntodotxt/common/misc.dart' show SnackBarHandler;
import 'package:ntodotxt/common/router/router.dart';
import 'package:ntodotxt/common/theme/theme.dart' show lightTheme, darkTheme;
import 'package:ntodotxt/database/controller/database.dart';
import 'package:ntodotxt/drawer/state/drawer_cubit.dart';
import 'package:ntodotxt/filter/controller/filter_controller.dart'
    show FilterController;
import 'package:ntodotxt/filter/repository/filter_repository.dart'
    show FilterRepository;
import 'package:ntodotxt/filter/state/filter_cubit.dart';
import 'package:ntodotxt/filter/state/filter_list_bloc.dart';
import 'package:ntodotxt/filter/state/filter_list_event.dart';
import 'package:ntodotxt/filter/state/filter_list_state.dart';
import 'package:ntodotxt/filter/state/filter_state.dart';
import 'package:ntodotxt/intro/page/intro_page.dart';
import 'package:ntodotxt/login/state/login_cubit.dart';
import 'package:ntodotxt/login/state/login_state.dart';
import 'package:ntodotxt/setting/controller/setting_controller.dart';
import 'package:ntodotxt/setting/repository/setting_repository.dart'
    show SettingRepository;
import 'package:ntodotxt/todo/api/todo_list_api.dart';
import 'package:ntodotxt/todo/repository/todo_list_repository.dart';
import 'package:ntodotxt/todo/state/todo_list_bloc.dart';
import 'package:ntodotxt/todo/state/todo_list_event.dart';
import 'package:ntodotxt/todo_file/state/todo_file_cubit.dart';
import 'package:ntodotxt/todo_file/state/todo_file_state.dart';
import 'package:ntodotxt/webdav/client/webdav_client.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final Logger log = Logger('ntodotxt');
const FlutterSecureStorage secureStorage = FlutterSecureStorage(
  // Pass the option to the constructor
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

void main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
  }

  Logger.root.level = Level.FINER; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  log.info('Initialize main');

  log.info('Setup bloc oberserver');
  Bloc.observer = GenericBlocObserver();
  Directory appDataDir = await getApplicationDocumentsDirectory();

  log.info('Run app');
  runApp(
    App(appDataDir: appDataDir.path),
  );
}

class App extends StatefulWidget {
  final String appDataDir;

  const App({
    required this.appDataDir,
    super.key,
  });

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final DatabaseController dbController;

  @override
  void initState() {
    super.initState();
    dbController = DatabaseController(path.join(widget.appDataDir, 'data.db'));
  }

  @override
  void dispose() {
    dbController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseController dbController = DatabaseController(
      path.join(widget.appDataDir, 'data.db'),
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingRepository>(
          create: (BuildContext context) => SettingRepository(
            SettingController(dbController),
          ),
        ),
        RepositoryProvider<FilterRepository>(
          create: (BuildContext context) => FilterRepository(
            FilterController(dbController),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LoginCubit>(
            create: (BuildContext context) => LoginCubit(),
          ),
          BlocProvider<TodoFileCubit>(
            create: (BuildContext context) => TodoFileCubit(
              repository: context.read<SettingRepository>(),
              localPath: widget.appDataDir,
            ),
          ),
          BlocProvider<DrawerCubit>(
            create: (BuildContext context) => DrawerCubit(),
          ),
          // Default filter
          BlocProvider<FilterCubit>(
            create: (BuildContext context) => FilterCubit(
              settingRepository: context.read<SettingRepository>(),
              filterRepository: context.read<FilterRepository>(),
            ),
          ),
          BlocProvider<FilterListBloc>(
            create: (BuildContext context) => FilterListBloc(
              repository: context.read<FilterRepository>(),
            ),
          ),
        ],
        child: Builder(
          builder: (BuildContext context) {
            return BlocBuilder<LoginCubit, LoginState>(
              builder: (BuildContext context, LoginState state) {
                if (state is LoginLocal || state is LoginWebDAV) {
                  return CoreApp(loginState: state);
                } else {
                  return const InitialApp();
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class InitialApp extends StatelessWidget {
  final ThemeMode? themeMode;

  const InitialApp({
    this.themeMode,
    super.key,
  });

  Future<bool> _initialize(BuildContext context) async {
    if (context.mounted) {
      await context.read<FilterCubit>().load();
    }
    if (context.mounted) {
      await context.read<TodoFileCubit>().load();
    }
    if (context.mounted) {
      context.read<FilterListBloc>()
        ..add(const FilterListSubscriped())
        ..add(const FilterListSynchronizationRequested());
    }
    if (context.mounted) {
      await context.read<LoginCubit>().login();
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'),
        Locale('de'),
      ],
      home: MultiBlocListener(
        listeners: [
          BlocListener<LoginCubit, LoginState>(
            listener: (BuildContext context, LoginState state) {
              if (state is LoginError) {
                SnackBarHandler.error(context, state.message);
              }
            },
          ),
          BlocListener<TodoFileCubit, TodoFileState>(
            listener: (BuildContext context, TodoFileState state) {
              if (state is TodoFileError) {
                SnackBarHandler.error(context, state.message);
              }
            },
          ),
          BlocListener<FilterListBloc, FilterListState>(
            listener: (BuildContext context, FilterListState state) {
              if (state is FilterListError) {
                SnackBarHandler.error(context, state.message);
              }
            },
          ),
          BlocListener<FilterCubit, FilterState>(
            listener: (BuildContext context, FilterState state) {
              if (state is FilterError) {
                SnackBarHandler.error(context, state.message);
              }
            },
          ),
        ],
        child: FutureBuilder<bool>(
          future: _initialize(context),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              return BlocBuilder<LoginCubit, LoginState>(
                builder: (BuildContext context, LoginState state) {
                  if (state is LoginLoading ||
                      state is LoginLocal ||
                      state is LoginWebDAV) {
                    // Keep loading screen to prevent screen flickering.
                    return _loadingScreen();
                  } else {
                    return const IntroPage();
                  }
                },
              );
            } else if (snapshot.hasError) {
              return _errorScreen();
            } else {
              return _loadingScreen();
            }
          },
        ),
      ),
    );
  }

  Widget _loadingScreen() {
    return Scaffold(
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.5,
          heightFactor: 0.5,
          child: Image.asset('assets/icon/icon.png'),
        ),
      ),
    );
  }

  Widget _errorScreen() {
    return const Scaffold(
      body: Center(
        child: Text('Something went wrong.'),
      ),
    );
  }
}

class CoreApp extends StatelessWidget {
  final LoginState loginState;
  final ThemeMode? themeMode;

  const CoreApp({
    required this.loginState,
    this.themeMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoFileCubit, TodoFileState>(
      builder: (BuildContext context, TodoFileState todoFileState) {
        final TodoListRepository todoListRepository =
            _createTodoListRepository(loginState, todoFileState);
        final TodoListBloc todoListBloc = TodoListBloc(
          repository: todoListRepository,
        )
          ..add(const TodoListSubscriptionRequested())
          ..add(const TodoListSynchronizationRequested());
        return RepositoryProvider(
          create: (BuildContext context) => todoListRepository,
          child: BlocProvider.value(
            value: todoListBloc,
            child: Builder(
              builder: (BuildContext context) {
                return MaterialApp.router(
                  title: 'ntodotxt',
                  debugShowCheckedModeBanner: false,
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: themeMode,
                  localizationsDelegates: [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: [
                    Locale('en'),
                    Locale('de'),
                  ],
                  routerConfig: AppRouter().config,
                );
              },
            ),
          ),
        );
      },
    );
  }

  TodoListRepository _createTodoListRepository(
      LoginState loginState, TodoFileState todoFileState) {
    late TodoListApi api;
    switch (loginState) {
      case LoginLocal():
        log.info('Use local backend');
        log.info('Using local todo file ${todoFileState.localTodoFilePath}');
        api = LocalTodoListApi.fromString(
          localFilePath: todoFileState.localTodoFilePath,
        );
      case LoginWebDAV():
        log.info('Use local+webdav backend');
        log.info('Using remote todo file ${todoFileState.localTodoFilePath}');
        api = WebDAVTodoListApi.fromString(
          localFilePath: todoFileState.localTodoFilePath,
          remoteFilePath: todoFileState.remoteTodoFilePath,
          client: WebDAVClient(
            server: loginState.server,
            path: loginState.path,
            username: loginState.username,
            password: loginState.password,
            acceptUntrustedCert: loginState.acceptUntrustedCert,
          ),
        );
      default:
        log.info('Fallback to local backend');
        log.info('Using local todo file ${todoFileState.localTodoFilePath}');
        api = LocalTodoListApi.fromString(
          localFilePath: todoFileState.localTodoFilePath,
        );
    }

    return TodoListRepository(api);
  }
}
