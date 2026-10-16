import 'dart:convert';

/// Bloque l'édition vendeur si le véhicule a une réservation active.
class VehicleEditLockHelper {
  VehicleEditLockHelper._();

  static const Set<String> activeStatuses = {
    'pending',
    'confirmed',
    'ongoing',
    'accepted',
    'upcoming',
    'in_progress',
    'inprogress',
    'live',
    'confirmée',
    'confirmee',
    'en cours',
    'en_cours',
    'encours',
    'en attente',
    'en_attente',
    'en direct',
    'en_direct',
  };

  static const Set<String> terminalStatuses = {
    'cancelled',
    'canceled',
    'completed',
    'declined',
    'rejected',
    'expired',
    'annulé',
    'annule',
    'terminée',
    'terminee',
  };

  static bool isLocked(
    dynamic vehicle, {
    Iterable<String>? extraLockedIds,
  }) {
    if (_fromPayload(vehicle)) return true;
    final id = vehicleIdOf(vehicle);
    if (id.isEmpty || extraLockedIds == null) return false;
    final needle = id.toLowerCase();
    for (final extra in extraLockedIds) {
      if (extra.trim().toLowerCase() == needle) return true;
    }
    return false;
  }

  static bool isActiveBookingStatus(dynamic raw) {
    final s = raw?.toString().trim().toLowerCase() ?? '';
    if (s.isEmpty) return false;
    if (terminalStatuses.contains(s)) return false;
    return activeStatuses.contains(s);
  }

  static String vehicleIdOf(dynamic vehicle) {
    if (vehicle == null) return '';
    if (vehicle is Map) {
      return (vehicle['_id'] ?? vehicle['id'] ?? vehicle['item_id'] ?? '')
          .toString()
          .trim();
    }
    try {
      final id = vehicle.id?.toString().trim() ?? '';
      if (id.isNotEmpty && id != 'null') return id;
    } catch (_) {}
    final map = _asMap(vehicle);
    return (map?['_id'] ?? map?['id'] ?? '').toString().trim();
  }

  static bool _fromPayload(dynamic vehicle) {
    final map = _asMap(vehicle);
    if (map == null) return false;

    if (_truthy(map['hasActiveBooking']) ||
        _truthy(map['has_active_booking']) ||
        _truthy(map['hasOngoingBooking']) ||
        _truthy(map['has_ongoing_booking']) ||
        _truthy(map['isCurrentlyBooked']) ||
        _truthy(map['is_currently_booked'])) {
      return true;
    }

    for (final key in const [
      'activeBookingCount',
      'active_booking_count',
      'ongoingBookingsCount',
      'confirmedBookingsCount',
    ]) {
      final n = num.tryParse(map[key]?.toString() ?? '');
      if (n != null && n > 0) return true;
    }

    for (final key in const [
      'bookingStatus',
      'booking_status',
      'currentBookingStatus',
      'current_booking_status',
      'activeBookingStatus',
      'reservationStatus',
      'status_booking',
    ]) {
      if (isActiveBookingStatus(map[key])) return true;
    }

    final nested = map['activeBooking'] ??
        map['active_booking'] ??
        map['currentBooking'] ??
        map['current_booking'];
    if (nested is Map) {
      if (isActiveBookingStatus(
            nested['status'] ??
                nested['bookingStatus'] ??
                nested['booking_status'],
          )) {
        return true;
      }
    } else if (_truthy(nested)) {
      return true;
    }

    for (final key in const [
      'bookings',
      'Bookings',
      'activeBookings',
      'active_bookings',
      'currentBookings',
    ]) {
      if (_listHasActive(map[key])) return true;
    }

    if (_hasUpcomingBookedDate(
          map['booked_dates'] ?? map['bookedDates'],
        )) {
      return true;
    }

    final itemInfo = map['item_info'] ?? map['itemInfo'];
    if (itemInfo is String && itemInfo.trim().isNotEmpty) {
      try {
        final decoded = json.decode(itemInfo);
        if (decoded is Map &&
            _fromPayload(Map<String, dynamic>.from(decoded))) {
          return true;
        }
      } catch (_) {}
    } else if (itemInfo is Map &&
        _fromPayload(Map<String, dynamic>.from(itemInfo))) {
      return true;
    }

    return false;
  }

  static Map<String, dynamic>? _asMap(dynamic vehicle) {
    if (vehicle == null) return null;
    if (vehicle is Map) {
      return Map<String, dynamic>.from(vehicle);
    }
    try {
      final src = vehicle.sourceJson;
      if (src is Map && src.isNotEmpty) {
        return Map<String, dynamic>.from(src);
      }
    } catch (_) {}
    try {
      final jsonMap = vehicle.toJson();
      if (jsonMap is Map) return Map<String, dynamic>.from(jsonMap);
    } catch (_) {}
    return null;
  }

  static bool _listHasActive(dynamic raw) {
    if (raw is! List || raw.isEmpty) return false;
    for (final item in raw) {
      if (item is Map) {
        final status = item['status'] ??
            item['bookingStatus'] ??
            item['booking_status'];
        if (isActiveBookingStatus(status)) return true;
        if (status == null && !_isTerminalStatus(item['status'])) {
          // Élément sans statut dans une liste de bookings → considéré actif.
          if (item.containsKey('check_in') ||
              item.containsKey('checkIn') ||
              item.containsKey('item_id')) {
            return true;
          }
        }
      } else if (isActiveBookingStatus(item)) {
        return true;
      }
    }
    return false;
  }

  static bool _isTerminalStatus(dynamic raw) {
    final s = raw?.toString().trim().toLowerCase() ?? '';
    return terminalStatuses.contains(s);
  }

  static bool _hasUpcomingBookedDate(dynamic raw) {
    if (raw is! List || raw.isEmpty) return false;
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    for (final item in raw) {
      String? dateStr;
      if (item is Map) {
        dateStr = (item['date'] ?? item['day'] ?? item['check_in'])?.toString();
      } else {
        dateStr = item?.toString();
      }
      if (dateStr == null || dateStr.trim().isEmpty) continue;
      final parsed = DateTime.tryParse(dateStr.trim());
      if (parsed == null) continue;
      final day = DateTime(parsed.year, parsed.month, parsed.day);
      if (!day.isBefore(startOfToday)) return true;
    }
    return false;
  }

  static bool _truthy(dynamic raw) {
    if (raw == true) return true;
    if (raw is num) return raw != 0;
    final s = raw?.toString().trim().toLowerCase() ?? '';
    return s == 'true' || s == '1' || s == 'yes';
  }
}
