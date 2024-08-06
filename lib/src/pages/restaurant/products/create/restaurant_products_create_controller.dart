import 'dart:convert';
import 'dart:io';
//import 'dart:js';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:servicek/src/models/product.dart';
import 'package:servicek/src/models/response_api.dart';
import 'package:servicek/src/providers/category_providers.dart';
import '../../../../models/category.dart';
import '../../../../models/user.dart';
import '../../../../providers/products_providers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class RestaurantProductsCreateController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  CategoriesProvider categoriesProvider = CategoriesProvider();

  ImagePicker picker = ImagePicker();
  File? imageFile1;
  File? imageFile2;
  File? imageFile3;

  String? idCategory;
  // var idCategory = ''.obs;

  static const ROOT2 = 'https://www.aaservicek.com/servicek_backend/actions/products_actions.php';
  static const _PRODUCTS_ACTION = 'ADD_PRD';

  List<Category> categories = <Category>[].obs;
  ProductsProvider productsProvider = ProductsProvider();

  File? imageFile;
  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  @override
  void onInit() {
    super.onInit();
    getCategories();
  }

  RestaurantProductsCreateController() {
    // getCategories();
  }

  void getCategories() async {
    var result = await categoriesProvider.getAll();

    categories.clear();
    categories.addAll(result);
  }

  void createProduct(BuildContext context) async {
    String name = nameController.text;
    String description = descriptionController.text;
    String priceString = priceController.text;

    print('NAME: ${name}');
    print('DESCRIPCION: ${description}');
    print('PRICE: ${priceString}');
    print('ID CATEGORIA: ${idCategory}');

    ProgressDialog progressDialog = ProgressDialog(context: context);

    if (isValidForm(name, description, priceString)) {
      double? price;
      try {
        price = double.parse(priceString);
      } catch (e) {
        print('Error al convertir el precio a double: $e');
        return;
      }

      List<File> images = [];
      images.add(imageFile1!);
      images.add(imageFile2!);
      images.add(imageFile3!);

      Product product = Product(
        id: ' ',
        name: name,
        description: description,
        image1: imageFile1?.path ?? 'Sin imagen',
        image2: imageFile2?.path ?? 'Sin imagen',
        image3: imageFile3?.path ?? 'Sin imagen',
        idCategory: idCategory,
        price: price,
        quantity: 0,
      );

      progressDialog.show(max: 100, msg: 'Espere un momento...');

      await create1(product, images);
      //await create2(product, images);
      //await create3(product, images);

      progressDialog.close();
    }
  }

  Future<void> create1(Product product, List<File> images) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(ROOT2));
      request.fields['action'] = _PRODUCTS_ACTION;
      request.fields['product'] = jsonEncode(product.toJson());

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      // Imprimir la respuesta del servidor antes de intentar decodificarla
      print('Respuesta del servidor (raw): $responseData');
      if (response.statusCode == 200) {
        // Verificar si la respuesta es un JSON válido
        try {
          var jsonResponse = jsonDecode(responseData);
          print('Respuesta del servidor (JSON): $jsonResponse');

          if (jsonResponse['success'] == true) {
            int productId = jsonResponse['product_id'];
            print('ID del producto creado: $productId');
            var img123 = 0;
            for (var imageFile in images) {
              img123 = img123 + 1;
              await subirImagen(imageFile,productId.toString(), img123.toString());//, productId.toString(), img123 as String);
            }
            clearForm();
          } else {
            print('Error en la respuesta del servidor: ${jsonResponse['message']}');
          }
        } catch (e) {
          // Si no es un JSON válido, manejarla como texto plano
          print('Respuesta del servidor (texto plano): $responseData');
          // Aquí puedes agregar lógica para manejar el texto plano según sea necesario
        }
      } else {
        print('Error en la petición: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la función create: $e');
    }
  }

  Future<void> subirImagen(imageFile, productId, img123) async{ //, String productId, String img123) async {
    if (imageFile != null) {
      String fileName = imageFile.path.split('/').last;
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://www.aaservicek.com/servicek_backend/actions/upload_image_products.php'));
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: fileName,
      ));

      request.fields['productId'] = productId;  // Agregando el parámetro productId
      request.fields['img123'] = img123;  // Agregando el parámetro img123

      var response = await request.send();
      if (response.statusCode == 200) {
        print('Imagen cargada correctamente: $imageFile');
      } else {
        print('Error cargando imagen: $imageFile');
      }
    } else {
      print('No se ha seleccionado ninguna imagen: $imageFile');
    }
  }

  bool isValidForm(String name, String description, String price) {
    if (name.isEmpty) {
      Get.snackbar('Formulario no valido', 'Nombre no debe estar vacío ');
      return false;
    }
    if (description.isEmpty) {
      Get.snackbar('Formulario no valido', 'Descripción no debe estar vacía ');
      return false;
    }
    if (price.isEmpty) {
      Get.snackbar('Formulario no valido', 'Precio no debe estar vacío ');
      return false;
    }
    if (idCategory == null) {
      Get.snackbar('Formulario no valido', 'Selecciona la Categoría, no debe estar vacío ');
      return false;
    }
    if (imageFile1 == null) {
      Get.snackbar('Formulario no valido', 'Selecciona la Imagen número 1 del producto');
      return false;
    }
    if (imageFile2 == null) {
      Get.snackbar('Formulario no valido', 'Selecciona la Imagen número 2 del producto');
      return false;
    }
    if (imageFile3 == null) {
      Get.snackbar('Formulario no valido', 'Selecciona la Imagen número 3 del producto');
      return false;
    }

    return true;
  }

  Future selectImage(ImageSource imageSource, int numberFile) async {
    XFile? image = await picker.pickImage(source: imageSource);
    if (image != null) {
      if (numberFile == 1) {
        imageFile1 = File(image.path);
      } else if (numberFile == 2) {
        imageFile2 = File(image.path);
      } else if (numberFile == 3) {
        imageFile3 = File(image.path);
      }
      update();
    }
  }

  void showAlertDialog(BuildContext context, int numberFile) {
    Widget galleryButton = ElevatedButton(
        onPressed: () {
          Get.back();
          selectImage(ImageSource.gallery, numberFile);
        },
        child: Text(
          'Galería',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
        ));

    Widget cameraButton = ElevatedButton(
        onPressed: () {
          Get.back();
          selectImage(ImageSource.camera, numberFile);
        },
        child: Text(
          'Cámara',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
        ));

    AlertDialog alertDialog = AlertDialog(
      title: Text(
        'Selecciona una opción',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      actions: [galleryButton, cameraButton],
    );

    showDialog(context: context, builder: (BuildContext context) {
      return alertDialog;
    });
  }

  void clearForm() {
    nameController.text = '';
    descriptionController.text = '';
    priceController.text = '';
    imageFile1 = null;
    imageFile2 = null;
    imageFile3 = null;
    idCategory = '';
    update();
  }


}
