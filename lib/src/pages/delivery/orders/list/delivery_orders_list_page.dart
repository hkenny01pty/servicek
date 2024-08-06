import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import 'delivery_order_listdetail_page.dart';
import 'package:servicek/src/pages/roles/rol_bottom_bar.dart';

class DeliveryOrdersListPage extends StatefulWidget {
  @override
  _DeliveryOrdersListPageState createState() => _DeliveryOrdersListPageState();
}

class _DeliveryOrdersListPageState extends State<DeliveryOrdersListPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> orders = [];
  final storage = GetStorage();
  late TabController _tabController;
  bool isLoading = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    print('DeliveryOrdersListPage initState llamado');
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        fetchOrders(status: getStatus(_tabController.index));
      }
    });
    fetchOrders(status: 'Pendiente');
  }

  String getStatus(int index) {
    switch (index) {
      case 0:
        return 'Pendiente';
      case 1:
        return 'Despachado';
      case 2:
        return 'En Camino';
      case 3:
        return 'Entregado';
      case 4:
        return 'Pagado';
      default:
        return 'Despachado';
    }
  }

  Future<void> fetchOrders({required String status}) async {
    setState(() {
      isLoading = true;
    });

    print('Obteniendo órdenes con estado: $status');

    final userInfo = storage.read('user');
    final userId = userInfo['user']['id'];
    print('ID de usuario Delivery: $userId');

    final response = await http.post(
      Uri.parse('https://www.aaservicek.com/servicek_backend/actions/orders_actions.php'),
      body: {
        'action': 'GET_DELIVERY_ORDERS2',
        'delivery_id': userId.toString(),
        'status': status,
      },
    );

    print('Datos enviados a GET_DELIVERY_ORDERS:');
    print('delivery_id: ${userId.toString()}');
    print('status: $status');

    if (response.statusCode == 200) {
      try {
        final decodedBody = json.decode(response.body);
        setState(() {
          orders = List<Map<String, dynamic>>.from(decodedBody);
          print('Número de órdenes obtenidas: ${orders.length}');
          isLoading = false;
        });
        for (var order in orders) {
          printOrderDetails(order);
        }
      } catch (e) {
        print('Error al decodificar la respuesta: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('Error al cargar las órdenes. Código de estado: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }


  void printOrderDetails(Map<String, dynamic> order) {
    print('Detalles de la orden:');
    print('Número de orden: ${order['numero_orden']}');
    print('Pedido: ${order['fecha_hora_orden']}');
    print('Cliente: ${order['nombre_usuario']}');
    print('Teléfono: ${order['phone']}');
    print('Dirección de entrega: ${order['direccion_entrega']}');
    print('Tipo de vivienda: ${order['tipo_vivienda']}');
    print('Avenida/Calle: ${order['avenida_calle']}');
    print('PH/Casa: ${order['ph_casa']}');
    print('Apto/Casa: ${order['apto_casa']}');
    print('Corregimiento: ${order['corregimiento']}');
    print('Punto de referencia: ${order['punto_referencia']}');
    print('Monto total: \$${order['monto_total']}');
    print('Latitud: ${order['latitud']}');
    print('Longitud: ${order['longitud']}');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Tus órdenes (${orders.length})',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.amber,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white,
              tabs: [
                _buildTab(Icons.pending, 'Pendiente'),
                _buildTab(Icons.local_shipping, 'Despachado'),
                _buildTab(Icons.delivery_dining, 'En Camino'),
                _buildTab(Icons.check_circle, 'Entregado'),
                _buildTab(Icons.payment, 'Pagado'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            buildOrderListView('Pendiente'),
            buildOrderListView('Despachado'),
            buildOrderListView('En Camino'),
            buildOrderListView('Entregado'),
            buildOrderListView('Pagado'),
          ],
        ),
        bottomNavigationBar: RolBottomBar(
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            // Aquí puedes agregar la lógica para manejar la navegación si es necesario
          },
          selectedIndex: _selectedIndex,
        ),
      ),
    );
  }

  Widget _buildTab(IconData icon, String label) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget buildOrderListView(String status) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : orders.isEmpty
        ? Center(child: Text('No hay órdenes para mostrar'))
        : ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeliveryOrderListdetailPage(order: order),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Orden #${order['numero_orden']}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 19),
                  ),
                  SizedBox(height: 8),
                  Text(
                      'Fecha y hora del pedido: ${formatDate(order['fecha_hora_orden'])}',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey[600])),
                  Text('Cliente: ${order['nombre_usuario']}',
                      style: TextStyle(fontSize: 16)),
                  Text('Tlf.: ${order['phone']}',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Dirección de entrega:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (order['tipo_vivienda'] != null) Text('Tipo de vivienda: ${order['tipo_vivienda']}',
                      style: TextStyle(fontSize: 16)),
                  if (order['avenida_calle'] != null) Text('Avenida/Calle: ${order['avenida_calle']}',
                      style: TextStyle(fontSize: 16)),
                  if (order['ph_casa'] != null) Text('PH/Casa: ${order['ph_casa']}',
                      style: TextStyle(fontSize: 16)),
                  if (order['apto_casa'] != null) Text('Apto/Casa: ${order['apto_casa']}',
                      style: TextStyle(fontSize: 16)),
                  if (order['corregimiento'] != null) Text('Corregimiento: ${order['corregimiento']}',
                      style: TextStyle(fontSize: 16)),
                  if (order['punto_referencia'] != null) Text('Punto de referencia: ${order['punto_referencia']}',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Total: \$${order['monto_total']}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(dateTime);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Delivery Orders App',
    home: DeliveryOrdersListPage(),
  ));
}