import 'dart:convert';

class Source {
  String? category;
  String? country;
  String? description;
  String? id;
  String? language;
  String? name;
  String? url;

  Source({
    required this.category,
    required this.country,
    required this.description,
    required this.id,
    required this.language,
    required this.name,
    required this.url,
  });

  Source.fromJson(Map<String, dynamic> json)
      : category = json['category'],
        country = json['country'],
        description = json['description'],
        id = json['id'],
        language = json['language'],
        name = json['name'],
        url = json['url'];
}

