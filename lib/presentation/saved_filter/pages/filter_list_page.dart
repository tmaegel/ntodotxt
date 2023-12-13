import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/actions.dart' show primaryAddFilterAction;
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/common_widgets/navigation_drawer.dart';
import 'package:ntodotxt/constants/app.dart';
import 'package:ntodotxt/domain/saved_filter/filter_model.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority;
import 'package:ntodotxt/presentation/saved_filter/states/filter_list_bloc.dart';
import 'package:ntodotxt/presentation/saved_filter/states/filter_list_state.dart';

class FilterListPage extends StatelessWidget {
  const FilterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isNarrowLayout =
        MediaQuery.of(context).size.width < maxScreenWidthCompact;

    return BlocBuilder<FilterListBloc, FilterListState>(
      builder: (BuildContext context, FilterListState state) {
        return Scaffold(
          appBar: const MainAppBar(title: 'Filters'),
          drawer: isNarrowLayout
              ? const ResponsiveNavigationDrawer(selectedIndex: 1)
              : null,
          body: ListView.builder(
            itemCount: state.filterList.length,
            itemBuilder: (BuildContext context, int index) {
              Filter filter = state.filterList[index];
              return ListTile(
                title: Text(filter.name),
                subtitle: _buildSubtitle(filter),
                onTap: () => context.pushNamed('filter-edit', extra: filter),
              );
            },
          ),
          floatingActionButton: PrimaryFloatingActionButton(
            icon: Icon(primaryAddFilterAction.icon),
            tooltip: primaryAddFilterAction.label,
            action: () => primaryAddFilterAction.action(context),
          ),
        );
      },
    );
  }

  Widget _buildSubtitle(Filter filter) {
    const String delimiter = '/';
    List<Widget> children = [];
    for (String attr in [
      filter.order.name,
      delimiter,
      filter.groupBy.name,
      delimiter,
      [for (Priority p in filter.priorities) p.name].join(' '),
      delimiter,
      [for (String p in filter.projects) '+$p'].join(' '),
      delimiter,
      [for (String c in filter.contexts) '@$c'].join(' '),
    ]) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Text(attr),
        ),
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 0.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: children,
    );
  }
}
