import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/constants/app.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority;
import 'package:ntodotxt/misc.dart' show PopScopeDrawer;
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
        return PopScopeDrawer(
          child: Scaffold(
            appBar: const MainAppBar(title: 'Filters'),
            body: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              itemCount: state.filterList.length,
              itemBuilder: (BuildContext context, int index) {
                return FilterListTile(filter: state.filterList[index]);
              },
            ),
            drawer: Container(),
            bottomNavigationBar: const BottomAppBar(
              child: Row(
                children: [],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endContained,
            floatingActionButton: FloatingActionButton(
              tooltip: 'Add filter',
              child: const Icon(Icons.add),
              onPressed: () => context.push(
                context.namedLocation('filter-create'),
              ),
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
        return PopScopeDrawer(
          child: Scaffold(
            appBar: const MainAppBar(title: 'Filters'),
            body: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              itemCount: state.filterList.length,
              itemBuilder: (BuildContext context, int index) {
                return FilterListTile(filter: state.filterList[index]);
              },
            ),
            floatingActionButton: FloatingActionButton(
              tooltip: 'Add filter',
              child: const Icon(Icons.add),
              onPressed: () => context.push(
                context.namedLocation('filter-create'),
              ),
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
      onTap: () => context.pushNamed('filter-edit', extra: filter),
    );
  }

  Widget? _buildSubtitle() {
    final List<String> items = [
      filter.order.name,
      filter.filter.name,
      filter.group.name,
      for (Priority p in filter.priorities) p.name,
      for (String p in filter.projects) '+$p',
      for (String c in filter.contexts) '@$c',
    ]..removeWhere((value) => value.isEmpty);

    if (items.isEmpty) {
      return null;
    }

    List<String> shortenedItems;
    if (items.length > 5) {
      shortenedItems = items.sublist(0, 5);
      shortenedItems.add('...');
    } else {
      shortenedItems = [...items];
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        for (String attr in shortenedItems) BasicChip(label: attr, mono: true),
      ],
    );
  }
}
