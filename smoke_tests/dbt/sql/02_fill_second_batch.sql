insert into stg.web__registrations (event_id, data, record_source)
values
  ('evt-3', '{
    "user_id": "user-123",
    "registration_channel": "mobile",
    "event_time": "2025-03-30T12:10:00"
  }'::jsonb, 'smoke_test'),

  ('evt-4', '{
    "user_id": "user-789",
    "registration_channel": "ads",
    "event_time": "2025-03-30T12:15:00"
  }'::jsonb, 'smoke_test');
