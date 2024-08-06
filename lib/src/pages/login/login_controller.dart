import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  static const ROOT = 'https://www.aaservicek.com/servicek_backend/actions/user_actions.php';
  static const _LOGIN_ACTION = 'LOGIN_USR';

  void goToRegisterPage() {
    Get.toNamed('/register');
  }

  bool isValidForm(String email, String password) {
    if (email.isEmpty) {
      Get.snackbar('Formulario no válido ', 'Debes ingresar un email válido');
      return false;
    }

    if (email.isEmpty) {
      Get.snackbar('Formulario no válido', 'Debes ingresar el email');
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Formulario no válido', 'El email no es válido');
      return false;
    }

    if (password.isEmpty) {
      Get.snackbar('Formulario no válido', 'Debes ingresar el password');
      return false;
    }

    return true;
  }

  void goToHomePage() {
    Get.offNamedUntil('/home', (route) => false);
  }

  void goToRolesPage() {
    Get.offNamedUntil('/roles', (route) => false);
  }

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    print('login Email $email');
    print('login Password $password');


    if (isValidForm(email, password)) {
      Map<String, dynamic>? result = await loginUsers(email, password);

      if (result != null) {
        print('Resultado completo: $result'); // Imprimir el resultado completo
        if (result.containsKey('message')) {
          String message = result['message'];
          if (message == "Contraseña incorrecta") {
            Get.snackbar('Error', message);
          } else if (message == "Usuario no encontrado") {
            Get.snackbar('Error', message);
          } else if (message == "Login exitoso") {

                  Map<String, dynamic> userData = result['user_data'];
                  String name = userData['name'];
                  Get.snackbar('Bienvenido: ', name);
                  // Puedes acceder a otros datos del usuario aquí
                  print('Correo electrónico: ${userData['email']}');
                  //Get.snackbar('Disfrutas del mejor servicio: ', userData['name']);
                  // Verificar si la clave 'token' existe y su valor no es null
                  if (result.containsKey('token') && result['token'] != null) {
                    String token = result['token'];
                    print('JWT: ${result['token']}');
                    // Puedes almacenar o utilizar el token JWT aquí
                  } else {
                    print('No se pudo obtener el token JWT');
                  }

                  Map<String, dynamic> userWithToken = {
                    'user': userData,
                    'token': result['token'],
                    'roles': result['roles'],
                  };
                  print('roles : $userWithToken');
                  GetStorage().write('user', userWithToken);
                  //goToHomePage();
                  goToRolesPage();
          }else {
            Get.snackbar('Error', 'Error en el login de usuario');
          }
        } else {
          Get.snackbar('Error', 'Respuesta inesperada del servidor');
        }
      } else {
        Get.snackbar('Error', 'Error en el login de usuario');
      }
    }

  }

  static Future<Map<String, dynamic>?> loginUsers(String email, String password) async {
    try {
      var map = Map<String, dynamic>();
      map['action'] = _LOGIN_ACTION;
      map['email'] = email;
      map['password'] = password;

      Uri uri = Uri.parse(ROOT);

      final response = await http.post(uri, body: map);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}