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
    var response = await httpGet(Config.getReplyThreads, postData);
    replyThreads = ReplyThreadsModel.fromJson(response);
    list = replyThreads.data!.replyThreadsData!;
  }

  getUserOpenTicket() async {
    var response = await httpGet(Config.getUserThreads, {});
    if (response != null) {
      return UserThreadModel.fromJson(response);
    }
  }

  getUsercloseTicket() async {
    Map<String, String> postData = {"thread_status": "0"};
    var response = await httpGet(Config.getUserThreads, postData);
    if (response != null) {
      return UserThreadModel.fromJson(response);
    }
  }

  createSupportTicket(title, desc) async {
    showLoading();
    Map<String, String> postData = {"title": title, "description": desc};
    var response = await httpPost(Config.createSupportTicket, postData);
    closeLoading();
    if (response != null && response["status"] == 200) {
      closeLoading();
      showToastMessage(response["message"]);
    }
  }
}
