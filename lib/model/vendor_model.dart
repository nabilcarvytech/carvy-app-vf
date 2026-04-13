import 'package:carvy/api/config.dart';

/// Représentation légère d’un vendeur / agence côté API (profil, dashboard, etc.).
/// L’image peut être une URL absolue, un chemin relatif (`/uploads/...`) ou un objet `{ "url": "..." }`.
class Vendor {
  Vendor({
    this.id,
    this.name,
    this.image,
  });

  final String? id;
  final String? name;
  /// Valeur brute telle que renvoyée par l’API (peut être relative).
  final String? image;

  factory Vendor.fromJson(dynamic json) {
    if (json == null || json is! Map) {
      return Vendor();
    }
    final m = Map<String, dynamic>.from(json as Map);
    return Vendor(
      id: m['id']?.toString() ?? m['_id']?.toString(),
      name: m['name']?.toString() ??
          m['company_name']?.toString() ??
          m['title']?.toString(),
      image: Vendor.rawImageFromJson(m),
    );
  }

  /// URL affichable (domaine + chemin si besoin).
  String? get resolvedImageUrl => Vendor.resolveImageUrl(image);

  /// Extrait une chaîne image depuis la racine d’un objet JSON utilisateur / vendeur.
  static String? rawImageFromJson(Map<String, dynamic> json) {
    final candidates = <dynamic>[
      json['agency_logo'],
      json['agencyLogo'],
      json['logo'],
      json['logo_url'],
      json['avatar'],
      json['image'],
      json['profile_image'],
      json['profileImage'],
    ];
    for (final c in candidates) {
      final s = _asImageString(c);
      if (s != null && s.isNotEmpty) return s;
    }
    return null;
  }

  static String? _asImageString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.trim().isEmpty ? null : v.trim();
    if (v is Map) {
      final u = v['url'] ?? v['path'] ?? v['src'];
      if (u != null) return u.toString().trim();
    }
    return null;
  }

  /// Concatène avec le domaine si l’URL est relative (même logique que le profil utilisateur).
  static String? resolveImageUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final t = raw.trim();
    if (t.startsWith('data:image')) return t;
    final resolved = Config.getFullImageUrl(t);
    return resolved.trim().isEmpty ? null : resolved;
  }
}
