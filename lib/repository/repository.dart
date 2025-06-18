import 'package:dio/dio.dart';
import 'package:my_berita/model/article/article_response.dart';
import 'package:my_berita/model/source/source_response.dart';

class NewsRepository {
  static const String baseUrl = "https://newsapi.org/v2";
  final String apiKey = "d0d335cc1074458e9c2b29a1d23ca37c";

  final Dio _dio = Dio();

  var getSourcesUrl = "$baseUrl/sources";
  var getTopHeadlinesUrl = "$baseUrl/top-headlines";
  var getEverythingUrl = "$baseUrl/everything";

  Future<SourceResponse> getSources() async {
    var params = {
      "apiKey": apiKey,
      "language": "id",
      "country": "id",
    };
    try {
      Response response = await _dio.get(
        getSourcesUrl,
        queryParameters: params
      );
      return SourceResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      print("Error fetching sources: $e");
      print("Stack trace: $stackTrace");
      return SourceResponse.withError("$e");
    }
  }

  Future<ArticleResponse> getTopHeadlines() async {
    var params = {
      "apiKey": apiKey,
      "country": "us",
    };
    try {
      Response response = await _dio.get(
        getTopHeadlinesUrl,
        queryParameters: params
      );
      return ArticleResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      print("Error fetching top headlines: $e");
      print("Stack trace: $stackTrace");
      return ArticleResponse.withError("$e");
    }
  }

  Future<ArticleResponse> search(String query) async {
    var params = {
      "apiKey": apiKey,
      "q": query,
      "language": "id",
      "sortBy": "popularity",
    };
    try {
      Response response = await _dio.get(
          getEverythingUrl,
          queryParameters: params
      );
      return ArticleResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      print("Error searching articles: $e");
      print("Stack trace: $stackTrace");
      return ArticleResponse.withError("$e");
    }
  }
}