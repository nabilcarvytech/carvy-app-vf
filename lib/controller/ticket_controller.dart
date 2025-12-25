import 'package:get/state_manager.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/reply_thred_model.dart';
import 'package:carvy/model/user_thread_model.dart';

class TicketController extends GetxController implements GetxService {
  RxBool ticketLoading = false.obs;
  getdata(Threads thread, List<ReplyThreadsData> list,
      ReplyThreadsModel? replyThreads) async {
    Map<String, String> postData = {"thread_id": thread.threadId.toString()};
    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var response = await httpGet(Config.getReplyThreads, postData);

    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // MOCK: Static reply threads data
    var response = {
      "status": 200,
      "message": "Reply threads retrieved successfully",
      "error": "",
      "data": {
        "replyThreads": [
          {
            "id": 1,
            "thread_id": thread.threadId.toString(),
            "user_id": "1",
            "is_admin_reply": "0",
            "message":
                "Thank you for your inquiry. We will get back to you soon.",
            "created_at": "2025-01-15T10:00:00.000Z",
            "updated_at": "2025-01-15T10:00:00.000Z",
            "reply_status": "1"
          },
          {
            "id": 2,
            "thread_id": thread.threadId.toString(),
            "user_id": "1",
            "is_admin_reply": "1",
            "message":
                "We have received your message and are working on a solution.",
            "created_at": "2025-01-15T11:00:00.000Z",
            "updated_at": "2025-01-15T11:00:00.000Z",
            "reply_status": "1"
          }
        ]
      }
    };
    // ========== END MOCK DATA ==========
    replyThreads = ReplyThreadsModel.fromJson(response);
    list = replyThreads.data!.replyThreadsData!;
  }

  getUserOpenTicket() async {
    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var response = await httpGet(Config.getUserThreads, {});

    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // MOCK: Static user threads data (open tickets)
    var response = {
      "status": 200,
      "message": "User threads retrieved successfully",
      "error": "",
      "data": {
        "threads": [
          {
            "id": 1,
            "user_id": "1",
            "thread_id": "THREAD_001",
            "thread_status": "1",
            "title": "Payment Issue",
            "description": "I have a problem with my payment",
            "created_at": "2025-01-15T10:00:00.000Z",
            "updated_at": "2025-01-15T10:00:00.000Z"
          },
          {
            "id": 2,
            "user_id": "1",
            "thread_id": "THREAD_002",
            "thread_status": "1",
            "title": "Booking Cancellation",
            "description": "I need to cancel my booking",
            "created_at": "2025-01-14T09:00:00.000Z",
            "updated_at": "2025-01-14T09:00:00.000Z"
          }
        ]
      }
    };
    // ========== END MOCK DATA ==========
    if (response != null) {
      return UserThreadModel.fromJson(response);
    }
  }

  getUsercloseTicket() async {
    Map<String, String> postData = {"thread_status": "0"};
    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var response = await httpGet(Config.getUserThreads, postData);

    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // MOCK: Static user threads data (closed tickets)
    var response = {
      "status": 200,
      "message": "Closed threads retrieved successfully",
      "error": "",
      "data": {
        "threads": [
          {
            "id": 3,
            "user_id": "1",
            "thread_id": "THREAD_003",
            "thread_status": "0",
            "title": "Account Issue",
            "description": "Resolved account problem",
            "created_at": "2025-01-10T08:00:00.000Z",
            "updated_at": "2025-01-12T15:00:00.000Z"
          }
        ]
      }
    };
    // ========== END MOCK DATA ==========
    if (response != null) {
      return UserThreadModel.fromJson(response);
    }
  }

  createSupportTicket(title, desc) async {
    showLoading();
    Map<String, String> postData = {"title": title, "description": desc};
    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var response = await httpPost(Config.createSupportTicket, postData);

    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // MOCK: Static success response for creating support ticket
    var response = {
      "status": 200,
      "message": "Support ticket created successfully",
      "error": ""
    };
    // ========== END MOCK DATA ==========
    closeLoading();
    if (response != null && response["status"] == 200) {
      closeLoading();
      showToastMessage(response["message"]);
    }
  }
}
