import 'package:flutter/material.dart';

extension TextInputActionLabel on TextInputAction {
  String get label {
    switch (this) {
      case TextInputAction.done:
        return 'Done';
      case TextInputAction.go:
        return 'Go';
      case TextInputAction.send:
        return 'Send';
      case TextInputAction.search:
        return 'Search';
      case TextInputAction.next:
        return 'Next';
      case TextInputAction.previous:
        return 'Previous';
      case TextInputAction.continueAction:
        return 'Continue';
      case TextInputAction.join:
        return 'Join';
      case TextInputAction.route:
        return 'Route';
      case TextInputAction.emergencyCall:
        return 'Emergency Call';
      case TextInputAction.newline:
        return 'New line';
      default:
        return "Done";
    }
  }
}

class XFormFieldAccessory extends StatelessWidget {
  final TextInputAction textInputAction;
  final FocusNode focusNode;
  final Widget? child;
  final VoidCallback? onSubmit;

  const XFormFieldAccessory({
    super.key,
    required this.focusNode,
    this.child,
    this.textInputAction = TextInputAction.done,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    if (focusNode.hasFocus) focusNode.previousFocus();
                  },
                  icon: const Icon(Icons.keyboard_arrow_up),
                ),
                IconButton(
                  onPressed: () {
                    if (focusNode.hasFocus) focusNode.nextFocus();
                  },
                  icon: const Icon(Icons.keyboard_arrow_down),
                ),
                TextButton(
                  onPressed: () {
                    switch (textInputAction) {
                      case TextInputAction.search:
                      case TextInputAction.done:
                      case TextInputAction.send:
                        focusNode.unfocus();
                        onSubmit?.call();
                      case TextInputAction.continueAction:
                      case TextInputAction.next:
                        focusNode.nextFocus();
                      case TextInputAction.previous:
                        focusNode.previousFocus();
                      default:
                    }
                  },
                  child: Text(textInputAction.label),
                ),
              ],
            ),
            ?child,
          ],
        ),
      ),
    );
  }
}
