import 'package:flutter/material.dart';

class XFormFieldAccessory extends StatelessWidget {
  final FocusNode focusNode;
  final Widget? child;

  const XFormFieldAccessory({super.key, required this.focusNode, this.child});

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
                    focusNode.nextFocus();
                  },
                  child: const Text('Done'),
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
