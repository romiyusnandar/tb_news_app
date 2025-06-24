import 'package:dio/dio.dart';
import 'package:my_berita/model/login_model.dart';

class AuthRepository {
  static const String _baseUrl = 'http://45.149.187.204:3000';

  final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));

  Future<LoginResponse> loginUser(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      return LoginResponse.withError(
        e.response?.data?['body']?['message'] ?? 'Login gagal: ${e.message}',
      );
    } catch (e) {
      return LoginResponse.withError('Terjadi kesalahan yang tidak terduga.');
    }
  }
}