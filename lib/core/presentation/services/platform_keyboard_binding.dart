import 'dart:async';

import 'package:bandha/core/presentation/services/platform_keyboard_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PlatformKeyboardBinding {
  static const _channelName = 'id.bandha.app/keyboard';

  static final PlatformKeyboardBinding instance = PlatformKeyboardBinding._();

  final ValueNotifier<PlatformKeyboardData> notifier =
      ValueNotifier(PlatformKeyboardData.hidden);

  final EventChannel _channel = const EventChannel(_channelName);
  StreamSubscription? _subscription;
  int _attachCount = 0;

  PlatformKeyboardBinding._();

  void attach() {
    _attachCount++;
    if (_attachCount == 1) {
      _subscription = _channel.receiveBroadcastStream().listen(
        (event) {
          final map = Map<String, dynamic>.from(event as Map);
          notifier.value = PlatformKeyboardData(
            visible: map['visible'] as bool,
            height: (map['height'] as num).toDouble(),
          );
        },
        cancelOnError: false,
      );
    }
  }

  void detach() {
    if (_attachCount == 0) return;
    _attachCount--;
    if (_attachCount == 0) {
      _subscription?.cancel();
      _subscription = null;
    }
  }
}
