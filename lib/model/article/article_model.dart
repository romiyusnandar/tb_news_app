import 'package:my_berita/model/author/author_model.dart';
import 'package:my_berita/model/source/source_model.dart';
import 'package:my_berita/utils/utility.dart';

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
     id: json['id'] ?? '',
     title: json['title'] ?? '',
     category: json['category'] ?? '',
     publishedAt: Utility.parseCustomDate(json['publishedAt']),
     readTime: json['readTime'],
     imageUrl: json['imageUrl'],
     isTrending: json['isTrending'] ?? false,
     tags: List<String>.from(json['tags'] ?? []),
     content: json['content'],
     author: Author.fromJson(json['author']),
   );
  }
}

