
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:servicek/src/models/response_api.dart';
import 'package:servicek/src/providers/category_providers.dart';
import 'package:http/http.dart' as http;

import '../../../../models/category.dart';
import '../../../../models/response_api.dart';
import '../../../../providers/category_providers.dart';

class RestaurantCategoriesCreateController extends GetxController{

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  CategoriesProvider categoriesProvider = CategoriesProvider();

  static const ROOT = 'https://www.aaservicek.com/servicek_backend/actions/categories_actions.php';
  static const _CREATE_TABLE_ACTION = 'CREATE_TABLE';
  static const _GET_ALL_ACTION = 'GET_ALL';
  static const _ADD_CAT_ACTION = 'ADD_CAT';
  static const _UPDATE_USR_ACTION = 'UPDATE_USR';
  static const _DELETE_USR_ACTION = 'DELETE_USR';


  void createCategory(BuildContext context) async {
    String name = nameController.text;
    String description = descriptionController.text;

    Map<String, dynamic> userData = GetStorage().read('user') ?? {};
    Map<String, dynamic> userMap = userData['user'] ?? {};
    String id_user = userMap['id'] ?? '';

    print(id_user);

    if (isValidForm(name, description)) {
      //Get.snackbar('Formulario valido', 'ok..');
      if (description != null) {
        try {
          String result = await addCategories(
            name,
            description,
            id_user
          );

          if (result.contains("Ya existe una categoria con el mismo nombre")) {
            Get.snackbar('Error', result);
          } else if (result.contains("Categoria registrada correctamente")) {
            //Get.snackbar('Categoria registrada', result);
            Get.snackbar('Categoria registrada', 'Registro Correcto');
            clearForm();
            //goToHomePage();
          } else {
            Get.snackbar('Error', 'No se pudo registrar la Categoría');
          }
        } catch (e) {
          Get.snackbar('Error', 'No se pudo realizar ninguna de las operaciones');
        }
      }
    }
  }

  static Future<String> addCategories(
      String name,
      String description,
      String id_user,
      ) async {
    try {
      var map = Map<String, dynamic>();
      map['action'] = _ADD_CAT_ACTION;
      map['name'] = name;
      map['description'] = description;
      map['id_user'] = id_user;

      Uri uri = Uri.parse(ROOT);

      final response = await http.post(uri, body: map);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "_ADD_CAT_ACTION error";
      }
    } catch (e) {
      return "_ADD_CAT_ACTION .. error";
    }
  }

  bool isValidForm(String name, String description) {
    if (name.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar un nombre');
      return false; // Retorna false si el nombre está vacío
    }

    if (description.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar una descripción');
      return false; // Retorna false si la descripción está vacía
    }

    return true;
  }

/*
  void createCategory() async {
    String name = nameController.text;
    String description = descriptionController.text;

    if(name.isNotEmpty && description.isNotEmpty){
      Category category = Category(
        name: name,
        description: description, id: ''
      );
      ResponseApi responseApi = await categoriesProvider.create(category);
      Get.snackbar('Proceso Terminado', responseApi.message ?? '');
      if(responseApi.success == true){
        clearForm();
      }
    }
    else {
      Get.snackbar('Formulario no Válido', 'Ingresa todos los campos para crear la Categorìa');
    }
  }
*/

  void goToHomePage() {
    Get.offNamedUntil('/', (route) => false);
    //Get.offNamedUntil('/home', (route) => false);
    //Get.offNamedUntil(  '/client/products/list', (route) => false);
  }

  void clearForm(){
    nameController.text = '';
    descriptionController.text = ' ';

  }
}
