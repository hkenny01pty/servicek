import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class RegisterController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  static const ROOT = 'https://www.aaservicek.com/servicek_backend/actions/user_actions.php';
  static const _CREATE_TABLE_ACTION = 'CREATE_TABLE';
  static const _GET_ALL_ACTION = 'GET_ALL';
  static const _ADD_USR_ACTION = 'ADD_USR';
  static const _UPDATE_USR_ACTION = 'UPDATE_USR';
  static const _DELETE_USR_ACTION = 'DELETE_USR';

  ImagePicker picker = ImagePicker();
  File? imageFile;

  //https://aaservicek.com/servicek_images/users/FoodHouse.jpg
  //https://aaservicek.com/servicek_images/users/

/*  void register(BuildContext context) async {
    String email = emailController.text.trim();
    String name = nameController.text;
    String lastname = lastnameController.text;
    String image  = selectedImageName!;
    String phone = phoneController.text;
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String pw = confirmPasswordController.text.trim();
    String created_at = confirmPasswordController.text.trim();
    String updated_at = confirmPasswordController.text.trim();

    if (isValidForm(email, name, lastname, phone, password, confirmPassword)) {
      Get.snackbar('Formulario valido', 'ok..');
      //Get.snackbar('selectedImageName', selectedImageName!);


      String result = await addUsers(
        email,
        name,
        lastname,
        phone,
        image,
        password,
        created_at,
        updated_at,
        pw,
        selectedImageName!,
      );
      if (result.contains("Ya existe un usuario con el mismo correo electrónico") ||
          result.contains("Ya existe un usuario con el mismo número de teléfono")) {
        Get.snackbar('Error', result);
      } else if (result.contains("Usuario registrado correctamente")) {
        Get.snackbar('Éxito', result);
        goToHomePage();
      } else {
        Get.snackbar('Error', 'No se pudo registrar el usuario');
      }
    }
  }
 */

  void register(BuildContext context) async {
    String email = emailController.text.trim();
    String name = nameController.text;
    String lastname = lastnameController.text;
    String phone = phoneController.text;
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String pw = confirmPasswordController.text.trim();
    String created_at = confirmPasswordController.text.trim();
    String updated_at = confirmPasswordController.text.trim();

    if (isValidForm(email, name, lastname, phone, password, confirmPassword)) {
      Get.snackbar('Formulario valido', 'ok..');
      if (selectedImageName != null) {
        try {
         // await enviarImagenAlServidor(selectedImageName!);
          String result = await addUsers(
            email,
            name,
            lastname,
            phone,
            selectedImageName!,
            password,
            created_at,
            updated_at,
            pw,
            selectedImageName!,
          );

          if (result.contains("Ya existe un usuario con el mismo correo electrónico") ||
              result.contains("Ya existe un usuario con el mismo número de teléfono")) {
            Get.snackbar('Error', result);
          } else if (result.contains("Usuario registrado correctamente")) {
            Get.snackbar('Éxito', result);
            print(result);
            final idIndex = result.indexOf('ID del usuario: ');
            final userId = result.substring(idIndex + 'ID del usuario: '.length);
            print(userId);

            subirImagen(userId, context);
            goToHomePage();
          } else {
            Get.snackbar('Error', 'No se pudo registrar el usuario');
          }
        } catch (e) {
          Get.snackbar('Error', 'No se pudo enviar la imagen al servidor');
        }
      } else {
        Get.snackbar('Error', 'Debe seleccionar una imagen');
      }
    }
  }

  String imageUrl = 'https://aaservicek.com/servicek_images/users/';

  Future<void> enviarImagenAlServidor(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      // Enviar los datos de la imagen al servidor
      // ...
    } else {
      throw Exception('No se pudo cargar la imagen');
    }
  }


  static Future<String> addUsers(
      String email,
      String name,
      String lastname,
      String phone,
      String image,
      String password,
      String created_at,
      String updated_at,
      String pw,
      String selectedImageName,
      ) async {
    try {
      var map = Map<String, dynamic>();
      map['action'] = _ADD_USR_ACTION;
      map['email'] = email;
      map['name'] = name;
      map['lastname'] = lastname;
      map['phone'] = phone;
      map['image'] = image;
      map['password'] = password;
      map['created_at'] = created_at;
      map['updated_at'] = updated_at;
      map['pw'] = pw;
      map['selectedImageName'] = selectedImageName;

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
    Get.offNamedUntil('/', (route) => false);
    //Get.offNamedUntil('/home', (route) => false);
    //Get.offNamedUntil(  '/client/products/list', (route) => false);
  }

  bool isValidForm(
      String email,
      String name,
      String lastname,
      String phone,
      String password,
      String confirmPassword
      ) {
    if (email.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar el email');
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Formulario no valido', 'El email no es valido');
      return false;
    }

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

    if (password.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar el password');
      return false;
    }

    if (confirmPassword.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar la confirmación del password');
      return false;
    }

    if (password != confirmPassword) {
      Get.snackbar('Formulario no valido', 'los password no coinciden');
      return false;
    }
    return true;
  }
/*
  Future selectImage(ImageSource imageSource) async {
    XFile? image = await picker.pickImage(source: imageSource);
    if (image != null) {
      imageFile = File(image.path);
      update();
    }
  }

 */
//https://aaservicek.com/servicek_images/users/FoodHouse.jpg

  String? selectedImageName; // Declare una variable para almacenar el nombre del archivo

  Future selectImage(ImageSource imageSource) async {
    XFile? image = await picker.pickImage(source: imageSource);
    if (image != null) {
      imageFile = File(image.path);
      selectedImageName = 'https://aaservicek.com/servicek_images/users/${image.path.split('/').last}';

      update();
    }
  }


  Future<void> subirImagenxxxxx(userId)async{
    if (imageFile != null) {
      String fileName = imageFile!.path.split('/').last;
      var request = http.MultipartRequest('POST', Uri.parse('https://www.aaservicek.com/servicek_backend/actions/upload_image.php'));
      request.files.add(await http.MultipartFile.fromPath(
          'file', imageFile!.path,
          filename: fileName,
          ),
      );
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






}