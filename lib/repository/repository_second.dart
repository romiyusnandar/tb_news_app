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
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login ulang.");
    }

    if (tags.isEmpty) {
      throw Exception("Setidaknya satu tag diperlukan untuk membuat artikel.");
    }

    final data = {
      'title': title,
      'category': category,
      'readTime': readTime,
      'imageUrl': imageUrl,
      'content': content,
      'tags': tags,
    };

    try {
      final options = Options(headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      Response response = await _dio.post(createNewsUrl, data: data, options: options);

      if (response.data['success'] == true && response.data['data'] != null) {
        // --- PERBAIKAN UTAMA ADA DI SINI ---

        // 1. Ambil data JSON artikel dari respons API.
        final articleJson = response.data['data'] as Map<String, dynamic>;

        // 2. Ambil data pengguna yang tersimpan di lokal.
        final authorName = prefs.getString('user_name') ?? 'Saya';
        final authorTitle = prefs.getString('user_title') ?? '';
        final authorAvatar = prefs.getString('user_avatar') ?? '';

        // 3. Buat objek 'author' palsu secara manual.
        final authorMap = {
          'name': authorName,
          'title': authorTitle,
          'avatar': authorAvatar,
        };

        // 4. Suntikkan/tambahkan objek 'author' ke dalam JSON artikel.
        articleJson['author'] = authorMap;

        // 5. Sekarang, proses JSON yang sudah lengkap dengan aman.
        return Article.fromJson(articleJson);

      } else {
        throw Exception(response.data['message'] ?? 'Gagal membuat artikel: tidak ada data yang dikembalikan.');
      }

    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['errors'] != null) {
        final errors = e.response!.data['errors'] as Map<String, dynamic>;
        final errorMessages = errors.values.map((e) => (e as List).join('\n')).join('\n');
        throw Exception("Kesalahan Validasi:\n$errorMessages");
      }
      throw Exception(e.response?.data?['message'] ?? 'Terjadi error jaringan.');
    } catch (e) {
      throw Exception('Terjadi kesalahan yang tidak terduga.');
    }
  }
}