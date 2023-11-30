import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:ntodotxt/config/router/router.dart';
import 'package:ntodotxt/config/theme/theme.dart' show lightTheme, darkTheme;
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/presentation/login/pages/login_page.dart';
import 'package:ntodotxt/presentation/login/states/login_cubit.dart';
import 'package:ntodotxt/presentation/login/states/login_state.dart';
import 'package:ntodotxt/presentation/settings/states/settings_cubit.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Logger log = Logger('ntodotxt');
const FlutterSecureStorage secureStorage = FlutterSecureStorage(
  // Pass the option to the constructor
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);
late final SharedPreferences prefs;
late final String cacheDirectory;

void main() async {
  Logger.root.level = Level.FINE; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  log.info('Initialize main');

  log.info('Setup bloc oberserver');
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();

  log.info('Get users cache directory');
  cacheDirectory = (await getApplicationCacheDirectory()).path;

  log.info('Setup shared preferences');
  prefs = await SharedPreferences.getInstance();

  log.info('Check initial login and backend status');
  final LoginState initialLoginState = await LoginCubit.init(secureStorage);

  log.info('Run app');
  runApp(AuthenticationWrapper(initialLoginState: initialLoginState));
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log.fine(
        'STATE CHANGE: ${change.currentState.runtimeType} > ${change.nextState.runtimeType}');
    log.finer('${bloc.runtimeType} $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log.finest('${bloc.runtimeType} $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log.fine('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(
          create: (BuildContext context) => SettingsCubit(prefs: prefs),
        ),
        BlocProvider<TodoListBloc>(
          create: (context) => TodoListBloc(
            prefs: prefs,
            repository: context.read<TodoListRepository>(),
          )
            ..add(const TodoListSubscriptionRequested())
            ..add(const TodoListSynchronizationRequested()),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'ntodotxt',
            debugShowCheckedModeBanner: false, // Remove the debug banner
            theme: lightTheme,
            darkTheme: darkTheme,
            // If you do not have a themeMode switch, uncomment this line
            // to let the device system mode control the theme mode:
            themeMode: ThemeMode.system,
            routerConfig: AppRouter().config,
          );
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  final LoginState initialLoginState;

  const AuthenticationWrapper({
    required this.initialLoginState,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => LoginCubit(
        storage: secureStorage,
        state: initialLoginState,
      ),
      child: BlocConsumer<LoginCubit, LoginState>(
        listenWhen: (LoginState previous, LoginState current) =>
            current is LoginError,
        listener: (BuildContext context, LoginState state) {
          if (state is LoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).colorScheme.error,
                content: Text(state.message),
              ),
            );
          }
        },
        buildWhen: (previousState, state) =>
            (previousState is Logout && state is! Logout) ||
            (previousState is! Logout && state is Logout),
        builder: (BuildContext context, LoginState state) {
          if (state is Logout) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: ThemeMode.system,
              home: const LoginPage(),
            );
          } else {
            return RepositoryProvider(
              create: (BuildContext context) {
                log.info('Create repository');
                return TodoListRepository(api: _createApi(state));
              },
              child: const App(),
            );
          }
        },
      ),
    );
  }

  TodoListApi _createApi(LoginState loginState) {
    final File file = File('$cacheDirectory${Platform.pathSeparator}todo.txt');
    switch (loginState) {
      case LoginOffline():
        log.info('Use local backend');
        return LocalTodoListApi(todoFile: file);
      case LoginWebDAV():
        log.info('Use local+webdav backend');
        return WebDAVTodoListApi(
          todoFile: file,
          server: loginState.server,
          baseUrl: loginState.baseUrl,
          username: loginState.username,
          password: loginState.password,
        );
      default:
        log.info('Fallback to local backend');
        return LocalTodoListApi(todoFile: file);
    }
  }
}
