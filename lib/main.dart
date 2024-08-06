import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:servicek/src/models/user.dart';
import 'package:servicek/src/models/product.dart';

import 'package:servicek/src/pages/client/home/client_home_page.dart';
import 'package:servicek/src/pages/client/payment/client_payment_page.dart';
import 'package:servicek/src/pages/client/products/detail/product_datail_page.dart';
import 'package:servicek/src/pages/client/products/list/client_products_list_page.dart';
import 'package:servicek/src/pages/client/profile/update/client_profile_update_page.dart';
import 'package:servicek/src/pages/client/orders/create/client_order_create_page.dart';
import 'package:servicek/src/pages/comercios/comercios_page.dart';
import 'package:servicek/src/pages/delivery/home/delivery_home_page.dart';

import 'package:servicek/src/pages/delivery/orders/list/delivery_orders_list_page.dart';
import 'package:servicek/src/pages/home/home_page.dart';
import 'package:servicek/src/pages/login/login_page.dart';
import 'package:servicek/src/pages/register/register_page.dart';
import 'package:servicek/src/pages/restaurant/home/restaurant_home_page.dart';
import 'package:servicek/src/pages/restaurant/orders/list/restaurant_orders_list_page.dart';
import 'package:servicek/src/pages/restaurant/products/create/restaurant_products_test_page.dart';
import 'package:servicek/src/pages/roles/roles_page.dart';
import 'src/pages/welcome/welcome_page.dart';

var userData = GetStorage().read('user')?? {};
User userSesion = User.fromJson(GetStorage().read('user')?? {});
Map<String, dynamic> userMap = userData['user']?? {};
String? id = userMap['id'];

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyappState();
}

class _MyappState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    print('******************');
    print(userData);
    print('******************');
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Servicek Delivery',
      debugShowCheckedModeBanner: false,
      initialRoute: id!= null? '/roles' : '/welcome',
      //initialRoute: id!= null? '/roles' : '/client/home',
      getPages: [
        GetPage(name: '/', page: () => LoginPage()),
        GetPage(name: '/welcome', page: () => WelcomeScreen()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/roles', page: () => RolesPage()),

        GetPage(name: '/delivery/home', page: () => DeliveryHomePage()),
        GetPage(name: '/delivery/orders/list', page: () => DeliveryOrdersListPage()),

        GetPage(name: '/client/orders/create', page: () => ClientOrderCreatePage()),
        GetPage(name: '/client/home', page: () => ClientHomePage()),
        GetPage(name: '/client/products/list', page: () => ClientProductsListPage()),
        GetPage(name: '/client/profile/update', page: () => ClientProfileUpdatePage()),
        GetPage(name: '/client/payment', page: () => ClientPaymentPage()),

        GetPage(name: '/comercios', page: () => ComerciosPage()),

        GetPage(name: '/restaurant/home', page: () => RestaurantHomePage()),
        GetPage(name: '/restaurant/products/create', page: () =>  RestaurantProductsTestPage()),
        GetPage(name: '/restaurant/orders/list', page: () => RestaurantOrdersListPage()),

        //'/restaurantorderlistpage');

      ],
      navigatorKey: Get.key,
    );
  }
}
