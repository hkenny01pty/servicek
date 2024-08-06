import 'dart:convert';
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';
import 'package:servicek/src/models/user.dart';
import '../environment/environment.dart';
import '../models/response_api.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';


class UsersProvider extends GetConnect {

  String url = Environment.API_URL + 'api/users';
  User userSession = User.fromJson(GetStorage().read('user') ?? {});

//***************************************************************************************
  Future<Response> create(User user) async {
    Response response = await post(
        '$url/create',
        user.toJson(),
        headers: {
          'Content-Type': 'application/json'
        }
    );
    return response;
  }
//****************************** sin image *********************************************************
  Future<ResponseApi> update(User user) async {
    userSession.sessiontoken = userSession.sessiontoken;
    Response response = await put(
        '$url/updateWithoutImage',
        user.toJson(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessiontoken ?? ''

        }
    );
    if(response.body == null ){
      Get.snackbar('user_provider Error', 'No se puede Update del registro');
      return ResponseApi(success: false, message: '', data: null);
    };

    if(response.statusCode == 401){
      Get.snackbar('user_provider Error', 'No esta autorizado a realizar esta acción');
      return ResponseApi(success: false, message: '', data: null);

    }

    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    return responseApi;
  }
  //******************************* con image ********************************************************
  Future<Stream> updateWithImage(User user, File image) async {
    Uri uri = Uri.http(Environment.API_URL_OLD, '/api/users/updateWithImage');
    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = userSession.sessiontoken ?? '';
    request.files.add(http.MultipartFile(
        'image',
        http.ByteStream(image.openRead().cast()),
        await image.length(),
        filename: basename(image.path)
    ));
    request.fields['user'] = json.encode(user);
    final response = await request.send();
    return response.stream.transform(utf8.decoder);
  }
   //*******************************  xxxxxxx ********************************************************
  Future<http.Response> updateWithImagexxx(User user, File image) async {
    Uri uri = Uri.http(Environment.API_URL_OLD, '/api/users/update');
    var request = http.MultipartRequest('PUT', uri);
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    request.fields['id'] = user.id.toString();
    request.fields['name'] = user.name!;
    request.fields['lastname'] = user.lastname!;
    request.fields['phone'] = user.phone!;

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);

    return http.Response(responseString, response.statusCode);
  }

//***************************************************************************************
  Future<Stream> createWithImage(User user, File image) async {
    Uri uri = Uri.http(Environment.API_URL_OLD, '/api/users/createWithImage');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(http.MultipartFile(
        'image',
        http.ByteStream(image.openRead().cast()),
        await image.length(),
        filename: basename(image.path)
    ));
    request.fields['user'] = json.encode(user);
    final response = await request.send();
    return response.stream.transform(utf8.decoder);
  }
//***************************************************************************************
  Future<ResponseApi> login(String email, String password) async {
    Response response = await post(
       // '$url/findByEmail',
        '$url/login',
        {
          'email': email,
          'password': password
        },
        headers: {
          'Content-Type': 'application/json'
        }
    );

    if(response.body == null){
      Get.snackbar('user_provider Error', 'No se puede ejecutar la petición');
      return ResponseApi(success: false, message: 'No se puede ejecutar la petición LOGIN', data: null);
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    return responseApi;
  }
//***************************************************************************************


}