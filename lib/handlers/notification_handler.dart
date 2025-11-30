import 'package:banda/types/controller_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandler {
  final GlobalKey<NavigatorState> navigator;

  NotificationHandler(this.navigator);

  navigate(String path) async {
    return navigator.currentState!.pushNamed(path);
  }

  handle(NotificationResponse response) async {
    final notificationType = ControllerType.parse(
      response.notificationResponseType.name,
    );

    switch (notificationType) {
      case ControllerType.entry:
        return navigate("/entries/${response.payload!}/detail");
      case ControllerType.loan:
        return navigate("/loans/${response.payload!}/detail");
      case ControllerType.budget:
        return navigate("/budgets/${response.payload!}/detail");
      case ControllerType.bill:
        return navigate("/bills/${response.payload!}/detail");
      case ControllerType.savings:
        return navigate("/savings/${response.payload!}/detail");
      case ControllerType.transfer:
        return navigate("/transfers/${response.payload!}/detail");
      default:
    }
  }
}
