import 'package:flutter/material.dart';
import 'package:github_search/store_provider_adapter.dart';
import 'package:vessel_flutter/vessel_flutter.dart';
import 'package:warden/warden.dart';

import 'home_screen/home_screen.dart';

void main() {
  Observable.debugEnabled = true;
  runApp(
    const ProviderScope(
      adapters: [StoreProviderAdapter()],
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
