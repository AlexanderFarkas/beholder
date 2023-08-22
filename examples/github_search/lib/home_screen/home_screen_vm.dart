import 'package:github_search/github_api.dart';
import 'package:warden/warden.dart';

class HomeScreenVm extends ViewModel {
  final githubApi = GithubApi();

  late final items = future(
    (watch) async {
      final searchValue = watch(search);
      if (searchValue.isEmpty) return const SearchResult(items: []);
      return githubApi.searchRepositories(searchValue);
    },
    initial: const Success(SearchResult(items: [])),
    debounceTime: const Duration(milliseconds: 500),
  );

  late final search = state('');
}
