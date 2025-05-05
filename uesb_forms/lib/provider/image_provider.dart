import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageProvider extends ChangeNotifier {
  Uint8List? _selectedImage;

  Uint8List? get selectedImage => _selectedImage;

  void setImage(Uint8List? image) {
    _selectedImage = image;
    notifyListeners();
  }

  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }
}
