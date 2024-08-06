class Order {
  int? id;
  int idClient;
  int? idDelivery;
  int idAddress;
  double? latitud;
  double? longitud;
  String status;
  int timestamp;

  Order({
    this.id,
    required this.idClient,
    this.idDelivery,
    required this.idAddress,
    this.latitud,
    this.longitud,
    required this.status,
    required this.timestamp,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"],
    idClient: json["id_client"],
    idDelivery: json["id_delivery"],
    idAddress: json["id_address"],
    latitud: json["latitud"],
    longitud: json["longitud"],
    status: json["status"],
    timestamp: json["timestamp"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_client": idClient,
    "id_delivery": idDelivery,
    "id_address": idAddress,
    "latitud": latitud,
    "longitud": longitud,
    "status": status,
    "timestamp": timestamp,
  };
}