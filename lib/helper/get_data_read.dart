import 'package:get_storage/get_storage.dart';

final getData = GetStorage();
save(key, val) {
  getData.write(key, val);
}
