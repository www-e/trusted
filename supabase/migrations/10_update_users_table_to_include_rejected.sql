-- 10_update_users_table.sql
-- Update users table to include rejected status and add updated_at column

-- First, update the status check constraint to include 'rejected'
ALTER TABLE public.users 
DROP CONSTRAINT IF EXISTS users_status_check;

ALTER TABLE public.users 
ADD CONSTRAINT users_status_check 
CHECK (status IN ('active', 'pending', 'rejected'));

-- Add updated_at column with trigger to update it automatically
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Create or replace function to update the updated_at column
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update the updated_at column
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();
