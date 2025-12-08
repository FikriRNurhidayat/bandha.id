CREATE TABLE IF NOT EXISTS notifications (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    sent_at TEXT NOT NULL,
    controller_id TEXT NOT NULL,
    controller_type TEXT NOT NULL
);
