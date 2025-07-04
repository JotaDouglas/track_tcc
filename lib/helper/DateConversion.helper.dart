import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateConversion {
  static convertDateFromString(String strDate) {
    final todayDate = DateTime.tryParse(strDate);

    if (todayDate == null) return '---';
    // DateTime todayDate = DateTime.parse(strDate);
    // print(todayDate);
    var dateFormatted = formatDate(
        todayDate, [dd, '/', mm, '/', yyyy, ' ', HH, ':', nn, ':', ss]);
    // print(dateFormatted);
    return dateFormatted;
  }

  static convertDateTimeFromString(String strDate) {
    if (strDate.contains('/')) strDate = strDate.replaceAll('/', '-');

    DateTime? todayDate = DateTime.tryParse(strDate);
    // print(todayDate);
    var dateFormatted =
        formatDate(todayDate ?? DateTime.now(), [dd, '/', mm, '/', yyyy, ' ', HH, ':', nn]);
    // print(dateFormatted);
    return dateFormatted;
  }

  static onlyDateFromString(String strDate) {
    if (strDate.contains('/')) strDate = strDate.replaceAll('/', '-');

    DateTime todayDate = DateTime.parse(strDate);
    var dateFormatted = formatDate(todayDate, [dd, '/', mm, '/', yyyy]);
    return dateFormatted;
  }

  static String toDate(DateTime now, {format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(now);
  }

  static String toHourAndMinute(DateTime now) {
    return DateFormat('HH:mm').format(now);
  }

  static DateTime toDateTime(String date) {
    if (date.contains('-')) date = date.replaceAll('-', '/');

    return DateTime(
      int.parse(date.split("/")[0]),
      int.parse(date.split("/")[1]),
      int.parse(date.split("/")[2]),
    );
  }

  static TimeOfDay toTimeOfDay(String time) {
    if (!isTimeValid(time)) return TimeOfDay.now(); //verify is valid time

    return TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1]));
  }

  static bool isTimeValid(String timeString) {
    try {
      final List<String> parts = timeString.split(':');
      if (parts.length != 2) {
        return false; // Time format should be "hh:mm"
      }

      final int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return false; // Invalid hour or minute
      }

      // final TimeOfDay time = TimeOfDay(hour: hour, minute: minute); //Variável não utilizada
      return true; // Valid time
    } catch (e) {
      return false; // Parsing error
    }
  }
}
