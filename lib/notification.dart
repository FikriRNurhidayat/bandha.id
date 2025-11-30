import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
didReceiveBackgroundNotificationResponseCallback(
  NotificationResponse response,
) {
  print("Background response: $response");
}
