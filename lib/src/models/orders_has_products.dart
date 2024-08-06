class OrderHasProducts {
  int? id;
  int idClient;
  int idOrder;
  int idProduct;
  int quantity;

  OrderHasProducts({
    this.id,
    required this.idClient,
    required this.idOrder,
    required this.idProduct,
    required this.quantity,
  });

  factory OrderHasProducts.fromJson(Map<String, dynamic> json) => OrderHasProducts(
    id: json["id"],
    idClient: json["id_client"],
    idOrder: json["id_order"],
    idProduct: json["id_product"],
    quantity: json["quantity"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_client": idClient,
    "id_order": idOrder,
    "id_product": idProduct,
    "quantity": quantity,
  };
}