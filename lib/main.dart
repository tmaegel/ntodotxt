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
import 'package:ntodotxt/domain/filter/filter_repository.dart'
    show FilterRepository;
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/presentation/default_filter/states/default_filter_cubit.dart';
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
late final String cacheDirectory;
// late final Future<Database> database;

void main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

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
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = GenericBlocObserver();

  log.info('Get users cache directory');
  cacheDirectory = (await getApplicationCacheDirectory()).path;
  final File todoFile =
      File('$cacheDirectory${Platform.pathSeparator}todo.txt');

  log.info('Check initial login and backend status');
  final LoginState initialLoginState = await LoginCubit.init();

  log.info('Run app');
  runApp(LoginWrapper(
    todoFile: todoFile,
    initialLoginState: initialLoginState,
  ));
}

class App extends StatelessWidget {
  const App({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (BuildContext context) {
        return FilterRepository(
          FilterController(path.join(cacheDirectory, 'data.db')),
        );
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider<DefaultFilterCubit>(
            create: (BuildContext context) => DefaultFilterCubit(),
          ),
          // Is required to retrieve general information from the
          // unfiltered todo list.
          BlocProvider<TodoListBloc>(
            create: (context) => TodoListBloc(
              repository: context.read<TodoListRepository>(),
            )
              ..add(const TodoListSubscriptionRequested())
              ..add(const TodoListSynchronizationRequested()),
          ),
          BlocProvider<FilterListBloc>(
            create: (BuildContext context) => FilterListBloc(
              context.read<FilterRepository>(),
            )..add(const FilterListSubscriped()),
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
      ),
    );
  }
}
