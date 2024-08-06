import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicek/src/pages/client/products/list/client_products_list_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

import 'package:servicek/src/models/product.dart';
import 'package:servicek/src/models/category.dart';

import '../../orders/create/client_order_create_controller.dart';
import '../../orders/create/client_order_create_page.dart';
import '../detail/product_datail_page.dart';

class ClientProductsListPage extends StatefulWidget {
  @override
  _ClientProductsListPageState createState() => _ClientProductsListPageState();
}

class _ClientProductsListPageState extends State<ClientProductsListPage> with SingleTickerProviderStateMixin {
  ClientProductsListController con = Get.put(ClientProductsListController());

  static const ROOT = 'https://www.aaservicek.com/servicek_backend/actions/categories_actions.php';
  static const ROOT2 = 'https://www.aaservicek.com/servicek_backend/actions/products_actions.php';
  static const _CATEGORIES_ACTION = 'SEL_CAT';
  static const _PRODUCTS_ACTION = 'SEL_PRD';
  static const IMAGE_BASE_URL = 'https://www.aaservicek.com/servicek_images/products/';

  List<Category> categories = [];
  List<Product> products = [];
  final GetStorage _box = GetStorage();
  TabController? _tabController;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final data = await fetchCategories();
      if (mounted) {
        setState(() {
          categories = data;
          _tabController?.dispose();
          _tabController = TabController(length: categories.length, vsync: this);
          _tabController?.addListener(_handleTabSelection);
        });

        if (categories.isNotEmpty) {
          await fetchProducts(categories[0].id ?? '');
        }
      }
    } catch (e) {
      print('Error al cargar datos: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Error al cargar datos. Por favor, intente de nuevo.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  void _handleTabSelection() {
    if (_tabController != null && _tabController!.index != _tabController!.previousIndex) {
      print('Cambiando a la categoría: ${categories[_tabController!.index].name}');
      fetchProducts(categories[_tabController!.index].id ?? '');
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'xSelección de Categoría',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          bottom: categories.isEmpty
              ? null
              : PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white.withOpacity(0.3),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(fontSize: 16),
              tabs: categories.map((Category category) {
                return Tab(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black26, width: 1),
                    ),
                    child: Text(category.name ?? ''),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : categories.isEmpty
            ? Center(child: Text('No hay categorías disponibles'))
            : TabBarView(
          controller: _tabController,
          children: categories.map((Category category) {
            return _buildProductGrid();
          }).toList(),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "btn1",
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.shopping_bag, color: Colors.green, size: 30),
              onPressed: () {
                ClientOrdersCreateController con = Get.put(ClientOrdersCreateController());
                con.selectedProducts = products;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClientOrderCreatePage(),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            FloatingActionButton(
              heroTag: "btn2",
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.delete_forever, color: Colors.red, size: 30),
              onPressed: () {
                _showConfirmationDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildProductGrid() {
    return products.isEmpty
        ? Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/cero-items.png',
              width: 100,
              height: 100,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No hay productos que mostrar en esta categoría',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    )
        : GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final imageUrl = IMAGE_BASE_URL + product.image1!;
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              _showProductTooltip(context, product);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Tooltip(
                    message: product.description,
                    child: Text(
                      product.name!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('\$${product.price}', style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
          ),
        );
      },
    );
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
        if (jsonResponse == null || !(jsonResponse is List)) {
          throw 'No se pudieron cargar las categorías.';
        }
        return jsonResponse.map((data) => Category.fromJson(data)).toList();
      } else {
        throw 'No se pudieron cargar las categorías.';
      }
    } catch (e) {
      print('Error al cargar categorías: $e');
      throw e;
    }
  }


  Future<void> fetchProducts(String categoryId) async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      var map = Map<String, dynamic>();
      map['action'] = _PRODUCTS_ACTION;
      map['id_category'] = categoryId;
      Uri uri = Uri.parse(ROOT2);
      final response = await http.post(uri, body: map);
      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            products = jsonResponse.map((data) => Product.fromJson(data)).toList();
            isLoading = false;
          });
        }
        print('Productos cargados para la categoría $categoryId. Longitud: ${products.length}');

        if (products.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No hay productos en esta categoría.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw 'No se pudieron cargar los productos.';
      }
    } catch (e) {
      print('Error al cargar productos: $e');
      if (mounted) {
        setState(() {
          products = [];
          errorMessage = 'Error al cargar productos. Verifique su conexión.';
          isLoading = false;
        });
      }
    }
  }


  void _showProductTooltip(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product.name!),
          content: Text(product.description!),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(product: product),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: Text('¿Estás seguro de que deseas eliminar todos los productos de la lista?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Aceptar'),
              onPressed: () async {
                Navigator.of(context).pop();

                // Limpiar la lista de productos en GetStorage
                await _box.remove('order');

                // Limpiar la lista de productos en el estado
                setState(() {
                  products.clear();
                });

                // Imprimir para verificar
                print('Lista de productos eliminada. Longitud actual: ${products.length}');

                // Recargar los productos de la categoría actual
                if (categories.isNotEmpty && _tabController != null) {
                  await fetchProducts(categories[_tabController!.index].id ?? '');
                }

                // Mostrar un mensaje de confirmación
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lista de productos eliminada')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}