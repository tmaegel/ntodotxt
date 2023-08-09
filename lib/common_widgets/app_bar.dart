import 'package:flutter/material.dart';
import 'package:ntodotxt/constants/screen.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconButton? leadingAction;
  final Widget? toolbar;

  const MainAppBar({
    required this.title,
    this.leadingAction,
    this.toolbar,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return AppBar(
      automaticallyImplyLeading: leadingAction != null,
      leading: leadingAction,
      title: Text(title),
      actions: (screenWidth < maxScreenWidthCompact && toolbar != null)
          ? <Widget>[_buildToolBar(context)]
          : null,
    );
  }

  Widget _buildToolBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: toolbar,
    );
  }

  // Scaffold requires as appbar a class that implements PreferredSizeWidget.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
