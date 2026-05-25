import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Traductions et affichage LTR des libellés filtres renvoyés par l'API.
class FilterLabelHelper {
  FilterLabelHelper._();

  static String translateFuelType(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final normalized = raw.trim().toLowerCase();
    const Map<String, String> keyByApi = {
      'gasoline': 'gasoline',
      'petrol': 'gasoline',
      'essence': 'gasoline',
      'diesel': 'diesel',
      'electric': 'electric',
      'electrique': 'electric',
      'électrique': 'electric',
      'hybrid': 'filter_fuel_hybrid',
      'hybride': 'filter_fuel_hybrid',
    };
    final key = keyByApi[normalized];
    if (key != null) {
      final translated = key.tr;
      if (translated != key) return translated;
    }
    return raw;
  }

  static String translateTransmission(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final normalized = raw.trim().toLowerCase();
    const Map<String, String> keyByApi = {
      'automatic': 'filter_transmission_automatic',
      'automatique': 'filter_transmission_automatic',
      'manual': 'filter_transmission_manual',
      'manuelle': 'filter_transmission_manual',
    };
    final key = keyByApi[normalized];
    if (key != null) {
      final translated = key.tr;
      if (translated != key) return translated;
    }
    return raw;
  }

  /// Kilométrage / plages numériques : conserve le texte API, traduit les mots-clés connus.
  static String translateInsuranceCoverage(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final normalized = raw.trim().toUpperCase();
    if (normalized == 'FULL') return 'full_insurance'.tr;
    if (normalized == 'BASIC') return 'basic_insurance'.tr;
    return raw;
  }

  static String translateOdometerLabel(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final text = raw.trim();
    final lower = text.toLowerCase();
    if (lower.contains('unlimited') || lower.contains('illimit')) {
      return 'filter_odometer_unlimited'.tr;
    }
    return text;
  }

  static bool _looksNumericRange(String text) {
    return RegExp(r'\d').hasMatch(text);
  }

  static Widget ltrText(
    String text, {
    required TextStyle style,
    TextAlign textAlign = TextAlign.center,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final useLtr = _looksNumericRange(text);
    final child = Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      textDirection: useLtr ? TextDirection.ltr : null,
    );
    if (!useLtr) return child;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    );
  }
}
