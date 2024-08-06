import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../../../models/category.dart';
import '../mec/restaurant_products_mec_page.dart';
import 'restaurant_products_create_controller.dart';

class RestaurantProductsCreatePage extends StatefulWidget {
  @override
  _RestaurantProductsCreatePageState createState() => _RestaurantProductsCreatePageState();
}

class _RestaurantProductsCreatePageState extends State<RestaurantProductsCreatePage> {
  static const ROOT = 'https://www.aaservicek.com/servicek_backend/actions/categories_actions.php';
  static const _CATEGORIES_ACTION = 'SEL_CAT';

  RestaurantProductsCreateController con = Get.put(RestaurantProductsCreateController());
  String? selectedCategory;
  List<Category> categories = [];
  final GetStorage _box = GetStorage();

  @override
  void initState() {
    super.initState();
    fetchCategories().then((data) {
      setState(() {
        categories = data;
        if (categories.isNotEmpty) {
          con.idCategory = categories.first.id;
        }
      });
    });
  }

  Future<List<Category>> fetchCategories() async {
    try {
      final userJson = _box.read('user');
      Map<String, dynamic> user = userJson != null ? Map<String, dynamic>.from(userJson) : {};
      final userId = user['user']['id'];

      var map = Map<String, dynamic>();
      map['action'] = _CATEGORIES_ACTION;
      map['idUser'] = userId;
      Uri uri = Uri.parse(ROOT);
      final response = await http.post(uri, body: map);
      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((data) => Category.fromJson(data)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _backgroundCover(context),
          _boxForm(context),
          _textNewCategory(context),
        ],
      ),
    );
  }

  Widget _backgroundCover(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.35,
      color: Colors.amber,
    );
  }

  Widget _boxForm(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.13, left: 50, right: 50),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black54,
                blurRadius: 15,
                offset: Offset(0, 0.75)
            )
          ]
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _textYourInfo(),
            _textFieldName(),
            _textFieldDescription(),
            _textFieldPrice(),
            _dropDownCategories(categories),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  GetBuilder<RestaurantProductsCreateController>(
                      builder: (value) => _cardImage(context, con.imageFile1, 1)
                  ),
                  SizedBox(width: 7),
                  GetBuilder<RestaurantProductsCreateController>(
                      builder: (value) => _cardImage(context, con.imageFile2, 2)
                  ),
                  SizedBox(width: 7),
                  GetBuilder<RestaurantProductsCreateController>(
                      builder: (value) => _cardImage(context, con.imageFile3, 3)
                  ),
                ],
              ),
            ),
            _buttonCreate(context),
            _buttonEdit(context),
          ],
        ),
      ),
    );
  }

  Widget _textFieldName() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: con.nameController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            hintText: 'Nombre',
            prefixIcon: Icon(Icons.category_sharp)
        ),
      ),
    );
  }

  Widget _textFieldPrice() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: con.priceController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            hintText: 'Precio',
            prefixIcon: Icon(Icons.attach_money_rounded)
        ),
      ),
    );
  }

  Widget _textFieldDescription() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: con.descriptionController,
        keyboardType: TextInputType.text,
        maxLines: 3,
        decoration: InputDecoration(
            hintText: 'Descripción',
            prefixIcon: Container(
                margin: EdgeInsets.only(bottom: 50),
                child: Icon(FontAwesomeIcons.list)
            )
        ),
      ),
    );
  }

  Widget _dropDownCategories(List<Category> categories) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      margin: EdgeInsets.only(top: 15),
      child: GetBuilder<RestaurantProductsCreateController>(
        builder: (controller) => DropdownButton<String>(
          underline: Container(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.arrow_drop_down_circle,
              color: Colors.amber,
            ),
          ),
          elevation: 3,
          isExpanded: true,
          hint: Text(
            'Seleccionar categoría',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          value: selectedCategory,
          items: _dropDownItems(categories),
          onChanged: (option) {
            setState(() {
              selectedCategory = option;
              con.idCategory = option;
            });
            print('Opción seleccionada $option');
          },
        ),
      ),
    );
  }


  List<DropdownMenuItem<String>> _dropDownItems(List<Category> categories) {
    return categories.map((category) {
      return DropdownMenuItem<String>(
        child: Text(category.name),
        value: category.id.toString(),
      );
    }).toList();
  }

  Widget _cardImage(BuildContext context, File? imageFile, int numberFile){
    return GestureDetector(
      onTap: () => con.showAlertDialog(context, numberFile),
      child: Card(
        elevation: 3,
        child: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[200],
          ),
          child: Center(
            child: imageFile != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                imageFile,
                fit: BoxFit.cover,
                width: 70,
                height: 70,
              ),
            )
                : Image(
              image: AssetImage('assets/img/cover_image.png'),
              fit: BoxFit.cover,
              width: 70,
              height: 70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonCreate(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: ElevatedButton(
          onPressed: () => con.createProduct(context),
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15)
          ),
          child: Text(
            'Crear Producto ',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 17
            ),
          )
      ),
    );
  }


  Widget _buttonEdit(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 1),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>ProductListPage()), // Reemplaza RestaurantProductsMecPage con la página real si es diferente
          );
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          'Editar Producto ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
    );
  }


  Widget _textNewCategory(BuildContext context) {
    return SafeArea(
      child: Container(
          margin: EdgeInsets.only(top: 18),
          alignment: Alignment.topCenter,
          child: Text(
            'NUEVO PRODUCTO',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 25
            ),
          )
      ),
    );
  }

  Widget _textYourInfo() {
    return Container(
      margin: EdgeInsets.only(top: 40, bottom: 30),
      child: Text(
        'INGRESA ESTA INFORMACION',
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 17
        ),
      ),
    );
  }
}

class Category {
  final String id;
  final String name;
  final String description;

  Category({required this.id, required this.name, required this.description});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}
