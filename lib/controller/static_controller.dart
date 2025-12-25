import 'package:get/get.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/static_model.dart';

class StaticController extends GetxController implements GetxService {
  RxString string = "".obs;

  fetchData(data) async {
    dynamic response;
    try {
      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // All httpGet calls to Config.staticPage are commented out and replaced with mock data

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Static page content based on the page type
      String pageContent = "";
      String pageName = "";
      String pageId = "";

      if (data == "About Us".tr) {
        pageId = "2";
        pageName = "About Us";
        pageContent =
            "<h1>About Us</h1><p>Welcome to Carvy, your trusted vehicle rental platform. We connect vehicle owners with renters, making car sharing easy and convenient.</p><p>Our mission is to provide a seamless experience for both hosts and guests.</p>";
      } else if (data == "Get Help".tr) {
        pageId = "4";
        pageName = "Get Help";
        pageContent =
            "<h1>Get Help</h1><p>Need assistance? We're here to help!</p><p>Contact our support team at support@carvy.com or use the in-app support feature.</p>";
      } else if (data == "Give Us Feedback".tr) {
        pageId = "5";
        pageName = "Give Us Feedback";
        pageContent =
            "<h1>Give Us Feedback</h1><p>We value your feedback! Please share your thoughts and suggestions to help us improve.</p>";
      } else if (data == "Terms of Service for Vehicle Owner") {
        pageId = "11";
        pageName = "Terms of Service for Vehicle Owner";
        pageContent =
            "<h1>Terms of Service for Vehicle Owner</h1><p>By listing your vehicle on Carvy, you agree to our terms and conditions...</p>";
      } else if (data == "Terms and Condition" ||
          data == "Terms of Service for Users & Privacy Policy") {
        pageId = "1";
        pageName = "Terms and Condition";
        pageContent =
            "<h1>Terms of Service for Users & Privacy Policy</h1><p>By using Carvy, you agree to our terms of service and privacy policy...</p><h2>Privacy Policy</h2><p>We respect your privacy and protect your personal information...</p>";
      } else if (data == "Booking Agreement") {
        pageId = "32";
        pageName = "Booking Agreement";
        pageContent =
            "<h1>Booking Agreement</h1><p>This agreement outlines the terms and conditions for booking vehicles through Carvy...</p>";
      } else {
        pageId = "1";
        pageName = "Static Page";
        pageContent =
            "<h1>Static Page</h1><p>This is a static content page.</p>";
      }

      response = {
        "status": 200,
        "message": "Static page retrieved successfully",
        "error": "",
        "data": {
          "StaticPage": {
            "id": int.tryParse(pageId) ?? 1,
            "name": pageName,
            "content": pageContent,
            "status": "1",
            "created_at": "2024-01-01T00:00:00.000Z",
            "updated_at": "2024-01-01T00:00:00.000Z",
            "deleted_at": null
          }
        }
      };
      // ========== END MOCK DATA ==========
      if (response != null && response.isNotEmpty) {
        StaticModel staticModel = StaticModel.fromJson(response);
        string.value =
            staticModel.data?.staticPage?.content ?? 'Content not available';
      } else {
        throw Exception("Failed to fetch data or empty response");
      }
    } catch (e) {
      string.value = 'Error fetching data';
    }
  }
}
