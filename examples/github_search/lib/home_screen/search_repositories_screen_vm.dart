import 'package:github_search/github_api.dart';
import 'package:beholder/beholder.dart';
import 'package:github_search/models/github_repository.dart';
import 'package:rxdart/rxdart.dart';

class SearchRepositoriesScreenVm extends ViewModel {
  final githubApi = GithubApi();

  late final searchString = state(
    '',
  )..asStream()
      .debounceTime(const Duration(milliseconds: 500))
      .listen((_) => refresh());

  Future<void> refresh() async {
    final search = searchString.value;
    if (search.isEmpty) {
      items.value = const Success([]);
      return;
    }

    items.value = Loading.fromPrevious(items.value);
    final result = await Result.guard(() {
      if (search == "error") {
        throw "Unexpected error";
      }

      return githubApi.searchRepositories(search);
    });

    if (search == searchString.value) {
      items.value = result;
    }
  }

  late final items = state<AsyncValue<List<GithubRepository>>>(
    const Success([]),
  );
}
