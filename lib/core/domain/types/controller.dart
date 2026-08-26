class Controller {
  final String id;
  final String type;

  Controller({required this.id, required this.type});

  static Controller? tryRow(Map row) {
    if (row["controller_id"] == null) {
      return null;
    }

    return Controller.fromRow(row);
  }

  factory Controller.fromRow(Map row) {
    return Controller(id: row["controller_id"], type: row["controller_type"]);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "type": type};
  }
}
