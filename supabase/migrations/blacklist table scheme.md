| column_name  | data_type                | is_nullable | column_default     |
| ------------ | ------------------------ | ----------- | ------------------ |
| id           | uuid                     | NO          | uuid_generate_v4() |
| user_id      | uuid                     | YES         | null               |
| email        | text                     | YES         | null               |
| phone_number | text                     | YES         | null               |
| device_id    | text                     | YES         | null               |
| reason       | text                     | NO          | null               |
| banned_at    | timestamp with time zone | NO          | now()              |
| banned_by    | uuid                     | YES         | null               |
| is_active    | boolean                  | NO          | true               |
| created_at   | timestamp with time zone | NO          | now()              |
| updated_at   | timestamp with time zone | YES         | now()              |