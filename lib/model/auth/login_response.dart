import 'package:my_berita/model/auth/user_profile_response.dart';

class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final UserProfile? userProfile; // Data profil pengguna
  final String error;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.userProfile,
    this.error = '',
  });

  /// Factory constructor untuk mem-parsing JSON dari API.
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Cek jika 'data' tidak null sebelum mengakses isinya.
    final data = json['data'];
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: data?['token'],
      userProfile: data?['user'] != null
          ? UserProfile.fromJson(data['user'])
          : null,
    );
  }

  factory LoginResponse.withError(String errorValue) {
    return LoginResponse(
      success: false,
      message: '',
      error: errorValue,
    );
  }
}