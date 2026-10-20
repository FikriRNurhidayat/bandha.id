enum DataCursorDirection {
  next("<"),
  previous(">");

  final String operator;
  const DataCursorDirection(this.operator);
}

class DataCursor {
  final DataCursorDirection direction;
  final Map<String, dynamic> values;

  DataCursor({required this.direction, required this.values});
}
