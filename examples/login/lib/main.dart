import 'package:flutter/material.dart';
import 'package:login/login_form_vm.dart';
import 'package:warden/warden.dart';

void main() {
  Observable.debugEnabled = true;
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
              Column(
                children: [
                  FieldObserver(
                    field: vm.username,
                    builder: (context, watch, controller) => TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        label: const Text("Username"),
                        errorText: watch(vm.username.error),
                      ),
                    ),
                  ),
                  FieldObserver(
                    field: vm.password,
                    builder: (context, watch, controller) => TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        label: const Text("Password"),
                        errorText: watch(vm.password.error),
                      ),
                    ),
                  ),
                  FieldObserver(
                    field: vm.repeatPassword,
                    builder: (context, watch, controller) => TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        label: const Text("Repeat password"),
                        errorText: watch(vm.repeatPassword.error),
                      ),
                    ),
                  ),
                  Observer(
                    builder: (context, watch) => TextButton(
                      onPressed: watch(vm.isValid) ? vm.submit : null,
                      child: const Text("Submit"),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
