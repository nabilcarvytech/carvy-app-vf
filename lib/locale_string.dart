import 'package:get/get.dart';
import 'package:carvy/languages/ar_ar_translations.dart';
import 'package:carvy/languages/spanish_tr.dart';
import 'languages/en_us_translations.dart';
import 'languages/ru_ru_translations.dart';
import 'languages/th_th_translations.dart';

class LocaleString extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUs,
        // 'ru_RU': ruRU,
        // 'th_TH': thTH,
        'ar_AR': arAR,
        'es_ES': esES,
      };
}
