import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../models/Rol.dart';
import '../../models/user.dart';

class RolesController extends GetxController {
  User user = User.fromJson(GetStorage().read('user') ?? {});

  void goToPageRol(Rol rol) {
    // Guardar los valores de user en el GetStorage
    GetStorage().write('user', user.toJson());

    // Navegar a la página especificada por rol.route
    Get.offNamedUntil(rol.route ?? '', (route) => false);
  }

  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/', (route) => false);
  }
}
