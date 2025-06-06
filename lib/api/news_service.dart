import 'dart:convert';

import 'package:berita/models/article_model.dart';
import 'package:http/http.dart' as http;

class NewsService {
  final String _apiKey = '';
  final String _baseUrl = 'https://newsapi.org/v2';

  Future<List<Article>> getTopHeadlines() async {
    final response = await http.get(Uri.parse('$_baseUrl/top-headlines?country=id&apiKey=${_apiKey}'));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      Iterable list = result['articles'];
      return list.map((article) => Article.fromJson(article)).toList();
    } else {
      throw Exception('Gagal mendapatkan data top-headlines');
    }
  }

  Future <List<Article>> searchNews(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/everything?q=$query&language=id&apiKey=${_apiKey}'));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      Iterable list = result['articles'];
      return list.map((article) => Article.fromJson(article)).toList();
    } else {
      throw Exception('Gagal mendapatkan data pencarian');
    }
  }
}