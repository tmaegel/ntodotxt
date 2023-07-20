import 'package:flutter/material.dart';
import 'package:todotxt/constants/screen.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Icon icon;
  final Function action;
  final Widget? toolbar;

  const MainAppBar({
    required this.title,
    required this.icon,
    required this.action,
    this.toolbar,
    super.key,
  });

  // Scaffold requires as appbar a class that implements PreferredSizeWidget.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return AppBar(
      automaticallyImplyLeading: screenWidth < maxScreenWidthCompact,
      leading:
          screenWidth < maxScreenWidthCompact ? _backIconButton(context) : null,
      title: Text(title),
      actions: (screenWidth < maxScreenWidthCompact && toolbar != null)
          ? <Widget>[_buildDeleteAction(context)]
          : null,
    );
  }

  Widget _backIconButton(BuildContext context) {
    return IconButton(
      icon: icon,
      onPressed: () => action(),
    );
  }

  Widget _buildDeleteAction(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: toolbar,
    );
  }
}
