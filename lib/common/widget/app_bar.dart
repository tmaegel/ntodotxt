import 'package:flutter/material.dart';
import 'package:ntodotxt/drawer/widget/drawer.dart';

class MainSliverAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? toolbar;

  const MainSliverAppBar({
    required this.title,
    this.subtitle,
    this.toolbar,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // @todo: Activate WideLayout later!
    // final bool narrowView =
    //     MediaQuery.of(context).size.width < maxScreenWidthCompact;
    return SliverAppBar.large(
      centerTitle: true,
      title: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      flexibleSpace: subtitle != null
          ? FlexibleSpaceBar(
              background: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 72, 16, 16),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
      // leading: narrowView && Scaffold.of(context).hasDrawer
      leading: Scaffold.of(context).hasDrawer
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
    );
  }
}
