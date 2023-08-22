Simple state management for Flutter.

# Getting Started
1. Define ViewModel
    ```dart
   // import warden 
   import "package:warden/warden.dart"; 
   
    class CounterViewModel extends ViewModel {
      // define observable using `state` member function.
      late final counter = state(0);
      increment() => counter.value++;
    }
    ```
2. Watch value with `Warden` - it will rebuild the widget when the value changes:
    ```dart
   final vm = CounterViewModel();
   
   // ...
   
   Widget build(BuildContext context) {
      return Warden(
        builder: (context, watch) => OutlinedButton(
          onPressed: vm.increment,
          child: Text("${watch(vm.counter)}")
        ),
      );
   }
    ```

# `Computed`
Use `computed` to derive from `state`:

```dart
class User {
  final String name;
  User(this.name);
}

class UserProfileVm extends ViewModel {
  late final user = state<User?>(null);
  late final username = computed((watch) => watch(user)?.name ?? 'Guest');
}
```

# `Future`
`future` is an asynchronous `computed`:
```dart
// view_model.dart

class PostListVm extends ViewModel {
  late final page = state(1);
  late final posts = future(
    debounceTime: Duration(milliseconds: 500),         
    (watch) async {
       final page = watch(this.page);
       final posts = await Api.fetchPosts(page: page);
       return posts;
    },
  );
  
  // it will trigger `posts`'s refresh with increased page number, respecting debounceTime
  void nextPage() => page.value++;
  
  // triggers `posts`'s refresh ignoring debounce time and cancelling previous refresh
  void refresh() => posts.refresh();
}
```
```dart
/// posts_widget.dart

class PostsWidget extends StatelessWidget {
  final PostListVm vm;
  const PostsWidget(this.vm);

  Widget build(BuildContext context) {
    return Warden(
       builder: (context, watch) {
          final posts = watch(vm.posts);
          return switch (posts) {
            Loading() => const CircularProgressIndicator(),
            Success(value: var posts) => ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) => Text(posts[index].title),
            ),
            Failure(:var error) => Text(error.toString()),
          };
       }
    );
  }
}
```
## `AsyncValue`
`AsyncValue` is a default type for handling async data in `future`s.

It has three subtypes:
- `Loading` - the future is not completed yet
- `Success` - the future is completed successfully
- `Failure` - the future is completed with an error

It's a sealed class, so you can use `switch` to handle all cases.

`Loading` also has `previousResult` field, which is the last `Success`/`Failure` value. </br>
It might be useful for showing old data while loading new one:
```dart
Widget build(BuildContext context) {
  return Warden(
     builder: (context, watch) {
       final posts = watch(vm.posts);
       if (posts case Loading(previousResult: Success(value: var posts))) {
         return Stack(
            children: [
               ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) => Text(posts[index].title),
               ),
               const CircularProgressIndicator(),
            ]
         );
       }
       
       // ...
     }
  );
}
```


# `Dispose`
Every class extending `ViewModel` has `dispose` method. 
Call it once you don't need the ViewModel to release resources:

```dart
class MyWidget extends StatefulWidget {
   const MyWidget({super.key});

   @override
   State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
   final vm = CounterViewModel();
   
   @override
   Widget build(BuildContext context) {
      // ...
   }

   @override
   void dispose() {
      vm.dispose();
      super.dispose();
   }
}
```

## `disposers`
`disposers` is a `List<void Function()>` that is called when `dispose` is called.
You could register your own disposers:
```dart
class MyViewModel extends ViewModel {
   MyViewModel() {
     disposers.add(() => print('MyViewModel is disposed'));
  }
}

void main() {
  final vm = MyViewModel();
  vm.dispose(); // prints 'MyViewModel is disposed'
}
```

# `Observable` as `stream`
Every `Observable` could be converted to a stream.

```dart
class SearchScreenVm extends ViewModel {
   SearchScreenVm(this.githubApi) {
    final subscription = search.asStream().listen((value) {
      print("Search query changed to $value");
    });

    disposers.add(subscription.cancel);
  }

  late final search = state('');
}
```

# Why `late`?
`late` allows to call instance method in field initializer.
The following:
```dart
class CounterViewModel extends ViewModel {
  late final counter = state(0);
}
```
is a shorter (**but not the same!**) version for:
```dart
class CounterViewModel extends ViewModel {
  final ObservableState<int> counter;
  CounterViewModel(): counter = ObservableState(0) {
    disposers.add(counter.dispose);
  }
}
```

### Why "not the same"?
`late` fields are initialized *lazily* - when they are first accessed.
It's more notable with `future` observables:
```dart
class CounterViewModel extends ViewModel {
  late final counter = future(() async {
    print('Future is executed');
    return Future.delayed(const Duration(seconds: 1), () => 42);
  });
}

void main() {
  final vm = CounterViewModel(); // prints nothing
  vm.counter; // prints 'Future is executed'
}
```