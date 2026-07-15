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
    final DateTime now = DateTime.now();

    DateTime initial = now;
    if (initialDate != null) {
      // initialDate is in the past
      if (now.compareTo(initialDate) == 1) {
        initial = initialDate;
      }
    }

    return await showDatePicker(
      useRootNavigator: false,
      context: context,
      firstDate: now.subtract(
        Duration(days: startDateDaysOffset ?? defaultDaysOffset),
      ),
      initialDate: initial,
      lastDate: now.add(
        Duration(days: endDateDaysOffset ?? defaultDaysOffset),
      ),
      locale: const Locale('en', 'GB'),
    );
  }
}
