Simple state management for Flutter.

# Getting Started
1. Define ViewModel
    ```dart
    // import warden 
    import "package:beholder/beholder.dart"; 
    
    class CounterViewModel extends ViewModel {
       // define observable using `state` member function.
       late final counter = state(0);
       increment() => counter.value++;
    }
    ```
2. Watch value with `Observer` - it will rebuild the widget when the value changes:
    ```dart
   final vm = CounterViewModel();
   
   // ...
   
   Widget build(BuildContext context) {
      return Observer(
        builder: (context, watch) => OutlinedButton(
          onPressed: vm.increment,
          child: Text("${watch(vm.counter)}")
        ),
      );
   }
    ```

# `computed`
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

# `asyncState`
`asyncState` is an asynchronous `state` with quality of life additions:
```dart
// view_model.dart

class PostListVm extends ViewModel {
  PostListVm() {
    refresh();
  }
  
  late final page = state(
    1, 
    onSet: (page) => posts.scheduleRefresh(() => Api.fetchPosts(page: page)),
  );
  
  late final posts = asyncState(
    initialValue: const Loading(), 
    debounceTime: const Duration(milliseconds: 500)
  );
  
  // it will trigger `posts`'s refresh with increased page number, respecting debounceTime
  void nextPage() => page.value++;
  
  // triggers `posts`'s refresh ignoring debounce time and cancelling previous refresh
  void refresh() => posts.refresh(() => Api.fetchPosts(page: page.value));
}
```
```dart
/// posts_widget.dart

class PostsWidget extends StatelessWidget {
  final PostListVm vm;
  const PostsWidget(this.vm);

  Widget build(BuildContext context) {
    return Observer(
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
### `AsyncValue`
`AsyncValue` is a default type for handling async data in `asyncState`s.

It has three subtypes:
- `Loading` - the future is not completed yet
- `Success` - the future is completed successfully
- `Failure` - the future is completed with an error

It's a sealed class, so you can use `switch` to handle all cases.

`Loading` also has `previousResult` field, which is the last `Success`/`Failure` value. </br>
It might be useful for showing old data while loading new one:
```dart
Widget build(BuildContext context) {
  return Observer(
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

## `autoDispose`
`autoDispose` comes in handy when you're composing several `ViewModel`s:

```dart
class HomeViewModel extends ViewModel {
  late final appBarVm = autoDispose(AppBarViewModel());
  late final bottomBarVm = autoDispose(BottomBarViewModel());
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
is a shorter (**but not the same!***) version for:
```dart
class CounterViewModel extends ViewModel {
  final ObservableState<int> counter;
  CounterViewModel(): counter = ObservableState(0) {
    disposers.add(counter.dispose);
  }
}

```
*\*`late` fields are initialized *lazily* - when they are first accessed.*
