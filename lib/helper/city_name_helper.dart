import 'package:get/get.dart';

/// Affiche un nom de ville selon la langue active (GetX).
/// Les 4 villes principales passent par des clés i18n ; les autres conservent
/// un repli sur le mapping FR/AR historique.
class CityNameHelper {
  CityNameHelper._();

  static const Map<String, String> _cityTranslationKeys = {
    'sale': 'city_sale',
    'salé': 'city_sale',
    'sala': 'city_sale',
    'سلا': 'city_sale',
    'rabat': 'city_rabat',
    'الرباط': 'city_rabat',
    'casablanca': 'city_casablanca',
    'الدار البيضاء': 'city_casablanca',
    'marrakech': 'city_marrakech',
    'مراكش': 'city_marrakech',
  };

  static const Map<String, String> _frToAr = {
    'Salé': 'سلا',
    'Sale': 'سلا',
    'Rabat': 'الرباط',
    'Casablanca': 'الدار البيضاء',
    'Marrakech': 'مراكش',
    'Fès': 'فاس',
    'Fes': 'فاس',
    'Tanger': 'طنجة',
    'Agadir': 'أكادير',
    'Meknès': 'مكناس',
    'Meknes': 'مكناس',
  };

  static final Map<String, String> _arToFr = {
    for (final entry in _frToAr.entries) entry.value: entry.key,
  };

  static final Map<String, String> _frLowerToCanonical = {
    for (final entry in _frToAr.entries)
      entry.key.toLowerCase(): entry.key,
  };

  static String get currentLanguageCode =>
      Get.locale?.languageCode ?? 'fr';

  static String _normalizeCityToken(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e');
  }

  /// Clé GetX (`city_sale`, …) ou `null` si ville non référencée.
  static String? translationKeyForCity(String? rawName) {
    final trimmed = (rawName ?? '').trim();
    if (trimmed.isEmpty) return null;
    return _cityTranslationKeys[trimmed] ??
        _cityTranslationKeys[_normalizeCityToken(trimmed)];
  }

  static bool _preferArabic([String? languageCode]) {
    final code = (languageCode ?? currentLanguageCode).toLowerCase();
    return code == 'ar';
  }

  static bool _containsArabicScript(String value) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
  }

  /// Nom affichable pour l'UI (accueil, recherche, livraison, etc.).
  static String displayName(
    String? rawName, {
    String? languageCode,
  }) {
    final trimmed = (rawName ?? '').trim();
    if (trimmed.isEmpty) return '-';

    final trKey = translationKeyForCity(trimmed);
    if (trKey != null) {
      return trKey.tr;
    }

    if (_preferArabic(languageCode)) {
      if (_containsArabicScript(trimmed)) return trimmed;
      final fromFr = _frToAr[trimmed] ??
          _frToAr[_frLowerToCanonical[trimmed.toLowerCase()] ?? ''];
      return fromFr ?? trimmed;
    }

    if (!_containsArabicScript(trimmed)) {
      return _frLowerToCanonical[trimmed.toLowerCase()] ?? trimmed;
    }

    return _arToFr[trimmed] ?? trimmed;
  }

  /// Extrait le meilleur libellé ville depuis un item `deliveryLocations`.
  static String deliveryLocationLabel(
    dynamic item, {
    String? languageCode,
  }) {
    if (item is! Map) return '-';

    final location = item['location'];
    if (location is Map) {
      final lang = languageCode ?? currentLanguageCode;
      final localized = _pickLocalizedField(location, lang);
      if (localized != null && localized.trim().isNotEmpty) {
        return displayName(localized, languageCode: lang);
      }
    }

    final locationName = item['locationName']?.toString();
    if (locationName != null && locationName.trim().isNotEmpty) {
      return displayName(locationName, languageCode: languageCode);
    }

    final name = item['name']?.toString();
    if (name != null && name.trim().isNotEmpty) {
      return displayName(name, languageCode: languageCode);
    }

    if (location is Map) {
      final cityName = location['cityName']?.toString() ??
          location['city_name']?.toString();
      if (cityName != null && cityName.trim().isNotEmpty) {
        return displayName(cityName, languageCode: languageCode);
      }
    }

    return '-';
  }

  static String? _pickLocalizedField(Map location, String languageCode) {
    if (_preferArabic(languageCode)) {
      return location['cityNameAr']?.toString() ??
          location['city_name_ar']?.toString() ??
          location['nameAr']?.toString() ??
          location['name_ar']?.toString() ??
          location['cityName']?.toString() ??
          location['city_name']?.toString() ??
          location['name']?.toString();
    }
    return location['cityNameFr']?.toString() ??
        location['city_name_fr']?.toString() ??
        location['nameFr']?.toString() ??
        location['name_fr']?.toString() ??
        location['cityName']?.toString() ??
        location['city_name']?.toString() ??
        location['name']?.toString();
  }

  /// Libellé devise : MAD → clé i18n (`currency_mad`, ex. « درهم » en arabe).
  static String localizedCurrencyLabel([String? currencyCode]) {
    final code = (currencyCode ?? '').trim().toUpperCase();
    if (code.isEmpty || code == 'MAD') {
      return 'currency_mad'.tr;
    }
    return currencyCode!.trim();
  }

  /// Traduit Maroc / Morocco dans une chaîne (ex. « rabat, Maroc »).
  static String localizeCountryInText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;
    return trimmed.replaceAll(
      RegExp(r'Maroc|Morocco', caseSensitive: false),
      'morocco'.tr,
    );
  }

  static String localizedCountryName(String? raw) {
    final trimmed = (raw ?? '').trim();
    if (trimmed.isEmpty) return '';
    if (RegExp(r'^(maroc|morocco)$', caseSensitive: false).hasMatch(trimmed)) {
      return 'morocco'.tr;
    }
    return trimmed;
  }

  /// Ville (+ pays optionnel dans la même chaîne) pour l'affichage UI.
  static String formatCityCountryLabel(String? raw, {String? languageCode}) {
    final trimmed = (raw ?? '').trim();
    if (trimmed.isEmpty) return '-';
    if (!trimmed.contains(',')) {
      return displayName(trimmed, languageCode: languageCode);
    }
    final parts = trimmed
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '-';
    final city = displayName(parts.first, languageCode: languageCode);
    final countries =
        parts.skip(1).map(localizedCountryName).where((e) => e.isNotEmpty);
    if (countries.isEmpty) return city;
    return '$city, ${countries.join(', ')}';
  }

  /// Libellé « ville, pays » à partir de champs séparés.
  static String formatLocationLabel({
    String? city,
    String? country,
    String? languageCode,
  }) {
    final cityDisplay = (city ?? '').trim().isNotEmpty
        ? displayName(city, languageCode: languageCode)
        : '';
    final countryDisplay = localizedCountryName(country);
    final parts = [cityDisplay, countryDisplay]
        .where((value) => value.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    return parts.join(', ');
  }
}
