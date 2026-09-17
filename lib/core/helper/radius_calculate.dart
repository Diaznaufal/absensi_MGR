import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;

class RadiusCalculate {
  /// Menghitung jarak antara dua titik koordinat (satuan Kilometer)
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    const c = cos;
    final a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  /// Menghitung jarak dalam meter
  static double calculateDistanceInMeters(
      double lat1, double lon1, double lat2, double lon2) {
    return calculateDistance(lat1, lon1, lat2, lon2) * 1000;
  }

  /// Parse string JSON polygon dari API
  static List<List<double>> parsePolygon(String? polygonStr) {
    if (polygonStr == null || polygonStr.isEmpty) return [];
    try {
      final List<dynamic> parsedJson = jsonDecode(polygonStr);
      return parsedJson.map<List<double>>((point) {
        return [
          (point[0] as num).toDouble(),
          (point[1] as num).toDouble(),
        ];
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Cek posisi user di dalam polygon dengan toleransi GPS Jitter
  static bool isPointInPolygon(
    double pointLat,
    double pointLng,
    List<List<double>> polygonPoints, {
    double toleranceMeters = 35.0,
  }) {
    if (polygonPoints.length < 3) return false;

    bool isInside = false;
    int j = polygonPoints.length - 1;

    for (int i = 0; i < polygonPoints.length; i++) {
      double xi = polygonPoints[i][0];
      double yi = polygonPoints[i][1];
      double xj = polygonPoints[j][0];
      double yj = polygonPoints[j][1];

      bool intersect = ((yi > pointLng) != (yj > pointLng)) &&
          (pointLat < (xj - xi) * (pointLng - yi) / (yj - yi) + xi);

      if (intersect) isInside = !isInside;
      j = i;
    }

    if (isInside) return true;

    for (final point in polygonPoints) {
      final distance = calculateDistanceInMeters(
        pointLat,
        pointLng,
        point[0],
        point[1],
      );

      if (distance <= toleranceMeters) {
        return true;
      }
    }

    return false;
  }
}
