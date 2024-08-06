import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:servicek/src/models/product.dart';
import 'package:servicek/src/pages/client/orders/create/client_order_create_controller.dart';
import 'package:servicek/src/widget/no_data_widget.dart';

import '../../address/list/client_address_list_page.dart';

class ClientOrderCreatePage extends StatefulWidget {
  @override
  _ClientOrderCreatePageState createState() => _ClientOrderCreatePageState();
}

class _ClientOrderCreatePageState extends State<ClientOrderCreatePage> {
  final ClientOrdersCreateController con = Get.put(ClientOrdersCreateController());
  final GetStorage _box = GetStorage();
  static const IMAGE_BASE_URL = 'https://www.aaservicek.com/servicek_images/products/';

  List<Product> storedProducts = [];

  @override
  void initState() {
    super.initState();
    _loadStoredProducts();
  }

  void _loadStoredProducts() {
    setState(() {
      storedProducts = (_box.read<List<dynamic>>('order') ?? [])
          .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: storedProducts.isNotEmpty
          ? Container(
        color: Color.fromRGBO(220, 220, 220, 1),
        height: 80,
        child: _buildBottomButtons(),
      )
          : null, // No muestra la barra inferior si no hay productos
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mi Orden',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (storedProducts.isNotEmpty) _buildTotalWidget(),
          ],
        ),
      ),
      body: storedProducts.isNotEmpty
          ? ListView.builder(
        itemCount: storedProducts.length,
        itemBuilder: (context, index) {
          Product product = storedProducts[index];
          return _cardProduct(product, context);
        },
      )
          : _buildNoOrdersWidget(),
    );
  }

  Widget _buildNoOrdersWidget() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 100,
              color: Colors.amber,
            ),
            SizedBox(height: 20),
            Text(
              'No tiene órdenes pendientes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Su pedido está vacío. ¿Desea agregar algunos productos?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              child: Text('Volver a la pantalla anterior'),
              style: ElevatedButton.styleFrom(
                primary: Colors.amber,
                onPrimary: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalWidget() {
    double total = storedProducts.fold(0, (sum, item) => sum + (item.price ?? 0) * (item.quantity ?? 0));
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        'Total: \$${total.toStringAsFixed(2)}',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20, // Increased font size
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    if (storedProducts.isEmpty) {
      return SizedBox.shrink(); // No muestra nada si no hay productos
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              onPressed: storedProducts.isNotEmpty
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClientAddressListPage()),
                );
              }
                  : null, // Deshabilita el botón si no hay productos
              icon: Icon(Icons.location_on, color: Colors.black),
              label: Text(
                'Dirección envío',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBackgroundColor: Colors.grey[300], // Color cuando está deshabilitado
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              onPressed: storedProducts.isNotEmpty
                  ? () {
                _logStoredData();
                _createOrder();
              }
                  : null, // Deshabilita el botón si no hay productos
              icon: Icon(Icons.check_circle, color: Colors.white),
              label: Text(
                'Confirmar Pedido',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBackgroundColor: Colors.grey[300], // Color cuando está deshabilitado
              ),
            ),
          ),
        ),
      ],
    );
  }
  void _logStoredData() {
    print('======== DATOS ALMACENADOS ========');

    print('--- USER ---');
    var user = _box.read('user');
    print(user != null ? user : 'No hay datos de usuario');

    print('\n--- SELECTED ADDRESS ---');
    var selectedAddress = _box.read('selected_address');
    print(selectedAddress != null ? selectedAddress : 'No hay dirección seleccionada');

    print('\n--- ORDER ---');
    var order = _box.read('order');
    print(order != null ? order : 'No hay orden');
    print('\n--- selectedAddress[id_user] ---');
    print(selectedAddress['id_user'].toString());

    print('\n--- SHOPPING BAG ---');
    var shoppingBag = _box.read('Shopping_bag');
    print(shoppingBag != null ? shoppingBag : 'La bolsa de compras está vacía');

    print('===================================');
  }

  void _createOrder() async {
    print('Iniciando creación de orden...');

    var selectedAddress = _box.read('selected_address');
    if (selectedAddress == null) {
      print('Error: No hay dirección seleccionada');
      return;
    }

    var orderData = {
      'action': 'CREATE_ORDER_PND',
      'id_client': selectedAddress['id_user'].toString(),
      'id_delivery': '10',
      'id_address': selectedAddress['id'].toString(),
      'latitud': selectedAddress['latitud'].toString(),
      'longitud': selectedAddress['longitud'].toString(),
      'status': 'Pendiente'
    };

    print('Datos de la orden: $orderData');

    try {
      var response = await http.post(
          Uri.parse('https://www.aaservicek.com/servicek_backend/actions/orders_actions.php'),
          body: orderData
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          print('Orden creada exitosamente. ID de la orden: ${jsonResponse['order_id']}');
          _addOrderProducts(selectedAddress['id_user'].toString(), jsonResponse['order_id'].toString());
        } else {
          print('Error al crear la orden: ${jsonResponse['message']}');
        }
      } else {
        print('Error en la solicitud HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al enviar la solicitud: $e');
    }
  }

  void _addOrderProducts(String idClient, String orderId) async {
    print('Añadiendo productos a la orden...');

    var orderProducts = _box.read('order');
    if (orderProducts == null || orderProducts.isEmpty) {
      print('Error: No hay productos en la orden');
      return;
    }

    var productsData = orderProducts.map((product) => {
      'id_product': product['id'].toString(),
      'quantity': product['quantity'].toString()
    }).toList();

    var orderProductsData = {
      'action': 'ADD_ORDER_PRODUCTS',
      'id_client': idClient,
      'id_order': orderId,
      'products': json.encode(productsData)
    };

    print('Datos de productos de la orden: $orderProductsData');

    try {
      var response = await http.post(
          Uri.parse('https://www.aaservicek.com/servicek_backend/actions/orders_actions.php'),
          body: orderProductsData
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          print('Productos añadidos a la orden exitosamente.');
          _clearOrderFromStorage();
          _showOrderConfirmationDialog();
        } else {
          print('Error al añadir productos a la orden: ${jsonResponse['message']}');
        }
      } else {
        print('Error en la solicitud HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al enviar la solicitud: $e');
    }
  }

  void _clearOrderFromStorage() {
    _box.remove('order');
    setState(() {
      storedProducts = [];
    });
  }

  void _showOrderConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pedido Confirmado'),
          content: Text('Su pedido ha sido creado y enviado con éxito. Gracias por su compra.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to the previous screen
              },
            ),
          ],
        );
      },
    );
  }

  Widget _cardProduct(Product product, BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            _imageProduct(product),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20, // Increased font size
                    ),
                  ),
                  SizedBox(height: 8),
                  _buttonsAddOrRemove(product),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonsAddOrRemove(Product product) {
    double total = (product.quantity ?? 0) * (product.price ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _quantityButton(Icons.remove, () {
                  if (product.quantity! > 1) {
                    setState(() {
                      product.quantity = product.quantity! - 1;
                    });
                    _updateProductQuantity(product);
                  }
                }, Colors.red),
                SizedBox(width: 8),
                Text(
                  '${product.quantity}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                _quantityButton(Icons.add, () {
                  setState(() {
                    product.quantity = product.quantity! + 1;
                  });
                  _updateProductQuantity(product);
                }, Colors.green),
              ],
            ),
            IconButton(
              icon: Icon(Icons.delete_forever, color: Colors.red, size: 36),
              onPressed: () => _removeProductFromOrder(product),
            ),
          ],
        ),
        Divider(color: Colors.grey),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('\$${product.price}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onPressed, Color color) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: Icon(icon, size: 24, color: Colors.white),
      ),
    );
  }

  Widget _imageProduct(Product product) {
    final imageUrl = IMAGE_BASE_URL + product.image1!;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FadeInImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          fadeInDuration: Duration(milliseconds: 50),
          placeholder: AssetImage('assets/img/no-image.png'),
        ),
      ),
    );
  }

  void _updateProductQuantity(Product product) {
    List<Product> updatedProducts = storedProducts.map((p) {
      if (p.id == product.id) {
        return product;
      }
      return p;
    }).toList();

    setState(() {
      storedProducts = updatedProducts;
    });

    _box.write('order', updatedProducts.map((p) => p.toJson()).toList());
  }

  void _removeProductFromOrder(Product product) {
    setState(() {
      storedProducts.removeWhere((p) => p.id == product.id);
    });

    if (storedProducts.isEmpty) {
      _box.remove('order');
    } else {
      _box.write('order', storedProducts.map((p) => p.toJson()).toList());
    }
  }
}