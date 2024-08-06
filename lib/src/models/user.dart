import 'dart:convert';
import 'Rol.dart';

User userFromJson(String str) => User.fromJson(json.decode(str));
String userToJson(User data) => json.encode(data.toJson());

class User {
  //int? id;
  String? id;
  String? email;
  String? name;
  String? lastname;
  String? phone;
  String? image;
  String? password;
  String? sessiontoken;
  String? createdAt;
  String? updatedAt;
  String? pw;
  List<Rol>? roles = [];

  User({
    this.id,
    this.email,
    this.name,
    this.lastname,
    this.phone,
    this.image,
    this.password,
    this.sessiontoken,
    this.createdAt,
    this.updatedAt,
    this.pw,
    this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    //id: json["id"],
    id: json["id"]?.toString(),
    email: json["email"],
    name: json["name"],
    lastname: json["lastname"],
    phone: json["phone"],
    image: json["image"],
    password: json["password"],
    sessiontoken: json["sessiontoken"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    pw: json["pw"],
    roles: json["roles"] == null
        ? []
        //: List<Rol>.from(json["roles"].map((model) => Rol.fromJson(model))),
        : List<Rol>.from(jsonDecode(json["roles"]).map((model) => Rol.fromJson(model))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "name": name,
    "lastname": lastname,
    "phone": phone,
    "image": image,
    "password": password,
    "sessiontoken": sessiontoken,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "pw": pw,
    "roles": roles,
  };
}