import 'package:flutter/material.dart';
import 'package:ntodotxt/common/misc.dart';
import 'package:ntodotxt/common/widget/context_selector.dart';
import 'package:ntodotxt/common/widget/filter_selector.dart';
import 'package:ntodotxt/common/widget/group_by_selector.dart';
import 'package:ntodotxt/common/widget/order_selector.dart';
import 'package:ntodotxt/common/widget/priority_selector.dart';
import 'package:ntodotxt/common/widget/project_selector.dart';

class FilterDialog extends StatelessWidget {
  final Set<String> projects;
  final Set<String> contexts;

  const FilterDialog({
    this.projects = const {},
    this.contexts = const {},
    super.key,
  });

  static Future<void> dialog({
    required BuildContext context,
    required Set<String> projects,
    required Set<String> contexts,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => FilterDialog(
        projects: projects,
        contexts: contexts,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: ListView(
            controller: scrollController,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 4.0),
                title: Text(
                  'Filter',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Text(
                  'Order',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: OrderSelector(),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Text(
                  'Filter',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: FilterSelector(),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Text(
                  'Group by',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: GroupBySelector(),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Text(
                  'Priorities',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: PrioritySelector(),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Text(
                  'Projects',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: ProjectSelector(items: projects),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Text(
                  'Contexts',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: ContextSelector(items: contexts),
              ),
            ],
          ),
        );
      },
    );
  }
}
