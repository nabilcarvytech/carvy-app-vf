import 'dart:convert';

import 'package:get/get.dart';
import 'package:carvy/controller/vehicle_controller.dart';
import 'package:carvy/helper/mongo_id_helper.dart';

/// Résout les règles véhicule (objets peuplés ou ObjectIds) en libellés affichables.
class VehicleRulesHelper {
  VehicleRulesHelper._();

  static const List<String> _labelKeys = [
    'title',
    'name',
    'rule_name',
    'ruleName',
    'description',
    'text',
    'rule',
    'label',
    'content',
  ];

  static List<dynamic> normalizeRawList(dynamic source) {
    if (source == null) return [];
    if (source is String) {
      final t = source.trim();
      if (t.isEmpty) return [];
      if (t.startsWith('[') || t.startsWith('{')) {
        try {
          return normalizeRawList(json.decode(t));
        } catch (_) {}
      }
      return [t];
    }
    if (source is Map) return [Map<String, dynamic>.from(source)];
    if (source is List) {
      final out = <dynamic>[];
      for (final e in source) {
        out.addAll(normalizeRawList(e));
      }
      return out;
    }
    return [source];
  }

  static List<dynamic> mergeRaw(Iterable<dynamic> sources) {
    final out = <dynamic>[];
    final seen = <String>{};
    for (final src in sources) {
      for (final item in normalizeRawList(src)) {
        final key = _dedupeKey(item);
        if (key.isEmpty || seen.add(key)) out.add(item);
      }
    }
    return out;
  }

  static String _dedupeKey(dynamic item) {
    if (item is Map) {
      final id = idOf(item) ?? '';
      final label = labelFromObject(item) ?? '';
      return '${id.toLowerCase()}|$label';
    }
    return item.toString().trim().toLowerCase();
  }

  static String? labelFromObject(Map item) {
    for (final k in _labelKeys) {
      final v = item[k]?.toString().trim() ?? '';
      if (v.isNotEmpty && !isObjectIdLike(v)) return v;
    }
    return null;
  }

  static bool isObjectIdLike(String? raw) {
    return MongoIdHelper.extractAny(raw) != null;
  }

  static String? idOf(dynamic item) {
    if (item == null) return null;
    if (item is Map) {
      return MongoIdHelper.extractAny(item['_id']) ??
          MongoIdHelper.extractAny(item['id']) ??
          MongoIdHelper.extractAny(item);
    }
    return MongoIdHelper.extractAny(item);
  }

  static String? labelFromCatalog(String id, List<dynamic> catalog) {
    final needle = id.trim().toLowerCase();
    if (needle.isEmpty) return null;
    for (final rule in catalog) {
      if (rule is! Map) continue;
      final catalogId = idOf(rule)?.toLowerCase() ?? '';
      if (catalogId == needle) return labelFromObject(rule);
    }
    return null;
  }

  static List<dynamic> catalog() {
    try {
      return Get.find<VehicleController>().rulesList.toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<void> ensureCatalogLoaded() async {
    try {
      final vc = Get.find<VehicleController>();
      if (vc.rulesList.isEmpty) {
        await vc.fetchRules();
      }
    } catch (_) {}
  }

  static String? resolveOne(dynamic item, {List<dynamic>? catalog}) {
    final cat = catalog ?? VehicleRulesHelper.catalog();
    if (item == null) return null;
    if (item is Map) {
      final fromObj = labelFromObject(item);
      if (fromObj != null) return fromObj;
      final id = idOf(item);
      if (id == null || id.isEmpty) return null;
      return labelFromCatalog(id, cat);
    }
    final s = item.toString().trim();
    if (s.isEmpty) return null;
    if (s.startsWith('{') || s.startsWith('Instance of')) {
      final nestedId = MongoIdHelper.extractAny(s);
      if (nestedId != null) return labelFromCatalog(nestedId, cat);
      return null;
    }
    final asId = MongoIdHelper.extractAny(s);
    if (asId != null) return labelFromCatalog(asId, cat);
    if (isObjectIdLike(s)) return null;
    return s;
  }

  static List<String> resolveDisplayLabels(
    dynamic list, {
    List<dynamic>? catalog,
  }) {
    final cat = catalog ?? VehicleRulesHelper.catalog();
    final out = <String>[];
    final seen = <String>{};
    for (final item in normalizeRawList(list)) {
      final label = resolveOne(item, catalog: cat);
      if (label == null || label.trim().isEmpty) continue;
      if (isObjectIdLike(label)) continue;
      if (seen.add(label)) out.add(label);
    }
    return out;
  }
}
