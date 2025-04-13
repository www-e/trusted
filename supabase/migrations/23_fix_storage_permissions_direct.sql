-- 23_fix_storage_permissions_direct.sql
-- Fix storage permissions with a direct approach that works reliably

-- Start transaction
BEGIN;

-- First, ensure the bucket exists and is public
DO $$
DECLARE
  bucket_exists BOOLEAN;
BEGIN
  -- Check if the bucket exists
  SELECT EXISTS (
    SELECT 1 FROM storage.buckets WHERE name = 'userphotos'
  ) INTO bucket_exists;
  
  -- Create the bucket if it doesn't exist
  IF NOT bucket_exists THEN
    INSERT INTO storage.buckets (id, name, owner, created_at, updated_at, public)
    VALUES (gen_random_uuid(), 'userphotos', auth.uid(), now(), now(), TRUE);
  ELSE
    -- Update the bucket to be public if it exists
    UPDATE storage.buckets SET public = TRUE WHERE name = 'userphotos';
  END IF;
END $$;

-- Drop all existing policies on storage.objects
DROP POLICY IF EXISTS "Allow all authenticated operations" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to upload photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own photos" ON storage.objects;
DROP POLICY IF EXISTS "Admins can view all photos" ON storage.objects;
DROP POLICY IF EXISTS "Admins can manage all photos" ON storage.objects;

-- Make sure RLS is enabled on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Create a simple policy that allows authenticated users to do anything with their own files
CREATE POLICY "Users can manage their own files" ON storage.objects
FOR ALL TO authenticated
USING (
  bucket_id = 'userphotos' AND
  (auth.uid() = owner)
)
WITH CHECK (
  bucket_id = 'userphotos' AND
  (auth.uid() = owner)
);

-- Create a policy that allows authenticated users to upload to the userphotos bucket
CREATE POLICY "Users can upload to userphotos" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'userphotos'
);

-- Create a policy that allows users to view public files
CREATE POLICY "Anyone can view public files" ON storage.objects
FOR SELECT TO authenticated
USING (
  bucket_id = 'userphotos'
);

-- Create a direct function to check if a user can upload photos
CREATE OR REPLACE FUNCTION public.can_upload_photos(user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Check if the user exists and is authenticated
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = user_id) THEN
    RETURN FALSE;
  END IF;
  
  -- All authenticated users can upload photos
  RETURN TRUE;
END;
$$;

-- Grant execute permission on the function to authenticated users
GRANT EXECUTE ON FUNCTION public.can_upload_photos TO authenticated;

-- Commit transaction
COMMIT;
