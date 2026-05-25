import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Politique d'annulation standard (3 paliers) + affichage RTL / pourcentages.
class CancellationPolicyHelper {
  CancellationPolicyHelper._();

  static const List<String> standardRuleKeys = [
    'rule_more_than_48h',
    'rule_between_24_and_48h',
    'rule_less_than_24h',
  ];

  /// Supprime les indices parasites « 1 », « 2 », « 3 » en fin de phrase API.
  static String stripTrailingIndex(String text) {
    return text.trim().replaceFirst(RegExp(r'\s*[123]\s*$'), '').trim();
  }

  /// Isole les pourcentages en LTR pour un rendu arabe correct (ex. 80%).
  static String isolatePercentsForBidi(String text) {
    return text.replaceAllMapped(
      RegExp(r'\d+\s*%'),
      (m) => '\u2066${m.group(0)}\u2069',
    );
  }

  static String localizedRuleAt(int index) {
    if (index < 0 || index >= standardRuleKeys.length) return '';
    return isolatePercentsForBidi(standardRuleKeys[index].tr);
  }

  static List<String> localizedStandardRules() {
    return List.generate(standardRuleKeys.length, localizedRuleAt);
  }

  static bool isCancellationPolicyContext(String? title, dynamic list) {
    final t = (title ?? '').trim().toLowerCase();
    if (t.contains('annulation') ||
        t.contains('cancellation') ||
        t.contains('cancel') ||
        t.contains('إلغاء')) {
      return true;
    }
    if (list is List && list.isNotEmpty) {
      for (final item in list) {
        final s = stripTrailingIndex(item.toString()).toLowerCase();
        if (s.contains('déduction') ||
            s.contains('deduction') ||
            s.contains('خصم') ||
            (s.contains('%') && (s.contains('48') || s.contains('24')))) {
          return true;
        }
      }
    }
    return false;
  }

  static List<String> normalizeList(dynamic list) {
    if (list == null) return [];
    if (list is List) {
      return list.map((e) => stripTrailingIndex(e.toString())).toList();
    }
    if (list is String && list.trim().isNotEmpty) {
      return [stripTrailingIndex(list)];
    }
    return [];
  }

  /// Règles à afficher : 3 paliers traduits pour la politique d'annulation.
  static List<String> resolveDisplayRules(
    dynamic list, {
    required bool isCancellationPolicy,
  }) {
    if (!isCancellationPolicy) {
      return normalizeList(list);
    }
    final raw = normalizeList(list);
    if (raw.isEmpty) return [];
    return localizedStandardRules();
  }

  static bool textHasArabicScript(String s) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(s);

  static Widget buildRuleListTile(String text) {
    final isRtl =
        Get.locale?.languageCode == 'ar' || textHasArabicScript(text);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        minLeadingWidth: 28,
        visualDensity: VisualDensity.compact,
        leading: const Icon(
          Icons.done_all,
          color: Colors.blue,
          size: 20,
        ),
        title: Text(
          text,
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.start,
          textDirection: isRtl ? TextDirection.rtl : null,
        ),
      ),
    );
  }
}
