import 'package:dio/dio.dart';
import 'package:my_berita/model/article_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsRepository {
  static String mainUrl = "http://45.149.187.204:3000";
  final String newsUrl = "$mainUrl/api/news";
  final String authorNewsUrl = "$mainUrl/api/author/news";

  final Dio _dio = Dio();

  final Options _apiOptions = Options(headers: {'Accept': 'application/json'});

  Future<ArticleResponse> getAllNews({int page = 1, int limit = 10}) async {
    final params = {'page': page, 'limit': limit};
    try {
      Response response = await _dio.get(newsUrl, queryParameters: params, options: _apiOptions);
      return ArticleResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ArticleResponse.withError(e.response?.data?['body']?['message'] ?? 'Gagal memuat berita.');
    } catch (e) {
      return ArticleResponse.withError("Terjadi kesalahan yang tidak terduga.");
    }
  }

  Future<ArticleResponse> getTrendingNews() async {
    return getAllNews(page: 1, limit: 5);
  }

  Future<ArticleResponse> getAuthorNews() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      return ArticleResponse.withError("Akses ditolak. Silakan login.");
    }

    try {
      final options = Options(headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      Response response = await _dio.get(authorNewsUrl, options: options);

      if (response.statusCode == 200 && response.data['body']['success'] == true) {

        final List articlesJson = response.data['body']['data'];

        final authorName = prefs.getString('user_name') ?? 'Penulis';

        final List<Article> articlesWithAuthor = articlesJson.map((json) {
          json['author_name'] = authorName;
          return Article.fromJson(json);
        }).toList();

        return ArticleResponse(
          success: true,
          articles: articlesWithAuthor,
          message: response.data['body']['message'],
          pagination: response.data['body']['pagination'] != null
              ? Pagination.fromJson(response.data['body']['pagination'])
              : null,
        );

      } else {
        throw Exception(response.data['body']['message'] ?? 'Gagal memuat artikel Anda.');
      }

    } on DioException catch (e) {
      return ArticleResponse.withError(e.response?.data?['body']?['message'] ?? 'Gagal memuat artikel Anda.');
    } catch (e) {
      return ArticleResponse.withError("Terjadi kesalahan yang tidak terduga.");
    }
  }
}
