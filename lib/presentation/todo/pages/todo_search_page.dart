import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
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
      keyboardType: TextInputType.text,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\n')),
      ],
      style: Theme.of(context).textTheme.titleLarge,
      textCapitalization: TextCapitalization.sentences,
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
    // @todo: Activate WideLayout later!
    // final bool narrowView =
    //     MediaQuery.of(context).size.width < maxScreenWidthCompact;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // titleSpacing: narrowView ? 0.0 : null,
          titleSpacing: 0.0,
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
        title: _buildTitle(context),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: _buildSubtitle(),
        ),
        onTap: () => _onTapAction(context),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final List<String> items = todo.description.split(' ')
      ..removeWhere(
        (String item) => item.startsWith('due:'),
      );

    return RichText(
      text: TextSpan(
        style: todo.completion
            ? Theme.of(context).textTheme.titleMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  decorationThickness: 4.0,
                )
            : Theme.of(context).textTheme.titleMedium,
        text: '',
        children: <TextSpan>[
          for (int i = 0; i < items.length; i++)
            TextSpan(
                text: i == items.length - 1 ? items[i] : '${items[i]} ',
                style: Todo.matchProject(items[i]) ||
                        Todo.matchContext(items[i]) ||
                        Todo.matchKeyValue(items[i])
                    ? const TextStyle(fontWeight: FontWeight.bold)
                    : null),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget? _buildSubtitle() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 2.0, // gap between adjacent chips
      runSpacing: 2.0, // gap between lines
      children: <Widget>[
        if (todo.priority != Priority.none)
          BasicIconChip(
            mono: true,
            iconData: Icons.flag_outlined,
            label: todo.priority.name,
          ),
        if (todo.creationDate != null)
          BasicIconChip(
            mono: true,
            iconData: Icons.edit_calendar,
            label: Todo.differenceToToday(todo.creationDate!),
          ),
        if (todo.completionDate != null && todo.completion)
          BasicIconChip(
            mono: true,
            iconData: Icons.event_available,
            label: Todo.differenceToToday(todo.completionDate!),
          ),
        if (todo.dueDate != null)
          BasicIconChip(
            mono: true,
            iconData: Icons.event,
            label: Todo.date2Str(todo.dueDate!)!,
          )
      ],
    );
  }

  void _onTapAction(BuildContext context) {
    context.pushNamed('todo-edit', extra: todo);
  }
}
