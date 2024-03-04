import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/constants/app.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart';
import 'package:ntodotxt/domain/filter/filter_repository.dart';
import 'package:ntodotxt/domain/settings/setting_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_state.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';

class TodoSearchPage extends StatelessWidget {
  final Filter? filter;

  const TodoSearchPage({
    this.filter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => FilterCubit(
        settingRepository: context.read<SettingRepository>(),
        filterRepository: context.read<FilterRepository>(),
        filter: filter,
      )..load(),
      child: Builder(
        builder: (BuildContext context) => const TodoSearchView(),
      ),
    );
  }
}

class TodoSearchView extends StatefulWidget {
  const TodoSearchView({super.key});

  @override
  State<TodoSearchView> createState() => _TodoSearchViewState();
}

class _TodoSearchViewState extends State<TodoSearchView> {
  String query = '';
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.text = query;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Iterable<Todo> _getResults(Iterable<Todo> todoList) {
    return todoList.where(
      (Todo t) => t.toString().toLowerCase().contains(query.toLowerCase()),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enableInteractiveSelection: true,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
      keyboardType: TextInputType.text,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\n')),
      ],
      style: Theme.of(context).textTheme.titleLarge,
      decoration: const InputDecoration(hintText: 'Search ...'),
      onChanged: (String value) => setState(() => query = _controller.text),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: query.isEmpty
            ? null
            : () {
                setState(() => query = '');
                _controller.text = query;
              },
      ),
      const SizedBox(width: 8),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool narrowView =
        MediaQuery.of(context).size.width < maxScreenWidthCompact;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: narrowView ? 0.0 : null,
          title: _buildSearchField(context),
          actions: _buildActions(context),
        ),
        body: BlocBuilder<TodoListBloc, TodoListState>(
          builder: (BuildContext context, TodoListState todoListState) {
            return BlocBuilder<FilterCubit, FilterState>(
              builder: (BuildContext context, FilterState filterState) {
                final List<Todo> matchQuery = _getResults(
                  todoListState.filteredTodoList(filterState.filter),
                ).toList();
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: matchQuery.length,
                  itemBuilder: (BuildContext context, int index) {
                    Todo todo = matchQuery[index];
                    return TodoSearchTile(todo: todo);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class TodoSearchTile extends StatelessWidget {
  final Todo todo;

  TodoSearchTile({
    required this.todo,
    Key? key,
  }) : super(key: PageStorageKey<String>(todo.id));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        key: key,
        title: Text(
          todo.description,
          style: TextStyle(
            decoration: todo.completion ? TextDecoration.lineThrough : null,
            decorationThickness: 2.0,
          ),
        ),
        subtitle: _buildSubtitle(),
        onTap: () => _onTapAction(context),
      ),
    );
  }

  Widget? _buildSubtitle() {
    final List<String> items = [
      if (todo.priority != Priority.none) todo.priority.name,
      for (String p in todo.fmtProjects) p,
      for (String c in todo.fmtContexts) c,
      for (String kv in todo.fmtKeyValues) kv,
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

  void _onTapAction(BuildContext context) {
    context.pushNamed('todo-edit', extra: todo);
  }
}
