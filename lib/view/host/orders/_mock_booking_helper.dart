import 'dart:convert';

/// Helper function to generate mock booking data for vendor bookings
/// This file should be removed after Node.js backend implementation
Map<String, dynamic> generateMockVendorBooking({
  required String type,
  required num offset,
}) {
  String status;
  String checkIn;
  String checkOut;

  // Variables pour les statuts de delivery/return
  int isItemDelivered = 0;
  int isItemReturned = 0;
  String isItemDeliveredButton = "";
  String isItemReturnedButton = "";
  String pickOtp = "";
  String dropOtp = "";

  switch (type.toLowerCase()) {
    case 'upcoming':
      status = 'Confirmed'; // Changed to "Confirmed" to show "Mark as Delivered" button
      checkIn = '2025-12-16';
      checkOut = '2025-12-18';
      // For "Upcoming" with "Confirmed" status, enable the "Mark as Delivered" button
      isItemDelivered = 0; // Not yet delivered
      isItemDeliveredButton = "yes"; // Show the button
      isItemReturned = 0;
      pickOtp = "1234"; // Add a mock pickup OTP for testing
      break;
    case 'ongoing':
      status = 'Ongoing';
      checkIn = DateTime.now()
          .subtract(const Duration(days: 1))
          .toString()
          .split(' ')[0];
      checkOut =
          DateTime.now().add(const Duration(days: 2)).toString().split(' ')[0];
      isItemDelivered = 1; // Already delivered in ongoing bookings
      isItemDeliveredButton = "no";
      isItemReturned = 0;
      pickOtp = "1234";
      break;
    case 'previous':
      status = 'Completed';
      checkIn = DateTime.now()
          .subtract(const Duration(days: 10))
          .toString()
          .split(' ')[0];
      checkOut = DateTime.now()
          .subtract(const Duration(days: 8))
          .toString()
          .split(' ')[0];
      // For "Previous" bookings, enable the "Mark as Returned" button if not yet returned
      isItemDelivered = 1; // Already delivered
      isItemDeliveredButton = "no";
      isItemReturned = 0; // Not yet returned - this will show the "Mark as Returned" button
      isItemReturnedButton = "yes"; // Show the button
      dropOtp = "5678"; // Add a mock drop OTP for testing
      break;
    case 'cancelled':
      status = 'Cancelled';
      checkIn =
          DateTime.now().add(const Duration(days: 5)).toString().split(' ')[0];
      checkOut =
          DateTime.now().add(const Duration(days: 7)).toString().split(' ')[0];
      isItemDelivered = 0;
      isItemDeliveredButton = "";
      isItemReturned = 0;
      break;
    default:
      status = 'Pending';
      checkIn = '2025-12-16';
      checkOut = '2025-12-18';
  }

  return {
    "status": 200,
    "message": "Vendor bookings retrieved successfully",
    "error": "",
    "data": {
      "Bookings": [
        {
          "id": DateTime.now().millisecondsSinceEpoch,
          "itemid": "101",
          "userid": "1",
          "host_id": "1001",
          "check_in": checkIn,
          "check_out": checkOut,
          "status": status,
          "total_day": "2",
          "per_day": "50.00",
          "book_for": "",
          "base_price": "100.00",
          "cleaning_charge": "5.00",
          "guest_charge": "0.00",
          "service_charge": "10.00",
          "security_money": "100.00",
          "iva_tax": "12.50",
          "total_guest": "1",
          "doorstep_price": "0",
          "total": "127.50",
          "admin_commission": "10.00",
          "vendor_commision": "90.00",
          "currency_code": "MAD",
          "cancellation_reasion": "",
          "cancelled_charge": "",
          "transaction": "",
          "payment_method": "stripe",
          "payment_status": "Paid",
          "image": "https://example.com/camry.jpg",
          "item_title": "Toyota Camry 2023",
          "item_data": jsonEncode([
            {
              "item_id": 101,
              "title": "Toyota Camry 2023",
              "price": "50.00",
              "description": "",
              "bedrooms": "",
              "beds": "",
              "bathroom": "",
              "item_sqft": "",
              "item_rating": "4.5",
              "mobile": "+1234567890",
              "status": "1",
              "person_allowed": "5",
              "address": "123 Main Street, Los Angeles, CA 90001",
              "state_region": "California",
              "zip_postal_code": "90001",
              "latitude": "34.0522",
              "longitude": "-118.2437",
              "is_verified": "1",
              "is_featured": "1",
              "weekly_discount": "10",
              "weekly_discount_type": "percentage",
              "monthly_discount": "15",
              "monthly_discount_type": "percentage",
              "item_type": "Sedan",
              "cancellation_reason": "",
              "bed_type": "",
              "city": "Los Angeles",
              "amenities": [
                {
                  "id": 1,
                  "name": "GPS Navigation",
                  "image_url": "https://example.com/gps.png"
                },
                {
                  "id": 2,
                  "name": "Bluetooth",
                  "image_url": "https://example.com/bluetooth.png"
                }
              ],
              "available_dates": [],
              "host_id": "1001",
              "host_player_id": "player_12345",
              "host_first_name": "John",
              "host_last_name": "Doe",
              "host_email": "john.doe@example.com",
              "host_phone": "+1234567890",
              "host_profile_image": "https://example.com/profile.jpg",
              "front_image_url": "https://example.com/camry.jpg",
              "gallery_image_urls": [
                "https://example.com/camry-1.jpg",
                "https://example.com/camry-2.jpg"
              ],
              "reviews": [],
              "total_reviews": 0,
              "item_data": "",
              "item_info": jsonEncode({
                "host_id": "1001",
                "make_type": "Toyota",
                "model": "Camry",
                "year": "2023",
                "service_type": "booking"
              }),
              "is_in_wishlist": false
            }
          ]),
          "wall_amt": "0.00",
          "note": "",
          "rating": "4.5",
          "cancelled_by": "",
          "created_at": DateTime.now()
              .subtract(const Duration(days: 1))
              .toString()
              .split('.')[0],
          "updated_at": DateTime.now().toString().split('.')[0],
          "review_status": "0",
          "review_rating": "",
          "review": "",
          "host_name": "John Doe",
          "host_number": "+1234567890",
          "host_email": "john.doe@example.com",
          "host_phone_country": "+1",
          "user_name": "User Test",
          "user_number": "+212694492918",
          "user_phone_country": "+212",
          "user_email": "user@example.com",
          "module": "2",
          "token": "",
          "start_time": "00:00",
          "end_time": "11:30",
          "booking_meta": "",
          "is_item_delivered": isItemDelivered,
          "is_item_received": isItemDelivered == 1 ? 1 : 0, // Received if delivered
          "is_item_returned": isItemReturned,
          "is_item_delivered_button": isItemDeliveredButton,
          "is_item_returned_button": isItemReturnedButton,
          "is_received_button": isItemDelivered == 1 ? "no" : "",
          "pick_otp": pickOtp,
          "drop_otp": dropOtp,
          "doorStep_address": "",
          "booking_vehicle_images": null,
          "signature_image": null
        }
      ],
      "offset": offset + 10,
      "limit": 10
    }
  };
}

