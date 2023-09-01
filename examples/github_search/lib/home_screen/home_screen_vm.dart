import 'package:github_search/github_api.dart';
import 'package:warden/warden.dart';

class HomeScreenVm extends ViewModel {
  final githubApi = GithubApi();

  late final searchString = state('')
    ..listen((value) {
      if (value.isEmpty) {
        _searchResult.value = const Success(SearchResult.empty());
      } else {
        _searchResult.refreshWith(() async {
          final repositories = await githubApi.searchRepositories(value);
          return repositories;
        });
      }
    });

  late final items = computed(
    (watch) => watch(_searchResult).mapValue((value) => value.items),
  );

  late final _searchResult = asyncState(
    value: const Success(SearchResult.empty()),
    debounceTime: const Duration(milliseconds: 500),
  );
}
