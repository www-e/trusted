-- 28_create_blacklist_table_and_policies.sql
-- Create blacklist table for banning users and devices

-- Create blacklist table
CREATE TABLE IF NOT EXISTS public.blacklist (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    email TEXT,
    phone_number TEXT,
    device_id TEXT,
    reason TEXT NOT NULL,
    banned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    banned_by UUID REFERENCES auth.users(id),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- At least one of user_id, email, phone_number, or device_id must be provided
    CONSTRAINT at_least_one_identifier CHECK (
        user_id IS NOT NULL OR 
        email IS NOT NULL OR 
        phone_number IS NOT NULL OR 
        device_id IS NOT NULL
    )
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS blacklist_user_id_idx ON public.blacklist(user_id);
CREATE INDEX IF NOT EXISTS blacklist_email_idx ON public.blacklist(email);
CREATE INDEX IF NOT EXISTS blacklist_phone_number_idx ON public.blacklist(phone_number);
CREATE INDEX IF NOT EXISTS blacklist_device_id_idx ON public.blacklist(device_id);
CREATE INDEX IF NOT EXISTS blacklist_is_active_idx ON public.blacklist(is_active);

-- Add updated_at trigger
DROP TRIGGER IF EXISTS update_blacklist_updated_at ON public.blacklist;
CREATE TRIGGER update_blacklist_updated_at
BEFORE UPDATE ON public.blacklist
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Create function to check if a user or device is blacklisted
CREATE OR REPLACE FUNCTION public.is_blacklisted(
    p_user_id UUID DEFAULT NULL,
    p_email TEXT DEFAULT NULL,
    p_phone_number TEXT DEFAULT NULL,
    p_device_id TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    result BOOLEAN;
BEGIN
    -- Check if any parameters are provided
    IF p_user_id IS NULL AND p_email IS NULL AND p_phone_number IS NULL AND p_device_id IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Check if user is blacklisted
    SELECT EXISTS (
        SELECT 1 FROM public.blacklist
        WHERE is_active = TRUE
        AND (
            (p_user_id IS NOT NULL AND user_id = p_user_id) OR
            (p_email IS NOT NULL AND email = p_email) OR
            (p_phone_number IS NOT NULL AND phone_number = p_phone_number) OR
            (p_device_id IS NOT NULL AND device_id = p_device_id)
        )
    ) INTO result;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create RLS policies for the blacklist table
ALTER TABLE public.blacklist ENABLE ROW LEVEL SECURITY;

-- Policy for admins to manage blacklist
DROP POLICY IF EXISTS admin_manage_blacklist ON public.blacklist;
CREATE POLICY admin_manage_blacklist ON public.blacklist
FOR ALL
TO authenticated
USING (EXISTS (
    SELECT 1 FROM public.users
    WHERE users.id = auth.uid() AND users.role = 'admin'
));

-- Policy for users to view blacklist (for debugging)
DROP POLICY IF EXISTS users_view_blacklist ON public.blacklist;
CREATE POLICY users_view_blacklist ON public.blacklist
FOR SELECT
TO authenticated
USING (true);

-- Create function to add a user to the blacklist
CREATE OR REPLACE FUNCTION public.add_to_blacklist(
    p_user_id UUID DEFAULT NULL,
    p_email TEXT DEFAULT NULL,
    p_phone_number TEXT DEFAULT NULL,
    p_device_id TEXT DEFAULT NULL,
    p_reason TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_blacklist_id UUID;
BEGIN
    -- Validate that at least one identifier is provided
    IF p_user_id IS NULL AND p_email IS NULL AND p_phone_number IS NULL AND p_device_id IS NULL THEN
        RAISE EXCEPTION 'At least one of user_id, email, phone_number, or device_id must be provided';
    END IF;
    
    -- Validate that reason is provided
    IF p_reason IS NULL OR p_reason = '' THEN
        RAISE EXCEPTION 'Reason must be provided';
    END IF;
    
    -- Insert into blacklist
    INSERT INTO public.blacklist (
        user_id,
        email,
        phone_number,
        device_id,
        reason,
        banned_by
    ) VALUES (
        p_user_id,
        p_email,
        p_phone_number,
        p_device_id,
        p_reason,
        auth.uid()
    ) RETURNING id INTO v_blacklist_id;
    
    -- If user_id is provided, update user status to 'rejected'
    IF p_user_id IS NOT NULL THEN
        UPDATE public.users
        SET status = 'rejected'
        WHERE id = p_user_id;
    END IF;
    
    RETURN v_blacklist_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to remove a user from the blacklist
CREATE OR REPLACE FUNCTION public.remove_from_blacklist(
    p_blacklist_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
BEGIN
    -- Get the user_id before updating
    SELECT user_id INTO v_user_id
    FROM public.blacklist
    WHERE id = p_blacklist_id;
    
    -- Update blacklist entry to inactive
    UPDATE public.blacklist
    SET is_active = FALSE
    WHERE id = p_blacklist_id;
    
    -- If user_id exists and no other active blacklist entries for this user,
    -- allow the user to be reactivated (but don't automatically change status)
    IF v_user_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM public.blacklist
        WHERE user_id = v_user_id AND is_active = TRUE
    ) THEN
        -- We don't automatically change status back to active
        -- Admin will need to manually approve the user again
        NULL;
    END IF;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Note: We're not creating a trigger on auth.users as it requires special permissions
-- Instead, we'll check blacklist status in the application code
