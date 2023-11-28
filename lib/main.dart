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
  final AuthState initialAuthState = await AuthCubit.init(secureStorage);

  log.info('Run app');
  runApp(AuthenticationWrapper(initialAuthState: initialAuthState));
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log.finest('${bloc.runtimeType} $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log.finest('${bloc.runtimeType} $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log.finest('${bloc.runtimeType} $error $stackTrace');
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
          )..add(const TodoListSubscriptionRequested()),
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
  final AuthState initialAuthState;

  const AuthenticationWrapper({
    required this.initialAuthState,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AuthCubit(
        storage: secureStorage,
        state: initialAuthState,
      ),
      child: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: (previousState, state) =>
            (previousState is Unauthenticated && state is! Unauthenticated) ||
            (previousState is! Unauthenticated && state is Unauthenticated),
        builder: (BuildContext context, AuthState state) {
          if (state is Unauthenticated) {
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

  TodoListApi _createApi(AuthState authState) {
    final File file = File('$cacheDirectory${Platform.pathSeparator}todo.txt');
    switch (authState) {
      case OfflineLogin():
        log.info('Use local backend');
        return LocalTodoListApi(todoFile: file);
      case WebDAVLogin():
        log.info('Use local+webdav backend');
        return WebDAVTodoListApi(
          todoFile: file,
          server: authState.server,
          username: authState.username,
          password: authState.password,
        );
      default:
        log.info('Fallback to local backend');
        return LocalTodoListApi(todoFile: file);
    }
  }
}
