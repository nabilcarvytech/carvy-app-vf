import 'package:get/get.dart';

/// Marqueur de vie de la route paiement.
/// Enregistré par [PaymentMethodScreen], supprimé avant [Get.offAll] vers [MyBooking].
class PaymentController extends GetxController implements GetxService {
  bool _listenersMuted = false;

  bool get listenersMuted => _listenersMuted;

  /// Coupe les notifications GetX pendant la transition [offAll].
  void clearListeners() {
    _listenersMuted = true;
  }

  @override
  void onClose() {
    _listenersMuted = true;
    super.onClose();
  }
}
