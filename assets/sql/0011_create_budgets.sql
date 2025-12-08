CREATE TABLE IF NOT EXISTS budgets (
    id TEXT PRIMARY KEY,
    note TEXT NOT NULL,
    usage REAL NOT NULL,
    threshold REAL NOT NULL,
    "limit" REAL NOT NULL,
    cycle TEXT NOT NULL,
    category_id TEXT NOT NULL REFERENCES categories (id) ON DELETE CASCADE,
    issued_at TEXT NOT NULL,
    start_at TEXT,
    end_at TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT
);

CREATE TABLE IF NOT EXISTS budget_labels (
    label_id TEXT NOT NULL REFERENCES labels (id) ON DELETE CASCADE,
    budget_id TEXT NOT NULL REFERENCES budgets (id) ON DELETE CASCADE,
    PRIMARY KEY (label_id, budget_id)
);

CREATE TABLE IF NOT EXISTS budget_history (
    id TEXT PRIMARY KEY,
    budget_id TEXT NOT NULL REFERENCES budgets (id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    usage REAL NOT NULL,
    threshold REAL NOT NULL,
    "limit" REAL NOT NULL,
    start_at TEXT,
    end_at TEXT
);
