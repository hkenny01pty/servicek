import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicek/src/pages/salir/salir_page.dart';
import '../../client/profile/info/client_profile_info_page.dart';
import '../orders/list/delivery_orders_list_page.dart';
import 'delivery_home_controller.dart';

class DeliveryHomePage extends StatelessWidget {
  final DeliveryHomeController con = Get.put(DeliveryHomeController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Obx(() => IndexedStack(
          index: con.indexTab.value,
          children: [
            DeliveryOrdersListPage(),
            ClientProfileInfoPage(),
            SalirPage(),
          ],
        )),
        bottomNavigationBar: Obx(() => BottomNavigationBar(
          currentIndex: con.indexTab.value,
          onTap: (index) => con.changeTab(index),
          selectedItemColor: Colors.amber,
          unselectedItemColor: Colors.black54,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Pedidos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.power_settings_new_rounded),
              label: 'Salir',
            ),
          ],
        )),
      ),
    );
  }
}