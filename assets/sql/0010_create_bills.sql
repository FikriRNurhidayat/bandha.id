CREATE TABLE IF NOT EXISTS bills (
    id TEXT PRIMARY KEY,
    note TEXT NOT NULL,
    amount REAL NOT NULL,
    cycle TEXT NOT NULL,
    status TEXT NOT NULL,
    entry_id TEXT NOT NULL REFERENCES entries (id),
    category_id TEXT NOT NULL REFERENCES categories (id) ON DELETE CASCADE,
    account_id TEXT NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
    billed_at TEXT NOT NULL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT
);
CREATE TABLE IF NOT EXISTS bill_payments (
    entry_id TEXT NOT NULL REFERENCES entries (id) ON DELETE CASCADE,
    bill_id TEXT NOT NULL REFERENCES bills (id) ON DELETE CASCADE,
    fee REAL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    PRIMARY KEY (entry_id, bill_id)
);

CREATE TABLE IF NOT EXISTS bill_labels (
    label_id TEXT NOT NULL REFERENCES labels (id) ON DELETE CASCADE,
    bill_id TEXT NOT NULL REFERENCES bills (id) ON DELETE CASCADE,
    PRIMARY KEY (label_id, bill_id)
);
