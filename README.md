NOTE: Package is supported. I just haven't found any bugs since the last commit.

Simple state management for Flutter.

This package is built to work with:
- [beholder_form](https://pub.dev/packages/beholder_form) - elegant form validation
- [beholder_provider](https://pub.dev/packages/beholder_provider) - [package:provider](https://pub.dev/packages/provider) integration

# Getting Started
1. Define a `ViewModel`
   ```dart
   class CounterViewModel extends ViewModel {}
   ```

2. Define state and a method to update it:
   ```dart
   class CounterViewModel extends ViewModel {
     late final counter = state(0);
     void increment() => counter.value++;
   }
   ```
3. Watch value with `Observer` - it will rebuild the widget when the value changes:
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
# `ViewModel`
`ViewModel` is used to group `Observable`s.
Usually, you want to define `ViewModel` per piece of UI - it should represent UI state and related business rules.

If we need to develop a screen for searching users, its `ViewModel` might look like that:
```dart
class SearchUsersScreenVm extends ViewModel {
  late final search = state("");
  late final users = state(Loading<List<User>>()); // *

  SearchUsersScreenVm() {
    search.listen((_, current) => refresh());
  }
  
  Future<void> refresh() async {
    users.value = Loading();
    try {
      final List<User> result = Api.fetchUsers(search: search.value);
      users.value = Data(result);
    } catch (error) {
      users.value = Failure(error);
    }
  }
}
```
**`Data`, `Failure` and `Loading` - are helper classes. Read more about them [here](#asyncvalue)*

## `Dispose`
Every class extending `ViewModel` has `dispose` method.
Call it once you don't need `ViewModel` to release resources:

```dart
class MyWidget extends StatefulWidget {
   const MyWidget({super.key});

   @override
   State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
   final vm = SearchUsersScreenVm();
   
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


# Observables

## `state`
`state` is a core concept in `beholder`. 
It tracks changes to its value and notifies every observer listening.

### Updating value
```dart
late final counter = state(0);
void increment() {
  counter.value = counter.value + 1;
  // or
  counter.update((current) => current + 1);
}
```

### Listening to value changes
```dart
counter.listen((previous, current) {
  // Do something with `current`
});
```

## `computed`
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

## `computedFactory`
Need a parametrized `computed`? Use `computedFactory`:
```dart
class UserListVm extends ViewModel {
  late final users = state(<User>[]);
  late final usernameByIndex = computedFactory((watch, int index) {
    return watch(users)[index];
  });
}
```

Usage:
```dart
final vm = UserListVm();

Widget build(BuildContext context) {
   return ListView.builder(
     itemBuilder: (context, index) => Observer(
        builder: (context, watch) {
          final username = watch(vm.usernameByIndex(index));
          return Text(username);
        }
     )
   );
}
```


## `Observable` as `stream`
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

# Utils

## `AsyncValue`
`AsyncValue` is a default type for handling async data in `asyncState`s.

It has three subtypes:
- `Data` - the future is completed successfully
- `Loading` - the future is not completed yet
- `Failure` - the future is completed with an error

It's a sealed class, so you can use `switch` to handle all cases.

`Loading` also has `previousResult` field, which is the last `Data`/`Failure` value. </br>
It might be useful for showing old data while loading new one:
```dart
Widget build(BuildContext context) {
  return Observer(
     builder: (context, watch) {
       final posts = watch(vm.posts);
       if (posts case Loading(previousResult: Data(value: var posts))) {
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
