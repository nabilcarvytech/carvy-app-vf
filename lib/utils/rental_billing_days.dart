import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:carvy/utils/common_widget.dart' show getColorBasedOnActiveModuleid;
import 'package:carvy/utils/theme_style.dart';

/// Résultat du calcul « jours facturés » (cycle 24h + dépassement horaire).
class RentalBillingSummary {
  /// Écart calendaire entre la date de début et la date de fin (minuit à minuit).
  final int calendarSpanDays;

  /// `true` si l'heure de fin est strictement après l'heure de début le même jour
  /// → une journée supplémentaire est facturée (même règle que la réservation).
  final bool hasExtraDay;

  /// Jours de location affichés / facturés (minimum 1).
  final int totalDays;

  const RentalBillingSummary({
    required this.calendarSpanDays,
    required this.hasExtraDay,
    required this.totalDays,
  });
}

/// Logique unique pour réservation et recherche véhicule.
class RentalBillingDays {
  RentalBillingDays._();

  /// Créneaux 30 min pour la recherche véhicule : 09:00 à 20:30 (affichage 24h).
  static List<String> vehicleSearchTimeSlotsHHmm() {
    final out = <String>[];
    for (var h = 9; h <= 20; h++) {
      final hh = h.toString().padLeft(2, '0');
      out.add('$hh:00');
      out.add('$hh:30');
    }
    return out;
  }

  static int _minutesSinceMidnight(TimeOfDay t) => t.hour * 60 + t.minute;

  /// `true` si l'heure de retour est strictement après l'heure de prise en charge (même jour).
  static bool isReturnTimeAfterPickup(TimeOfDay start, TimeOfDay end) {
    return _minutesSinceMidnight(end) > _minutesSinceMidnight(start);
  }

  /// Retour strictement avant départ (comparaison sur [HH:mm]).
  static bool isEndTimeStrictlyBeforeStartTime(
    String startHHmm,
    String endHHmm,
  ) {
    final s = _minutesSinceMidnight(parseTimeOfDayFromSlot(startHHmm));
    final e = _minutesSinceMidnight(parseTimeOfDayFromSlot(endHHmm));
    return e < s;
  }

  /// Parse créneaux `HH:mm` ou format `h:mm a` (ex. issue du time picker).
  static TimeOfDay parseTimeOfDayFromSlot(String value) {
    if (value.isEmpty) return const TimeOfDay(hour: 9, minute: 0);
    try {
      if (RegExp(r'^[0-9]{1,2}:[0-9]{2}$').hasMatch(value.trim())) {
        final p = value.trim().split(':');
        return TimeOfDay(
          hour: int.parse(p[0]),
          minute: int.parse(p[1]),
        );
      }
      final dt = DateFormat('h:mm a').parse(value.trim());
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  /// [startDate] / [endDate] : seuls année-mois-jour sont pris en compte.
  static RentalBillingSummary compute({
    required DateTime startDate,
    required DateTime endDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) {
    final d0 = DateTime(startDate.year, startDate.month, startDate.day);
    final d1 = DateTime(endDate.year, endDate.month, endDate.day);
    final diffDays = d1.difference(d0).inDays;
    final hasExtraDay = isReturnTimeAfterPickup(startTime, endTime);
    var total = hasExtraDay ? diffDays + 1 : diffDays;
    if (total < 1) total = 1;
    return RentalBillingSummary(
      calendarSpanDays: diffDays,
      hasExtraDay: hasExtraDay,
      totalDays: total,
    );
  }
}

/// Bandeau bleu « Total : X jours… » (réservation / recherche).
class VehicleRentalBillableDaysInfoBanner extends StatelessWidget {
  final int totalBillableDays;
  final bool hasOvertimeDay;

  const VehicleRentalBillableDaysInfoBanner({
    super.key,
    required this.totalBillableDays,
    required this.hasOvertimeDay,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Container(
        key: ValueKey('rental-total-$totalBillableDays-$hasOvertimeDay'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue, width: 0.8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                Icons.info_outline,
                size: 18,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total : $totalBillableDays jours de location',
                    style: regular2(context).copyWith(
                      color: Colors.blue.shade900,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hasOvertimeDay) ...[
                    const SizedBox(height: 4),
                    Text(
                      '(Incluant 1 jour pour dépassement horaire)',
                      style: regular2(context).copyWith(
                        color: Colors.blue.shade900,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Date de fin + badge « +1j facturé » si dépassement horaire.
class VehicleReturnDateWithBillingBadgeRow extends StatelessWidget {
  final String dateText;
  final TextAlign textAlign;
  final bool isExtraDay;
  final bool emphasizeOvertime;
  final FontWeight idleFontWeight;
  final double? fontSize;

  const VehicleReturnDateWithBillingBadgeRow({
    super.key,
    required this.dateText,
    required this.textAlign,
    required this.isExtraDay,
    this.emphasizeOvertime = false,
    this.idleFontWeight = FontWeight.normal,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final carvyBlue = getColorBasedOnActiveModuleid();
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: textAlign == TextAlign.end
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            style: regular2(context).copyWith(
              color: emphasizeOvertime ? carvyBlue : Colors.grey,
              fontSize: fontSize,
              fontWeight: emphasizeOvertime ? FontWeight.bold : idleFontWeight,
            ),
            child: Text(
              dateText,
              textAlign: textAlign,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (isExtraDay) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: carvyBlue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '+1j facturé',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
