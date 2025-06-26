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
    return getAllNews(page: 1, limit: 10);
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

        if (response.data['body']['data'] == null || response.data['body']['data'] is! List) {
          return ArticleResponse(
            success: true,
            articles: [],
            message: response.data['body']['message'] ?? "Tidak ada artikel ditemukan.",
            pagination: null,
          );
        }

        final List articlesJson = response.data['body']['data'];
        final authorName = prefs.getString('user_name') ?? 'Penulis';

        final List<Article> articlesWithAuthor = [];

        for (var json in articlesJson) {
          try {
            json['author_name'] = authorName;
            articlesWithAuthor.add(Article.fromJson(json));
          } catch (e, stackTrace) {
            print("--- GAGAL MEMPROSES SATU ARTIKEL ---");
            print("Error: $e");
            print("Data JSON Bermasalah: $json");
            print(stackTrace);
            print("---------------------------------");
          }
        }

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
    } catch (e, stackTrace) {
      print("--- UNEXPECTED ERROR in getAuthorNews ---");
      print(e);
      print(stackTrace);
      print("---------------------------------------");
      return ArticleResponse.withError("Terjadi kesalahan: ${e.toString()}");
    }
  }

  Future<Article> getArticleBySlug(String slug) async {
    try {
      final response = await _dio.get("$newsUrl/$slug", options: _apiOptions);

      if (response.statusCode == 200 && response.data['body']['success'] == true) {
        return Article.fromJson(response.data['body']['data']);
      } else {
        throw Exception(response.data['body']['message'] ?? 'Artikel tidak ditemukan.');
      }
    } on DioException catch (e) {
      throw Exception('Gagal mengambil artikel: ${e.response?.data?['body']?['message'] ?? e.message}');
    } catch (e) {
      // Menangkap error lain jika terjadi masalah saat parsing JSON
      throw Exception('Terjadi kesalahan tak terduga saat memproses data artikel.');
    }
  }

  Future<Article> createArticle({
    required String title,
    required String summary,
    required String content,
    required String featuredImageUrl,
    required String category,
    required List<String> tags,
    required bool isPublished,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login ulang.");
    }

    final data = {
      'title': title,
      'summary': summary,
      'content': content,
      'featuredImageUrl': featuredImageUrl,
      'category': category,
      'tags': tags,
      'isPublished': isPublished,
    };

    try {
      final options = Options(headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      Response response = await _dio.post(authorNewsUrl, data: data, options: options);
      final responseBody = response.data['body'];

      if (responseBody['success'] == true && responseBody['data'] != null) {
        final articleJson = responseBody['data'] as Map<String, dynamic>;
        final authorName = prefs.getString('user_name') ?? 'Saya';
        final authorAvatar = prefs.getString('user_avatar') ?? '';
        articleJson['author_name'] = authorName;
        articleJson['author_avatar'] = authorAvatar;
        return Article.fromJson(articleJson);
      } else {
        throw Exception(responseBody['message'] ?? 'Gagal membuat artikel.');
      }

    } on DioException catch (e) {
      print("--- DIO ERROR on createArticle ---");
      print("Status Code: ${e.response?.statusCode}");
      print("Response Data: ${e.response?.data}");
      print("Error Message: ${e.message}");
      print("--------------------------------");
      final errorMessage = e.response?.data?['body']?['message'] ?? 'Gagal membuat artikel. Periksa koneksi atau data Anda.';
      throw Exception(errorMessage);

    } catch (e) {
      throw Exception('Terjadi kesalahan yang tidak terduga: $e');
    }
  }

  Future<void> updateArticle(String articleId, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception("Token tidak ditemukan.");

    try {
      final options = _apiOptions.copyWith(headers: {'Authorization': 'Bearer $token'});
      await _dio.put("$authorNewsUrl/$articleId", data: data, options: options);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['body']?['message'] ?? 'Gagal memperbarui artikel.');
    }
  }

  Future<void> deleteArticle(String articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception("Token tidak ditemukan.");

    try {
      final options = _apiOptions.copyWith(headers: {'Authorization': 'Bearer $token'});
      await _dio.delete("$authorNewsUrl/$articleId", options: options);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['body']?['message'] ?? 'Gagal menghapus artikel.');
    }
  }
}
