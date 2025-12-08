INSERT INTO categories
(
    id,
    name,
    readonly,
    created_at,
    updated_at,
    deleted_at
)
VALUES
(
    uuid(),
    'Transfer',
    1,
    strftime('%Y-%m-%dT%H:%M:%S', 'now'),
    strftime('%Y-%m-%dT%H:%M:%S', 'now'),
    NULL
),
(
    uuid(),
    'Receivable',
    1,
    strftime('%Y-%m-%dT%H:%M:%S', 'now'),
    strftime('%Y-%m-%dT%H:%M:%S', 'now'),
    NULL
),
(
    uuid(),
    'Debt',
    1,
    strftime('%Y-%m-%dT%H:%M:%S', 'now'),
    strftime('%Y-%m-%dT%H:%M:%S', 'now'),
    NULL
) ON CONFLICT (name, deleted_at) DO NOTHING;
