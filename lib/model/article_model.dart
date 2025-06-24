class ArticleResponse {
  final bool success;
  final List<Article> articles;
  final Pagination? pagination;
  final String message;
  final String error;

  ArticleResponse({
    required this.success,
    required this.articles,
    this.pagination,
    required this.message,
    this.error = '',
  });

  factory ArticleResponse.fromJson(Map<String, dynamic> json) {
    final body = json['body'];
    if (body == null || body['data'] == null) {
      return ArticleResponse.withError("Format respons tidak valid: 'body' atau 'data' tidak ditemukan.");
    }

    final data = body['data'] as List;
    final articleList = data.map((i) => Article.fromJson(i)).toList();

    return ArticleResponse(
      success: body['success'] ?? false,
      message: body['message'] ?? '',
      articles: articleList,
      pagination: body['pagination'] != null
          ? Pagination.fromJson(body['pagination'])
          : null,
    );
  }

  factory ArticleResponse.withError(String errorValue) {
    return ArticleResponse(
      success: false,
      articles: [],
      message: '',
      error: errorValue,
    );
  }
}

class Article {
  final String id;
  final String title;
  final String slug;
  final String? summary;
  final String content;
  final String? featuredImageUrl;
  final String category;
  final List<String> tags;
  final DateTime publishedAt;
  final String authorName;
  final String? authorAvatar;

  Article({
    required this.id,
    required this.title,
    required this.slug,
    this.summary,
    required this.content,
    this.featuredImageUrl,
    required this.category,
    required this.tags,
    required this.publishedAt,
    required this.authorName,
    this.authorAvatar,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      summary: json['summary'],
      content: json['content'],
      featuredImageUrl: json['featured_image_url'],
      category: json['category'],
      tags: List<String>.from(json['tags'] ?? []),
      publishedAt: DateTime.parse(json['published_at']),
      authorName: json['author_name'] ?? 'Penulis Tidak Dikenal',
      authorAvatar: json['author_avatar'],
    );
  }
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      totalPages: json['totalPages'],
    );
  }
}