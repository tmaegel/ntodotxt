import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todotxt/login/login.dart';
import 'package:todotxt/presentation/router/router.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: Builder(builder: (context) {
        return MaterialApp.router(
          title: 'Flutter layout demo',
          debugShowCheckedModeBanner: false, // Remove the debug banner
          // Light theme settings.
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            brightness: Brightness.light,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.light,
          routerConfig: AppRouter(context.read<LoginCubit>()).router,
        );
      }),
    );
  }
}
