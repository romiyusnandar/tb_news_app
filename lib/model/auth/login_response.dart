class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final String error;

  LoginResponse(
    this.success,
    this.message,
    this.token,
    this.error,
  );

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      json['success'] ?? false,
      json['message'] ?? '',
      json['data'] != null ? json['data']['token'] : null,
      '',
    );
  }

  factory LoginResponse.withError(String error) {
    return LoginResponse(
      false,
      '',
      null,
      error,
    );
  }
}