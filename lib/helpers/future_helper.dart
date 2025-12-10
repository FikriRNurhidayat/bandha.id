import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

AsyncWidgetBuilder<T> futureBuilder<T>(AsyncWidgetBuilder<T> callback) {
  return (BuildContext context, AsyncSnapshot<T> snapshot) {
    final theme = Theme.of(context);

    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      if (kDebugMode) {
        print(snapshot.error);
        print(snapshot.stackTrace);
      }

      return Center(child: Text("..."));
    }

    if (!snapshot.hasData) {
      return Center(
        child: Icon(
          Icons.dashboard_customize_outlined,
          size: theme.textTheme.displayLarge!.fontSize,
        ),
      );
    }

    if (snapshot.data is List<dynamic>) {
      final data = snapshot.data as List<dynamic>;
      if (data.isEmpty) {
        return Center(
          child: Icon(
            Icons.dashboard_customize_outlined,
            size: theme.textTheme.displayLarge!.fontSize,
          ),
        );
      }
    }

    return callback(context, snapshot);
  };
}
