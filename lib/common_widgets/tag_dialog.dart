import 'package:flutter/material.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/misc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_cubit.dart';

class Tag {
  String name;
  bool selected;

  Tag({
    required this.name,
    required this.selected,
  });

  @override
  String toString() => name;
}

class TagDialog extends StatefulWidget {
  final TodoCubit cubit;
  final String title;
  final String tagName;
  final Set<String> availableTags;

  const TagDialog({
    required this.cubit,
    required this.title,
    required this.tagName,
    this.availableTags = const {},
    super.key,
  });

  RegExp get regex => RegExp(r'^\S+$');

  void onSubmit(BuildContext context, Set<String> values) {}

  @override
  State<TagDialog> createState() => TagDialogState();
}

class TagDialogState<T extends TagDialog> extends State<T> {
  // Holds the selected tags before adding to the regular state.
  Set<Tag> tags = {};

  late GlobalKey<FormState> _formKey;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Set<Tag> get sortedTags {
    List<Tag> t = tags.toList()
      ..sort(
        (Tag a, Tag b) => a.toString().compareTo(b.toString()),
      );
    return t.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: ListView(
            controller: scrollController,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                  title: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  trailing: TextButton(
                    child: const Text('Apply'),
                    onPressed: () {
                      widget.onSubmit(context, {
                        for (Tag t in tags)
                          if (t.selected) t.name
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              const Divider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                  title: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _controller,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Enter <${widget.tagName}> tag ...',
                        isDense: true,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Missing tag name';
                        }
                        if (!widget.regex.hasMatch(value)) {
                          return 'Invalid tag format';
                        }
                        return null;
                      },
                    ),
                  ),
                  trailing: TextButton(
                    child: const Text('Add'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          tags.add(Tag(
                            name: _controller.text,
                            selected: true,
                          ));
                        });
                        _controller.text = '';
                      }
                    },
                  ),
                ),
              ),
              if (tags.isNotEmpty) const Divider(),
              if (tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                    title: GenericChipGroup(
                      children: [
                        for (var t in sortedTags)
                          GenericChoiceChip(
                            label: Text(t.name),
                            selected: t.selected,
                            onSelected: (bool selected) {
                              setState(() {
                                t.selected = selected;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
