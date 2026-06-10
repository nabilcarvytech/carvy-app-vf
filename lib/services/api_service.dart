import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/helper/http_service.dart';

/// Appels API REST génériques (hors domaines déjà couverts par d'autres services).
class ApiService {
  /// GET `/api/v1/client-profile/:clientId`
  /// Retourne `name`, `profileImage`, `rating`, `totalReviews`, `bio` dans `data`.
  static Future<Map<String, dynamic>> getClientProfile(String clientId) async {
    final id = clientId.trim();
    if (id.isEmpty) {
      return {'error': 'client_id_required', 'status': 400};
    }

    final raw = await httpGet(Config.clientProfilePath(id), {});
    if (raw is! Map) {
      return {'error': 'invalid_response'};
    }

    final response = Map<String, dynamic>.from(raw);
    final status = response['status'] ?? response['statusCode'];
    final is403 = status == 403 ||
        status == '403' ||
        response['statusCode'] == 403;

    if (is403) {
      Get.snackbar(
        'Error'.tr,
        'Access denied'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return response;
    }

    return response;
  }

  static Map<String, dynamic>? parseClientProfileData(Map<String, dynamic> response) {
    final dynamic block = response['data'] ?? response;
    if (block is! Map) return null;
    final map = Map<String, dynamic>.from(block);

    String readString(List<String> keys) {
      for (final key in keys) {
        final v = map[key];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString().trim();
        }
      }
      return '';
    }

    double readDouble(List<String> keys) {
      for (final key in keys) {
        final v = map[key];
        if (v == null) continue;
        if (v is num) return v.toDouble();
        final parsed = double.tryParse(v.toString());
        if (parsed != null) return parsed;
      }
      return 0.0;
    }

    int readInt(List<String> keys) {
      for (final key in keys) {
        final v = map[key];
        if (v == null) continue;
        if (v is num) return v.toInt();
        final parsed = int.tryParse(v.toString());
        if (parsed != null) return parsed;
      }
      return 0;
    }

    bool readBool(List<String> keys) {
      for (final key in keys) {
        final v = map[key];
        if (v == null) continue;
        if (v is bool) return v;
        final s = v.toString().trim().toLowerCase();
        if (s == '1' || s == 'true' || s == 'yes') return true;
        if (s == '0' || s == 'false' || s == 'no') return false;
      }
      return false;
    }

    bool? readOptionalBool(List<String> keys) {
      for (final key in keys) {
        if (!map.containsKey(key)) continue;
        return readBool([key]);
      }
      return null;
    }

    List<Map<String, dynamic>> readReviews() {
      final raw = map['reviews'];
      if (raw is! List) return [];
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    final verifiedEmail = readOptionalBool([
      'verifiedEmail',
      'verified_email',
      'email_verified',
      'is_email_verified',
    ]);
    final verifiedPhone = readOptionalBool([
      'verifiedPhone',
      'verified_phone',
      'phone_verified',
      'is_phone_verified',
    ]);

    return {
      'name': readString(['name', 'user_name', 'userName']),
      'profileImage': readString([
        'profileImage',
        'profile_image',
        'image',
        'avatar',
      ]),
      'rating': readDouble(['rating', 'average_rating', 'averageRating']),
      'totalReviews': readInt([
        'totalReviews',
        'total_reviews',
        'review_count',
      ]),
      'totalBookings': readInt([
        'totalBookings',
        'total_bookings',
        'total_rentals',
        'booking_count',
        'rentals_count',
      ]),
      'bio': readString(['bio', 'introText', 'intro_text', 'introduction']),
      'joinIn': readString([
        'joinIn',
        'join_in',
        'joined_since',
        'member_since',
        'created_at',
      ]),
      if (verifiedEmail != null) 'verifiedEmail': verifiedEmail,
      if (verifiedPhone != null) 'verifiedPhone': verifiedPhone,
      'reviews': readReviews(),
    };
  }

  static List<Map<String, dynamic>> parseClientReviewsList(
    Map<String, dynamic> response,
  ) {
    final data = parseClientProfileData(response);
    if (data == null) return [];
    final raw = data['reviews'];
    if (raw is! List) return [];
    return raw.whereType<Map<String, dynamic>>().toList();
  }
}
