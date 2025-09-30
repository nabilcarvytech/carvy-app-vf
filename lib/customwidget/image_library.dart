import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

Future<Map<String, String>> pickAndConvertImage({
  required Function(bool isLoading) onLoadingStateChange,
}) async {
  onLoadingStateChange(true);
  XFile? value = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (value != null) {
    var bytes = await File(value.path).readAsBytes();
    var base64Image = base64Encode(bytes);

    String format = '';
    if (bytes.length > 8) {
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
        format = 'jpeg';
      } else if (bytes[0] == 0x89 && bytes[1] == 0x50) {
        format = 'png';
      }
    }

    String identityBase64 = "data:image/$format;base64,$base64Image";

    onLoadingStateChange(false);
    return {'path': value.path, 'base64Image': identityBase64};
  }
  onLoadingStateChange(false);
  return {};
}