import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/domain/saved_filter/filter_model.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority;
import 'package:ntodotxt/misc.dart' show SnackBarHandler;
import 'package:ntodotxt/presentation/saved_filter/states/filter_cubit.dart';
import 'package:ntodotxt/presentation/saved_filter/states/filter_list_bloc.dart';
import 'package:ntodotxt/presentation/saved_filter/states/filter_list_event.dart';
import 'package:ntodotxt/presentation/saved_filter/states/filter_state.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart'
    show
        TodoFilter,
        TodoGroupBy,
        TodoListFilter,
        TodoListGroupBy,
        TodoListOrder,
        TodoOrder;

class FilterCreateEditPage extends StatelessWidget {
  final Filter? filter;
  final Set<String> projects;
  final Set<String> contexts;

  const FilterCreateEditPage({
    this.filter,
    this.projects = const {},
    this.contexts = const {},
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => FilterCubit(
        filter: filter ?? const Filter(),
      ),
      child: BlocConsumer<FilterCubit, FilterState>(
        listener: (BuildContext context, FilterState state) {
          if (state is FilterError) {
            SnackBarHandler.error(context, state.message);
          }
        },
        builder: (BuildContext context, FilterState state) {
          return Scaffold(
            appBar: MainAppBar(
              title: filter == null ? 'Add' : 'Edit',
              toolbar: Row(
                children: <Widget>[
                  IconButton(
                    tooltip: 'Save',
                    icon: const Icon(Icons.save),
                    onPressed: () {
                      if (filter == null) {
                        context.read<FilterListBloc>().add(
                              FilterCreated(filter: state.filter),
                            );
                      } else {
                        context.read<FilterListBloc>().add(
                              FilterUpdated(filter: state.filter),
                            );
                      }
                      context.goNamed('filter-list');
                    },
                  ),
                ],
              ),
            ),
            body: ListView(
              children: [
                const FilterNameTextField(),
                const Divider(),
                FilterListSection(
                  title: 'Order',
                  children: [
                    ListTile(
                      title: GenericChipGroup(
                        children: [
                          for (var t in TodoOrder.types)
                            GenericChoiceChip(
                              label: Text(t.name),
                              selected: state.filter.order == t,
                              onSelected: (bool selected) {
                                if (selected) {
                                  context.read<FilterCubit>().updateOrder(t);
                                } else {
                                  // If unselected fallback to the default.
                                  context
                                      .read<FilterCubit>()
                                      .updateOrder(TodoListOrder.ascending);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                FilterListSection(
                  title: 'Filter',
                  children: [
                    ListTile(
                      title: GenericChipGroup(
                        children: [
                          for (var t in TodoFilter.types)
                            GenericChoiceChip(
                              label: Text(t.name),
                              selected: state.filter.filter == t,
                              onSelected: (bool selected) {
                                if (selected) {
                                  context.read<FilterCubit>().updateFilter(t);
                                } else {
                                  // If unselected fallback to the default.
                                  context
                                      .read<FilterCubit>()
                                      .updateFilter(TodoListFilter.all);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                FilterListSection(
                  title: 'Priorities',
                  children: [
                    ListTile(
                      title: GenericChipGroup(
                        children: [
                          for (var p in Priority.values)
                            GenericChoiceChip(
                              label: Text(p.name),
                              selected: state.filter.priorities.contains(p),
                              onSelected: (bool selected) {
                                if (selected) {
                                  context.read<FilterCubit>().addPriority(p);
                                } else {
                                  context.read<FilterCubit>().removePriority(p);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                FilterListSection(
                  title: 'Projects',
                  children: [
                    ListTile(
                      title: GenericChipGroup(
                        children: [
                          for (var p
                              in {...projects, ...state.filter.projects}
                                  .toList()
                                ..sort())
                            GenericChoiceChip(
                              label: Text(p),
                              selected: state.filter.projects.contains(p),
                              onSelected: (bool selected) {
                                if (selected) {
                                  context.read<FilterCubit>().addProject(p);
                                } else {
                                  context.read<FilterCubit>().removeProject(p);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                FilterListSection(
                  title: 'Contexts',
                  children: [
                    ListTile(
                      title: GenericChipGroup(
                        children: [
                          for (var c
                              in {...contexts, ...state.filter.contexts}
                                  .toList()
                                ..sort())
                            GenericChoiceChip(
                              label: Text(c),
                              selected: state.filter.contexts.contains(c),
                              onSelected: (bool selected) {
                                if (selected) {
                                  context.read<FilterCubit>().addContext(c);
                                } else {
                                  context.read<FilterCubit>().removeContext(c);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                FilterListSection(
                  title: 'Group by',
                  children: [
                    ListTile(
                      title: GenericChipGroup(
                        children: [
                          for (var g in TodoGroupBy.types)
                            GenericChoiceChip(
                              label: Text(g.name),
                              selected: state.filter.groupBy == g,
                              onSelected: (bool selected) {
                                if (selected) {
                                  context.read<FilterCubit>().updateGroupBy(g);
                                } else {
                                  // If unselected fallback to the default.
                                  context
                                      .read<FilterCubit>()
                                      .updateGroupBy(TodoListGroupBy.none);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FilterListSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  FilterListSection({
    required this.title,
    required this.children,
    Key? key,
  }) : super(key: PageStorageKey<String>(title));

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: key,
      initiallyExpanded: true,
      title: Text(title),
      children: children,
    );
  }
}

class FilterNameTextField extends StatefulWidget {
  const FilterNameTextField({super.key});

  @override
  State<FilterNameTextField> createState() => _FilterNameTextFieldState();
}

class _FilterNameTextFieldState extends State<FilterNameTextField> {
  late GlobalKey<FormFieldState> _textFormKey;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _textFormKey = GlobalKey<FormFieldState>();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (BuildContext context, FilterState state) {
        _controller.text = state.filter.name;
        return TextFormField(
          key: _textFormKey,
          controller: _controller,
          minLines: 1,
          maxLines: 1,
          enableInteractiveSelection: true,
          enableSuggestions: false,
          enableIMEPersonalizedLearning: false,
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\n')),
          ],
          style: Theme.of(context).textTheme.titleMedium,
          decoration: const InputDecoration(
            hintText: 'Filter name',
            isDense: true,
            filled: false,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          onChanged: (String value) =>
              context.read<FilterCubit>().updateName(value),
        );
      },
    );
  }
}
