-- 04_create_user_policies.sql
-- Create policies for regular users

-- Drop existing policies first to avoid errors
DROP POLICY IF EXISTS users_read_own ON public.users;
DROP POLICY IF EXISTS users_update_own ON public.users;
DROP POLICY IF EXISTS users_insert_own ON public.users;

-- Policy for users to read their own data
CREATE POLICY users_read_own ON public.users 
    FOR SELECT 
    USING (auth.uid() = id);

-- Policy for users to update their own data
CREATE POLICY users_update_own ON public.users 
    FOR UPDATE 
    USING (auth.uid() = id);

-- Policy for inserting new users (anyone can create their own record)
CREATE POLICY users_insert_own ON public.users 
    FOR INSERT 
    WITH CHECK (auth.uid() = id);
