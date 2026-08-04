enum DataCursorDirection { next, previous }

class DataCursor {
  final DataCursorDirection direction;
  final Map<String, dynamic> values;

  DataCursor({required this.direction, required this.values});
}
