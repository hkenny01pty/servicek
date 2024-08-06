import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:servicek/src//models/product.dart'; // Asegúrate de importar el modelo de Producto

class RestaurantProductsMecController {
  static const ROOT2 = 'https://www.aaservicek.com/servicek_backend/actions/products_actions.php';

  List<Product> productList = [];

  Future<void> fetchProductsFromBackend() async {
    final url = Uri.parse(ROOT2);
    final response = await http.post(
      url,
      body: {'action': 'SEL_PRD', 'id_category': '3'}, // Aquí pasas la categoría fija '3'
    );

    if (response.statusCode == 200) {
      // Decodificar la respuesta JSON
      List<dynamic> responseData = jsonDecode(response.body);

      // Limpiar productList antes de llenarla con los nuevos datos
      productList.clear();

      // Iterar sobre los datos recibidos y convertirlos en objetos Product
      for (var item in responseData) {
        Product product = Product(
          id: item['id'],
          name: item['name'],
          description: item['description'],
          price: double.parse(item['price']), image1: '', image2: '', image3: '', idCategory: '', quantity: null,
          // Añadir otros campos como image1, image2, etc., según tu modelo Product
        );
        productList.add(product);
      }
    } else {
      throw Exception('Fallo al cargar productos desde el backend');
    }
  }

  // Métodos de actualización y eliminación de productos
  // ...

  // Método para actualizar un producto
  void updateProduct(Product updatedProduct) {
    // Implementación para actualizar producto
  }

  // Método para eliminar un producto
  void deleteProduct(Product productToDelete) {
    // Implementación para eliminar producto
  }
}
