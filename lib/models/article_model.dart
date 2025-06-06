class Article {
  final String title;
  final String? description;
  final String? urlToImage;
  final String url;
  final String? author;
  final String publishedAt;
  final String sourceName;

  Article({
    required this.title,
    this.description,
    this.urlToImage,
    required this.url,
    this.author,
    required this.publishedAt,
    required this.sourceName,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'Judul tidak ada',
      description: json['description'],
      urlToImage: json['urlToImage'],
      url: json['url'] ?? '',
      author: json['author'],
      publishedAt: json['publishedAt'] ?? '',
      sourceName: (json['source'] != null && json['source']['name'] != null)
          ? json['source']['name']
          : 'Sumber tidak diketahui',
    );
  }
}