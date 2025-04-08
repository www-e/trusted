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

-- Create RLS (Row Level Security) policies
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Policy for users to read their own data
CREATE POLICY users_read_own ON public.users 
    FOR SELECT 
    USING (auth.uid() = id);

-- Policy for users to update their own data
CREATE POLICY users_update_own ON public.users 
    FOR UPDATE 
    USING (auth.uid() = id);

-- Policy for admin to read all users
CREATE POLICY admin_read_all ON public.users 
    FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND email = 'omarasj445@gmail.com'
        )
    );

-- Policy for admin to update all users
CREATE POLICY admin_update_all ON public.users 
    FOR UPDATE 
    USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND email = 'omarasj445@gmail.com'
        )
    );

-- Policy for inserting new users (anyone can create their own record)
CREATE POLICY users_insert_own ON public.users 
    FOR INSERT 
    WITH CHECK (auth.uid() = id);

-- Create function to check if user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() AND email = 'omarasj445@gmail.com'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get pending users
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
