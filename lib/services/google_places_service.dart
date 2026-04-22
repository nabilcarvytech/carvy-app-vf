import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:carvy/api/config.dart';

class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final double? latitude;
  final double? longitude;

  const PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
    this.latitude,
    this.longitude,
  });
}

class GooglePlacesService {
  GooglePlacesService();
  static const Uuid _uuid = Uuid();
  String? _sessionToken;
  String? _lastAutocompleteError;
  String? get lastAutocompleteError => _lastAutocompleteError;

  String _ensureSessionToken() {
    _sessionToken ??= _uuid.v4();
    return _sessionToken!;
  }

  /// À appeler après sélection/annulation pour démarrer une nouvelle session.
  void completeSession() {
    print('🧹 [PlacesAutocomplete] completeSession() oldToken=$_sessionToken');
    _sessionToken = null;
  }

  Future<List<PlaceSuggestion>> searchAddress(String query) async {
    // IMPORTANT: n'utiliser QUE la saisie utilisateur reçue en argument.
    final userInput = query.trim();
    print('⌨️ [PlacesAutocomplete] raw input="$query" | trimmed="$userInput"');
    if (userInput.isEmpty) {
      print('⚠️ [PlacesAutocomplete] input empty -> return []');
      return const [];
    }
    final token = _ensureSessionToken();
    final queryParams = <String, String>{
      'input': userInput,
      'key': Config.googleKey,
      'components': 'country:ma',
      'language': 'fr',
      // Ne pas filtrer de façon restrictive : POI + adresses (comportement Maps).
      'sessiontoken': token,
    };
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      queryParams,
    );
    final finalUrl = uri.toString();
    print('📡 URL FINALE API: $finalUrl');
    print('🌐 [PlacesAutocomplete] URL: $uri');
    print('🔐 [PlacesAutocomplete] Using key (first 10): ${Config.googleKey.substring(0, Config.googleKey.length > 10 ? 10 : Config.googleKey.length)}...');
    print('🪪 [PlacesAutocomplete] sessionToken=$token');
    final resp = await http.get(uri);
    print('📡 [PlacesAutocomplete] API Response Status: ${resp.statusCode}');
    print('📄 [PlacesAutocomplete] API Body: ${resp.body}');
    if (resp.statusCode != 200) {
      _lastAutocompleteError =
          'HTTP ${resp.statusCode} on Place Autocomplete (check API key/billing)';
      debugPrint('❌ [PlacesAutocomplete] $_lastAutocompleteError');
      return const [];
    }
    final jsonBody = jsonDecode(resp.body) as Map<String, dynamic>;
    final status = jsonBody['status']?.toString() ?? '';
    final errorMsg = jsonBody['error_message']?.toString();
    print('📊 [PlacesAutocomplete] status=$status error=$errorMsg');
    if (status != 'OK' && status != 'ZERO_RESULTS') {
      _lastAutocompleteError = 'status=$status${errorMsg != null ? ', error=$errorMsg' : ''}';
      debugPrint('❌ [PlacesAutocomplete] $_lastAutocompleteError');
      return const [];
    }
    if (status == 'ZERO_RESULTS') {
      print('ℹ️ [PlacesAutocomplete] ZERO_RESULTS for "$userInput"');
      _lastAutocompleteError = null;
      return const [];
    }
    List<dynamic> preds =
        (jsonBody['predictions'] as List<dynamic>? ?? const []);
    if (status == 'OK' && preds.isEmpty) {
      // Debug urgent: test sans sessiontoken pour isoler un conflit potentiel.
      final fallbackParams = Map<String, String>.from(queryParams)
        ..remove('sessiontoken');
      final fallbackUri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        fallbackParams,
      );
      print('🧪 [PlacesAutocomplete] Fallback URL (without sessiontoken): $fallbackUri');
      final fallbackResp = await http.get(fallbackUri);
      print('📡 [PlacesAutocomplete] Fallback Response Status: ${fallbackResp.statusCode}');
      print('📄 [PlacesAutocomplete] Fallback API Body: ${fallbackResp.body}');
      if (fallbackResp.statusCode == 200) {
        final fallbackJson = jsonDecode(fallbackResp.body) as Map<String, dynamic>;
        final fallbackStatus = fallbackJson['status']?.toString() ?? '';
        if (fallbackStatus == 'OK') {
          preds = (fallbackJson['predictions'] as List<dynamic>? ?? const []);
        }
      }
    }
    final suggestions = preds
        .map((e) => PlaceSuggestion(
              placeId: e['place_id']?.toString() ?? '',
              description: e['description']?.toString() ?? '',
              mainText: e['structured_formatting']?['main_text']?.toString() ??
                  e['description']?.toString() ??
                  '',
              secondaryText:
                  e['structured_formatting']?['secondary_text']?.toString() ?? '',
            ))
        .toList();
    _lastAutocompleteError = null;
    debugPrint('✅ [PlacesAutocomplete] ${suggestions.length} suggestion(s)');
    for (var i = 0; i < suggestions.length && i < 5; i++) {
      final s = suggestions[i];
      print('   ↳ [$i] placeId=${s.placeId} main="${s.mainText}" secondary="${s.secondaryText}"');
    }
    return suggestions;
  }

  Future<PlaceSuggestion?> getPlaceDetails(String placeId) async {
    if (placeId.trim().isEmpty) return null;
    print('📍 [PlaceDetails] placeId=$placeId');
    final token = _ensureSessionToken();
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {
        'place_id': placeId,
        'key': Config.googleKey,
        'fields': 'geometry,formatted_address,name',
        'language': 'fr',
        'sessiontoken': token,
      },
    );
    final resp = await http.get(uri);
    print('📡 [PlaceDetails] statusCode=${resp.statusCode}');
    print('📄 [PlaceDetails] body=${resp.body}');
    if (resp.statusCode != 200) return null;
    final jsonBody = jsonDecode(resp.body) as Map<String, dynamic>;
    if (jsonBody['status']?.toString() != 'OK') return null;
    final result = jsonBody['result'] as Map<String, dynamic>? ?? const {};
    final geo = result['geometry'] as Map<String, dynamic>? ?? const {};
    final loc = geo['location'] as Map<String, dynamic>? ?? const {};
    final lat = (loc['lat'] as num?)?.toDouble();
    final lng = (loc['lng'] as num?)?.toDouble();
    final label = (result['formatted_address']?.toString().isNotEmpty ?? false)
        ? result['formatted_address'].toString()
        : (result['name']?.toString() ?? '');
    if (lat == null || lng == null || label.isEmpty) return null;
    print('✅ [PlaceDetails] resolved lat=$lat lng=$lng label="$label"');
    return PlaceSuggestion(
      placeId: placeId,
      description: label,
      mainText: result['name']?.toString() ?? label,
      secondaryText: result['formatted_address']?.toString() ?? '',
      latitude: lat,
      longitude: lng,
    );
  }

  Future<String?> reverseGeocode(double lat, double lng) async {
    print('🧭 [ReverseGeocode] request lat=$lat lng=$lng');
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {
        'latlng': '$lat,$lng',
        'key': Config.googleKey,
        'language': 'fr',
      },
    );
    final resp = await http.get(uri);
    print('📡 [ReverseGeocode] statusCode=${resp.statusCode}');
    print('📄 [ReverseGeocode] body=${resp.body}');
    if (resp.statusCode != 200) return null;
    final jsonBody = jsonDecode(resp.body) as Map<String, dynamic>;
    if (jsonBody['status']?.toString() != 'OK') return null;
    final results = jsonBody['results'] as List<dynamic>? ?? const [];
    if (results.isEmpty) return null;
    final addr = results.first['formatted_address']?.toString();
    print('✅ [ReverseGeocode] address="$addr"');
    return addr;
  }
}

