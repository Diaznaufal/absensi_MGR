import 'dart:convert';

class UserResponseModel {
  final int? idAdmin;
  final String? idEmployee;
  final String? name;
  final String? email;
  final int? role;
  final String? roleLabel;
  final String? avatar;
  final Employee? employee; // <--- Mengarah ke class Employee di bawah

  UserResponseModel({
    this.idAdmin,
    this.idEmployee,
    this.name,
    this.email,
    this.role,
    this.roleLabel,
    this.avatar,
    this.employee,
  });

  factory UserResponseModel.fromJson(String str) =>
      UserResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserResponseModel.fromMap(Map<String, dynamic> json) =>
      UserResponseModel(
        idAdmin: json["id_admin"],
        idEmployee: json["id_employee"],
        name: json["name"],
        email: json["email"],
        role: json["role"],
        roleLabel: json["role_label"],
        avatar: json["avatar"],
        employee: json["employee"] == null
            ? null
            : Employee.fromMap(json["employee"]),
      );

  Map<String, dynamic> toMap() => {
        "id_admin": idAdmin,
        "id_employee": idEmployee,
        "name": name,
        "email": email,
        "role": role,
        "role_label": roleLabel,
        "avatar": avatar,
        "employee": employee?.toMap(),
      };
}

class Employee {
  final String? idEmployee;
  final String? idDivision;
  final String? idPosition;
  final String? idProduct;
  final String? email;
  final String? noHp;
  final String? dateIn;
  final String? nip;
  final String? name;
  final String? gender;
  final String? placeOfBirth;
  final String? dateOfBirth;
  final String? status;
  final String? basicSalary;
  final String? uangMakan;
  final String? typeEmployee;
  final String? contractExpired;
  final String? typeUangMakan;
  final String? nameDivision;
  final String? namePosition;
  final String? nameProduct;
  final String? fullAddress;

  Employee({
    this.idEmployee,
    this.idDivision,
    this.idPosition,
    this.idProduct,
    this.email,
    this.noHp,
    this.dateIn,
    this.nip,
    this.name,
    this.gender,
    this.placeOfBirth,
    this.dateOfBirth,
    this.status,
    this.basicSalary,
    this.uangMakan,
    this.typeEmployee,
    this.contractExpired,
    this.typeUangMakan,
    this.nameDivision,
    this.namePosition,
    this.nameProduct,
    this.fullAddress,
  });

  factory Employee.fromJson(String str) => Employee.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Employee.fromMap(Map<String, dynamic> json) => Employee(
        idEmployee: json["id_employee"],
        idDivision: json["id_division"],
        idPosition: json["id_position"],
        idProduct: json["id_product"],
        email: json["email"],
        noHp: json["no_hp"],
        dateIn: json["date_in"],
        nip: json["nip"],
        name: json["name"],
        gender: json["gender"],
        placeOfBirth: json["place_of_birth"],
        dateOfBirth: json["date_of_birth"],
        status: json["status"],
        basicSalary: json["basic_salary"],
        uangMakan: json["uang_makan"],
        typeEmployee: json["type_employee"],
        contractExpired: json["contract_expired"],
        typeUangMakan: json["type_uang_makan"],
        nameDivision: json["name_division"],
        namePosition: json["name_position"],
        nameProduct: json["name_product"],
        fullAddress: json["full_address"],
      );

  Map<String, dynamic> toMap() => {
        "id_employee": idEmployee,
        "id_division": idDivision,
        "id_position": idPosition,
        "id_product": idProduct,
        "email": email,
        "no_hp": noHp,
        "date_in": dateIn,
        "nip": nip,
        "name": name,
        "gender": gender,
        "place_of_birth": placeOfBirth,
        "date_of_birth": dateOfBirth,
        "status": status,
        "basic_salary": basicSalary,
        "uang_makan": uangMakan,
        "type_employee": typeEmployee,
        "contract_expired": contractExpired,
        "type_uang_makan": typeUangMakan,
        "name_division": nameDivision,
        "name_position": namePosition,
        "name_product": nameProduct,
        "full_address": fullAddress,
      };
}
