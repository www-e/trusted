-- 11_add_accepted_at_column.sql
-- Add accepted_at column to users table and update user management functions

-- Add accepted_at column to users table
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS accepted_at TIMESTAMP WITH TIME ZONE;

-- Update the function to update user status (admin only) to set accepted_at when status is set to active
CREATE OR REPLACE FUNCTION public.update_user_status(user_id UUID, new_status TEXT)
RETURNS VOID AS $$
BEGIN
    IF public.is_admin() THEN
        IF new_status NOT IN ('active', 'pending', 'rejected') THEN
            RAISE EXCEPTION 'Invalid status: must be active, pending, or rejected';
        END IF;
        
        IF new_status = 'active' THEN
            UPDATE public.users 
            SET status = new_status, accepted_at = NOW() 
            WHERE id = user_id;
        ELSE
            UPDATE public.users 
            SET status = new_status
            WHERE id = user_id;
        END IF;
    ELSE
        RAISE EXCEPTION 'Only admin can update user status';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get all users (admin only)
CREATE OR REPLACE FUNCTION public.get_all_users()
RETURNS SETOF public.users AS $$
BEGIN
    IF public.is_admin() THEN
        RETURN QUERY SELECT * FROM public.users ORDER BY created_at DESC;
    ELSE
        RAISE EXCEPTION 'Only admin can access this function';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to update user data (admin only)
CREATE OR REPLACE FUNCTION public.update_user_data(
    user_id UUID,
    user_name TEXT,
    user_phone_number TEXT,
    user_secondary_phone_number TEXT,
    user_nickname TEXT,
    user_country TEXT,
    user_business_name TEXT,
    user_business_description TEXT,
    user_whatsapp_number TEXT
)
RETURNS VOID AS $$
BEGIN
    IF public.is_admin() THEN
        UPDATE public.users 
        SET 
            name = user_name,
            phone_number = user_phone_number,
            secondary_phone_number = user_secondary_phone_number,
            nickname = user_nickname,
            country = user_country,
            business_name = user_business_name,
            business_description = user_business_description,
            whatsapp_number = user_whatsapp_number
        WHERE id = user_id;
    ELSE
        RAISE EXCEPTION 'Only admin can update user data';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
