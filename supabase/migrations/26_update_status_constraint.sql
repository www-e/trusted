-- 26_update_status_constraint.sql
-- Fix the status constraint to be consistent with the existing code

-- Start transaction
BEGIN;

-- First, update the function to use 'pending' instead of 'pending_review'
CREATE OR REPLACE FUNCTION public.update_user_photos(
    user_id UUID,
    selfie_url TEXT,
    front_id_url TEXT,
    back_id_url TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Update user with photo URLs
    UPDATE public.users
    SET 
        selfie_photo_url = selfie_url,
        front_id_photo_url = front_id_url,
        back_id_photo_url = back_id_url
    WHERE id = user_id;
    
    -- We keep the user in 'pending' status after photos are uploaded
    -- This is consistent with the existing status values (active, pending, rejected)
    -- Admin will need to review and activate
END;
$$;

-- Commit transaction
COMMIT;
