import 'package:flutter/material.dart';
import 'package:ntodotxt/constants/app.dart' show maxScreenWidthCompact;
import 'package:ntodotxt/misc.dart' show PlatformInfo;

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? toolbar;

  const MainAppBar({
    required this.title,
    this.toolbar,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return AppBar(
      automaticallyImplyLeading: screenWidth < maxScreenWidthCompact,
      titleSpacing: screenWidth < maxScreenWidthCompact ? 0.0 : null,
      title: Text(title),
      actions: toolbar != null
          ? <Widget>[
              PlatformInfo.isDesktopOS
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: toolbar!,
                    )
                  : toolbar!,
            ]
          : null,
    );
  }

  // Scaffold requires as appbar a class that implements PreferredSizeWidget.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class PrimaryBottomAppBar extends StatelessWidget {
  final List<Widget> children;

  const PrimaryBottomAppBar({
    required this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: children,
      ),
    );
  }
}
