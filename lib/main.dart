import 'dart:io';

import 'package:flutter/material.dart';

import 'package:todotxt/storage.dart';

void main() {
  runApp(const TodoTxtApp());
}

class TodoTxtApp extends StatelessWidget {
  const TodoTxtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'todotxt',
      debugShowCheckedModeBanner: false, // Remove the debug banner
      home: HomeRoute(storage: NotesStorage()),
      // Light theme settings.
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      // Dark theme settings.
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      /*
       * ThemeMode.system to follow system theme,
       * ThemeMode.light for light theme,
       * ThemeMode.dark for dark theme
       */
      themeMode: ThemeMode.dark,
    );
  }
}

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key, required this.storage});

  final NotesStorage storage;

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    widget.storage.readCounter().then((value) {
      setState(() {
        _counter = value;
      });
    });
  }

  Future<File> _incrementCounter() {
    setState(() {
      _counter++;
    });

    // Write the variable as a string to the file.
    return widget.storage.writeCounter(_counter);
  }

  void _show(BuildContext ctx) {
    showModalBottomSheet(
      elevation: 10,
      backgroundColor: Colors.lightBlue.shade900,
      context: ctx,
      builder: (ctx) => Container(
        width: 300,
        height: 250,
        // color: Colors.white54,
        alignment: Alignment.center,
        child: const Text('Add tasks here...'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: const Drawer(),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            primary: true,
            pinned: true,
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'All tasks',
                style: TextStyle(color: Colors.grey[300]),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return ListTile(
                  title: Text("List tile $index"),
                );
              },
              childCount: 30,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      onPressed: () => _show(context),
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NewTashRoute extends StatelessWidget {
  const NewTashRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New note'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close), // Replace with our own icon data.
        ),
      ),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.all(10.0),
          children: <Widget>[
            const TextField(
              decoration: InputDecoration(
                labelText: '',
                hintText: "hint text",
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'UserName'),
            ),
          ],
        ),
      ),
    );
  }
}

Route _createRoute(Widget route) {
  return PageRouteBuilder(
    // Callback to build the content of the route.
    pageBuilder: (context, animation, secondaryAnimation) => route,
    // Callback to build the route’s transition.
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}
