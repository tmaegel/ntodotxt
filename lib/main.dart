import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:ntodotxt/bloc_observer.dart' show GenericBlocObserver;
import 'package:ntodotxt/config/router/router.dart';
import 'package:ntodotxt/config/theme/theme.dart' show lightTheme, darkTheme;
import 'package:ntodotxt/data/filter/filter_controller.dart'
    show FilterController;
import 'package:ntodotxt/data/settings/setting_controller.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/filter/filter_repository.dart'
    show FilterRepository;
import 'package:ntodotxt/domain/settings/setting_repository.dart'
    show SettingRepository;
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/misc.dart' show SnackBarHandler;
import 'package:ntodotxt/presentation/drawer/states/drawer_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_bloc.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_event.dart';
import 'package:ntodotxt/presentation/login/pages/login_page.dart';
import 'package:ntodotxt/presentation/login/states/login_cubit.dart';
import 'package:ntodotxt/presentation/login/states/login_state.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo_file/todo_file_cubit.dart';
import 'package:ntodotxt/presentation/todo_file/todo_file_state.dart';
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

  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
  }

  Logger.root.level = Level.INFO; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  log.info('Initialize main');

  log.info('Setup bloc oberserver');
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = GenericBlocObserver();

  log.info('Run app');
  runApp(const FutureApp());
}

Future<LoginState> _initialLogin() async {
  String? backendFromsecureStorage = await secureStorage.read(key: 'backend');
  Backend backend;

  if (backendFromsecureStorage == null) {
    return const Logout();
  }

  try {
    backend = Backend.values.byName(backendFromsecureStorage);
  } on Exception {
    return const Logout();
  }

  if (backend == Backend.none) {
    return const Logout();
  }
  if (backend == Backend.offline) {
    return const LoginOffline();
  }
  if (backend == Backend.webdav) {
    String? server = await secureStorage.read(key: 'server');
    String? baseUrl = await secureStorage.read(key: 'baseUrl');
    String? username = await secureStorage.read(key: 'username');
    String? password = await secureStorage.read(key: 'password');
    if (server != null &&
        baseUrl != null &&
        username != null &&
        password != null) {
      return LoginWebDAV(
        server: server,
        baseUrl: baseUrl,
        username: username,
        password: password,
      );
    }
  }

  return const Logout();
}

class FutureApp extends StatefulWidget {
  const FutureApp({super.key});

  @override
  State<FutureApp> createState() => _FutureAppState();
}

class _FutureAppState extends State<FutureApp> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        _initialLogin(),
        getApplicationCacheDirectory(),
      ]),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasError) {
          return const SplashScreen(message: 'Something went wrong!');
        }

        if (snapshot.hasData) {
          final String databasePath =
              path.join(snapshot.data![1].path, 'data.db');

          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider<SettingRepository>(
                create: (BuildContext context) => SettingRepository(
                  SettingController(databasePath),
                ),
              ),
              RepositoryProvider<FilterRepository>(
                create: (BuildContext context) => FilterRepository(
                  FilterController(databasePath),
                ),
              ),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider<LoginCubit>(
                  create: (BuildContext context) => LoginCubit(
                    state: snapshot.data![0] as LoginState,
                  ),
                ),
                BlocProvider<TodoFileCubit>(
                  create: (BuildContext context) => TodoFileCubit(
                    repository: context.read<SettingRepository>(),
                  )..initial(),
                ),
                BlocProvider<DrawerCubit>(
                  create: (BuildContext context) => DrawerCubit(),
                ),
                // Default filter
                BlocProvider<FilterCubit>(
                  create: (BuildContext context) => FilterCubit(
                    settingRepository: context.read<SettingRepository>(),
                    filterRepository: context.read<FilterRepository>(),
                  )..initial(),
                ),
                BlocProvider<FilterListBloc>(
                  create: (BuildContext context) {
                    return FilterListBloc(
                      repository: context.read<FilterRepository>(),
                    )
                      ..add(const FilterListSubscriped())
                      ..add(const FilterListSynchronizationRequested());
                  },
                ),
              ],
              child: Builder(
                builder: (BuildContext context) {
                  return BlocBuilder<TodoFileCubit, TodoFileState>(
                    builder:
                        (BuildContext context, TodoFileState todoFileState) {
                      if (todoFileState is TodoFileLoading) {
                        return const SplashScreen();
                      } else {
                        return const App();
                      }
                    },
                  );
                },
              ),
            ),
          );
        }

        return const SplashScreen();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  final String message;

  const SplashScreen({
    this.message = 'Loading ...',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: Center(
          child: Text(message),
        ),
      ),
    );
  }
}

class App extends StatelessWidget {
  final ThemeMode? themeMode;

  const App({
    this.themeMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listenWhen: (LoginState previous, LoginState current) =>
          current is LoginError,
      listener: (BuildContext context, LoginState state) {
        if (state is LoginError) {
          SnackBarHandler.error(context, state.message);
        }
      },
      buildWhen: (LoginState previousState, LoginState state) =>
          (previousState is Logout && state is! Logout) ||
          (previousState is! Logout && state is Logout),
      builder: (BuildContext context, LoginState loginState) {
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
                    if (loginState is Logout ||
                        todoFileState.localPath == null) {
                      return MaterialApp(
                        debugShowCheckedModeBanner: false,
                        theme: lightTheme,
                        darkTheme: darkTheme,
                        themeMode: themeMode,
                        home: const LoginPage(),
                      );
                    } else {
                      return MaterialApp.router(
                        title: 'ntodotxt',
                        debugShowCheckedModeBanner: false,
                        theme: lightTheme,
                        darkTheme: darkTheme,
                        themeMode: themeMode,
                        routerConfig: AppRouter().config,
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  TodoListRepository _createTodoListRepository(
      LoginState loginState, TodoFileState todoFileState) {
    late TodoListApi api;
    File todoFile = File(
        '${todoFileState.localPath}${Platform.pathSeparator}${todoFileState.todoFilename}');
    log.info('Use todo file ${todoFile.path}');
    switch (loginState) {
      case LoginOffline():
        log.info('Use local backend');
        api = LocalTodoListApi(todoFile: todoFile);
      case LoginWebDAV():
        log.info('Use local+webdav backend');
        api = WebDAVTodoListApi(
          todoFile: todoFile,
          server: loginState.server,
          baseUrl: loginState.baseUrl,
          username: loginState.username,
          password: loginState.password,
        );
      default:
        log.info('Fallback to local backend');
        api = LocalTodoListApi(todoFile: todoFile);
    }

    return TodoListRepository(api);
  }
}
