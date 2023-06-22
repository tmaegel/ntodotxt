import 'package:flutter/material.dart';
import 'package:todotxt/presentation/layout/adaptive_layout.dart';
// import 'package:flutter/rendering.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // debugPaintSizeEnabled = true;
    return MaterialApp(
      title: 'Flutter layout demo',
      debugShowCheckedModeBanner: false, // Remove the debug banner
      // Light theme settings.
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      // Dark theme settings.
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      /*
       * ThemeMode.system to follow system theme,
       * ThemeMode.light for light theme,
       * ThemeMode.dark for dark theme
       */
      themeMode: ThemeMode.light,
      home: const AdaptiveLayoutBuild(),
    );
  }

  // Widget _buildList() {
  //   return ListView(
  //     children: [
  //       _todoTile(title: "Call mom", priority: "A"),
  //       const Divider(),
  //       _todoTile(title: "Go to school", subtitle: "@school", priority: "A"),
  //       const Divider(),
  //       _todoTile(title: "Do nothing", subtitle: "@home +test", priority: "B"),
  //     ],
  //   );
  // }
  //
  // ListTile _todoTile(
  //     {required String title, required String priority, String? subtitle}) {
  //   return ListTile(
  //     title: Text(title,
  //         style: const TextStyle(
  //           fontWeight: FontWeight.w500,
  //           fontSize: 20,
  //         )),
  //     subtitle: subtitle != null ? Text(subtitle) : null,
  //     leading: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: <Widget>[
  //         Text(priority,
  //             style: const TextStyle(
  //               fontWeight: FontWeight.w500,
  //               fontSize: 20,
  //             )),
  //       ],
  //     ),
  //   );
  // }
}
