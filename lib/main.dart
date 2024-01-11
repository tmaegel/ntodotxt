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
import 'package:ntodotxt/domain/filter/filter_model.dart'
    show Filter, Order, Filters, Groups;
import 'package:ntodotxt/domain/filter/filter_repository.dart'
    show FilterRepository;
import 'package:ntodotxt/domain/settings/setting_model.dart' show Setting;
import 'package:ntodotxt/domain/settings/setting_repository.dart'
    show SettingRepository;
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/misc.dart' show SnackBarHandler;
import 'package:ntodotxt/presentation/default_filter/states/default_filter_cubit.dart';
import 'package:ntodotxt/presentation/drawer/states/drawer_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_bloc.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_event.dart';
import 'package:ntodotxt/presentation/login/pages/login_page.dart';
import 'package:ntodotxt/presentation/login/states/login_cubit.dart';
import 'package:ntodotxt/presentation/login/states/login_state.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
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
  runApp(
    FutureApp(
      basePath: (await getApplicationCacheDirectory()).path,
    ),
  );
}

Future<Filter> _initialFilter(String databasePath) async {
  final SettingRepository repository = SettingRepository(
    SettingController(databasePath),
  );
  final Setting? order = await repository.get(key: 'order');
  final Setting? filter = await repository.get(key: 'filter');
  final Setting? group = await repository.get(key: 'group');
  return Filter(
    order: Order.byName(order?.value),
    filter: Filters.byName(filter?.value),
    group: Groups.byName(group?.value),
  );
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

class SplashScreen extends StatelessWidget {
  final String? message;

  const SplashScreen({
    this.message,
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
          child: Text(message ?? 'Loading...'),
        ),
      ),
    );
  }
}

class FutureApp extends StatefulWidget {
  final String basePath;

  const FutureApp({
    required this.basePath,
    super.key,
  });

  @override
  State<FutureApp> createState() => _FutureAppState();
}

class _FutureAppState extends State<FutureApp> {
  late String databasePath;
  late File todoFile;

  @override
  void initState() {
    databasePath = path.join(widget.basePath, 'data.db');
    todoFile = File('${widget.basePath}${Platform.pathSeparator}todo.txt');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        _initialLogin(),
        _initialFilter(databasePath),
      ]),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasError) {
          return const SplashScreen(message: 'There is something wrong!');
        }

        if (snapshot.hasData) {
          return App(
            loginState: snapshot.data![0] as LoginState,
            filter: snapshot.data![1] as Filter,
            databasePath: databasePath,
            todoFile: todoFile,
          );
        }

        return const SplashScreen();
      },
    );
  }
}

class App extends StatelessWidget {
  final Filter filter;
  final LoginState loginState;
  final String databasePath;
  final File todoFile;
  final ThemeMode? themeMode;

  const App({
    required this.filter,
    required this.loginState,
    required this.databasePath,
    required this.todoFile,
    this.themeMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => LoginCubit(state: loginState),
      child: BlocConsumer<LoginCubit, LoginState>(
        listenWhen: (LoginState previous, LoginState current) =>
            current is LoginError,
        listener: (BuildContext context, LoginState state) {
          if (state is LoginError) {
            SnackBarHandler.error(context, state.message);
          }
        },
        buildWhen: (previousState, state) =>
            (previousState is Logout && state is! Logout) ||
            (previousState is! Logout && state is Logout),
        builder: (BuildContext context, LoginState state) {
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
              RepositoryProvider(
                create: (BuildContext context) {
                  return TodoListRepository(_createApi(state));
                },
              ),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider<DrawerCubit>(
                  create: (BuildContext context) => DrawerCubit(),
                ),
                BlocProvider<DefaultFilterCubit>(
                  create: (BuildContext context) => DefaultFilterCubit(
                    filter: filter,
                    repository: context.read<SettingRepository>(),
                  ),
                ),
                BlocProvider<TodoListBloc>(
                  create: (context) {
                    return TodoListBloc(
                      repository: context.read<TodoListRepository>(),
                    )
                      ..add(const TodoListSubscriptionRequested())
                      ..add(const TodoListSynchronizationRequested());
                  },
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
                  if (state is Logout) {
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
      ),
    );
  }

  TodoListApi _createApi(LoginState loginState) {
    switch (loginState) {
      case LoginOffline():
        log.info('Use local backend');
        return LocalTodoListApi(todoFile: todoFile);
      case LoginWebDAV():
        log.info('Use local+webdav backend');
        return WebDAVTodoListApi(
          todoFile: todoFile,
          server: loginState.server,
          baseUrl: loginState.baseUrl,
          username: loginState.username,
          password: loginState.password,
        );
      default:
        log.info('Fallback to local backend');
        return LocalTodoListApi(todoFile: todoFile);
    }
  }
}
