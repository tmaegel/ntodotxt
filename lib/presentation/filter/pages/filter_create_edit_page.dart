import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/confirm_dialog.dart';
import 'package:ntodotxt/constants/app.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart'
    show Filter, Filters, Groups, ListFilter, ListGroup, ListOrder, Order;
import 'package:ntodotxt/domain/filter/filter_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority;
import 'package:ntodotxt/misc.dart' show SnackBarHandler;
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_state.dart';

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

  bool get createMode => filter == null;

  @override
  Widget build(BuildContext context) {
    final bool narrowView =
        MediaQuery.of(context).size.width < maxScreenWidthCompact;

    return BlocProvider(
      create: (BuildContext context) => FilterCubit(
        repository: context.read<FilterRepository>(),
        filter: filter ?? const Filter(),
      ),
      child: BlocConsumer<FilterCubit, FilterState>(
        listener: (BuildContext context, FilterState state) {
          if (state is FilterError) {
            SnackBarHandler.error(context, state.message);
          }
        },
        builder: (BuildContext context, FilterState state) {
          final List<String> allProjects = [
            ...projects,
            ...state.filter.projects,
          ]
            ..sort()
            ..toSet();
          final List<String> allContexts = [
            ...contexts,
            ...state.filter.contexts,
          ]
            ..sort()
            ..toSet();

          return Scaffold(
            appBar: MainAppBar(
              title: createMode ? 'Create' : 'Edit',
              toolbar: narrowView
                  ? null
                  : Row(
                      children: <Widget>[
                        if (!createMode)
                          DeleteFilterButton(filter: state.filter),
                        SaveFilterButton(
                          filter: state.filter,
                          create: createMode,
                          narrowView: narrowView,
                        ),
                      ],
                    ),
            ),
            body: ListView(
              children: [
                const FilterNameTextField(),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListTile(
                    title: Text(
                      'Order',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListTile(
                    title: GenericChipGroup(
                      children: [
                        for (var t in Order.types)
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
                                    .updateOrder(ListOrder.ascending);
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListTile(
                    title: Text(
                      'Filter',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListTile(
                    title: GenericChipGroup(
                      children: [
                        for (var t in Filters.types)
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
                                    .updateFilter(ListFilter.all);
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListTile(
                    title: Text(
                      'Group by',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListTile(
                    title: GenericChipGroup(
                      children: [
                        for (var g in Groups.types)
                          GenericChoiceChip(
                            label: Text(g.name),
                            selected: state.filter.group == g,
                            onSelected: (bool selected) {
                              if (selected) {
                                context.read<FilterCubit>().updateGroup(g);
                              } else {
                                // If unselected fallback to the default.
                                context
                                    .read<FilterCubit>()
                                    .updateGroup(ListGroup.none);
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListTile(
                    title: Text(
                      'Priorities',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListTile(
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
                ),
                if (allProjects.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListTile(
                      title: Text(
                        'Projects',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                if (allProjects.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListTile(
                      title: GenericChipGroup(
                        children: [
                          for (var p in allProjects)
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
                  ),
                if (allContexts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListTile(
                      title: Text(
                        'Contexts',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                if (allContexts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListTile(
                      title: GenericChipGroup(
                        children: [
                          for (var c in allContexts)
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
                  ),
              ],
            ),
            bottomNavigationBar: !narrowView
                ? null
                : BottomAppBar(
                    child: Row(
                      children: createMode
                          ? []
                          : [
                              DeleteFilterButton(filter: state.filter),
                            ],
                    ),
                  ),
            floatingActionButtonLocation:
                !narrowView ? null : FloatingActionButtonLocation.endContained,
            floatingActionButton: !narrowView
                ? null
                : SaveFilterButton(
                    filter: state.filter,
                    create: createMode,
                    narrowView: narrowView,
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
            focusedErrorBorder: InputBorder.none,
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

class DeleteFilterButton extends StatelessWidget {
  final Filter filter;

  const DeleteFilterButton({
    required this.filter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Delete',
      icon: const Icon(Icons.delete),
      onPressed: () async {
        final bool confirm = await ConfirmationDialog.dialog(
          context: context,
          title: 'Delete filter',
          message: 'Do you want to delete the filter?',
          actionLabel: 'Delete',
        );
        if (context.mounted && confirm) {
          await context.read<FilterCubit>().delete(filter);
          if (context.mounted) {
            SnackBarHandler.info(context, 'Filter deleted');
            context.pop();
          }
        }
      },
    );
  }
}

class SaveFilterButton extends StatelessWidget {
  final Filter filter;
  final bool create;
  final bool narrowView;

  const SaveFilterButton({
    required this.filter,
    required this.create,
    required this.narrowView,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (narrowView) {
      return FloatingActionButton(
        tooltip: 'Save',
        child: const Icon(Icons.save),
        onPressed: () async {
          if (create) {
            await context.read<FilterCubit>().create(filter);
          } else {
            await context.read<FilterCubit>().update(filter);
          }
          if (context.mounted) {
            SnackBarHandler.info(context, 'Filter saved');
            context.pop();
          }
        },
      );
    } else {
      return IconButton(
        tooltip: 'Save',
        icon: const Icon(Icons.save),
        onPressed: () async {
          if (create) {
            await context.read<FilterCubit>().create(filter);
          } else {
            await context.read<FilterCubit>().update(filter);
          }
          if (context.mounted) {
            SnackBarHandler.info(context, 'Filter saved');
            context.pop();
          }
        },
      );
    }
  }
}
