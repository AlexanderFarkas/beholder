import 'dart:convert';

import 'package:github_search/models/github_repository.dart';
import 'package:vessel_flutter/vessel_flutter.dart';
import 'package:http/http.dart' as http;

final githubApiProvider = Provider((_) => GithubApi());

class GithubApi {
  GithubApi({
    this.baseUrl = "https://api.github.com",
  }) : this.httpClient = http.Client();

  final String baseUrl;
  final http.Client httpClient;

  Future<SearchResult> searchRepositories(String term) async {
    final response = await httpClient.get(Uri.parse("$baseUrl/search/repositories?q=$term"));
    final results = json.decode(response.body);

    if (response.statusCode == 200) {
      return SearchResult.fromJson(results);
    } else {
      throw SearchResultError.fromJson(results);
    }
  }
}

class SearchResult {
  const SearchResult({required this.items});

  final List<GithubRepository> items;

  static SearchResult fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map((dynamic item) => GithubRepository.fromJson(item as Map<String, dynamic>))
        .toList();
    return SearchResult(items: items);
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
