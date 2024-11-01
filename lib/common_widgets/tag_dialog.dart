import 'package:flutter/material.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/misc.dart';

class Tag {
  String name;
  bool selected;

  Tag({
    required this.name,
    required this.selected,
  });

  @override
  String toString() => '$name ($selected)';
}

class TagDialog extends StatefulWidget {
  final String title;
  final String tagName;
  final Set<String> availableTags;
  final bool addTags;

  const TagDialog({
    required this.title,
    required this.tagName,
    this.availableTags = const {},
    this.addTags = true,
    super.key,
  });

  RegExp get regex => RegExp(r'^\S+$');

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

  void onUpdate() {}

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: widget.addTags == true ? 0.9 : 0.5,
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
                ),
              ),
              const Divider(),
              if (widget.addTags)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                    title: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _controller,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Enter <${widget.tagName}> tag ...',
                          contentPadding: EdgeInsets.zero,
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Missing tag name';
                          }
                          if (!widget.regex.hasMatch(value.trim())) {
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
                          String text = _controller.text.trim();
                          if (text.startsWith('+') || text.startsWith('@')) {
                            text = text.substring(1);
                          }
                          setState(() {
                            tags.add(Tag(
                              name: text.toLowerCase(),
                              selected: true,
                            ));
                          });
                          _controller.text = '';
                          onUpdate();
                        }
                      },
                    ),
                  ),
                ),
              if (widget.addTags) const Divider(),
              tags.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                        title: Text('No ${widget.tagName} tags available.'),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8.0),
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
                                  onUpdate();
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
