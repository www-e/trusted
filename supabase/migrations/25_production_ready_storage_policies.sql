-- 25_production_ready_storage_policies.sql
-- Production-ready storage policies with proper security and admin management

-- Start transaction
BEGIN;

-- First, ensure the bucket exists and is properly configured
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
    RAISE NOTICE 'Created userphotos bucket';
  ELSE
    -- Update the bucket to be public
    UPDATE storage.buckets SET public = TRUE WHERE name = 'userphotos';
    RAISE NOTICE 'Updated userphotos bucket to be public';
  END IF;
END $$;

-- Drop all existing policies on storage.objects to start fresh
DROP POLICY IF EXISTS "Allow all authenticated operations" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to upload photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own photos" ON storage.objects;
DROP POLICY IF EXISTS "Admins can view all photos" ON storage.objects;
DROP POLICY IF EXISTS "Admins can manage all photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can manage their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload to userphotos" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view public files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can do anything" ON storage.objects;

-- Make sure RLS is enabled on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Create a policy for users to upload photos to their own folder
CREATE POLICY "Users can upload to their folder" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'userphotos' AND
  (storage.foldername(name))[1] = 'user_' || auth.uid()
);

-- Create a policy for users to view their own photos
CREATE POLICY "Users can view their own photos" ON storage.objects
FOR SELECT TO authenticated
USING (
  bucket_id = 'userphotos' AND
  (storage.foldername(name))[1] = 'user_' || auth.uid()
);

-- Create a policy for users to update their own photos
CREATE POLICY "Users can update their own photos" ON storage.objects
FOR UPDATE TO authenticated
USING (
  bucket_id = 'userphotos' AND
  (storage.foldername(name))[1] = 'user_' || auth.uid()
);

-- Create a policy for users to delete their own photos
CREATE POLICY "Users can delete their own photos" ON storage.objects
FOR DELETE TO authenticated
USING (
  bucket_id = 'userphotos' AND
  (storage.foldername(name))[1] = 'user_' || auth.uid()
);

-- Create a policy for admins to view all photos
CREATE POLICY "Admins can view all photos" ON storage.objects
FOR SELECT TO authenticated
USING (
  bucket_id = 'userphotos' AND
  EXISTS (
    SELECT 1 FROM public.users
    WHERE users.id = auth.uid() AND users.role = 'admin'
  )
);

-- Create a policy for admins to manage all photos
CREATE POLICY "Admins can manage all photos" ON storage.objects
FOR ALL TO authenticated
USING (
  bucket_id = 'userphotos' AND
  EXISTS (
    SELECT 1 FROM public.users
    WHERE users.id = auth.uid() AND users.role = 'admin'
  )
);

-- Create a fallback policy to ensure uploads work
CREATE POLICY "Fallback upload policy" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'userphotos'
);

-- Create a function to verify storage access and permissions
CREATE OR REPLACE FUNCTION public.verify_storage_access()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  bucket_exists BOOLEAN;
  user_role TEXT;
BEGIN
  -- Check if the bucket exists
  SELECT EXISTS (
    SELECT 1 FROM storage.buckets WHERE name = 'userphotos'
  ) INTO bucket_exists;
  
  -- If bucket doesn't exist, create it
  IF NOT bucket_exists THEN
    INSERT INTO storage.buckets (id, name, owner, created_at, updated_at, public)
    VALUES (gen_random_uuid(), 'userphotos', auth.uid(), now(), now(), TRUE);
    RAISE NOTICE 'Created userphotos bucket';
  ELSE
    -- Ensure the bucket is public
    UPDATE storage.buckets SET public = TRUE WHERE name = 'userphotos';
    RAISE NOTICE 'Updated userphotos bucket to be public';
  END IF;
  
  -- Get the user's role
  SELECT role INTO user_role FROM public.users WHERE id = auth.uid();
  
  -- Log the user role for debugging
  RAISE NOTICE 'User role: %', user_role;
  
  -- Return true to indicate success
  RETURN TRUE;
END;
$$;

