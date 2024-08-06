import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../models/product.dart';

class ClientOrdersCreateController extends GetxController {

  List<Product> selectedProducts = [];
  var counter = 0.obs;

  ClientOrdersCreateController() {

    if(GetStorage().read('order') != null){

      if(GetStorage().read('order') is List<Product>){
        selectedProducts = GetStorage().read('order').cast<Map<String, dynamic>>();
      }
      else {
        selectedProducts = Product.fromJsonList(GetStorage().read('order'));
      }
    }

  }

}
