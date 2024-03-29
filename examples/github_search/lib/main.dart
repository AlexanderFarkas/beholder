import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:flutter/material.dart';

import 'home_screen/search_repositories_screen.dart';

void main() {
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
