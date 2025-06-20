import 'package:dio/dio.dart';
import 'package:my_berita/model/article/article_model.dart';
import 'package:my_berita/model/article/article_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsRepositorySecond {
  static String mainUrl = "https://rest-api-berita.vercel.app/api/v1";
  final String getTrendingNewsUrl = "$mainUrl/news/trending";
  final String getAllNewsUrl = "$mainUrl/news";
  final String createNewsUrl = "$mainUrl/news";

  final Dio _dio = Dio();

  final Options _apiOptions = Options(headers: {
    'Accept': 'application/json',
  });

  Future<ArticleResponse> getTrendingNews() async {
    try {
      Response response = await _dio.get(getTrendingNewsUrl, options: _apiOptions);
      return ArticleResponse.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Gagal memuat berita trending.';
      return ArticleResponse.withError("Error ${e.response?.statusCode}: $errorMessage");
    } catch (e) {
      return ArticleResponse.withError("Terjadi kesalahan yang tidak terduga.");
    }
  }

  Future<ArticleResponse> getAllNews({int page = 1, int limit = 10}) async {
    final params = {
      'page': page,
      'limit': limit,
    };

    try {
      Response response = await _dio.get(getAllNewsUrl, queryParameters: params, options: _apiOptions);

      // ================== LOG DIAGNOSTIK ==================
      print("✅ Success calling: ${response.requestOptions.uri}");
      // ======================================================

      return ArticleResponse.fromJson(response.data);
    } on DioException catch (e) {
      // ================== LOG DIAGNOSTIK ==================
      if (e.response != null) {
        print("❌ Error calling: ${e.response?.requestOptions.uri}");
      }
      print("❌ DioException: ${e.message}");
      // ======================================================

      final apiErrorMessage = e.response?.data?['message'] ?? 'Gagal memuat daftar berita.';
      return ArticleResponse.withError("Error ${e.response?.statusCode}: $apiErrorMessage");
    } catch (e) {
      print("❌ Unexpected Error: $e");
      return ArticleResponse.withError("Terjadi kesalahan yang tidak terduga.");
    }
  }

  Future<Article> createArticle({
    required String title,
    required String category,
    required String readTime,
    required String imageUrl,
    required String content,
    required List<String> tags,
    bool? isTrending,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) throw Exception("Token tidak ditemukan.");
    if (tags.isEmpty) throw Exception("Setidaknya satu tag diperlukan.");

    final data = {
      'title': title,
      'category': category,
      'readTime': readTime,
      'imageUrl': imageUrl,
      'content': content,
      'tags': tags,
      'isTrending': isTrending ?? false,
    };

    try {
      final options = Options(headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      Response response = await _dio.post(createNewsUrl, data: data, options: options);

      if (response.data['success'] == true && response.data['data'] != null) {
        final articleJson = response.data['data'] as Map<String, dynamic>;

        final newArticleId = articleJson['id'] as String;
        final myArticleIds = prefs.getStringList('my_article_ids') ?? [];
        myArticleIds.add(newArticleId);
        await prefs.setStringList('my_article_ids', myArticleIds);

        final authorName = prefs.getString('user_name') ?? 'Saya';
        final authorTitle = prefs.getString('user_title') ?? '';
        final authorAvatar = prefs.getString('user_avatar') ?? '';

        final authorMap = {
          'name': authorName,
          'title': authorTitle,
          'avatar': authorAvatar,
        };

        articleJson['author'] = authorMap;

        return Article.fromJson(articleJson);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal membuat artikel: tidak ada data yang dikembalikan.');
      }

    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData != null && errorData['message'] != null) {
        throw Exception(errorData['message']);
      }
      throw Exception('Terjadi error jaringan.');
    } catch (e) {
      throw Exception('Terjadi kesalahan yang tidak terduga: $e');
    }
  }

  Future<void> deleteArticle(String articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) throw Exception("Token tidak ditemukan.");

    try {
      final options = Options(headers: { 'Authorization': 'Bearer $token' });
      await _dio.delete("$createNewsUrl/$articleId", options: options);

      final myArticleIds = prefs.getStringList('my_article_ids') ?? [];
      myArticleIds.remove(articleId);
      await prefs.setStringList('my_article_ids', myArticleIds);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal menghapus artikel.');
    }
  }

  Future<void> updateArticle(String articleId, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) throw Exception("Token tidak ditemukan.");

    try {
      final options = Options(headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      await _dio.put("$createNewsUrl/$articleId", data: data, options: options);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memperbarui artikel.');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga: $e');
    }
  }
}