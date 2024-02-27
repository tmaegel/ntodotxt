import 'package:flutter/material.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show ListFilter;
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart'
    show FilterCubit;

class FilterStateFilterDialog extends StatelessWidget {
  final FilterCubit cubit;
  final Map<String, ListFilter> items;

  const FilterStateFilterDialog({
    required this.cubit,
    super.key,
  }) : items = const {
          'All': ListFilter.all,
          'Completed only': ListFilter.completedOnly,
          'Incompleted only': ListFilter.incompletedOnly,
        };

  static Future<void> dialog({
    required BuildContext context,
    required FilterCubit cubit,
  }) async {
    return await showDialog<Future<void>>(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) => FilterStateFilterDialog(cubit: cubit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
      ),
    );
  }
}

class DefaultFilterStateFilterDialog extends StatelessWidget {
  final FilterCubit cubit;
  final Map<String, ListFilter> items;

  const DefaultFilterStateFilterDialog({
    required this.cubit,
    super.key,
  }) : items = const {
          'All': ListFilter.all,
          'Completed only': ListFilter.completedOnly,
          'Incompleted only': ListFilter.incompletedOnly,
        };

  static Future<void> dialog({
    required BuildContext context,
    required FilterCubit cubit,
  }) async {
    return await showDialog<Future<void>>(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) =>
          DefaultFilterStateFilterDialog(cubit: cubit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                cubit.updateDefaultFilter(value);
              }
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
