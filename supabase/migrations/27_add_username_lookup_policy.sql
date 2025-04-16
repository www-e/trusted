-- 27_add_username_lookup_policy.sql
-- Add a policy to allow username lookups during login

-- Drop the policy if it already exists
DROP POLICY IF EXISTS users_lookup_by_username ON public.users;

-- Create a policy that allows reading username and email for login purposes
-- This allows any client to look up users by username for authentication
CREATE POLICY users_lookup_by_username ON public.users
    FOR SELECT
    USING (true);

-- Add column-level security to restrict which columns can be accessed
-- This is optional but recommended for production environments
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Grant explicit SELECT permission on specific columns only
-- This ensures only necessary fields are exposed for authentication
GRANT SELECT (id, username, email) ON public.users TO authenticated, anon;

-- Note: This policy allows reading user records for authentication purposes
-- The column-level security ensures only necessary fields are exposed
