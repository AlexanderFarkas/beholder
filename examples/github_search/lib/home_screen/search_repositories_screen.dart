import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:flutter/material.dart';
import 'package:github_search/home_screen/search_repositories_screen_vm.dart';

class SearchRepositoriesScreen extends StatefulWidget {
  const SearchRepositoriesScreen({Key? key}) : super(key: key);

  @override
  State<SearchRepositoriesScreen> createState() =>
      _SearchRepositoriesScreenState();
}

class _SearchRepositoriesScreenState extends State<SearchRepositoriesScreen> {
  final vm = SearchRepositoriesScreenVm();

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Github Search"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: vm.searchString.setValue,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Observer(
                builder: (context, watch) => switch (watch(vm.items)) {
                  Loading() => const Center(child: CircularProgressIndicator()),
                  Data(value: var items) => ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final repository = items[index];
                        return ListTile(
                          leading: Image.network(repository.owner.avatarUrl),
                          title: Text(repository.fullName),
                          subtitle: Text(repository.owner.login),
                        );
                      },
                    ),
                  Failure(:var error) => RefreshIndicator(
                      onRefresh: vm.refresh,
                      child:
                          ListView(children: [Center(child: Text("$error"))]),
                    ),
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
