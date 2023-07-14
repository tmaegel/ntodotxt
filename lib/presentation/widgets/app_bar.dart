import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todotxt/constants/screen.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showToolBar;

  const MainAppBar({
    required this.title,
    required this.showToolBar,
    super.key,
  });

  // Scaffold requires as appbar a class that implements PreferredSizeWidget.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < maxScreenWidthCompact) {
      return _buildCompactAppBar();
    } else {
      return _buildExtendedAppBar();
    }
  }

  Widget _buildCompactAppBar() {
    return AppBar(
      title: Text(title),
      actions: showToolBar ? const <Widget>[AppToolBar()] : null,
    );
  }

  Widget _buildExtendedAppBar() {
    return AppBar(
      leadingWidth: 80, // Same as the width of NavigatorRail.
      title: Text(title),
      actions: showToolBar ? const <Widget>[AppToolBar()] : null,
    );
  }
}

class AppToolBar extends StatelessWidget {
  const AppToolBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      IconButton(
        tooltip: 'Search',
        icon: const Icon(Icons.search),
        onPressed: () {
          context.push(context.namedLocation('todo-search'));
        },
      ),
      IconButton(
        tooltip: 'Settings',
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          context.push(context.namedLocation('settings'));
        },
      ),
    ]);
  }
}
