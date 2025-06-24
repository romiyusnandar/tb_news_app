import 'package:dio/dio.dart';
import 'package:my_berita/model/article_model.dart';

class NewsRepository {
  static String mainUrl = "http://45.149.187.204:3000";
  final String newsUrl = "$mainUrl/api/news";

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
}
