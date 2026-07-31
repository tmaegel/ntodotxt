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
    final DateTime firstDate = now.subtract(
      Duration(days: startDateDaysOffset ?? defaultDaysOffset),
    );
    final DateTime lastDate = now.add(
      Duration(days: endDateDaysOffset ?? defaultDaysOffset),
    );

    DateTime initial = now;
    if (initialDate != null) {
      // initialDate has to be between firstDate and lastDate, otherwise initial will be set to now
      if ((initialDate.compareTo(firstDate) == 0 ||
              initialDate.compareTo(firstDate) == 1) &&
          (initialDate.compareTo(lastDate) == 0 ||
              initialDate.compareTo(lastDate) == -1)) {
        initial = initialDate;
      }
    }

    return await showDatePicker(
      useRootNavigator: false,
      context: context,
      firstDate: firstDate,
      initialDate: initial,
      lastDate: lastDate,
      locale: const Locale('en', 'GB'),
    );
  }
}
