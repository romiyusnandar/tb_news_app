class UserProfileResponse {
  final UserProfile? userProfile;
  final String error;

  UserProfileResponse(this.userProfile, this.error);

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      UserProfile.fromJson(json['data']),
      "",
    );
  }

  factory UserProfileResponse.loading() => UserProfileResponse(null, "loading");
  factory UserProfileResponse.withError(String errorValue) => UserProfileResponse(null, errorValue);
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String title;
  final String avatar;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.title,
    required this.avatar,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Tidak Ada Nama',
      email: json['email'] ?? 'Tidak Ada Email',
      title: json['title'] ?? 'Tidak Ada Jabatan',
      avatar: json['avatar'] ?? '',
    );
  }
}