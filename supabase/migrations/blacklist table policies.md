| schemaname | tablename | policyname             | permissive | roles           | cmd    | qual                                                                                                  | with_check |
| ---------- | --------- | ---------------------- | ---------- | --------------- | ------ | ----------------------------------------------------------------------------------------------------- | ---------- |
| public     | blacklist | admin_manage_blacklist | PERMISSIVE | {authenticated} | ALL    | (EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = auth.uid()) AND (users.role = 'admin'::text)))) | null       |
| public     | blacklist | users_view_blacklist   | PERMISSIVE | {authenticated} | SELECT | true                                                                                                  | null       |