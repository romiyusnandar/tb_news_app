import 'package:dio/dio.dart';
import 'package:my_berita/model/article/article_response.dart';

class NewsRepositorySecond {
  // URL API Anda
  static String mainUrl = "https://rest-api-berita.vercel.app/api/v1";
  final String getTrendingNewsUrl = "$mainUrl/news/trending";

  // Asumsikan _dio sudah diinisialisasi di tempat lain
  final Dio _dio = Dio();

  /// Mengambil daftar artikel yang sedang trending dari API.
  Future<ArticleResponse> getTrendingNews() async {
    // Menambahkan header 'Accept' yang seringkali dibutuhkan oleh REST API.
    final options = Options(headers: {
      'Accept': 'application/json',
    });

    try {
      // Melakukan GET request ke URL trending dengan options yang sudah diatur.
      Response response = await _dio.get(getTrendingNewsUrl, options: options);

      // Menggunakan ArticleResponse.fromJson yang sudah kita sesuaikan.
      return ArticleResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Penanganan error yang lebih spesifik untuk DioException.
      // Ini akan memberikan log yang lebih detail di konsol Anda untuk debugging.
      print("DioException fetching trending news: ${e.message}");
      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
        print('Error response status code: ${e.response?.statusCode}');
        // Coba ambil pesan error dari body response API jika ada, jika tidak gunakan pesan default.
        final apiErrorMessage = e.response?.data?['message'] ??
            'Server returned an error';
        return ArticleResponse.withError(
            "Error ${e.response?.statusCode}: $apiErrorMessage");
      } else {
        // Error yang terjadi sebelum server merespon (misal: tidak ada koneksi internet)
        print("Error sending request: ${e.message}");
        return ArticleResponse.withError("Gagal terhubung ke server.");
      }
    } catch (e, stackTrace) {
      // Menangkap error tak terduga lainnya.
      print("Unexpected error fetching trending news: $e");
      print("Stack trace: $stackTrace");
      return ArticleResponse.withError("Terjadi kesalahan yang tidak terduga.");
    }
  }
}