import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/config/router/router.dart';
import 'package:ntodotxt/config/theme/theme.dart';
import 'package:ntodotxt/constants/placeholder.dart';
import 'package:ntodotxt/constants/screen.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/presentation/login/states/login_cubit.dart';
import 'package:ntodotxt/presentation/settings/states/settings_cubit.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  Bloc.observer = SimpleBlocObserver();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final LocalStorageTodoListApi todoListApi =
      LocalStorageTodoListApi.fromList(rawTodoList);
  final TodoListRepository todoListRepository =
      TodoListRepository(todoListApi: todoListApi);
  runApp(
    App(
      todoListRepository: todoListRepository,
      prefs: prefs,
    ),
  );
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('${bloc.runtimeType} $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint('${bloc.runtimeType} $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}

class App extends StatelessWidget {
  final TodoListRepository todoListRepository;
  final SharedPreferences prefs;

  const App({
    required this.todoListRepository,
    required this.prefs,
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
          BlocProvider<LoginCubit>(
            create: (BuildContext context) => LoginCubit(),
          ),
          BlocProvider<SettingsCubit>(
            create: (BuildContext context) => SettingsCubit(prefs: prefs),
          ),
          BlocProvider<TodoListBloc>(
            create: (context) => TodoListBloc(
              todoListRepository: todoListRepository,
            )..add(
                const TodoListSubscriptionRequested(),
              ),
          ),
        ],
        child: Builder(
          builder: (context) {
            return MaterialApp.router(
              title: 'Flutter layout demo',
              debugShowCheckedModeBanner: false, // Remove the debug banner
              theme: lightTheme.copyWith(
                listTileTheme: lightTheme.listTileTheme.copyWith(
                  selectedColor: lightTheme.textTheme.bodySmall?.color,
                  selectedTileColor: lightTheme.hoverColor,
                ),
              ),
              darkTheme: darkTheme.copyWith(
                listTileTheme: darkTheme.listTileTheme.copyWith(
                  selectedColor: darkTheme.textTheme.bodySmall?.color,
                  selectedTileColor: darkTheme.hoverColor,
                ),
              ),
              // If you do not have a themeMode switch, uncomment this line
              // to let the device system mode control the theme mode:
              themeMode: ThemeMode.system,
              routerConfig: _isNarrowLayout(context)
                  ? AppRouter(context.read<LoginCubit>()).routerNarrowLayout
                  : AppRouter(context.read<LoginCubit>()).routerWideLayout,
            );
          },
        ),
      ),
    );
  }

  bool _isNarrowLayout(BuildContext context) =>
      MediaQuery.of(context).size.width < maxScreenWidthCompact;
}
