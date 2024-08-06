import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../environment/environment.dart';
import '../models/product.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'package:path/path.dart';


class ProductsProvider extends GetConnect{
  static const ROOT = 'https://www.aaservicek.com/servicek_backend/actions/user_actions.php';
  static const _PRODUCTS_ACTION = 'ADD_PRD';

  File? imageFile;
  User userSession = User.fromJson(GetStorage().read('user') ?? {});

//***************************************************************************************

  Future<List> create(Product product, List<File> images) async {
    try {
      var map = Map<String, dynamic>();
      map['action'] = _PRODUCTS_ACTION;
      map['product'] = product;
      map['images'] = images;
      Uri uri = Uri.parse(ROOT);
      final response = await http.post(uri, body: map);
      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((data) => Product.fromJson(data)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

//***************************************************************************************
  Future<void> subirImagen(userId, context) async {
    if (imageFile != null) {
      String fileName = imageFile!.path.split('/').last;
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://www.aaservicek.com/servicek_backend/actions/upload_image_products.php'));
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
//***************************************************************************************

  Future<List<Product>> findByCategory(String idCategory) async {
    Response response = await get(
        '$url/findByCategory/$idCategory',
        headers: {
          'Content-Type': 'application/json',
          //'Authorization': userSession.session_token ?? ''
        }
    );
    if(response.statusCode == 401){
      Get.snackbar(('Petición Denegada'), 'Usuario sin permiso');
      return [];
    }
    List<Product> products = Product.fromJsonList(response.body);
    return products;
  }
//***************************************************************************************


}