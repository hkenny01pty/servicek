import 'package:get_storage/get_storage.dart';
import 'package:servicek/src/models/product.dart';

class ShoppingCart {
  List<Product> items = [];

  void addProduct(Product product, int quantity) {
    int index = items.indexWhere((p) => p.id == product.id);
    if (index == -1) {
      product.quantity = quantity;
      items.add(product);
    } else {
      items[index].quantity = quantity;
    }
    saveCartToStorage();
  }

  void removeProduct(Product product) {
    items.removeWhere((p) => p.id == product.id);
    saveCartToStorage();
  }

  void updateQuantity(Product product, int quantity) {
    int index = items.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      items[index].quantity = quantity;
    }
    saveCartToStorage();
  }

  double get totalPrice {
    double total = 0.0;
    for (var product in items) {
      total += product.price! * (product.quantity ?? 1);
    }
    return total;
  }

  void saveCartToStorage() {
    GetStorage().write('shopping_cart', items.map((p) => p.toJson()).toList());
  }

  void loadCartFromStorage() {
    var cartData = GetStorage().read('shopping_cart');
    if (cartData != null) {
      items = Product.fromJsonList(cartData);
    }
  }
}