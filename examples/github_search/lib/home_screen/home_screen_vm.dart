import 'package:github_search/github_api.dart';
import 'package:vessel_flutter/vessel_flutter.dart';
import 'package:warden/warden.dart';

final homeScreenVmProvider = Provider(
  (read) => HomeScreenVm(
    read(githubApiProvider),
  ),
);

class HomeScreenVm extends ViewModel {
  HomeScreenVm(this.githubApi);

  final GithubApi githubApi;

  late final items = future(
    (watch) async {
      final searchValue = watch(search);
      if (searchValue.isEmpty) return const SearchResult(items: []);
      return githubApi.searchRepositories(searchValue);
    },
    initial: const Success(SearchResult(items: [])),
    debounceTime: const Duration(milliseconds: 500),
  );

  late final search = observable('');
}
