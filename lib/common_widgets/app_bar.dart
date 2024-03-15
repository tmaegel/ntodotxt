import 'package:flutter/material.dart';
import 'package:ntodotxt/constants/app.dart';
import 'package:ntodotxt/misc.dart' show CustomScrollBehavior;
import 'package:ntodotxt/presentation/drawer/widgets/drawer.dart';
import 'package:ntodotxt/presentation/filter/widgets/filter_chip.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? toolbar;
  final Widget? bottom;

  const MainAppBar({
    required this.title,
    this.toolbar,
    this.bottom,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool narrowView =
        MediaQuery.of(context).size.width < maxScreenWidthCompact;
    return AppBar(
      titleSpacing: narrowView ? 0.0 : null,
      title: Text(title),
      leading: narrowView && Scaffold.of(context).hasDrawer
          ? Builder(
              builder: (BuildContext context) {
                return IconButton(
                  tooltip: 'Open drawer',
                  icon: const Icon(Icons.menu),
                  onPressed: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) =>
                          const BottomSheetNavigationDrawer(),
                    );
                  },
                );
              },
            )
          : null,
      actions: toolbar == null
          ? null
          : <Widget>[
              toolbar!,
              const SizedBox(width: 8),
            ],
      bottom: bottom == null
          ? null
          : PreferredSize(
              preferredSize: Size.zero,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: bottom!,
              ),
            ),
    );
  }

  // Scaffold requires as appbar a class that implements PreferredSizeWidget.
  @override
  Size get preferredSize =>
      Size.fromHeight(bottom == null ? kToolbarHeight : 110);
}

class AppBarFilterList extends StatelessWidget {
  const AppBarFilterList({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController controller = ScrollController();
    return ScrollConfiguration(
      behavior: CustomScrollBehavior(),
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilterOrderChip(),
              SizedBox(width: 4),
              FilterFilterChip(),
              SizedBox(width: 4),
              FilterGroupChip(),
              SizedBox(width: 4),
              FilterPrioritiesChip(),
              SizedBox(width: 4),
              FilterProjectsChip(),
              SizedBox(width: 4),
              FilterContextsChip(),
            ],
          ),
        ),
      ),
    );
  }
}
