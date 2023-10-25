library beholder_provider;

import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ViewModelProvider<T extends ViewModel> extends InheritedProvider<T> {
  ViewModelProvider({
    super.key,
    required super.create,
    Dispose<T>? dispose,
    super.lazy,
    ObserverBuilder? builder,
    Widget? child,
  })  : assert(builder != null || child != null, "Either builder or child must be provided"),
        assert(builder == null || child == null, "Either builder or child must be provided"),
        super(
          dispose: (context, viewModel) {
            if (dispose != null) {
              dispose(context, viewModel);
            } else {
              viewModel.dispose();
            }
          },
          child: builder != null ? Observer(builder: builder) : child,
        );

  ViewModelProvider.value({
    super.key,
    required super.value,
    super.updateShouldNotify,
    ObserverBuilder? builder,
    Widget? child,
  })  : assert(builder != null || child != null, "Either builder or child must be provided"),
        assert(builder == null || child == null, "Either builder or child must be provided"),
        super.value(child: builder != null ? Observer(builder: builder) : child);
}
