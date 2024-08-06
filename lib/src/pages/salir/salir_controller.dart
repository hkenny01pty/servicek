import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SalirController extends GetxController {


  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/welcome', (route) => false); // ELIMINAR EL HISTORIAL DE PANTALLAS
  }



  }