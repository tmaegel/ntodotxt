import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:ntodotxt/config/router/router.dart';
import 'package:ntodotxt/config/theme/theme.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/misc.dart';
import 'package:ntodotxt/presentation/login/states/login_cubit.dart';
import 'package:ntodotxt/presentation/login/states/login_state.dart';
import 'package:ntodotxt/presentation/settings/states/settings_cubit.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final log = Logger('ntodotxt');

void main() async {
  Logger.root.level = Level.FINE; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  log.info('Initialize main');

  log.info('Setup bloc oberserver');
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();

  log.info('Setup shared preferences');
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  log.info('Setup secure storage');
  const secureStorage = FlutterSecureStorage(
    // Pass the option to the constructor
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  log.info('Setup todo list repository');
  final String directory = (await getApplicationCacheDirectory()).path;
  final File file = File('$directory${Platform.pathSeparator}todo.txt');
  final LocalTodoListApi todoListApi = LocalTodoListApi(file);
  final TodoListRepository todoListRepository =
      TodoListRepository(todoListApi: todoListApi);

  // Initialize the initial auth state before starting the app.
  log.info('Setup authentication state');
  final AuthState authState = await AuthCubit.init(secureStorage);

  log.info('Run app');
  runApp(
    App(
      todoListRepository: todoListRepository,
      secureStorage: secureStorage,
      authState: authState,
      prefs: prefs,
    ),
  );
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
  final TodoListRepository todoListRepository;
  final FlutterSecureStorage secureStorage;
  final SharedPreferences prefs;
  final AuthState authState;

  const App({
    required this.todoListRepository,
    required this.secureStorage,
    required this.prefs,
    required this.authState,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = CustomTheme.light;
    final ThemeData darkTheme = CustomTheme.dark;
    return RepositoryProvider.value(
      value: todoListRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (BuildContext context) => AuthCubit(
              storage: secureStorage,
              state: authState,
            ),
          ),
          BlocProvider<SettingsCubit>(
            create: (BuildContext context) => SettingsCubit(prefs: prefs),
          ),
          BlocProvider<TodoListBloc>(
            create: (context) => TodoListBloc(
              prefs: prefs,
              todoListRepository: todoListRepository,
            )..add(const TodoListSubscriptionRequested()),
          ),
        ],
        child: Builder(
          builder: (context) {
            return MaterialApp.router(
              title: 'Flutter layout demo',
              debugShowCheckedModeBanner: false, // Remove the debug banner
              theme: lightTheme.copyWith(
                appBarTheme: lightTheme.appBarTheme.copyWith(
                  backgroundColor: Colors.transparent,
                ),
                splashColor: PlatformInfo.isAppOS ? Colors.transparent : null,
                chipTheme: lightTheme.chipTheme.copyWith(
                  backgroundColor: lightTheme.dividerColor,
                  shape: const StadiumBorder(),
                ),
                expansionTileTheme: lightTheme.expansionTileTheme.copyWith(
                  collapsedBackgroundColor:
                      lightTheme.appBarTheme.backgroundColor,
                ),
                listTileTheme: lightTheme.listTileTheme.copyWith(
                  selectedColor: lightTheme.textTheme.bodySmall?.color,
                  selectedTileColor: lightTheme.hoverColor,
                ),
              ),
              darkTheme: darkTheme.copyWith(
                appBarTheme: darkTheme.appBarTheme.copyWith(
                  backgroundColor: Colors.transparent,
                ),
                splashColor: PlatformInfo.isAppOS ? Colors.transparent : null,
                chipTheme: darkTheme.chipTheme.copyWith(
                  backgroundColor: darkTheme.dividerColor,
                  shape: const StadiumBorder(),
                ),
                expansionTileTheme: darkTheme.expansionTileTheme.copyWith(
                  collapsedBackgroundColor:
                      darkTheme.appBarTheme.backgroundColor,
                ),
                listTileTheme: darkTheme.listTileTheme.copyWith(
                  selectedColor: darkTheme.textTheme.bodySmall?.color,
                  selectedTileColor:
                      PlatformInfo.isAppOS ? Colors.red : darkTheme.hoverColor,
                ),
              ),
              // If you do not have a themeMode switch, uncomment this line
              // to let the device system mode control the theme mode:
              themeMode: ThemeMode.system,
              routerConfig: AppRouter(context.read<AuthCubit>()).config,
            );
          },
        ),
      ),
    );
  }
}
