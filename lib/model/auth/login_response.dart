import 'package:my_berita/model/auth/user_profile_response.dart';

class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final UserProfile? userProfile;
  final String error;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.userProfile,
    required this.error,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['data'] != null ? json['data']['token'] : null,
      userProfile: null,
      error: '',
    );
  }

  factory LoginResponse.withError(String errorValue) {
    return LoginResponse(
      success: false,
      message: '',
      token: null,
      userProfile: null,
      error: errorValue,
    );
  }
}