INSERT INTO labels
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
    'd84cbeeb-a35c-47fb-983b-42c5a8c7e8f6',
    'Fee',
    1,
    strftime('%Y-%m-%dT%H:%M:%S', 'now'),
    strftime('%Y-%m-%dT%H:%M:%S', 'now'),
    NULL
),
(
    '93242916-4ffb-4757-8f81-abc62fe26d90',
    'Tax',
    1,
    strftime('%Y-%m-%dT%H:%M:%S', 'now'),
    strftime('%Y-%m-%dT%H:%M:%S', 'now'),
    NULL
) ON CONFLICT (name, deleted_at) DO NOTHING;
