import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicek/src/pages/client/products/list/client_products_list_page.dart';
import 'package:servicek/src/pages/comercios/comercios_page.dart';
import 'package:servicek/src/pages/delivery/orders/list/delivery_orders_list_page.dart';
import 'package:servicek/src/pages/salir/salir_page.dart';
import 'package:servicek/src/utils/custom_animated_bottom_bar.dart';
import '../orders/create/client_order_create_page.dart';
import '../orders/list/client_orders_list_page.dart';
import '../profile/info/client_profile_info_page.dart';
import 'client_home_controller.dart';

class ClientHomePage extends StatelessWidget {
  ClientHomeController con = Get.put(ClientHomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (con.indexTab.value == null) {
          return Center(child: CircularProgressIndicator());
        } else {
          try {
            return IndexedStack(
              index: con.indexTab.value,
              children: [
                ComerciosPage(),
                ClientOrdersListPage(),
                SalirPage()
              ],
            );
          } catch (e) {
            print('Error: $e');
            return Center(child: Text('Ocurrió un error inesperado'));
          }
        }
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => ClientOrderCreatePage());
        },
        icon: Icon(Icons.shopping_bag, size: 24),
        label: Text('Ordenes Incompletas', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.amber,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }


  // Se ha comentado la función _bottomBar() para uso posterior
  /*
  Widget _bottomBar() {
    return Obx(() => CustomAnimatedBottomBar(
      containerHeight: 70,
      backgroundColor: Colors.amber,
      showElevation: false,
      itemCornerRadius: 24,
      curve: Curves.easeIn,
      selectedIndex: con.indexTab.value,
      onItemSelected: (index) => con.changeTab(index),
      items: [
        _buildIcon(Icons.account_circle_sharp, 0, 'Cliente1'),
        //_buildIcon(Icons.apps, 1, 'Productos'), // esto selecciona TODOS los productos sun comercio..
        _buildIcon(Icons.list, 2, 'Ordenes'),
        //_buildIcon(Icons.person, 3, 'Perfil'),
        _buildIcon(Icons.power_settings_new, 4, 'Salir'),
      ],
    ));
  }

  BottomNavyBarItem _buildIcon(IconData icon, int index, String title) {
    return BottomNavyBarItem(
      icon: Icon(icon),
      title: Text(title),
      activeColor: Colors.white,
      inactiveColor: Colors.black,
    );
  }
  */
}