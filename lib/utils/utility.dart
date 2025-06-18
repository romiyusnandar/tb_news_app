import 'package:flutter/material.dart';

class Utility {
  static getImageComponent(String imageName) {
    return imageName.isEmpty
        ? const AssetImage("assets/images/default_image.png")
        : NetworkImage(imageName);
  }

  static DateTime parseCustomDate(String dateString) {
    try {
      final parts = dateString.split(' ');
      if (parts.length != 3) return DateTime.now();

      final day = int.parse(parts[0]);
      final month = _getMonthNumber(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      print('Error parsing date: $e');
      return DateTime.now();
    }
  }

  static int _getMonthNumber(String month) {
    switch (month.toLowerCase()) {
      case 'jan': return 1;
      case 'feb': return 2;
      case 'mar': return 3;
      case 'apr': return 4;
      case 'mei': return 5;
      case 'jun': return 6;
      case 'jul': return 7;
      case 'agu': return 8;
      case 'sep': return 9;
      case 'okt': return 10;
      case 'nov': return 11;
      case 'des': return 12;
      default: return 1;
    }
  }
}