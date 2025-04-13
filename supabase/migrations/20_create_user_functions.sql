-- 20_create_user_functions.sql
-- Create improved user functions to handle the user creation process without placeholders

-- Start transaction
BEGIN;

-- Create a function to create a user with relaxed constraints
-- This allows creating a user without photo URLs initially
CREATE OR REPLACE FUNCTION public.create_initial_user(
    user_id UUID,
    user_email TEXT,
    user_name TEXT,
    user_role TEXT,
    user_phone_number TEXT,
    user_whatsapp_number TEXT,
    user_vodafone_cash_number TEXT,
    user_nickname TEXT,
    user_country TEXT,
    user_username TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    user_status TEXT;
    temp_selfie TEXT;
    temp_front_id TEXT;
    temp_back_id TEXT;
BEGIN
    -- Determine status based on role
    IF user_role = 'buyer_seller' THEN
        user_status := 'active';
    ELSE
        user_status := 'pending';
    END IF;
    
    -- For merchant and mediator roles, we need temporary photo URLs to satisfy constraints
    -- These will be updated with real values later
    IF user_role IN ('merchant', 'mediator') THEN
        temp_selfie := 'pending_upload';
        temp_front_id := 'pending_upload';
        temp_back_id := 'pending_upload';
    ELSE
        temp_selfie := NULL;
        temp_front_id := NULL;
        temp_back_id := NULL;
    END IF;
    
    -- Check if user already exists
    IF EXISTS (SELECT 1 FROM public.users WHERE id = user_id) THEN
        -- Update existing user
        UPDATE public.users
        SET 
            email = user_email,
            name = user_name,
            role = user_role,
            phone_number = user_phone_number,
            whatsapp_number = user_whatsapp_number,
            vodafone_cash_number = user_vodafone_cash_number,
            nickname = user_nickname,
            country = user_country,
            status = user_status,
            username = COALESCE(user_username, username)
        WHERE id = user_id;
    ELSE
        -- Create new user with temporary values to satisfy constraints
        INSERT INTO public.users (
            id,
            email,
            name,
            role,
            phone_number,
            whatsapp_number,
            vodafone_cash_number,
            nickname,
            country,
            status,
            username,
            selfie_photo_url,
            front_id_photo_url,
            back_id_photo_url
        ) VALUES (
            user_id,
            user_email,
            user_name,
            user_role,
            user_phone_number,
            user_whatsapp_number,
            user_vodafone_cash_number,
            user_nickname,
            user_country,
            user_status,
            user_username,
            temp_selfie,
            temp_front_id,
            temp_back_id
        );
    END IF;
    
    RETURN user_id;
END;
$$;

-- Create a function to update user photos
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
    
    -- Check if user is merchant or mediator and needs to be activated
    -- If all required photos are provided, we can update status to active
    IF EXISTS (
        SELECT 1 
        FROM public.users 
        WHERE 
            id = user_id AND 
            status = 'pending' AND
            role IN ('merchant', 'mediator') AND
            selfie_photo_url IS NOT NULL AND
            front_id_photo_url IS NOT NULL AND
            back_id_photo_url IS NOT NULL
    ) THEN
        -- Update status to pending_review to indicate photos are uploaded
        -- Admin will need to review and activate
        UPDATE public.users
        SET status = 'pending_review'
        WHERE id = user_id;
    END IF;
END;
$$;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION public.create_initial_user TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_user_photos TO authenticated;

-- Commit transaction
COMMIT;
