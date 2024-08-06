import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:servicek/src/pages/client/products/list/client_products_list_comercios_page.dart';

import '../../models/product.dart';

class ComerciosPage extends StatefulWidget {
  @override
  _ComerciosPageState createState() => _ComerciosPageState();
}

class _ComerciosPageState extends State<ComerciosPage> {
  static const ROOT = 'https://www.aaservicek.com/servicek_backend/actions/categories_actions.php';
  static const ROOT2 = 'https://www.aaservicek.com/servicek_backend/actions/comercios_actions.php';
  static const _CATEGORIES_ACTION = 'SEL_CAT';
  static const _COMERCIOS_ACTION = 'SEL_COM';
  static const _PRODUCTOS_ACTION = 'SEL_PRD_BY_COMERCIO';
  static const IMAGE_BASE_URL = 'https://www.aaservicek.com/servicek_images/logoscomercios/';

  String? selectedCategory;
  List<Category> categories = [];
  List<Comercio> comercios = [];
  final GetStorage _box = GetStorage();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCategories().then((data) {
      setState(() {
        categories = data;
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
      print('fetchCategories() - error: $e');
      return [];
    }
  }

  Future<List<Comercio>> fetchComercios(String categoryId) async {
    try {
      var map = Map<String, dynamic>();
      map['action'] = _COMERCIOS_ACTION;
      map['idCategory'] = categoryId;

      Uri uri = Uri.parse(ROOT2);
      final response = await http.post(uri, body: map);

      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((data) => Comercio.fromJson(data)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('fetchComercios() - error: $e');
      return [];
    }
  }

  Future<List<Product>> fetchProductos(String comercioId) async {
    try {
      var map = Map<String, dynamic>();
      map['action'] = _PRODUCTOS_ACTION;
      map['idComercio'] = comercioId;

      Uri uri = Uri.parse(ROOT2);
      final response = await http.post(uri, body: map);

      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((data) => Product.fromJson(data)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('fetchProductos() - error: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Selección de Categoría',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.amber,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/fondoCategorias.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildCategoryDropdown(),
            ),
            Expanded(
              child: selectedCategory == null
                  ? _buildInitialState()
                  : isLoading
                      ? Center(child: CircularProgressIndicator())
                      : comercios.isEmpty
                          ? _buildEmptyState()
                          : _buildComerciosList(),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInitialState() {
  return Center(
    child: Text(
      'Seleccione una categoría para ver los comercios disponibles',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(
            blurRadius: 10.0,
            color: Colors.black,
            offset: Offset(2.0, 2.0),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    ),
  );
}

  Widget _buildInitialState3() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/img/CategoriasFondo.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            Text(
              'Seleccione una categoría',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.amber,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text('Seleccionar categoría'),
          value: selectedCategory,
          items: categories.map((Category category) {
            return DropdownMenuItem<String>(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedCategory = newValue;
              isLoading = true;
              if (newValue != null) {
                fetchComercios(newValue).then((data) {
                  setState(() {
                    comercios = data;
                    comercios.sort((a, b) => a.name.compareTo(b.name)); // Ordenar alfabéticamente
                    isLoading = false;
                  });
                });
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/img/cero-items.png',
            width: 150,
            height: 150,
          ),
          SizedBox(height: 20),
          Text(
            '¡Ups! No hay comercios disponibles',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.amber,
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            'Por favor, seleccione otra categoría',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComerciosList() {
    return ListView.builder(
      itemCount: comercios.length,
      itemBuilder: (context, index) => _buildComercioItem(comercios[index]),
    );
  }

  Widget _buildComercioItem(Comercio comercio) {
    String? imageUrl = comercio.image != null
        ? IMAGE_BASE_URL + comercio.image
        : null;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToProductList(comercio),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      color: Colors.amber,
                      child: Icon(Icons.store, color: Colors.white, size: 50),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comercio.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      comercio.description,
                      style: TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.arrow_forward_ios, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProductList(Comercio comercio) async {
    final List<Product> products = await fetchProductos(comercio.id);

    final List<Map<String, dynamic>> productsData = products.map((product) => product.toJson()).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientProductsListComerciosPage(
          productsData: productsData,
          comercioName: comercio.name,
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

class Comercio {
  final String id;
  final String name;
  final String description;
  final String image;

  Comercio({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  factory Comercio.fromJson(Map<String, dynamic> json) {
    return Comercio(
      id: json['id'] ?? '',
      name: json['nombre'] ?? '',
      description: json['descripcion'] ?? '',
      image: json['image'] ?? '',
    );
  }
}