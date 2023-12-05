import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:ntodotxt/config/router/router.dart';
import 'package:ntodotxt/config/theme/theme.dart' show lightTheme, darkTheme;
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
  final String cacheDirectory = (await getApplicationCacheDirectory()).path;
  final File todoFile =
      File('$cacheDirectory${Platform.pathSeparator}todo.txt');

  log.info('Setup shared preferences');
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  log.info('Check initial login and backend status');
  final LoginState initialLoginState = await LoginCubit.init();

  log.info('Run app');
  runApp(LoginWrapper(
    prefs: prefs,
    todoFile: todoFile,
    initialLoginState: initialLoginState,
  ));
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
  final SharedPreferences prefs;

  const App({
    required this.prefs,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(
          create: (BuildContext context) => SettingsCubit(
            prefs: prefs,
          ),
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
        builder: (BuildContext context) {
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
