import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servicek/main.dart';
import 'package:servicek/src/models/response_api.dart';
import 'package:servicek/src/models/user.dart';
import 'package:servicek/src/pages/client/profile/info/client_profile_info_controller.dart';
import 'package:servicek/src/providers/users_providers.dart';
import 'package:servicek/src/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';


class ClientProfileUpdateController extends GetxController {
  late User user;
  TextEditingController nameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController empIdController = TextEditingController();
  ImagePicker picker = ImagePicker();
  File? imageFile;

  static const ROOT = 'https://www.aaservicek.com/servicek_backend/actions/user_actions.php';
  static const _UPDATE_USR_ACTION = 'UPDATE_USR';
  static const _READ_ACTION = 'READ_USR';

  UsersProvider userProvider = UsersProvider();

  ClientProfileUpdateController() {
    Map<String, dynamic>? userDataMap = GetStorage().read('user');
    if (userDataMap != null && userDataMap.containsKey('user')) {
      Map<String, dynamic> userData = userDataMap['user'];
      user = User.fromJson(userData);
    } else {
      user = User();
    }
    nameController.text = user.name ?? '';
    lastnameController.text = user.lastname ?? '';
    phoneController.text = user.phone ?? '';
    empIdController.text = user.id ?? '';
  }

  Future selectImage(ImageSource imageSource) async {
    XFile? image = await picker.pickImage(source: imageSource);
    if (image != null) {
      imageFile = File(image.path);
      update();
    }
  }

  void showAlertDialog(BuildContext context) {
    Widget galleryButton = ElevatedButton(
        onPressed: () {
          Get.back();
          selectImage(ImageSource.gallery);
        },
        child: Text(
          'Galería',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 17
          ),
        )
    );

    Widget cameraButton = ElevatedButton(
        onPressed: () {
          Get.back();
          selectImage(ImageSource.camera);
        },
        child: Text(
          'Càmara',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 17
          ),
        )
    );


    AlertDialog alertDialog = AlertDialog(
      title: Text(
        'Selecciona una opción',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        galleryButton,
        cameraButton
      ],
    );

    showDialog(context: context, builder: (BuildContext context) {
      return alertDialog;
    });
  }

  void updateInfo(BuildContext context) async {
    String name = nameController.text;
    String lastname = lastnameController.text;
    String phone = phoneController.text;
    String emp_id = empIdController.text;

    if (isValidForm(name, lastname, phone)) {
      /*User Myuser = User(
        id: user.id,
        email: user.email,
        name: name,
        lastname: lastname,
        phone: phone,
        image: user.image,
        password: user.password,
        roles: user.roles,
      );
       */

        String result = await updateUsers(
            user.id != null ? user.id! : '',
            name,
            lastname,
            phone
        );
        User updatedUser = User(
          id: user.id,
          email: user.email,
          name: name,
          lastname: lastname,
          phone: phone,
          image: user.image,
          password: user.password,
          roles: user.roles,
        );
        GetStorage().write('user', updatedUser.toJson());
        Map<String, dynamic>? userData = GetStorage().read('user');
        //String userDataString = const JsonEncoder.withIndent('  ').convert(userData);
        //print('Datos del usuario almacenados en GetStorage:\n$userDataString');
        if (imageFile == null) {
          Get.snackbar('Proceso terminado', 'Actualizado..!');
        } else{
          var userId = user.id;
          subirImagen(userId, context);
          Get.snackbar('Proceso terminado', 'Actualizado con imagen..!');
        }
        goToBackPage();
    }
  }


  Future<void> subirImagen(userId, context) async {
    if (imageFile != null) {
      String fileName = imageFile!.path.split('/').last;
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://www.aaservicek.com/servicek_backend/actions/upload_image.php'));
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile!.path,
        filename: fileName,
      ));

      request.fields['userId'] = userId;
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Imagen cargada ok ..');
      } else {
        print('Error cargando image');
      }
    } else {
      print('No image seleccioanda');
    }
  }



  static Future<String> updateUsers(String id,
      String name,
      String lastname,
      String phone,) async {
    try {
      var map = Map<String, dynamic>();
      map['action'] = _UPDATE_USR_ACTION;
      map['emp_id'] = id;
      map['name'] = name;
      map['lastname'] = lastname;
      map['phone'] = phone;

      Uri uri = Uri.parse(ROOT);

      final response = await http.post(uri, body: map);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "_ADD_USR_ACTION error";
      }
    } catch (e) {
      return "_ADD_USR_ACTION .. error";
    }
  }

  void goToHomePage() {
    //Get.offNamedUntil('/home', (route) => false);
    Get.offNamedUntil('/client/products/list', (route) => false);
  }

  void goToBackPage() {
    //Get.offNamedUntil('/home', (route) => false);
    Get.offNamedUntil('/', (route) => false);
  }


  bool isValidForm(String name,
      String lastname,
      String phone) {
    if (name.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu nombre');
      return false;
    }

    if (lastname.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu apellido');
      return false;
    }

    if (phone.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu numero telefónico');
      return false;
    }

    return true;
  }

}