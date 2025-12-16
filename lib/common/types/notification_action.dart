enum NotificationAction {
  markEntryAsDone("Mark as Done"),
  snoozeEntry("Snooze");

  final String title;

  get id {
    return name;
  }

  static parse(String id) {
    return NotificationAction.values.firstWhere((i) => i.id == id);
  }

  const NotificationAction(this.title);
}
