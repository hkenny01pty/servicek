
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:servicek/src/models/product.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ClientProductsDetailController extends GetxController {

  List<Product> selectedProducts = [];

  ClientProductsDetailController() {
    print('..\n\n..');
    var shoppingBag = GetStorage().read('shopping_bag');
    if (shoppingBag is List<Product>) {
      print('GET STORAGE memoria  ------>:');
      shoppingBag.forEach((product) {
        print(product);
      });
    } else {
      print('GET STORAGE memoria  ------>: $shoppingBag');
    }
    print('..\n\n..');
  }

  void checkIfProductsWasAddes(Product product,var price,var counter) {

    price.value = product.price ?? 0.0;

    if(GetStorage().read('shopping_bag') != null){
      if(GetStorage().read('shopping_bag') is List<Product>){
        selectedProducts = GetStorage().read('shopping_bag').cast<Map<String, dynamic>>();
      }
      else {
        selectedProducts = Product.fromJsonList(GetStorage().read('shopping_bag'));
      }
      int index = selectedProducts.indexWhere((p) => p.id == product.id);
      if (index > -1) {
        counter.value = selectedProducts[index].quantity ?? 0;
        price.value = selectedProducts[index].price! * counter.value ;
      }else{
        counter.value =  0;
        price.value = product.price! * 1 ;
      }


      print('..\n\n..');
      var shoppingBag = GetStorage().read('shopping_bag');
      print('GET STORAGE memoria  ------>:');
      shoppingBag.forEach((product) {
        print('\n\n');
        print(product);
      });
      print('..\n\n..');

    };
  }

  void addToBag(Product product,var price,var counter) {
    price.value = product.price! * counter.value; // Actualizar el precio total
    int index = selectedProducts.indexWhere((p) => p.id == product.id);
    if (index == -1) {
      product.quantity = counter.value;
      selectedProducts.add(product);
    } else {
      selectedProducts[index].quantity = counter.value;
    }

    GetStorage().write('shopping_bag', selectedProducts.map((p) => p.toJson()).toList());
    Fluttertoast.showToast(msg: 'Producto Agregado');

    //selectedProducts.forEach((p) {
    //  print('..\n\n..');
    //  print('addToBag PRODUCTO: ${p.toJson()}');
    //});

    print('..\n\n..');
    var shoppingBag = GetStorage().read('shopping_bag');
    print('GET STORAGE memoria  ------>:');
    shoppingBag.forEach((product) {
      print('\n\n');
      print(product);
    });
    print('..\n\n..');
  }

  void addItem(Product product,var price,var counter) {
    counter.value = counter.value + 1;
    price.value = product!.price! * counter.value; // Actualizar el precio total
    print(counter.value);
    print(price.value);
  }

  void removeItem(Product product,var price,var counter) {
    if (counter.value > 1) {
      counter.value = counter.value - 1;
      price.value = product!.price! * counter.value; // Actualizar el precio total
      print(counter.value);
      print(price.value);
    }
  }

}

