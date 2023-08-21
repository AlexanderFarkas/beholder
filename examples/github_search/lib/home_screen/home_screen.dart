import 'package:flutter/material.dart';
import 'package:github_search/github_api.dart';
import 'package:github_search/home_screen/home_screen_vm.dart';
import 'package:warden/warden.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final vm = HomeScreenVm();

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Github Search'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) => vm.search.value = value,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Warden(
                builder: (context, watch) {
                  print("rebuild");
                  return switch (watch(vm.items)) {
                    Loading() => const Center(child: CircularProgressIndicator()),
                    Success(value: SearchResult(:var items)) => ListView.builder(
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
                    Failure(:var error) => Text(error.toString()),
                  };
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
