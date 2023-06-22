import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  // Scaffold requires as appbar a class that implements PreferredSizeWidget.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: const IconButton(onPressed: null, icon: Icon(Icons.menu)),
      leadingWidth: 80, // Same as the width of NavigatorRail.
      title: const Text('Example title'),
      actions: const <Widget>[
        IconButton(
          tooltip: 'Search',
          icon: Icon(Icons.search),
          onPressed: null,
        ),
        IconButton(
          tooltip: 'Favorite',
          icon: Icon(Icons.favorite_border),
          onPressed: null,
        ),
        IconButton(
          tooltip: 'More',
          icon: Icon(Icons.more_vert),
          onPressed: null,
        ),
      ],
    );
  }
}
