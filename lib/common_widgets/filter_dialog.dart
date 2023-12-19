import 'package:flutter/material.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show ListFilter;
import 'package:ntodotxt/presentation/default_filter/states/default_filter_cubit.dart'
    show DefaultFilterCubit;
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart'
    show FilterCubit;

class FilterTodoListBottomSheet extends StatelessWidget {
  final FilterCubit cubit;
  final Map<String, ListFilter> items;

  const FilterTodoListBottomSheet({
    required this.cubit,
    super.key,
  }) : items = const {
          'All': ListFilter.all,
          'Completed only': ListFilter.completedOnly,
          'Incompleted only': ListFilter.incompletedOnly,
        };

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      key: const Key('FilterTodoListBottomSheet'),
      enableDrag: false,
      showDragHandle: false,
      onClosing: () {},
      builder: (BuildContext context) {
        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16.0),
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            String key = items.keys.elementAt(index);
            ListFilter value = items[key]!;
            return RadioListTile<ListFilter>(
              key: Key('${value.name}BottomSheetRadioButton'),
              contentPadding: EdgeInsets.zero,
              title: Text(key),
              value: value,
              groupValue: cubit.state.filter.filter,
              onChanged: (ListFilter? value) {
                if (value != null) {
                  cubit.updateFilter(value);
                }
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}

class FilterSettingsDialog extends StatelessWidget {
  final DefaultFilterCubit cubit;
  final Map<String, ListFilter> items;

  const FilterSettingsDialog({
    required this.cubit,
    super.key,
  }) : items = const {
          'All': ListFilter.all,
          'Completed only': ListFilter.completedOnly,
          'Incompleted only': ListFilter.incompletedOnly,
        };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key('FilterSettingsDialog'),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          String key = items.keys.elementAt(index);
          ListFilter value = items[key]!;
          return RadioListTile<ListFilter>(
            key: Key('${value.name}DialogRadioButton'),
            contentPadding: EdgeInsets.zero,
            value: value,
            title: Text(key),
            groupValue: cubit.state.filter.filter,
            onChanged: (ListFilter? value) {
              if (value != null) {
                cubit.updateListFilter(value);
              }
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
