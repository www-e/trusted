-- 21_fix_storage_bucket_permissions.sql
-- Fix storage bucket permissions to ensure users can upload photos

-- Start transaction
BEGIN;

-- First, make sure the storage API extension is installed
CREATE EXTENSION IF NOT EXISTS "pg_net";

-- Drop all existing policies on storage.objects to start fresh
DROP POLICY IF EXISTS "Users can upload their own photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own photos" ON storage.objects;
DROP POLICY IF EXISTS "Admins can view all photos" ON storage.objects;
DROP POLICY IF EXISTS "Admins can manage all photos" ON storage.objects;

-- Make sure RLS is enabled on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Create a more permissive policy for authenticated users to upload files
-- This policy allows any authenticated user to upload files to the userphotos bucket
CREATE POLICY "Allow authenticated users to upload photos" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'userphotos');

-- Create policy for users to view their own photos
CREATE POLICY "Users can view their own photos" ON storage.objects
FOR SELECT TO authenticated
USING (
  bucket_id = 'userphotos' AND
  (storage.foldername(name))[1] = 'user_' || auth.uid()
);

-- Create policy for users to update their own photos
CREATE POLICY "Users can update their own photos" ON storage.objects
FOR UPDATE TO authenticated
USING (
  bucket_id = 'userphotos' AND
  (storage.foldername(name))[1] = 'user_' || auth.uid()
);

-- Create policy for users to delete their own photos
CREATE POLICY "Users can delete their own photos" ON storage.objects
FOR DELETE TO authenticated
USING (
  bucket_id = 'userphotos' AND
  (storage.foldername(name))[1] = 'user_' || auth.uid()
);

-- Create policy for admins to view all photos
CREATE POLICY "Admins can view all photos" ON storage.objects
FOR SELECT TO authenticated
USING (
  bucket_id = 'userphotos' AND
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid() AND auth.users.role = 'admin'
  )
);

-- Create policy for admins to manage all photos
CREATE POLICY "Admins can manage all photos" ON storage.objects
FOR ALL TO authenticated
USING (
  bucket_id = 'userphotos' AND
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid() AND auth.users.role = 'admin'
  )
);

-- Create a function to ensure the userphotos bucket exists
CREATE OR REPLACE FUNCTION public.ensure_userphotos_bucket()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  bucket_exists BOOLEAN;
BEGIN
  -- Check if the bucket exists
  SELECT EXISTS (
    SELECT 1 FROM storage.buckets WHERE name = 'userphotos'
  ) INTO bucket_exists;
  
  -- If bucket doesn't exist, create it
  IF NOT bucket_exists THEN
    BEGIN
      -- Create the bucket with public = false
      INSERT INTO storage.buckets (id, name, owner, created_at, updated_at, public)
      VALUES (gen_random_uuid(), 'userphotos', auth.uid(), now(), now(), FALSE);
      
      RETURN TRUE;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Could not create bucket: %', SQLERRM;
      RETURN FALSE;
    END;
  END IF;
  
  RETURN TRUE;
END;
$$;

-- Grant execute permission on the function to authenticated users
GRANT EXECUTE ON FUNCTION public.ensure_userphotos_bucket TO authenticated;

-- Execute the function to ensure the bucket exists
SELECT public.ensure_userphotos_bucket();

-- Commit transaction
COMMIT;
