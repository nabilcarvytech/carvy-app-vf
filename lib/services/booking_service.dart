import 'package:carvy/helper/http_service.dart';

class BookingService {
  /// PATCH `/api/v1/bookings/:id/complete` — libération immédiate du véhicule côté client.
  static Future<dynamic> manualCompleteBooking(String id) =>
      httpPatch('v1/bookings/$id/complete', jsonBody: {});
}
