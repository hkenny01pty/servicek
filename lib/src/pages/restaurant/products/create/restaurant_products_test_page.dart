import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class RestaurantProductsTestPage extends StatefulWidget {
  @override
  _RestaurantProductsTestPageState createState() => _RestaurantProductsTestPageState();
}

class _RestaurantProductsTestPageState extends State<RestaurantProductsTestPage> with SingleTickerProviderStateMixin {
  static const ROOT = 'https://www.aaservicek.com/servicek_backend/actions/categories_actions.php';
  static const _CATEGORIES_ACTION = 'SEL_CAT';

  String? selectedCategory;
  List<Category> categories = [];
  final GetStorage _box;
  TabController? _tabController;

  _RestaurantProductsTestPageState() : _box = GetStorage();

  @override
  void initState() {
    super.initState();
    fetchCategories().then((data) {
      setState(() {
        categories = data;
        _tabController = TabController(length: categories.length, vsync: this);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Selección de Categoría'),
          bottom: categories.isEmpty
              ? null
              : TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: categories.map((Category category) {
              return Tab(text: category.name);
            }).toList(),
          ),
        ),
        body: categories.isEmpty
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
          controller: _tabController,
          children: categories.map((Category category) {
            return Center(
              child: Text('Productos de la categoría: ${category.name}'),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<List<Category>> fetchCategories() async {
    try {
      final userJson = _box.read('user');
      Map<String, dynamic> user = userJson != null ? Map<String, dynamic>.from(userJson) : {};
      final userId = user['user']['id']; // Obtener el valor del id del usuario

      var map = Map<String, dynamic>();
      map['action'] = _CATEGORIES_ACTION;
      map['idUser'] = userId; // Agregar el parámetro idUser con el valor obtenido
      Uri uri = Uri.parse(ROOT);
      final response = await http.post(uri, body: map);
      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((data) => Category.fromJson(data)).toList();
      } else {
        return []; // Devuelve una lista vacía en caso de error
      }
    } catch (e) {
      return []; // Devuelve una lista vacía en caso de excepción
    }
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
