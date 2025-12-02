import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeeplinkHandler {
  init(BuildContext context) async {
    final appLinks = AppLinks();
    final uri = await appLinks.getInitialLink();
    if (uri != null) navigate(context, uri);
    appLinks.uriLinkStream.listen((uri) {
      navigate(context, uri);
    });
  }

  void navigate(BuildContext context, Uri uri) {
    if (uri.scheme == 'app' && uri.host == 'bandha.id') {
      final path = '/${uri.pathSegments.join('/')}';
      Navigator.of(context).pushNamed(path);
    }
  }
}
