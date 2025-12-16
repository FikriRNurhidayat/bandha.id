import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
didReceiveBackgroundNotificationResponseCallback(
  NotificationResponse response,
) {
  if (kDebugMode) {
    print("Background response: $response");
  }
}
