-- 29_primitive_phone_blocking.sql
-- Create primitive phone blocking functionality

-- Create primitive_phone_block table
CREATE TABLE IF NOT EXISTS public.primitive_phone_block (
    phone_number TEXT PRIMARY KEY,
    reason TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    is_active BOOLEAN DEFAULT TRUE NOT NULL
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS primitive_phone_block_is_active_idx ON public.primitive_phone_block(is_active);

-- Add updated_at trigger
CREATE TRIGGER update_primitive_phone_block_updated_at
BEFORE UPDATE ON public.primitive_phone_block
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Create RLS policies for the primitive_phone_block table
ALTER TABLE public.primitive_phone_block ENABLE ROW LEVEL SECURITY;

-- Policy for admins to manage primitive phone blocks
CREATE POLICY admin_manage_primitive_phone_block ON public.primitive_phone_block
FOR ALL
TO authenticated
USING (EXISTS (
    SELECT 1 FROM public.users
    WHERE users.id = auth.uid() AND users.role = 'admin'
));

-- Policy for users to view primitive phone blocks (for debugging)
CREATE POLICY users_view_primitive_phone_block ON public.primitive_phone_block
FOR SELECT
TO authenticated
USING (true);

-- Create function to check if a phone number is blocked
CREATE OR REPLACE FUNCTION public.is_primitive_blocked(
    p_phone_number TEXT
) RETURNS BOOLEAN AS $$
DECLARE
    result BOOLEAN;
BEGIN
    -- Check if phone number is provided
    IF p_phone_number IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Check if phone number is blocked
    SELECT EXISTS (
        SELECT 1 FROM public.primitive_phone_block
        WHERE phone_number = p_phone_number AND is_active = TRUE
    ) INTO result;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to block a phone number
CREATE OR REPLACE FUNCTION public.primitive_block_phone(
    p_phone_number TEXT,
    p_reason TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
BEGIN
    -- Validate that phone number is provided
    IF p_phone_number IS NULL OR p_phone_number = '' THEN
        RAISE EXCEPTION 'Phone number must be provided';
    END IF;
    
    -- Validate that reason is provided
    IF p_reason IS NULL OR p_reason = '' THEN
        RAISE EXCEPTION 'Reason must be provided';
    END IF;
    
    -- Insert into primitive_phone_block
    INSERT INTO public.primitive_phone_block (
        phone_number,
        reason,
        created_by
    ) VALUES (
        p_phone_number,
        p_reason,
        auth.uid()
    )
    ON CONFLICT (phone_number) 
    DO UPDATE SET 
        reason = p_reason,
        is_active = TRUE,
        created_by = auth.uid(),
        created_at = NOW();
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to unblock a phone number
CREATE OR REPLACE FUNCTION public.primitive_unblock_phone(
    p_phone_number TEXT
) RETURNS BOOLEAN AS $$
BEGIN
    -- Validate that phone number is provided
    IF p_phone_number IS NULL OR p_phone_number = '' THEN
        RAISE EXCEPTION 'Phone number must be provided';
    END IF;
    
    -- Update primitive_phone_block entry to inactive
    UPDATE public.primitive_phone_block
    SET is_active = FALSE
    WHERE phone_number = p_phone_number;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a trigger to prevent account creation for blocked phone numbers
CREATE OR REPLACE FUNCTION public.check_phone_block_before_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the phone number is blocked
    IF EXISTS (
        SELECT 1 FROM public.primitive_phone_block
        WHERE phone_number = NEW.phone_number AND is_active = TRUE
    ) THEN
        RAISE EXCEPTION 'This phone number has been blocked from using the service';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply the trigger to the users table
DROP TRIGGER IF EXISTS check_phone_block_before_insert_users ON public.users;
CREATE TRIGGER check_phone_block_before_insert_users
BEFORE INSERT ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.check_phone_block_before_insert();

-- Modify the existing add_to_blacklist function to also block the device
CREATE OR REPLACE FUNCTION public.add_to_blacklist(
    p_user_id UUID DEFAULT NULL,
    p_email TEXT DEFAULT NULL,
    p_phone_number TEXT DEFAULT NULL,
    p_device_id TEXT DEFAULT NULL,
    p_reason TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_blacklist_id UUID;
    v_phone_number TEXT;
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
    
    -- If user_id is provided, update user status to 'rejected' and get phone number
    IF p_user_id IS NOT NULL THEN
        UPDATE public.users
        SET status = 'rejected'
        WHERE id = p_user_id
        RETURNING phone_number INTO v_phone_number;
        
        -- Also block the phone number if it's not already provided
        IF p_phone_number IS NULL AND v_phone_number IS NOT NULL THEN
            PERFORM public.primitive_block_phone(v_phone_number, p_reason);
        END IF;
    END IF;
    
    -- If phone_number is provided directly, also block it in primitive_phone_block
    IF p_phone_number IS NOT NULL THEN
        PERFORM public.primitive_block_phone(p_phone_number, p_reason);
    END IF;
    
    RETURN v_blacklist_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
