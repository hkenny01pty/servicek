import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:servicek/src/models/product.dart';
import 'package:servicek/src/pages/client/products/detail/client_products_detail_page.dart';
import 'package:servicek/src/providers/products_providers.dart';
import 'package:servicek/src/models/category.dart';
import 'package:servicek/src/providers/category_providers.dart';

class ClientProductsListController extends GetxController {

  CategoriesProvider categoriesProvider = CategoriesProvider();
  ProductsProvider productsProvider = ProductsProvider();

  List<Category> categories = <Category>[].obs;

  ClientProductsListController(){
    getCategories();
  }

  void getCategories() async{
    var result = await categoriesProvider.getAll();
    categories.clear();
    categories.addAll(result);
  }

  Future<List<Product>> getProducts(String idCategory) async{
    return await productsProvider.findByCategory(idCategory);
  }


  void goToOrderCreate(){
    Get.toNamed('/client/orders/create');
  }


  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/', (route) => false); // ELIMINAR EL HISTORIAL DE PANTALLAS
  }


  void openBottomSheet(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => FractionallySizedBox(
        heightFactor: 1.0,
        child: ClientProductsDetailPage(product: product),
      ),
    );
  }

}
