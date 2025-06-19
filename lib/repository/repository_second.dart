import 'package:dio/dio.dart';
import 'package:my_berita/model/article/article_response.dart';

class NewsRepositorySecond {
  static String mainUrl = "https://rest-api-berita.vercel.app/api/v1";
  final String getTrendingNewsUrl = "$mainUrl/news/trending";
  final String getAllNewsUrl = "$mainUrl/news";

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
}