import 'package:flutter/material.dart';

class TextInputActionText extends StatelessWidget {
  final TextInputAction? textInputAction;

  const TextInputActionText(this.textInputAction, {super.key});

  @override
  Widget build(BuildContext context) {
    final text = switch (textInputAction) {
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

    return Text(text);
  }
}
