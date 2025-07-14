import 'package:get/get.dart';

import 'ar_translation.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'ar': arTranslation};
}
