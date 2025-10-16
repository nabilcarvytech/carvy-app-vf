import 'package:get/get.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/static_model.dart';

class StaticController extends GetxController implements GetxService {
  RxString string = "".obs;

  fetchData(data) async {
    dynamic response;
    try {
      if (data == "About Us".tr) {
        response = await httpGet(Config.staticPage, {"id": "2"});
      } else if (data == "Get Help".tr) {
        response = await httpGet(Config.staticPage, {"id": "4"});
      } else if (data == "Give Us Feedback".tr) {
        response = await httpGet(Config.staticPage, {"id": "5"});
      } else if (data == "Terms of Service for Vehicle Owner") {
        response = await httpGet(Config.staticPage, {"id": "11"});
      } else if (data ==
          "Условия обслуживания для владельцев транспортных средств") {
        response = await httpGet(Config.staticPage, {"id": "14"});
      } else if (data == "ข้อกำหนดในการให้บริการสำหรับเจ้าของรถ") {
        response = await httpGet(Config.staticPage, {"id": "15"});
      } else if (data == "Terms and Condition" ||
          data == "Terms of Service for Users & Privacy Policy") {
        response = await httpGet(Config.staticPage, {"id": "1"});
      } else if (data == "Условиями и положениями" ||
          data ==
              "Условия обслуживания для пользователей и политика конфиденциальности") {
        response = await httpGet(Config.staticPage, {"id": "19"});
      } else if (data == "เงื่อนไขและข้อตกลง" ||
          data ==
              "ข้อกำหนดในการให้บริการสำหรับผู้ใช้และนโยบายความเป็นส่วนตัว") {
        response = await httpGet(Config.staticPage, {"id": "13"});
      } else if (data == "شروط الخدمة للمستخدمين وسياسة الخصوصية") {
        response = await httpGet(Config.staticPage, {"id": "20"});
      } else if (data == "شروط الخدمة لمالك المركبة") {
        response = await httpGet(Config.staticPage, {"id": "21"});
      } else if (data == "Booking Agreement") {
        response = await httpGet(Config.staticPage, {"id": "32"});
      } else {
        throw Exception("Unrecognized data type");
      }
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
