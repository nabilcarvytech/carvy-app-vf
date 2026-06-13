import 'package:carvy/languages/en_fr_translations.dart';
import 'package:get/get.dart';
import 'package:carvy/languages/ar_ar_translations.dart';
import 'package:carvy/languages/spanish_tr.dart';
import 'languages/en_us_translations.dart';

class LocaleString extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUs,
        'ar_AR': arAR,
        'es_ES': esES,
        'fr_FR': frFR,
      };
}
