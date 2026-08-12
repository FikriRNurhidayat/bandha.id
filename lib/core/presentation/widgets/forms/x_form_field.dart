import 'package:flutter/material.dart';

class XFormField<T> extends FormField<T> {
  final TextInputAction? textInputAction;
  final VoidCallback? onFieldSubmitted;
  final bool readOnly;
  final bool autofocus;

  const XFormField({
    super.key,
    super.onSaved,
    super.validator,
    super.enabled,
    super.initialValue,
    super.autovalidateMode,
    required super.builder,
    this.textInputAction,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.autofocus = false,
  });

  @override
  FormFieldState<T> createState() => XFormFieldState<T, XFormField<T>>();
}

class XFormFieldState<T, W extends XFormField<T>> extends FormFieldState<T> {
  W get view => widget as W;

  final FocusNode focusNode = FocusNode();

  PersistentBottomSheetController? sheetController;
  bool wasFocus = false;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChanged);
  }

  void onFocusChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (focusNode.hasFocus) {
        onFocus();
      } else {
        onBlur();
      }
    });
  }

  void onFocus() {
    showAccessory();
  }

  void onBlur() {
    dismissAccessory();
  }

  void showAccessory() {}

  void dismissAccessory() {
    sheetController?.close();
    sheetController = null;
  }

  void refocusIfNeeded() {
    if (wasFocus) {
      dismissAccessory();
      focusNode.requestFocus();
      wasFocus = false;
    }
  }

  void mustNotFocus() {
    if (focusNode.hasFocus) {
      wasFocus = true;
      dismissAccessory();
      focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(onFocusChanged);
    focusNode.dispose();
    super.dispose();
  }
}
