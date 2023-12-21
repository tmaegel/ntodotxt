import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/constants/app.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority;
import 'package:ntodotxt/presentation/drawer/widgets/drawer.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_bloc.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_state.dart';

class FilterListPage extends StatelessWidget {
  const FilterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isNarrowLayout =
        MediaQuery.of(context).size.width < maxScreenWidthCompact;
    if (isNarrowLayout) {
      return const FilterListViewNarrow();
    } else {
      return const FilterListViewWide();
    }
  }
}

class FilterListViewNarrow extends StatelessWidget {
  const FilterListViewNarrow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterListBloc, FilterListState>(
      builder: (BuildContext context, FilterListState state) {
        return Scaffold(
          appBar: const MainAppBar(title: 'Filters'),
          body: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            itemCount: state.filterList.length,
            itemBuilder: (BuildContext context, int index) {
              return FilterListTile(filter: state.filterList[index]);
            },
          ),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Drawer',
                  icon: const Icon(Icons.menu),
                  onPressed: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true, // set this to true
                      builder: (BuildContext context) =>
                          const BottomSheetNavigationDrawer(),
                    );
                  },
                ),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.endContained,
          floatingActionButton: PrimaryFloatingActionButton(
            tooltip: 'Add filter',
            icon: const Icon(Icons.add),
            action: () => context.push(
              context.namedLocation('filter-create'),
            ),
          ),
        );
      },
    );
  }
}

class FilterListViewWide extends StatelessWidget {
  const FilterListViewWide({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterListBloc, FilterListState>(
      builder: (BuildContext context, FilterListState state) {
        return Scaffold(
          appBar: const MainAppBar(title: 'Filters'),
          body: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            itemCount: state.filterList.length,
            itemBuilder: (BuildContext context, int index) {
              return FilterListTile(filter: state.filterList[index]);
            },
          ),
          floatingActionButton: PrimaryFloatingActionButton(
            tooltip: 'Add filter',
            icon: const Icon(Icons.add),
            action: () => context.push(
              context.namedLocation('filter-create'),
            ),
          ),
        );
      },
    );
  }
}

class FilterListTile extends StatelessWidget {
  final Filter filter;

  const FilterListTile({
    required this.filter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey<int>(filter.id!),
      title: Text(filter.name),
      subtitle: _buildSubtitle(),
      onTap: () => context.pushNamed('todo-list', extra: filter),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        tooltip: 'Edit',
        onPressed: () => context.pushNamed('filter-edit', extra: filter),
      ),
    );
  }

  Widget _buildSubtitle() {
    int i = 0;
    List<Widget> children = [];
    final List<String> items = [
      filter.order.name,
      filter.filter.name,
      filter.group.name,
      [for (Priority p in filter.priorities) p.name].join(' '),
      [for (String p in filter.projects) '+$p'].join(' '),
      [for (String c in filter.contexts) '@$c'].join(' '),
    ]..removeWhere((value) => value.isEmpty);
    for (String attr in items) {
      i++;
      children.add(
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Text(attr),
        ),
      );
      if (attr.isNotEmpty && i < items.length) {
        children.add(
          const Padding(
            padding: EdgeInsets.only(right: 4.0),
            child: Text('/'),
          ),
        );
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 0.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: children,
    );
  }
}
