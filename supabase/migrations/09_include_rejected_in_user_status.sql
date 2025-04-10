-- 09_update_user_status_function.sql
-- Update the user status function to allow 'rejected' status

-- Update the function to update user status (admin only)
CREATE OR REPLACE FUNCTION public.update_user_status(user_id UUID, new_status TEXT)
RETURNS VOID AS $$
BEGIN
    IF public.is_admin() THEN
        IF new_status NOT IN ('active', 'pending', 'rejected') THEN
            RAISE EXCEPTION 'Invalid status: must be active, pending, or rejected';
        END IF;
        
        UPDATE public.users 
        SET status = new_status 
        WHERE id = user_id;
    ELSE
        RAISE EXCEPTION 'Only admin can update user status';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
