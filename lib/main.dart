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
import 'package:ntodotxt/domain/filter/filter_model.dart'
    show Filter, Order, Filters, Groups;
import 'package:ntodotxt/domain/filter/filter_repository.dart'
    show FilterRepository;
import 'package:ntodotxt/domain/settings/setting_model.dart' show Setting;
import 'package:ntodotxt/domain/settings/setting_repository.dart'
    show SettingRepository;
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/presentation/default_filter/states/default_filter_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_bloc.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_event.dart';
import 'package:ntodotxt/presentation/login/pages/login_page.dart';
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

  Logger.root.level = Level.FINER; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  log.info('Initialize main');

  log.info('Setup bloc oberserver');
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = GenericBlocObserver();

  final String cacheDirectory = (await getApplicationCacheDirectory()).path;
  log.info('Run app');
  runApp(LoginWrapper(
    databasePath: path.join(cacheDirectory, 'data.db'),
    todoFile: File('$cacheDirectory${Platform.pathSeparator}todo.txt'),
  ));
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

class App extends StatelessWidget {
  final String databasePath;

  const App({
    required this.databasePath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingRepository>(
          create: (BuildContext context) =>
              SettingRepository(SettingController(databasePath)),
        ),
        RepositoryProvider<FilterRepository>(
          create: (BuildContext context) =>
              FilterRepository(FilterController(databasePath)),
        ),
      ],
      child: FutureBuilder<Filter>(
        future: _initialFilter(databasePath),
        builder: (BuildContext context, AsyncSnapshot<Filter> snapshot) {
          if (!snapshot.hasData) {
            // While data is loading:
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
            );
          } else {
            return AppCore(initialFilter: snapshot.data ?? const Filter());
          }
        },
      ),
    );
  }
}

class AppCore extends StatelessWidget {
  final Filter initialFilter;

  const AppCore({
    required this.initialFilter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DefaultFilterCubit>(
          create: (BuildContext context) => DefaultFilterCubit(
            filter: initialFilter,
            repository: context.read<SettingRepository>(),
          ),
        ),
        // Is required to retrieve general information from the
        // unfiltered todo list.
        BlocProvider<TodoListBloc>(
          create: (context) {
            return TodoListBloc(
              filter: initialFilter,
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
            )..add(const FilterListSubscriped());
          },
        ),
      ],
      child: Builder(
        builder: (BuildContext context) {
          return MaterialApp.router(
            title: 'ntodotxt',
            debugShowCheckedModeBanner: false,
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
