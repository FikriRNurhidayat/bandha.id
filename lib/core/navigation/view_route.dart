import 'package:flutter/material.dart';

class ViewRoute<T> extends MaterialPageRoute<T> {
  ViewRoute({required super.builder, super.settings});

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
