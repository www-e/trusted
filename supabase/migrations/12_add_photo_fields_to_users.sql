-- 12_add_photo_fields_to_users.sql
-- Add photo fields and additional user information fields to the users table

-- Add new columns to the users table
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS selfie_photo_url TEXT,
ADD COLUMN IF NOT EXISTS front_id_photo_url TEXT,
ADD COLUMN IF NOT EXISTS back_id_photo_url TEXT,
ADD COLUMN IF NOT EXISTS vodafone_cash_number TEXT,
ADD COLUMN IF NOT EXISTS username TEXT UNIQUE;

-- Update the merchant_fields_check constraint to include photo requirements for merchants
ALTER TABLE public.users 
DROP CONSTRAINT IF EXISTS merchant_fields_check;

ALTER TABLE public.users 
ADD CONSTRAINT merchant_fields_check CHECK (
    (role != 'merchant') OR 
    (
        business_name IS NOT NULL AND 
        business_description IS NOT NULL AND 
        working_solo IS NOT NULL AND
        (working_solo = true OR (working_solo = false AND associate_ids IS NOT NULL)) AND
        selfie_photo_url IS NOT NULL AND
        front_id_photo_url IS NOT NULL AND
        back_id_photo_url IS NOT NULL
    )
);

-- Update the mediator_fields_check constraint to include photo requirements for mediators
ALTER TABLE public.users 
DROP CONSTRAINT IF EXISTS mediator_fields_check;

ALTER TABLE public.users 
ADD CONSTRAINT mediator_fields_check CHECK (
    (role != 'mediator') OR 
    (
        whatsapp_number IS NOT NULL AND
        selfie_photo_url IS NOT NULL AND
        front_id_photo_url IS NOT NULL AND
        back_id_photo_url IS NOT NULL
    )
);

-- Create a function to check if a username already exists
CREATE OR REPLACE FUNCTION public.username_exists(username TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.users WHERE users.username = username
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update the function to update user data (admin only) to include new fields
CREATE OR REPLACE FUNCTION public.update_user_data(
    user_id UUID,
    user_name TEXT,
    user_phone_number TEXT,
    user_secondary_phone_number TEXT,
    user_nickname TEXT,
    user_country TEXT,
    user_business_name TEXT,
    user_business_description TEXT,
    user_whatsapp_number TEXT,
    user_vodafone_cash_number TEXT,
    user_selfie_photo_url TEXT,
    user_front_id_photo_url TEXT,
    user_back_id_photo_url TEXT,
    user_username TEXT
)
RETURNS VOID AS $$
BEGIN
    IF public.is_admin() THEN
        -- Check if the username is being changed and if it already exists
        IF user_username IS NOT NULL AND 
           user_username != (SELECT username FROM public.users WHERE id = user_id) AND
           public.username_exists(user_username) THEN
            RAISE EXCEPTION 'Username already exists';
        END IF;
        
        UPDATE public.users 
        SET 
            name = user_name,
            phone_number = user_phone_number,
            secondary_phone_number = user_secondary_phone_number,
            nickname = user_nickname,
            country = user_country,
            business_name = user_business_name,
            business_description = user_business_description,
            whatsapp_number = user_whatsapp_number,
            vodafone_cash_number = user_vodafone_cash_number,
            selfie_photo_url = user_selfie_photo_url,
            front_id_photo_url = user_front_id_photo_url,
            back_id_photo_url = user_back_id_photo_url,
            username = user_username
        WHERE id = user_id;
    ELSE
        RAISE EXCEPTION 'Only admin can update user data';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create storage bucket for user photos if it doesn't exist
DO $$
BEGIN
    -- Check if the storage API extension is available
    IF EXISTS (
        SELECT 1 FROM pg_extension WHERE extname = 'pg_net'
    ) THEN
        -- Create bucket through SQL is not directly supported
        -- This will be handled by the application code
        RAISE NOTICE 'Storage bucket creation should be handled by the application code';
    END IF;
END $$;

-- Create index for username lookups
CREATE INDEX IF NOT EXISTS users_username_idx ON public.users(username);
