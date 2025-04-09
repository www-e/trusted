-- 08_grant_permissions.sql
-- Grant necessary permissions to authenticated users

-- Table permissions
GRANT SELECT, INSERT, UPDATE ON public.users TO authenticated;

-- Function permissions
GRANT EXECUTE ON FUNCTION public.is_admin TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_pending_users TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_user_status TO authenticated;
