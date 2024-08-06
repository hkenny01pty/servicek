import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicek/src/pages/client/products/list/client_products_list_controller.dart';
import 'package:servicek/src/pages/delivery/orders/list/delivery_orders_list_page.dart';
import 'package:servicek/src/pages/register/register_page.dart';
import 'package:servicek/src/pages/restaurant/orders/list/restaurant_orders_list_page.dart';
import 'package:servicek/src/pages/restaurant/products/create/restaurant_products_test_page.dart';
import 'package:servicek/src/pages/salir/salir_page.dart';
import 'package:servicek/src/utils/custom_animated_bottom_bar.dart';
import '../../client/profile/info/client_profile_info_page.dart';
import '../categories/create/restaurant_categories_create_page.dart';
import '../products/create/restaurant_products_create_page.dart';
import 'restaurant_home_controller.dart';

class RestaurantHomePage extends StatelessWidget {

  RestaurantHomeController con = Get.put(RestaurantHomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bottomBar(),
      body: Obx(() => IndexedStack(
        index: con.indexTab.value,
        children: [
          RestaurantOrdersListPage(),
          RestaurantCategoriesCreatePage(),
          RestaurantProductsCreatePage(),
          //RestaurantProductsTestPage(),
          //DeliveryOrdersListPage(),
          //RegisterPage()
          ClientProfileInfoPage(),
          //TestPage()
          SalirPage(),
        ],
      )
    ),
   );
  }

  Widget _bottomBar() {
    return Obx(() =>   CustomAnimatedBottomBar(
      containerHeight: 70,
      backgroundColor: Colors.amber,
      showElevation: true,
      itemCornerRadius: 24,
      curve: Curves.easeIn,
      selectedIndex: con.indexTab.value,
      onItemSelected: (index)  => con.changeTab(index),

      items: [
        BottomNavyBarItem(
          icon: Icon(Icons.list),
          title: Text('Pedidos'),
          activeColor: Colors.white,
          inactiveColor: Colors.black,
        ),

        BottomNavyBarItem(
          icon: Icon(Icons.category_sharp),
          title: Text('Categorías'),
          activeColor: Colors.white,
          inactiveColor: Colors.black,
        ),

        BottomNavyBarItem(
          icon: Icon(Icons.restaurant),
          title: Text('Productos'),
          activeColor: Colors.white,
          inactiveColor: Colors.black,
        ),


        BottomNavyBarItem(
          icon: Icon(Icons.person),
          title: Text('Perfil'),
          activeColor: Colors.white,
          inactiveColor: Colors.black,
        ),

        BottomNavyBarItem(
          icon: Icon(Icons.power_settings_new_rounded),
          title: Text('Salir'),
          activeColor: Colors.white,
          inactiveColor: Colors.black,
        ),

      ],
    ));
  }

  }
