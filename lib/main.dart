import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todotxt/constants/screen.dart';
import 'package:todotxt/presentation/login/states/login.dart';
import 'package:todotxt/presentation/router/router.dart';
import 'package:todotxt/presentation/todo/states/todo.dart';

void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(const App());
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
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>(
          create: (BuildContext context) => LoginCubit(),
        ),
        BlocProvider<TodoCubit>(
          create: (BuildContext context) => TodoCubit(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'Flutter layout demo',
            debugShowCheckedModeBanner: false, // Remove the debug banner
            // Light theme settings.
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
              brightness: Brightness.light,
              searchBarTheme: SearchBarThemeData(
                elevation: MaterialStateProperty.all(0.0),
              ),
              useMaterial3: true,
            ),
            themeMode: ThemeMode.light,
            routerConfig: _isNarrowLayout(context)
                ? AppRouter(context.read<LoginCubit>()).routerNarrowLayout
                : AppRouter(context.read<LoginCubit>()).routerWideLayout,
          );
        },
      ),
    );
  }

  bool _isNarrowLayout(BuildContext context) =>
      MediaQuery.of(context).size.width < maxScreenWidthCompact;
}
