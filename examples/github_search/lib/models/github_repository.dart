import 'github_user.dart';

class GithubRepository {
  const GithubRepository({
    required this.fullName,
    required this.htmlUrl,
    required this.owner,
  });

  final String fullName;
  final String htmlUrl;
  final GithubUser owner;

  static GithubRepository fromJson(dynamic json) {
    return GithubRepository(
      fullName: json['full_name'] as String,
      htmlUrl: json['html_url'] as String,
      owner: GithubUser.fromJson(json['owner']),
    );
  }
}
