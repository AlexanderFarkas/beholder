import 'package:github_search/github_api.dart';
import 'package:warden/warden.dart';

class HomeScreenVm extends ViewModel {
  final githubApi = GithubApi();

  late final items = future(
    (watch) {
      final search = watch(this.search);
      return () async {
        if (search.isEmpty) return const SearchResult(items: []);
        return githubApi.searchRepositories(search);
      };
    },
    initial: const Success(SearchResult(items: [])),
    debounceTime: const Duration(milliseconds: 500),
  );

  late final search = state('');
}
