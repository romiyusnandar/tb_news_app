import 'package:my_berita/model/author/author_model.dart';

class Article {
  final String id;
  final String title;
  final String category;
  final DateTime publishedAt;
  final String? readTime;
  final String? imageUrl;
  final bool isTrending;
  final List<String> tags;
  final String? content;
  final Author author;

  Article({
    required this.id,
    required this.title,
    required this.category,
    required this.publishedAt,
    this.readTime,
    this.imageUrl,
    required this.isTrending,
    required this.tags,
    this.content,
    required this.author,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      publishedAt: _parseCustomDate(json['publishedAt']),
      readTime: json['readTime'],
      imageUrl: json['imageUrl'],
      isTrending: json['isTrending'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      content: json['content'],
      author: Author.fromJson(json['author']),
    );
  }

  static DateTime _parseCustomDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      try {
        final parts = dateString.split(' ');
        if (parts.length != 3) return DateTime.now();
        final day = int.parse(parts[0]);
        final month = _getMonthNumber(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      } catch (e) {
        return DateTime.now();
      }
    }
  }

  static int _getMonthNumber(String month) {
    const monthMap = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'mei': 5, 'jun': 6,
      'jul': 7, 'agu': 8, 'sep': 9, 'okt': 10, 'nov': 11, 'des': 12
    };
    return monthMap[month.toLowerCase().substring(0, 3)] ?? 1;
  }
}