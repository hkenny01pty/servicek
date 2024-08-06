import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'restaurant_order_listdetail_page.dart';

class RestaurantOrdersListPage extends StatefulWidget {
  @override
  _RestaurantOrdersListPage createState() => _RestaurantOrdersListPage();
}

class _RestaurantOrdersListPage extends State<RestaurantOrdersListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> orders = [];

  final List<String> statuses = [
    'Pendiente',
    'Pagado',
    'Despachado',
    'En Camino',
    'Entregado'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: statuses.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    fetchOrders();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      fetchOrders();
    }
  }

  Future<void> fetchOrders() async {
    final response = await http.post(
      Uri.parse('https://www.aaservicek.com/servicek_backend/actions/orders_actions.php'),
      body: {
        'action': 'GET_ORDERS',
        'status': statuses[_tabController.index],
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        orders = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      print('Failed to load orders');
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendiente':
        return Colors.amber;
      case 'pagado':
        return Colors.green;
      case 'despachado':
        return Colors.blue;
      case 'en camino':
        return Colors.red;
      case 'entregado':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Órdenes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Container(
            color: Colors.amber[700],
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: statuses.map((status) => Tab(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )).toList(),
              indicator: BoxDecoration(),
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: statuses.map((status) {
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestaurantOrderListDetailPage(
                        orderId: order['numero_orden'].toString(),
                        orderStatus: order['status'],
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Container(
                        color: _getStatusColor(order['status']),
                        padding: EdgeInsets.all(8),
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Orden #${order['numero_orden']}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.black),
                            ),
                            Text(
                              '${order['status']}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: 'Pedido: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  TextSpan(text: '${order['fecha_hora_orden']}', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: 'Cliente: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  TextSpan(text: '${order['nombre_usuario']}', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: 'Tlf.: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  TextSpan(text: '${order['phone']}', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: 'Entregar en: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  TextSpan(text: '${order['direccion_entrega']}', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: 'Total: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  TextSpan(text: '\$${order['monto_total']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                                ],
                              ),
                            ),
                            if (order['delivery_image'] != null && order['delivery_name'] != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 16),
                                  Text('Repartidor:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(order['delivery_image']),
                                        radius: 25,
                                      ),
                                      SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${order['delivery_name']} ${order['delivery_lastname']}', style: TextStyle(fontSize: 16)),
                                          Text('${order['delivery_phone']}', style: TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
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
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}