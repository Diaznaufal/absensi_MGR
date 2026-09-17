import 'dart:ui';
import 'package:flutter_absensi_app/core/ml/recognition_embedding.dart';
import 'package:image/image.dart' as img;

class Recognizer {
  Recognizer({int? numThreads});

  Future<void> loadModel() async {}

  List<dynamic> imageToArray(img.Image inputImage) {
    return [];
  }

  RecognitionEmbedding recognize(img.Image image, Rect location) {
    return RecognitionEmbedding(location, List.filled(192, 0.0));
  }

  PairEmbedding findNearest(List<double> emb, List<double> authFaceEmbedding) {
    return PairEmbedding(0.0);
  }

  Future<bool> isValidFace(List<double> emb) async {
    return true; // Dibuat selalu true agar flow absensi bisa dilewati saat tes UI
  }
}

class PairEmbedding {
  double distance;
  PairEmbedding(this.distance);
}
