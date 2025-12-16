import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeeplinkHandler {
  init(BuildContext context) async {
    final navigator = Navigator.of(context);
    final appLinks = AppLinks();
    final uri = await appLinks.getInitialLink();
    if (uri != null) navigate(navigator, uri);
    appLinks.uriLinkStream.listen((uri) {
      navigate(navigator, uri);
    });
  }

  void navigate(NavigatorState navigator, Uri uri) {
    if (uri.scheme == 'app' && uri.host == 'bandha.id') {
      final path = '/${uri.pathSegments.join('/')}';
      navigator.pushNamed(path);
    }
  }
}
