import 'package:flutter/material.dart';

class Utility {
  static getImageComponent(String imageName) {
    return imageName.isEmpty
        ? const AssetImage("assets/images/default_image.png")
        : NetworkImage(imageName);
  }
}