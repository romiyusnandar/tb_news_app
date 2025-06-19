class RegisterResponse {
  final bool success;
  final String message;
  final String error;

  RegisterResponse(this.success, this.message, this.error);

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      json['success'] ?? false,
      json['message'] ?? '',
      '',
    );
  }

  factory RegisterResponse.withError(String errorValue) {
    return RegisterResponse(false, '', errorValue);
  }
}
