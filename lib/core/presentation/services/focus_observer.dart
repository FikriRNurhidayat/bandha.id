import 'package:flutter/material.dart';

mixin FocusObserver<T extends StatefulWidget> on State<T> {
  FocusNode? get focusNode;
  FocusNode get effectiveFocusNode;
  bool _wasFocus = false;

  @override
  void initState() {
    debugPrint("FocusObserver/initState");
    super.initState();
    effectiveFocusNode.addListener(didChangeFocus);
  }

  @mustCallSuper
  void didChangeFocus() {
    debugPrint("FocusObserver/didChangeFocus");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (effectiveFocusNode.hasFocus) {
        didFocus();
      } else {
        didBlur();
      }
    });
  }

  @mustCallSuper
  void didFocus() {
    debugPrint("FocusObserver/didFocus");
  }

  @mustCallSuper
  void didBlur() {
    debugPrint("FocusObserver/didBlur");
  }

  void refocusIfNeeded() {
    debugPrint("FocusObserver/refocusIfNeeded");
    if (_wasFocus) {
      effectiveFocusNode.requestFocus();
      _wasFocus = false;
    }
  }

  void mustNotFocus() {
    debugPrint("FocusObserver/mustNotFocus");
    if (effectiveFocusNode.hasFocus) {
      _wasFocus = true;
      effectiveFocusNode.unfocus();
    }
  }

  @override
  dispose() {
    debugPrint("FocusObserver/dispose");
    focusNode?.dispose();
    super.dispose();
  }
}
