CREATE TABLE IF NOT EXISTS transfers (
    id TEXT PRIMARY KEY,
    note TEXT,
    credit_id TEXT NOT NULL REFERENCES entries (id) ON DELETE CASCADE,
    credit_fee_id TEXT REFERENCES entries (id) ON DELETE CASCADE,
    debit_id TEXT NOT NULL REFERENCES entries (id) ON DELETE CASCADE,
    debit_fee_id TEXT REFERENCES entries (id) ON DELETE CASCADE,
    issued_at TEXT NOT NULL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);
