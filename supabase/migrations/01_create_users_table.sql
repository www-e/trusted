-- 01_create_users_table.sql
-- Create users table for the Trusted application
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('buyer_seller', 'merchant', 'mediator', 'admin')),
    phone_number TEXT NOT NULL,
    secondary_phone_number TEXT,
    nickname TEXT NOT NULL,
    country TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('active', 'pending')),
    business_name TEXT,
    business_description TEXT,
    working_solo BOOLEAN,
    associate_ids TEXT,
    whatsapp_number TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    -- Add constraints for role-specific fields
    CONSTRAINT merchant_fields_check CHECK (
        (role != 'merchant') OR 
        (
            business_name IS NOT NULL AND 
            business_description IS NOT NULL AND 
            working_solo IS NOT NULL AND
            (working_solo = true OR (working_solo = false AND associate_ids IS NOT NULL))
        )
    ),
    CONSTRAINT mediator_fields_check CHECK (
        (role != 'mediator') OR whatsapp_number IS NOT NULL
    )
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS users_role_status_idx ON public.users(role, status);
CREATE INDEX IF NOT EXISTS users_email_idx ON public.users(email);
