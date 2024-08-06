import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ClientOrdersListController extends GetxController {

  void signOut() {
    GetStorage().remove('user');

    Get.offNamedUntil('/', (route) => false); // ELIMINAR EL HISTORIAL DE PANTALLAS
  }

}