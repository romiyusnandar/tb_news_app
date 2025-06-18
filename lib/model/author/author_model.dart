class Author {
  final String name;
  final String? title;
  final String? avatar;

  Author({
    required this.name,
    required this.title,
    required this.avatar,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      name: json['name'] ?? 'Tidak Diketahui',
      title: json['title'],
      avatar: json['avatar'],
    );
  }
}