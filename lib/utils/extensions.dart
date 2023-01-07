import 'package:flutter/material.dart';

extension StringExtension on String? {
  bool isNullOrEmpty() => this == null || this!.isEmpty;
}

extension DateTimeExt on DateTime {
  DateTime copy() => DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch);

  DateTime applyDate(DateTime date) {
    return DateTime(date.year, date.month, date.day, hour, minute, second, millisecond, microsecond);
  }

  DateTime applyTime(TimeOfDay time) {
    return DateTime(year, month, day, time.hour, time.minute, second, millisecond, microsecond);
  }
}
