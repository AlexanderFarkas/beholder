import 'dart:convert';

import 'package:github_search/models/github_repository.dart';
import 'package:http/http.dart' as http;

class GithubApi {
  GithubApi({
    this.baseUrl = "https://api.github.com",
  }) : httpClient = http.Client();

  final String baseUrl;
  final http.Client httpClient;

  Future<List<GithubRepository>> searchRepositories(String term) async {
    final response = await httpClient.get(Uri.parse("$baseUrl/search/repositories?q=$term"));
    final results = json.decode(response.body);

    if (response.statusCode == 200) {
      return (results['items'] as List<dynamic>)
          .map((dynamic item) => GithubRepository.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw SearchResultError.fromJson(results);
    }
  }
}

class SearchResultError {
  const SearchResultError({required this.message});

  final String message;

  static SearchResultError fromJson(dynamic json) {
    return SearchResultError(
      message: json['message'] as String,
    );
  }

  @override
  String toString() {
    return message;
  }
}
