import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

/// Fenêtre glissante de sélection : du 1er jour du mois courant
/// au dernier jour du 3e mois (ex. janvier → fin mars).
class RollingCalendarBounds {
  RollingCalendarBounds._();

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Borne de début : 1er jour du mois courant.
  static DateTime firstDate([DateTime? reference]) {
    final ref = _dateOnly(reference ?? DateTime.now());
    return DateTime(ref.year, ref.month, 1);
  }

  /// Borne de fin : dernier jour du 3e mois à partir du mois courant.
  static DateTime lastDate([DateTime? reference]) {
    final ref = _dateOnly(reference ?? DateTime.now());
    return DateTime(ref.year, ref.month + 3, 0);
  }

  static bool isWithinWindow(DateTime date, [DateTime? reference]) {
    final d = _dateOnly(date);
    return !d.isBefore(firstDate(reference)) && !d.isAfter(lastDate(reference));
  }

  /// Date sélectionnable (dans la fenêtre ; passé exclu si [disallowPastDays]).
  static bool isSelectable(
    DateTime date, {
    bool disallowPastDays = true,
    DateTime? reference,
  }) {
    if (!isWithinWindow(date, reference)) return false;
    if (!disallowPastDays) return true;
    final today = _dateOnly(reference ?? DateTime.now());
    return !_dateOnly(date).isBefore(today);
  }

  /// minDate pour réservation : aujourd'hui ou 1er du mois (le plus tardif).
  static DateTime bookingMinDate([DateTime? reference]) {
    final first = firstDate(reference);
    final today = _dateOnly(reference ?? DateTime.now());
    return today.isAfter(first) ? today : first;
  }

  static DateTime clamp(DateTime date, [DateTime? reference]) {
    final d = _dateOnly(date);
    final min = firstDate(reference);
    final max = lastDate(reference);
    if (d.isBefore(min)) return min;
    if (d.isAfter(max)) return max;
    return d;
  }

  /// Empêche la navigation au-delà de la fenêtre (mois grisés côté Syncfusion).
  static void clampPickerView(
    DateRangePickerViewChangedArgs args,
    DateRangePickerController controller, [
    DateTime? reference,
  ]) {
    final visibleStart = args.visibleDateRange.startDate;
    if (visibleStart == null) return;
    final first = firstDate(reference);
    final last = lastDate(reference);
    if (visibleStart.isAfter(last)) {
      controller.displayDate = DateTime(last.year, last.month, 1);
    } else if (visibleStart.isBefore(first)) {
      controller.displayDate = first;
    }
  }

  static TextStyle disabledDateTextStyle({double fontSize = 16}) {
    return TextStyle(
      color: Colors.grey.withOpacity(0.4),
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
    );
  }
}
