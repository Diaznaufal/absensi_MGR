class kategoriModel {
  final String title;
  final String value;
  kategoriModel({required this.title, required this.value});
}

final List<kategoriModel> kategoriOptions = [
  kategoriModel(title: "Fasilitas Kantor", value: "1"),
  kategoriModel(title: "Keamanan", value: "2"),
  kategoriModel(title: "Lingkungan Kerja", value: "3"),
  kategoriModel(title: "Lainnya", value: "4"),
];
