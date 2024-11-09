// lib/core/utils/file_utils.dart

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';

class FileUtils {
  static Future<String> getImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(appDir.path, AppConstants.imagesFolder));

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    return imagesDir.path;
  }

  static Future<String> saveImage(File image) async {
    final imagesDir = await getImagesDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await image.copy(path.join(imagesDir, fileName));
    return savedImage.path;
  }

  static Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
