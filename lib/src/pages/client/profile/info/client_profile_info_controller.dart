import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:servicek/src/models/user.dart';

class ClientProfileInfoController extends GetxController {

    var userData = GetStorage().read('user')?? {};
    var user     = GetStorage().read('user')?? {};

    void signOut() {
        GetStorage().remove('user');
        Get.offNamedUntil('/', (route) => false); // ELIMINAR EL HISTORIAL DE PANTALLAS
    }

    void goToProfileUpdate(){
        Get.toNamed('/client/profile/update');
    }

    void goToRoles(){
        Get.offNamedUntil('/roles', (route) => false);
    }

    @override
    void onInit() {
        super.onInit();
        print('userData: $userData'); // Muestra el valor de userData en la consola
        print('user    : $user'); // Muestra el valor de userData en la consola
    }
}
