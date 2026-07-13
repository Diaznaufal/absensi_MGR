// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:image_picker/image_picker.dart';

class UserRequestModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address; // Ditambahkan
  final String emergencyContact; // Ditambahkan
  final XFile? image;

  UserRequestModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address, // Ditambahkan
    required this.emergencyContact, // Ditambahkan
    this.image,
  });
  // Ubah tipe data kembalian fungsi menjadi Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'id': id, // id bertipe int tidak akan error di sini
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'emergency_contact': emergencyContact,
    };
  }
}
