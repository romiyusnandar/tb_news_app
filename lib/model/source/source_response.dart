
import 'package:my_berita/model/source/source_model.dart';

class SourceResponse {
  final List<Source> sources;
  final String error;

  SourceResponse.fromJson(Map<String, dynamic> json)
      :   sources = (json['sources'] as List)
      .map((source) => Source.fromJson(source))
      .toList(),
        error = '';

  SourceResponse.withError(String errorValue)
      : sources = [],
        error = errorValue;

}