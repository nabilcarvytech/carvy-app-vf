/// Validation and normalization for MongoDB ObjectId strings (24 hex chars).
class MongoIdHelper {
  MongoIdHelper._();

  static final RegExp _objectIdPattern = RegExp(r'^[0-9a-fA-F]{24}$');

  /// True when [value] is null, blank, or a JSON/JS placeholder (`"null"`, `"undefined"`, …).
  static bool isNullPlaceholder(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return true;
    switch (v.toLowerCase()) {
      case 'null':
      case 'undefined':
      case 'none':
      case 'nu':
      case 'n/a':
      case '-':
        return true;
      default:
        return false;
    }
  }

  /// Converts placeholders and whitespace-only strings to Dart `null`.
  static String? sanitizeNullableString(String? value) {
    if (isNullPlaceholder(value)) return null;
    return value!.trim();
  }

  static bool isValid(String? value) {
    final v = sanitizeNullableString(value);
    if (v == null) return false;
    return v.length == 24 && _objectIdPattern.hasMatch(v);
  }

  /// Returns a trimmed ObjectId or `null` if invalid (rejects index ids like "1", "2").
  static String? normalize(String? value) {
    final v = sanitizeNullableString(value);
    if (v == null) return null;
    return isValid(v) ? v : null;
  }

  /// Reads `_id` first, then `id`, keeping only valid ObjectIds.
  static String? parseLocationId(Map<String, dynamic> json) {
    for (final key in ['_id', 'id']) {
      final normalized = normalize(json[key]?.toString());
      if (normalized != null) return normalized;
    }
    return null;
  }

  static String? extractRefId(dynamic ref) {
    if (ref == null) return null;
    if (ref is String) return normalize(ref);
    if (ref is Map) {
      return normalize(ref['_id']?.toString() ?? ref['id']?.toString());
    }
    return null;
  }

  static bool idsEqual(String? a, String? b) {
    if (a == null || b == null) return false;
    return a.trim().toLowerCase() == b.trim().toLowerCase();
  }
}
