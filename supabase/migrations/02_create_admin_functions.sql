-- 02_create_admin_functions.sql
-- Create function to check if user is admin (before enabling RLS)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    -- Check directly against auth.users to avoid recursion
    RETURN EXISTS (
        SELECT 1 FROM auth.users 
        WHERE id = auth.uid() AND email = 'omarasj445@gmail.com'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
