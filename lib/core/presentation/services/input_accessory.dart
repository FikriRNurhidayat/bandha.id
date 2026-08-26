import 'package:flutter/material.dart';

mixin InputAccessory<T extends StatefulWidget> on State<T> {
  FocusNode? focusNode;
  FocusNode get effectiveFocusNode;
  PersistentBottomSheetController? _persistentBottomSheetController;
  bool _wasFocus = false;

  @override
  void initState() {
    debugPrint("InputAccessory/initState");
    super.initState();
    effectiveFocusNode.addListener(didChangeFocus);
  }

  void didChangeFocus() {
    debugPrint("InputAccessory/didChangeFocus");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (effectiveFocusNode.hasFocus) {
        didFocus();
      } else {
        didBlur();
      }
    });
  }

  void didFocus() {
    debugPrint("InputAccessory/didFocus");
    if (accessoryBuilder != null) {
      _persistentBottomSheetController = Scaffold.of(context).showBottomSheet(
        accessoryBuilder!,
        shape: const RoundedRectangleBorder(),
      );
      _persistentBottomSheetController?.closed.whenComplete(() {
        if (!mounted) return;
        if (effectiveFocusNode.hasFocus) {
          effectiveFocusNode.unfocus();
        }
      });
    }
  }

  void didBlur() {
    debugPrint("InputAccessory/didBlur");
    dismissAccessory();
  }

  WidgetBuilder? get accessoryBuilder;

  void dismissAccessory() {
    debugPrint("InputAccessory/_dismissAccessory");
    _persistentBottomSheetController?.close();
    _persistentBottomSheetController = null;
  }

  void refocusIfNeeded() {
    debugPrint("InputAccessory/refocusIfNeeded");
    if (_wasFocus) {
      dismissAccessory();
      effectiveFocusNode.requestFocus();
      _wasFocus = false;
    }
  }

  void mustNotFocus() {
    debugPrint("InputAccessory/mustNotFocus");
    if (effectiveFocusNode.hasFocus) {
      _wasFocus = true;
      dismissAccessory();
      effectiveFocusNode.unfocus();
    }
  }

  @override
  dispose() {
    focusNode?.dispose();
    super.dispose();
  }
}
