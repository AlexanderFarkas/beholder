library beholder_provider;

import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:provider/provider.dart';

class ViewModelProvider<T extends ViewModel> extends InheritedProvider<T> {
  ViewModelProvider({
    super.key,
    required super.create,
    Dispose<T>? dispose,
    super.lazy,
    ObserverBuilder? builder,
  }) : super(
          dispose: (context, viewModel) {
            if (dispose != null) {
              dispose(context, viewModel);
            } else {
              viewModel.dispose();
            }
          },
          child: builder != null ? Observer(builder: builder) : null,
        );

  ViewModelProvider.value({
    super.key,
    required super.value,
    super.updateShouldNotify,
    ObserverBuilder? builder,
  }) : super.value(child: builder != null ? Observer(builder: builder) : null);
}
