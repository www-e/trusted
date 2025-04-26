| schemaname | tablename | policyname               | permissive | roles           | cmd    | qual              | with_check        |
| ---------- | --------- | ------------------------ | ---------- | --------------- | ------ | ----------------- | ----------------- |
| public     | users     | admin_read_all           | PERMISSIVE | {public}        | SELECT | is_admin()        | null              |
| public     | users     | admin_update_all         | PERMISSIVE | {public}        | UPDATE | is_admin()        | null              |
| public     | users     | users_insert_own         | PERMISSIVE | {authenticated} | INSERT | null              | (auth.uid() = id) |
| public     | users     | users_lookup_by_username | PERMISSIVE | {public}        | SELECT | true              | null              |
| public     | users     | users_read_own           | PERMISSIVE | {public}        | SELECT | (auth.uid() = id) | null              |
| public     | users     | users_update_own         | PERMISSIVE | {authenticated} | UPDATE | (auth.uid() = id) | null              |