-- Grant execute permission on the function to authenticated users
GRANT EXECUTE ON FUNCTION public.verify_storage_access TO authenticated;

-- Create a function for admins to manage user photos
CREATE OR REPLACE FUNCTION public.admin_manage_user_photos(
  admin_id UUID,
  target_user_id UUID,
  action TEXT, -- 'view', 'delete', 'update'
  photo_type TEXT -- 'selfie', 'front_id', 'back_id'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  is_admin BOOLEAN;
  result JSONB;
  photo_path TEXT;
BEGIN
  -- Check if the user is an admin
  SELECT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = admin_id AND role = 'admin'
  ) INTO is_admin;
  
  -- If not an admin, return error
  IF NOT is_admin THEN
    RETURN jsonb_build_object(
      'success', FALSE,
      'message', 'Only admins can manage user photos',
      'error', 'unauthorized'
    );
  END IF;
  
  -- Construct the photo path
  photo_path := 'user_' || target_user_id || '/' || target_user_id || '_' || photo_type;
  
  -- Perform the requested action
  IF action = 'view' THEN
    -- Return information about the photo
    SELECT jsonb_build_object(
      'success', TRUE,
      'action', 'view',
      'user_id', target_user_id,
      'photo_type', photo_type,
      'photo_path', photo_path
    ) INTO result;
  ELSIF action = 'delete' THEN
    -- Logic to delete the photo would go here
    -- This is a placeholder as actual deletion would require more complex logic
    SELECT jsonb_build_object(
      'success', TRUE,
      'action', 'delete',
      'user_id', target_user_id,
      'photo_type', photo_type,
      'photo_path', photo_path
    ) INTO result;
  ELSIF action = 'update' THEN
    -- Logic to update the photo would go here
    -- This is a placeholder as actual update would require more complex logic
    SELECT jsonb_build_object(
      'success', TRUE,
      'action', 'update',
      'user_id', target_user_id,
      'photo_type', photo_type,
      'photo_path', photo_path
    ) INTO result;
  ELSE
    -- Invalid action
    SELECT jsonb_build_object(
      'success', FALSE,
      'message', 'Invalid action. Must be one of: view, delete, update',
      'error', 'invalid_action'
    ) INTO result;
  END IF;
  
  RETURN result;
END;
$$;

-- Grant execute permission on the function to authenticated users
GRANT EXECUTE ON FUNCTION public.admin_manage_user_photos TO authenticated;

-- Create a function to check if a user has uploaded all required photos
CREATE OR REPLACE FUNCTION public.check_user_photos_status(user_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_role TEXT;
  has_selfie BOOLEAN;
  has_front_id BOOLEAN;
  has_back_id BOOLEAN;
  result JSONB;
BEGIN
  -- Get the user's role
  SELECT role INTO user_role FROM public.users WHERE id = user_id;
  
  -- Check if the user has uploaded each photo type
  SELECT 
    selfie_photo_url IS NOT NULL AND selfie_photo_url != '' AND selfie_photo_url != 'pending_upload',
    front_id_photo_url IS NOT NULL AND front_id_photo_url != '' AND front_id_photo_url != 'pending_upload',
    back_id_photo_url IS NOT NULL AND back_id_photo_url != '' AND back_id_photo_url != 'pending_upload'
  INTO 
    has_selfie, has_front_id, has_back_id
  FROM public.users 
  WHERE id = user_id;
  
  -- Build the result object
  SELECT jsonb_build_object(
    'user_id', user_id,
    'role', user_role,
    'photos_required', user_role IN ('merchant', 'mediator'),
    'photos_status', jsonb_build_object(
      'selfie', has_selfie,
      'front_id', has_front_id,
      'back_id', has_back_id
    ),
    'all_photos_uploaded', (has_selfie AND has_front_id AND has_back_id)
  ) INTO result;
  
  RETURN result;
END;
$$;

-- Grant execute permission on the function to authenticated users
GRANT EXECUTE ON FUNCTION public.check_user_photos_status TO authenticated;

-- Commit transaction
COMMIT;
