class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final AuthorProfile? authorProfile;
  final String error;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.authorProfile,
    this.error = '',
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final body = json['body'];
    if (body == null || body['success'] != true || body['data'] == null) {
      return LoginResponse.withError(body?['message'] ?? 'Format respons tidak valid.');
    }

    final data = body['data'];
    return LoginResponse(
      success: true,
      message: body['message'] ?? 'Login berhasil',
      token: data['token'],
      authorProfile: data['author'] != null
          ? AuthorProfile.fromJson(data['author'])
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

class AuthorProfile {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatarUrl;

  String get fullName => '$firstName $lastName';

  AuthorProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
  });

  factory AuthorProfile.fromJson(Map<String, dynamic> json) {
    return AuthorProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      avatarUrl: json['avatarUrl'],
    );
  }
}
