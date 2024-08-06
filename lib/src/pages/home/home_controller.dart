import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import '../../models/user.dart';

class HomeController extends GetxController {
  User user = User.fromJson({});
  String token = '';

  HomeController() {
    var userData = GetStorage().read('user') ?? {};

    print('userData  ->: ${userData}');

    // Extraer campos específicos de userData['user']
    Map<String, dynamic> userMap = userData['user'] ?? {};
    String? id = userMap['id'];
    String? name = userMap['name'];
    String? lastname = userMap['lastname'];
    String? phone = userMap['phone'];
    String? image = userMap['image'];
    String? email = userMap['email'];
    token = userData['token'] ?? '';
    String? roles = userMap['roles'];

    print('Id: $id');
    print('Nombre: $name');
    print('Apellido: $lastname');
    print('Teléfono: $phone');
    print('Imagen: $image');
    print('Email: $email');
    print('TOKEN: $token');
    print('ROLES: $roles');

    // Crea un nuevo objeto User con los valores extraídos
    user = User.fromJson(userData);

  }

  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/', (route) => false); // ELIMINAR EL HISTORIAL DE PANTALLAS
  }
}