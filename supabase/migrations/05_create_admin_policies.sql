-- 05_create_admin_policies.sql
-- Create policies for admin users

-- Drop existing policies first to avoid errors
DROP POLICY IF EXISTS admin_read_all ON public.users;
DROP POLICY IF EXISTS admin_update_all ON public.users;

-- Policy for admin to read all users (fixed to avoid recursion)
CREATE POLICY admin_read_all ON public.users 
    FOR SELECT 
    USING (public.is_admin());

-- Policy for admin to update all users (fixed to avoid recursion)
CREATE POLICY admin_update_all ON public.users 
    FOR UPDATE 
    USING (public.is_admin());
