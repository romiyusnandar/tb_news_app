import 'package:dio/dio.dart';
import 'package:my_berita/model/auth/login_response.dart';
import 'package:my_berita/model/auth/register_response.dart';

class AuthRepository {
  static String mainUrl = "https://rest-api-berita.vercel.app/api/v1";
  final String loginUrl = "$mainUrl/auth/login";
  final String registerUrl = "$mainUrl/auth/register";

  final Dio _dio = Dio();

  Future<LoginResponse> login(String email, String password) async {
    final data = {'email': email, 'password': password};
    final options = Options(headers: {'Accept': 'application/json'});

    try {
      Response response = await _dio.post(loginUrl, data: data, options: options);
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? "Email atau password salah.";
      return LoginResponse.withError("Error ${e.response?.statusCode}: $errorMessage");
    } catch (e) {
      return LoginResponse.withError("Terjadi kesalahan yang tidak terduga.");
    }
  }

  Future<RegisterResponse> register(String email, String password, String name, String title, String avatar) async {
    final data = {
      'email': email,
      'password': password,
      'name': name,
      'title': title,
      'avatar': avatar,
    };

    final options = Options(headers: {'Accept': 'application/json'});

    try {
      Response response = await _dio.post(registerUrl, data: data, options: options);
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      print("DioException on register: ${e.message}");
      if (e.response != null) {
        final errorMessage = e.response?.data?['message'] ?? 'Gagal mendaftarkan pengguna.';
        return RegisterResponse.withError("Error ${e.response?.statusCode}: $errorMessage");
      } else {
        return RegisterResponse.withError("Gagal terhubung ke server.");
      }
    } catch (e) {
      print("Unexpected error on register: $e");
      return RegisterResponse.withError("Terjadi kesalahan yang tidak terduga.");
    }
  }
}