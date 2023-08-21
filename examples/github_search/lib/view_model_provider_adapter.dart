import 'dart:async';

import 'package:vessel_flutter/vessel_flutter.dart';
import 'package:warden/warden.dart';

class ViewModelProviderAdapter extends ProviderAdapter<ViewModel> {
  const ViewModelProviderAdapter();

  @override
  FutureOr<void> dispose(ViewModel providerValue) {
    providerValue.dispose();
  }
}
