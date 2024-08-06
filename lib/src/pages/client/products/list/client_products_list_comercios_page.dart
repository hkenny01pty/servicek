import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicek/src/pages/client/products/list/client_products_list_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'package:servicek/src/models/product.dart';
import '../../orders/create/client_order_create_controller.dart';
import '../../orders/create/client_order_create_page.dart';
import '../detail/product_datail_page.dart';
import 'customer_bottom_bar.dart';

class ClientProductsListComerciosPage extends StatefulWidget {
  final List<dynamic> productsData;
  final String comercioName;

  ClientProductsListComerciosPage({required this.productsData, required this.comercioName});

  @override
  _ClientProductsListComerciosPageState createState() => _ClientProductsListComerciosPageState();
}

class _ClientProductsListComerciosPageState extends State<ClientProductsListComerciosPage> {
  ClientProductsListController con = Get.put(ClientProductsListController());
  final GetStorage _box = GetStorage();
  static const IMAGE_BASE_URL = 'https://www.aaservicek.com/servicek_images/logoscomercios/';

  late List<Product> products;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    products = widget.productsData.map((data) => Product.fromJson(data)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Comercio:  ${widget.comercioName}',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _buildProductGrid(),
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

      bottomNavigationBar: CustomBottomBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),

    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Aquí puedes agregar la lógica para navegar a diferentes páginas
    // dependiendo del índice seleccionado
  }


  Widget _buildProductGrid() {
    return products.isEmpty
        ? Center(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/img/cero-items.png',
                      width: 100,
                      height: 100,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No hay productos que mostrar en este Comercio',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          )
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            padding: EdgeInsets.all(10),
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
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/img/no-image.png',
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name!,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '\$${product.price?.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
  void _showProductTooltip(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product.name!),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.description!),
                SizedBox(height: 16),
                Text(
                  'Precio: \$${product.price?.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ver detalles'),
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
                await _box.remove('order');
                setState(() {
                  // No podemos limpiar widget.products ya que es final
                  // En su lugar, mostramos un mensaje
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lista de productos eliminada del carrito')),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }
}