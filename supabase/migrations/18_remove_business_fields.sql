-- 18_remove_business_fields.sql
-- Migration to remove business fields from the users table and related constraints

-- Start transaction
BEGIN;

-- First, drop the constraints that reference the business fields
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS merchant_fields_check;
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS mediator_fields_check;

-- Create a new merchant_fields_check constraint without business fields
-- Allow 'pending_upload' as a temporary value during initial creation
ALTER TABLE public.users 
ADD CONSTRAINT merchant_fields_check CHECK (
    (role != 'merchant') OR 
    (
        (selfie_photo_url IS NOT NULL AND selfie_photo_url != '') AND
        (front_id_photo_url IS NOT NULL AND front_id_photo_url != '') AND
        (back_id_photo_url IS NOT NULL AND back_id_photo_url != '')
    )
);

-- Create a new mediator_fields_check constraint
-- Allow 'pending_upload' as a temporary value during initial creation
ALTER TABLE public.users 
ADD CONSTRAINT mediator_fields_check CHECK (
    (role != 'mediator') OR 
    (
        (whatsapp_number IS NOT NULL AND whatsapp_number != '') AND
        (selfie_photo_url IS NOT NULL AND selfie_photo_url != '') AND
        (front_id_photo_url IS NOT NULL AND front_id_photo_url != '') AND
        (back_id_photo_url IS NOT NULL AND back_id_photo_url != '')
    )
);

-- Remove business fields from the users table
ALTER TABLE public.users DROP COLUMN IF EXISTS business_name;
ALTER TABLE public.users DROP COLUMN IF EXISTS business_description;

-- Note: working_solo and associate_ids were already removed in migration 16

-- Commit transaction
COMMIT;

-- Rollback function in case we need to revert this migration
COMMENT ON MIGRATION '18_remove_business_fields' IS $$
-- To rollback this migration, run the following SQL:
BEGIN;
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS merchant_fields_check;
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS mediator_fields_check;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS business_name TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS business_description TEXT;
ALTER TABLE public.users 
ADD CONSTRAINT merchant_fields_check CHECK (
    (role != 'merchant') OR 
    (
        business_name IS NOT NULL AND 
        business_description IS NOT NULL AND 
        selfie_photo_url IS NOT NULL AND
        front_id_photo_url IS NOT NULL AND
        back_id_photo_url IS NOT NULL
    )
);
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
COMMIT;
$$;
