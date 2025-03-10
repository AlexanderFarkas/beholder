## 0.4.2

 - **FEAT**: add toggle extension method.

## 0.4.1+1

 - **FIX**: edgecase.

## 0.4.1

 - **FEAT**: generalize `data` and `dataOrNull` getters to all observables.

## 0.4.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: better error handling during computeds' rebuilds.

## 0.3.1+1

 - **FIX**: concurrent modification.

## 0.3.1

 - **FEAT**: add `Watchable`.

## 0.3.0+4

 - **FIX**: don't create inner state of computed, if it was disposed.

## 0.3.0+3

 - **FIX**: catch any errors during prepare/rebuild.

## 0.3.0+2

 - **FIX**: computed superfluous rebuilds.

## 0.3.0+1

 - **FIX**: computed superfluous rebuilds.

## 0.3.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: internal refactoring.

## 0.2.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: make computed lazy.

## 0.1.1+1

 - **FIX**: handle throws in `prepare` and `build`.

## 0.1.1

 - **FEAT**: computed factory.

## 0.1.0+1

 - **FIX**: allow `data` and `dataOrNull` shortcuts on ObservableState<AsyncValue>.

## 0.1.0

> Note: This release has breaking changes.

 - **BREAKING** **REFACTOR**: internal rework.

## 0.0.3+2

 - **FIX**: superfluous print.

## 0.0.3+1

 - **REFACTOR**: inner code organization.

## 0.0.3

 - **FEAT**: export plugins.

## 0.0.2+1

 - **REFACTOR**: AsyncValue extensions.

## 0.0.2

 - **FEAT**: autoDispose plugin.

## 0.0.1+9

 - **REFACTOR**: add 'ObserverBuilder' typedef.

## 0.0.1+8

 - **FIX**: cancellation token wrong behavior.

## 0.0.1+7

 - **REFACTOR**: add `CancellationToken` to `asyncState`.

## 0.0.1+6

 - **REFACTOR**: refresh returns Result.

## 0.0.1+5

 - **REFACTOR**: rename Dispose -> Disposer.

## 0.0.1+4

 - **REFACTOR**: remove onSet.

## 0.0.1+3

 - **REFACTOR**: allow FutureOr<T> for Result.guard.

## 0.0.1+2

- **DOCS**: fix symlinks.

## 0.0.1+1

 - **REVERT**: restricting watch usages.

## 0.0.1

- Initial version.
