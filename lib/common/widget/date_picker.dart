import 'package:flutter/material.dart';

class TodoDatePicker {
  static final int defaultDaysOffset = 3650;

  const TodoDatePicker();

  static Future<DateTime?> pickDate({
    required BuildContext context,
    required DateTime? initialDate,
    int? startDateDaysOffset,
    int? endDateDaysOffset,
  }) async {
    final DateTime initial = initialDate ?? DateTime.now();

    return await showDatePicker(
      useRootNavigator: false,
      context: context,
      firstDate: initial.subtract(
        Duration(days: startDateDaysOffset ?? defaultDaysOffset),
      ),
      initialDate: initial,
      lastDate: initial.add(
        Duration(days: endDateDaysOffset ?? defaultDaysOffset),
      ),
      locale: const Locale('en', 'GB'),
    );
  }
}
