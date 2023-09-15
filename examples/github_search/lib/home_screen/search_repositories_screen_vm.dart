import 'package:github_search/github_api.dart';
import 'package:beholder/beholder.dart';

class SearchRepositoriesScreenVm extends ViewModel {
  final githubApi = GithubApi();

  late final searchString = state(
    '',
    onSet: (value) {
      if (value.isEmpty) {
        items.value = const Success([]);
      } else {
        items.scheduleRefresh(() {
          if (value == "error") {
            throw "Unexpected error";
          }
          return githubApi.searchRepositories(value);
        });
      }
    },
  );

  Future<void> refresh() {
    return items.refresh(() => githubApi.searchRepositories(searchString.value));
  }

  late final items = asyncState(
    value: const Success([]),
    debounceTime: const Duration(milliseconds: 500),
  );
}
