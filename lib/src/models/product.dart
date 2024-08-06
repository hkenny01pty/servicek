class Product {
  String? id;
  String? name;
  String? description;
  String? image1;
  String? image2;
  String? image3;
  String? idCategory;
  double? price;
  int? quantity;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.image1,
    required this.image2,
    required this.image3,
    required this.idCategory,
    required this.price,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Intenta convertir el precio a un número de punto flotante
    double? price;
    if (json['price'] is String) {
      price = double.tryParse(json['price']);
    } else if (json['price'] is num) {
      price = (json['price'] as num).toDouble();
    }

    return Product(
      id: json["id"].toString(),
      name: json["name"],
      description: json["description"],
      image1: json["image1"],
      image2: json["image2"],
      image3: json["image3"],
      idCategory: json["id_category"],
      price: price,
      quantity: json["quantity"],
    );
  }

  static List<Product> fromJsonList(List<dynamic> jsonList) {
    List<Product> toList = [];
    jsonList.forEach((item) {
      Product product = Product.fromJson(item);
      toList.add(product);
    });

    return toList;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "image1": image1,
    "image2": image2,
    "image3": image3,
    "id_category": idCategory,
    "price": price,
    "quantity": quantity,
  };

    factory Product.fromMap(Map<String, dynamic> map) {
    // Llama al método fromJson para convertir el mapa en un objeto Product
    return Product.fromJson(map);
  }

}
