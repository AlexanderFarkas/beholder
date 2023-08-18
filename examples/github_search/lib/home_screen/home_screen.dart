import 'package:flutter/material.dart';
import 'package:github_search/github_api.dart';
import 'package:github_search/home_screen/home_screen_store.dart';
import 'package:vessel_flutter/vessel_flutter.dart';
import 'package:warden/warden.dart';

import '../models/async_value.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = homeScreenStoreProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Github Search'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) => store.search.value = value,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Warden(
                builder: (context, observe) => switch (observe(store.items)) {
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
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
