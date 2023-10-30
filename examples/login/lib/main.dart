import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:flutter/material.dart';
import 'package:login/login_form_vm.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final vm = LoginFormVm();

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          minimum: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Observer(
                builder: (context, watch) => Column(
                  children: [
                    TextField(
                      controller: vm.username.controller,
                      focusNode: vm.username.focusNode,
                      decoration: InputDecoration(
                        label: const Text("Username"),
                        errorText: watch(vm.username.displayError),
                      ),
                    ),
                    TextField(
                      controller: vm.password.controller,
                      focusNode: vm.password.focusNode,
                      decoration: InputDecoration(
                        label: const Text("Password"),
                        errorText: watch(vm.password.displayError),
                      ),
                    ),
                    TextField(
                      controller: vm.repeatPassword.controller,
                      focusNode: vm.repeatPassword.focusNode,
                      decoration: InputDecoration(
                        label: const Text("Repeat password"),
                        errorText: watch(vm.repeatPassword.displayError),
                      ),
                    ),
                    Observer(
                      builder: (context, watch) => TextButton(
                        onPressed: watch(vm.isSubmittable) ? vm.submit : null,
                        child: const Text("Submit"),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
