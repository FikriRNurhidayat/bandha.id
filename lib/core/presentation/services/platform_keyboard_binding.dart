import 'dart:async';

import 'package:bandha/core/presentation/services/platform_keyboard_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PlatformKeyboardBinding {
  static const _channelName = 'id.bandha.app/keyboard';

  final ValueNotifier<PlatformKeyboardData> notifier =
      ValueNotifier(PlatformKeyboardData.hidden);
  final EventChannel _channel;

  StreamSubscription? _subscription;
  bool _disposed = false;

  PlatformKeyboardBinding({EventChannel? channel})
    : _channel = channel ?? const EventChannel(_channelName);

  Future<void> initialize() async {
    if (_disposed) return;
    _subscription = _channel.receiveBroadcastStream().listen(
      (event) {
        if (_disposed) return;
        final map = Map<String, dynamic>.from(event as Map);
        notifier.value = PlatformKeyboardData(
          visible: map['visible'] as bool,
          height: (map['height'] as num).toDouble(),
        );
      },
      cancelOnError: false,
    );
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _subscription?.cancel();
    _subscription = null;
    notifier.dispose();
  }
}
