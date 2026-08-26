import 'package:flutter/material.dart';

extension TextInputActionLabel on TextInputAction {
  String get label => switch (this) {
    TextInputAction.done => 'Done',
    TextInputAction.go => 'Go',
    TextInputAction.send => 'Send',
    TextInputAction.search => 'Search',
    TextInputAction.next => 'Next',
    TextInputAction.previous => 'Previous',
    TextInputAction.continueAction => 'Continue',
    TextInputAction.join => 'Join',
    TextInputAction.route => 'Route',
    TextInputAction.emergencyCall => 'Emergency Call',
    TextInputAction.newline => 'New line',
    _ => "Done",
  };
}
