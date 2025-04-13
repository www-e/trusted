-- 19_fix_storage_rls_policies.sql
-- Fix storage RLS policies to ensure users can upload their photos

-- Start transaction
BEGIN;

-- First, drop existing storage policies to recreate them properly
DROP POLICY IF EXISTS "Users can upload their own photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own photos" ON storage.objects;
DROP POLICY IF EXISTS "Admins can view all photos" ON storage.objects;

-- Create policy for users to upload their own photos
-- This policy allows authenticated users to upload files to their own folder
CREATE POLICY "Users can upload their own photos" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'userphotos' AND
  (storage.foldername(name))[1] = 'user_' || auth.uid()
);

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

-- Improve the storage permissions function to be more robust
CREATE OR REPLACE FUNCTION public.ensure_storage_permissions(bucket_name TEXT)
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
    SELECT 1 FROM storage.buckets WHERE name = bucket_name
  ) INTO bucket_exists;
  
  -- If bucket doesn't exist, try to create it
  IF NOT bucket_exists THEN
    BEGIN
      -- Try to create the bucket
      PERFORM storage.create_bucket(bucket_name, JSONB_BUILD_OBJECT('public', false));
      bucket_exists := TRUE;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Could not create bucket %: %', bucket_name, SQLERRM;
      RETURN FALSE;
    END;
  END IF;

  -- Enable RLS on the storage.objects table if not already enabled
  BEGIN
    ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
  EXCEPTION WHEN OTHERS THEN
    -- RLS might already be enabled, which is fine
    NULL;
  END;
  
  RETURN TRUE;
END;
$$;

-- Grant execute permission on the function to authenticated users
GRANT EXECUTE ON FUNCTION public.ensure_storage_permissions TO authenticated;

-- Commit transaction
COMMIT;
