import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product {
  String? id;
  String? name;
  String? description;
  String? image1;
  String? image2;
  String? image3;
  String? idCategory;
  double? price;
  int? quantity;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.image1,
    required this.image2,
    required this.image3,
    required this.idCategory,
    required this.price,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double? price;
    if (json['price'] is String) {
      price = double.tryParse(json['price']);
    } else if (json['price'] is num) {
      price = (json['price'] as num).toDouble();
    }

    return Product(
      id: json["id"].toString(),
      name: json["name"],
      description: json["description"],
      image1: json["image1"],
      image2: json["image2"],
      image3: json["image3"],
      idCategory: json["id_category"],
      price: price,
      quantity: json["quantity"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "image1": image1,
    "image2": image2,
    "image3": image3,
    "id_category": idCategory,
    "price": price,
    "quantity": quantity,
  };
}

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: ProductListPage(),
    );
  }
}

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<Product>> futureProducts;
  late Future<List<Category>> futureCategories;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = 'All';
    futureCategories = fetchCategories();
    futureProducts = fetchProducts();
  }

  Future<List<Category>> fetchCategories() async {
    final response = await http.post(
      Uri.parse('https://www.aaservicek.com/servicek_backend/actions/categories_actions.php'),
      body: {
        'action': 'SEL_CAT',
        'idUser': '1', // Reemplaza esto con el ID de usuario real
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<Category> categories = body.map((dynamic item) => Category.fromJson(item)).toList();
      categories.insert(0, Category(id: 'All', name: 'All'));
      return categories;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(
        'https://www.aaservicek.com/servicek_backend/actions/products_actions.php?&action=GET_ALL2'));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<Product> products = body.map((dynamic item) => Product.fromJson(item)).toList();

      if (selectedCategory != 'All') {
        products = products.where((product) => product.idCategory == selectedCategory).toList();
      }

      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }

  void updateProduct(Product product) async {
    final response = await http.post(
      Uri.parse('https://www.aaservicek.com/servicek_backend/actions/products_actions.php?&action=UPDATE_PRD'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 200) {
      setState(() {
        futureProducts = fetchProducts();
      });
    } else {
      throw Exception('Failed to update product');
    }
  }

  void deleteProduct(String id) async {
    final response = await http.post(
      Uri.parse('https://www.aaservicek.com/servicek_backend/actions/products_actions.php?&action=DELETE_PRD'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode == 200) {
      setState(() {
        futureProducts = fetchProducts();
      });
    } else {
      throw Exception('Failed to delete product');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.amber.shade100,
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder<List<Category>>(
              future: futureCategories,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return DropdownButton<String>(
                    value: selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                        futureProducts = fetchProducts();
                      });
                    },
                    items: snapshot.data!.map<DropdownMenuItem<String>>((Category category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Failed to load categories');
                }
                return CircularProgressIndicator();
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: futureProducts,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Product product = snapshot.data![index];
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.all(8),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${product.id}: ${product.name}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, size: 20),
                                        onPressed: () {
                                          // Editing functionality
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, size: 20),
                                        onPressed: () {
                                          deleteProduct(product.id!);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(product.description!),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildProductImage(product.image1),
                                  _buildProductImage(product.image2),
                                  _buildProductImage(product.image3),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load products'));
                }

                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    return Container(
      width: MediaQuery.of(context).size.width / 3 - 20,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl != null ? 'https://www.aaservicek.com/servicek_images/products/$imageUrl' : 'assets/no-image.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/no-image.png',
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }
}