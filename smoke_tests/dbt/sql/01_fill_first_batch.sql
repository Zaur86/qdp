insert into stg.web__registrations (event_id, data, record_source)
values
  ('evt-1', '{
    "user_id": "user-123",
    "registration_channel": "email",
    "event_time": "2025-03-30T12:00:00"
  }'::jsonb, 'smoke_test'),

  ('evt-2', '{
    "user_id": "user-456",
    "registration_channel": "telegram",
    "event_time": "2025-03-30T12:05:00"
  }'::jsonb, 'smoke_test');
