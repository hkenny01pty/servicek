import 'dart:convert';
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';
import 'package:servicek/src/models/user.dart';
import '../environment/environment.dart';
import '../models/category.dart';
import '../models/response_api.dart';
import 'package:http/http.dart' as http;

class CategoriesProvider extends GetConnect {

  String url = Environment.API_URL + 'api/categories';
  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  //***************************************************************************************
  Future<List<Category>> getAll() async {
    try {
      Response response = await get(
          '$url/getAll',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': userSession.sessiontoken ?? ''
          }
      );

      if (response.statusCode == 401) {
        Get.snackbar('Petición Denegada', 'Usuario sin permiso');
        return [];
      }

      if (response.statusCode == 200 && response.body != null) {
        if (response.body is List) {
          List<Category> categories = Category.fromJsonList(response.body);
          return categories;
        } else {
          // La respuesta no es una lista, devolver una lista vacía
          print('Error: La respuesta no es una lista');
          return [];
        }
      } else {
        // La respuesta no es exitosa o es nula, devolver una lista vacía
        print('Error: Código de respuesta no exitoso o respuesta nula');
        return [];
      }
    } catch (e) {
      // Captura cualquier error en la llamada a la API
      print('Error fetching categories: $e');
      return [];
    }
  }

  //***************************************************************************************
  Future<ResponseApi> create(Category category) async {
    Response response = await post(
        '$url/create',
        category.toJson(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessiontoken ?? ''
        }
    );
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }
//***************************************************************************************
}
