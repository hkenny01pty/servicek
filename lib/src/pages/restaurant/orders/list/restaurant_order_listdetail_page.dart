import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RestaurantOrderListDetailPage extends StatefulWidget {
  final String orderId;
  final String orderStatus;

  RestaurantOrderListDetailPage({required this.orderId, required this.orderStatus});

  @override
  _RestaurantOrderListDetailPageState createState() => _RestaurantOrderListDetailPageState();
}

class _RestaurantOrderListDetailPageState extends State<RestaurantOrderListDetailPage> {
  Map<String, dynamic> orderDetails = {};
  List<Map<String, dynamic>> orderItems = [];
  List<Map<String, dynamic>> deliveryPersons = [];
  Map<String, dynamic>? selectedDeliveryPerson;
  String? selectedPaymentMethod;
  static const IMAGE_BASE_URL2 = 'https://www.aaservicek.com/servicek_images/products';
  static const NO_IMAGE_URL = 'https://www.aaservicek.com/servicek_images/no-image.png';

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
    fetchDeliveryPersons();
  }

  Future<void> fetchOrderDetails() async {
    print("Iniciando fetchOrderDetails para orden: ${widget.orderId}");
    final response = await http.post(
      Uri.parse('https://www.aaservicek.com/servicek_backend/actions/orders_actions.php'),
      body: {
        'action': 'GET_ORDER_DETAILS',
        'order_id': widget.orderId,
      },
    );

    print("Respuesta recibida para orden ${widget.orderId}. Código de estado: ${response.statusCode}");

    if (response.statusCode == 200) {
      print("Respuesta del servidor para orden ${widget.orderId}:");
      print(response.body);

      final data = json.decode(response.body);
      print("Datos decodificados para orden ${widget.orderId}:");
      print(json.encode(data));

      setState(() {
        orderDetails = data['order_details'];
        orderItems = List<Map<String, dynamic>>.from(data['order_items']);
        orderDetails['status'] = widget.orderStatus;
      });

      print("orderDetails para orden ${widget.orderId}:");
      print(json.encode(orderDetails));

      print("Estado de la orden: ${orderDetails['status']}");

      print("orderItems para orden ${widget.orderId}:");
      print(json.encode(orderItems));

      print("Número de productos en la orden: ${orderItems.length}");
    } else {
      print('Failed to load order details for order ${widget.orderId}. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> fetchDeliveryPersons() async {
    final response = await http.post(
      Uri.parse('https://www.aaservicek.com/servicek_backend/actions/orders_actions.php'),
      body: {
        'action': 'GET_DELIVERY_PERSONS',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        deliveryPersons = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      print('Failed to load delivery persons');
    }
  }

  Future<void> updateOrderStatus(String newStatus) async {
    print("Actualizando estado de la orden ${widget.orderId} a $newStatus");
    final response = await http.post(
      Uri.parse('https://www.aaservicek.com/servicek_backend/actions/orders_actions.php'),
      body: {
        'action': 'UPDATE_ORDER_STATUS',
        'order_id': widget.orderId,
        'new_status': newStatus,
        'delivery_person_id': selectedDeliveryPerson?['id'] ?? '',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        print("Estado de la orden actualizado exitosamente");
        setState(() {
          orderDetails['status'] = newStatus;
        });
        return;
      }
    }
    print('Failed to update order status. Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    throw Exception('Failed to update order status');
  }

  void _handleDispatchOrder() async {
    if (selectedDeliveryPerson == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debe asignar un repartidor antes de despachar la orden.')),
      );
      return;
    }

    try {
      await updateOrderStatus('Despachado');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Orden despachada exitosamente.')),
      );

      // Mostrar resumen del despacho
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Resumen del Despacho'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Orden #${widget.orderId} despachada'),
                  Text('Repartidor: ${selectedDeliveryPerson!['name']} ${selectedDeliveryPerson!['lastname']}'),
                  Text('Cliente: ${orderDetails['nombre_cliente']}'),
                  Text('Dirección: ${orderDetails['direccion_entrega']}'),
                  Text('Total a pagar: \$${orderDetails['total_pagar']}'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Redirigir a restaurant_order_list_page
                  Navigator.of(context).pushReplacementNamed('/restaurant/orders/list');
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al despachar la orden: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Orden #${widget.orderId}'),
        backgroundColor: Colors.amber,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildClientInfo(),
                  SizedBox(height: 20),
                  _buildProductList(),
                  SizedBox(height: 20),
                  _buildTotalAmount(),
                  SizedBox(height: 20),
                  _buildOrderOptions(),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildStatusBadge(),
          _buildDispatchButton(),
        ],
      ),
    );
  }


  Widget _buildClientInfo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Image.network(
                orderDetails['image'] != null && orderDetails['image'].isNotEmpty
                    ? orderDetails['image']
                    : NO_IMAGE_URL,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cliente: ${orderDetails['nombre_cliente'] ?? ''}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 4),
                  Text('Dirección: ${orderDetails['direccion_entrega'] ?? ''}'),
                  SizedBox(height: 4),
                  Text('Fecha: ${orderDetails['fecha_pedido'] ?? ''}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    print("Construyendo lista de productos. Número de productos: ${orderItems.length}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        SizedBox(height: 8),
        ...orderItems.map((item) {
          print("Construyendo item de producto: ${json.encode(item)}");
          return Card(
            margin: EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    child: Image.network(
                      item['image1'] != null && item['image1'].isNotEmpty
                          ? '$IMAGE_BASE_URL2/${item['image1']}'
                          : NO_IMAGE_URL,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['nombre_producto'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Cantidad: ${item['cantidad_solicitada']}'),
                        Text('Precio: \$${item['precio_producto']}'),
                        Text(
                          'Total: \$${item['total_producto']}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTotalAmount() {
    return Text(
      'Total a pagar: \$${orderDetails['total_pagar'] ?? ''}',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red),
    );
  }

  Widget _buildOrderOptions() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPaymentMethod(),
            SizedBox(height: 16),
            _buildDeliveryPersonSelection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Row(
      children: [
        Icon(Icons.payment, color: Colors.blue, size: 28),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Método de pago:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: selectedPaymentMethod,
                hint: Text('Seleccionar método de pago'),
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                items: ['Efectivo', 'Tarjeta', 'Yappy', 'Nequi'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPaymentMethod = newValue;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDispatchButton() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: ElevatedButton.icon(
        icon: Icon(Icons.send, color: Colors.black),
        label: Text(
          'DESPACHAR ORDEN',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        onPressed: orderDetails['status'] == 'Pendiente' ? _handleDispatchOrder : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: orderDetails['status'] == 'Pendiente' ? Colors.amber : Colors.grey,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryPersonSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Asignar repartidor:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        InkWell(
          onTap: orderDetails['status'] == 'Pendiente' ? _showDeliveryPersonModal : null,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                selectedDeliveryPerson != null
                    ? Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        selectedDeliveryPerson!['image'] != null && selectedDeliveryPerson!['image'].isNotEmpty
                            ? selectedDeliveryPerson!['image']
                            : NO_IMAGE_URL,
                      ),
                      radius: 35,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${selectedDeliveryPerson!['name']} ${selectedDeliveryPerson!['lastname']}',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(width: 8),
                    Text(
                      selectedDeliveryPerson!['phone'],
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                )
                    : Text('Seleccionar repartidor'),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
  void _showDeliveryPersonModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Seleccionar Repartidor',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: deliveryPersons.length,
                  itemBuilder: (context, index) {
                    final person = deliveryPersons[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            person['image'] != null && person['image'].isNotEmpty
                                ? person['image']
                                : NO_IMAGE_URL,
                          ),
                          radius: 30,
                        ),
                        title: Text('${person['name']} ${person['lastname']}'),
                        subtitle: Text(person['phone']),
                        onTap: () {
                          setState(() {
                            selectedDeliveryPerson = person;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Estado: ${widget.orderStatus}',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

}