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
      final month = getMonthNumber(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      print('Error parsing date: $e');
      return DateTime.now();
    }
  }

  static int getMonthNumber(String month) {
    const monthMap = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'mei': 5, 'jun': 6,
      'jul': 7, 'agu': 8, 'sep': 9, 'okt': 10, 'nov': 11, 'des': 12
    };
    return monthMap[month.toLowerCase().substring(0, 3)] ?? 1;
  }
}