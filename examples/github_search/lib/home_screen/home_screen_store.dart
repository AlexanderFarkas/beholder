import 'package:github_search/github_api.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vessel_flutter/vessel_flutter.dart';
import 'package:warden/warden.dart';

import '../models/async_value.dart';

final homeScreenStoreProvider = Provider(
  (read) => HomeScreenStore(
    read(githubApiProvider),
  ),
);

class HomeScreenStore extends Store {
  HomeScreenStore(this.githubApi) {
    final subscription = search
        .asStream()
        .doOnData((value) {
          items.value = value.isEmpty ? const Success(SearchResult(items: [])) : const Loading();
        })
        .debounceTime(const Duration(milliseconds: 500))
        .where((value) => value.isNotEmpty)
        .switchMap<AsyncValue<SearchResult>>((value) async* {
          if (value != search.value) return;
          yield await Result.guard(() => githubApi.searchRepositories(value));
        })
        .listen((value) => items.value = value);

    onDispose.add(subscription.cancel);
  }

  final GithubApi githubApi;

  late final items = observable<AsyncValue<SearchResult>>(const Success(SearchResult(items: [])));
  late final search = observable('');
}
