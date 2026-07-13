import 'dart:convert';

class ProductpengaduanResponseModel {
  final bool? status;
  final String? message;
  final List<Product>? listProduct;

  ProductpengaduanResponseModel({this.status, this.message, this.listProduct});

  factory ProductpengaduanResponseModel.fromJson(String str) =>
      ProductpengaduanResponseModel.fromMap(json.decode(str));

  factory ProductpengaduanResponseModel.fromMap(Map<String, dynamic> json) =>
      ProductpengaduanResponseModel(
        status: json["status"],
        message: json["message"],
        listProduct:
            json["data"] != null && json["data"]["list_product"] != null
                ? List<Product>.from(
                    json["data"]["list_product"].map((x) => Product.fromMap(x)))
                : [],
      );
}

class Product {
  final String? idProduct;
  final String? nameProduct;

  Product({this.idProduct, this.nameProduct});

  factory Product.fromMap(Map<String, dynamic> json) => Product(
      idProduct: json["id_product"]?.toString(),
      nameProduct: json["name_product"]?.toString());
}
