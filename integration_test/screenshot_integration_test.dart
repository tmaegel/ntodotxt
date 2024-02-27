import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/client/webdav_client.dart';
import 'package:ntodotxt/data/filter/filter_controller.dart'
    show FilterController;
import 'package:ntodotxt/data/settings/setting_controller.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart'
    show Filter, ListFilter, ListGroup, ListOrder;
import 'package:ntodotxt/domain/filter/filter_repository.dart';
import 'package:ntodotxt/domain/settings/setting_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority, Todo;
import 'package:ntodotxt/main.dart';
import 'package:ntodotxt/presentation/drawer/states/drawer_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_bloc.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_event.dart';
import 'package:ntodotxt/presentation/login/states/login_cubit.dart';
import 'package:ntodotxt/presentation/login/states/login_state.dart'
    show LoginLoading, LoginOffline, LoginState, LoginWebDAV;
import 'package:ntodotxt/presentation/todo_file/todo_file_cubit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:integration_test/integration_test.dart';

// https://developer.android.com/studio/run/emulator-networking#networkaddresses
// Special alias to your host loopback interface (127.0.0.1 on your development machine)
const String host = '10.0.2.2';
const int port = 80;
const String baseUrl = '/remote.php/dav/files';
const String username = 'test';
const String password = 'test';

class FakeController extends Fake implements FilterController {
  List<Filter> items = [
    const Filter(
      id: 1,
      name: 'Agenda',
      order: ListOrder.ascending,
      filter: ListFilter.incompletedOnly,
      group: ListGroup.upcoming,
    ),
    const Filter(
      id: 2,
      name: 'Highly prioritized',
      order: ListOrder.ascending,
      filter: ListFilter.incompletedOnly,
      group: ListGroup.project,
      priorities: {Priority.A},
    ),
    const Filter(
      id: 3,
      name: 'Projectideas',
      order: ListOrder.ascending,
      filter: ListFilter.incompletedOnly,
      group: ListGroup.none,
      projects: {'projectideas'},
    ),
    const Filter(
      id: 4,
      name: 'Completed only',
      order: ListOrder.ascending,
      filter: ListFilter.completedOnly,
      group: ListGroup.none,
    ),
  ];

  @override
  Future<List<Filter>> list() async {
    return Future.value(items);
  }
}

class AppTester extends StatelessWidget {
  final ThemeMode? themeMode;
  final String appCacheDir;

  const AppTester({
    this.themeMode,
    required this.appCacheDir,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingRepository>(
          create: (BuildContext context) => SettingRepository(
            SettingController(inMemoryDatabasePath),
          ),
        ),
        RepositoryProvider<FilterRepository>(
          create: (BuildContext context) => FilterRepository(
            FakeController(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LoginCubit>(
            create: (BuildContext context) => LoginCubit(
              state: const LoginWebDAV(
                server: 'http://$host:$port',
                baseUrl: baseUrl,
                username: username,
                password: password,
              ),
            ),
          ),
          BlocProvider<TodoFileCubit>(
            create: (BuildContext context) => TodoFileCubit(
              repository: context.read<SettingRepository>(),
              defaultLocalPath: appCacheDir,
            )..load(),
          ),
          BlocProvider<DrawerCubit>(
            create: (BuildContext context) => DrawerCubit(),
          ),
          // Default filter
          BlocProvider<FilterCubit>(
            create: (BuildContext context) => FilterCubit(
              settingRepository: context.read<SettingRepository>(),
              filterRepository: context.read<FilterRepository>(),
            )..load(),
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
            return BlocBuilder<LoginCubit, LoginState>(
              builder: (BuildContext context, LoginState state) {
                if (state is LoginLoading) {
                  return const LoadingApp();
                }
                if (state is LoginOffline || state is LoginWebDAV) {
                  return const App();
                }

                return const LoginApp();
              },
            );
          },
        ),
      ),
    );
  }
}

void main() async {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final DateTime today = DateTime.now();
  final List<Todo> todoList = [
    Todo(
      creationDate: today.subtract(const Duration(days: 7)),
      priority: Priority.A,
      description:
          'Automate the generation of app screenshots +app +learnflutter @development @automation @productivity due:${Todo.date2Str(today.add(const Duration(days: 3)))!}',
    ),
    Todo(
      creationDate: today.subtract(const Duration(days: 14)),
      priority: Priority.B,
      description:
          'Puplish this app +app +learnflutter @development due:${Todo.date2Str(today.add(const Duration(days: 7)))!}',
    ),
    Todo(
      creationDate: today.subtract(const Duration(days: 2)),
      description:
          'Increase test coverage +app +learnflutter @development @testing @productivity',
    ),
    Todo(
      creationDate: today.subtract(const Duration(days: 2)),
      completion: true,
      completionDate: today.subtract(const Duration(days: 1)),
      description:
          'Write some tests +app +learnflutter @development @testing @productivity',
    ),
    Todo(
      creationDate: today.subtract(const Duration(days: 21)),
      priority: Priority.C,
      description:
          'Setup a good project management tool @development @productivity',
    )
  ];

  setUp(() async {
    // Setup todos.
    WebDAVClient client = WebDAVClient(
        host: host,
        port: port,
        baseUrl: baseUrl,
        username: username,
        password: password);
    try {
      await client.upload(
          content: todoList.join(Platform.lineTerminator),
          filename: 'todo.txt');
    } catch (e) {
      fail('An exception was thrown: $e');
    }
  });

  group('dark mode', () {
    group('take screenshots', () {
      testWidgets('of todo list (default)', (tester) async {
        await tester.pumpWidget(
          AppTester(
            themeMode: ThemeMode.dark,
            appCacheDir: (await getApplicationCacheDirectory()).path,
          ),
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 5000));

        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('phone/1');
      });
      testWidgets('of todo list (with open drawer)', (tester) async {
        await tester.pumpWidget(
          AppTester(
            themeMode: ThemeMode.dark,
            appCacheDir: (await getApplicationCacheDirectory()).path,
          ),
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 5000));

        await tester.tap(find.byTooltip('Open drawer'));
        await tester.pumpAndSettle();

        await tester.drag(
            find.byType(DraggableScrollableSheet), const Offset(0, -500));
        await tester.pumpAndSettle();

        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('phone/2');
      });
      testWidgets('of todo edit page', (tester) async {
        await tester.pumpWidget(
          AppTester(
            themeMode: ThemeMode.dark,
            appCacheDir: (await getApplicationCacheDirectory()).path,
          ),
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 5000));

        await tester.tap(find.text('Puplish this app'));
        await tester.pumpAndSettle();

        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('phone/3');
      });
      testWidgets('of filter list (default)', (tester) async {
        await tester.pumpWidget(
          AppTester(
            themeMode: ThemeMode.dark,
            appCacheDir: (await getApplicationCacheDirectory()).path,
          ),
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 5000));

        await tester.tap(find.byTooltip('Open drawer'));
        await tester.pumpAndSettle();

        await tester.drag(
            find.byType(DraggableScrollableSheet), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Filters'));
        await tester.pumpAndSettle();

        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('phone/4');
      });
      testWidgets('of filter edit page', (tester) async {
        await tester.pumpWidget(
          AppTester(
            themeMode: ThemeMode.dark,
            appCacheDir: (await getApplicationCacheDirectory()).path,
          ),
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 5000));

        await tester.tap(find.byTooltip('Open drawer'));
        await tester.pumpAndSettle();

        await tester.drag(
            find.byType(DraggableScrollableSheet), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Filters'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Projectideas'));
        await tester.pumpAndSettle();

        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('phone/5');
      });
    });
  });
}
