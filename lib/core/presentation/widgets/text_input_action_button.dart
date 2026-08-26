import 'package:bandha/core/presentation/widgets/text_input_action_text.dart';
import 'package:flutter/material.dart';

class TextInputActionButton extends StatelessWidget {
  final TextInputAction? textInputAction;
  final VoidCallback? onNext;
  final VoidCallback? onDone;

  const TextInputActionButton(
    this.textInputAction, {
    super.key,
    this.onNext,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        switch (textInputAction) {
          case TextInputAction.next:
            onNext?.call();
          default:
            onDone?.call();
        }
      },
      child: TextInputActionText(textInputAction),
    );
  }
}
