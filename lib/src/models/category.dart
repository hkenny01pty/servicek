import 'dart:convert';

Category categoryFromJson(String str) => Category.fromJson(json.decode(str));
String categoryToJson(Category data) => json.encode(data.toJson());

class Category {
  String? id;
  String? name;
  String? description;

  Category({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"].toString(),
    name: json["name"],
    description: json["description"],
  );

  static List<Category> fromJsonList(dynamic jsonList) {
    if (jsonList == null || !(jsonList is List)) {
      // Si jsonList es null o no es una lista, devolver una lista vacía
      return [];
    }
    List<Category> toList = [];
    for (var item in jsonList) {
      if (item is Map<String, dynamic>) {
        Category category = Category.fromJson(item);
        toList.add(category);
      }
    }
    return toList;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
  };
}
