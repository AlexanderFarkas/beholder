import 'package:flutter/material.dart';
import 'package:warden/warden.dart';

import 'home_screen/search_repositories_screen.dart';

void main() {
  Observable.debugEnabled = true;
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: const SearchRepositoriesScreen(),
    );
  }
}
