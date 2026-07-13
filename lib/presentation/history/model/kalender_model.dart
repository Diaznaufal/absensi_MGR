enum statusKalender {
  ontime,
  terlambat,
  tidakHadir,
  minggu,
  holiday,
  dayOff,
  cuti
}

class kalenderModel {
  final DateTime date;
  final statusKalender status;
  final String title;

  const kalenderModel(
      {required this.date, required this.status, required this.title});
}
