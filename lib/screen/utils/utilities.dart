import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as Im;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class Utilities {
  static String getUsername(String email) {
    return "live:${email.split("@")[0]}";
  }

  static Future<File> pickImage({@required ImageSource source}) async {
    final ImagePicker _picker = ImagePicker();
    PickedFile pickedImage = await _picker.getImage(source: source);
    if(pickedImage == null){
      
    }
    File selectedImage = File(pickedImage.path);
    return await compressImage(selectedImage);
  }

  static Future<File> compressImage(File imageToCompress) async {
    final tempDir = await getTemporaryDirectory();
    final  path = tempDir.path;
    int random = Random().nextInt(1000);
    Im.Image image = Im.decodeImage(imageToCompress.readAsBytesSync());
    Im.copyResize(image, width: 500, height: 500);
    return new File('$path/img_$random.jpg')..writeAsBytesSync(Im.encodeJpg(image, quality: 85));
  }
}
