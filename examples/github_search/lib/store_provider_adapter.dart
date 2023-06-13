import 'dart:async';

import 'package:vessel_flutter/vessel_flutter.dart';
import 'package:warden/warden.dart';

class StoreProviderAdapter extends ProviderAdapter<Store> {
  const StoreProviderAdapter();

  @override
  FutureOr<void> dispose(Store providerValue) {
    providerValue.dispose();
  }
}
