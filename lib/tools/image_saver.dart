import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// ==================================
// LOCAL IMAGE PERSISTENCE TOOL
// ==================================

/// Utility for saving user-captured/selected images to local app storage
class ImageSaver {
  /// Saves a single image file into local application directory and returns the saved file path
  Future<String> saveImage(XFile image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory("${appDir.path}/saved_images");
    if(!await imageDir.exists()) {
      await imageDir.create();
    }
    final imageName = "${path.basename(image.path)}";
    final imagePath = path.join(imageDir.path, imageName);

    final savedImage = await File(image.path).copy(imagePath);

    return savedImage.path;
  }

  /// Saves multiple images to local application directory and returns list of saved file paths
  Future<List<String>> saveMultipleImages(List<XFile> images) async {
    List<String> imagePaths = [];
    for(var img in images) {
      imagePaths.add(await saveImage(img));
    }
    return imagePaths;
  }
}