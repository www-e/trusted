-- 06_create_user_management_functions.sql
-- Create functions for user management

-- Function to get pending users (admin only)
CREATE OR REPLACE FUNCTION public.get_pending_users()
RETURNS SETOF public.users AS $$
BEGIN
    IF public.is_admin() THEN
        RETURN QUERY SELECT * FROM public.users WHERE status = 'pending';
    ELSE
        RAISE EXCEPTION 'Only admin can access this function';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update user status (admin only)
CREATE OR REPLACE FUNCTION public.update_user_status(user_id UUID, new_status TEXT)
RETURNS VOID AS $$
BEGIN
    IF public.is_admin() THEN
        IF new_status NOT IN ('active', 'pending') THEN
            RAISE EXCEPTION 'Invalid status: must be active or pending';
        END IF;
        
        UPDATE public.users 
        SET status = new_status 
        WHERE id = user_id;
    ELSE
        RAISE EXCEPTION 'Only admin can update user status';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
