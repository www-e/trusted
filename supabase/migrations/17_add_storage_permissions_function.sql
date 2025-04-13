-- 17_add_storage_permissions_function.sql
-- Create a function to ensure proper storage permissions for users

-- Start transaction
BEGIN;

-- Create a function to ensure storage permissions
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
  
  -- Return true as we're only checking permissions for an existing bucket
  -- Bucket creation should be handled by the application or manually
  IF NOT bucket_exists THEN
    RAISE NOTICE 'Bucket % does not exist. Please create it manually or through the application.', bucket_name;
    RETURN FALSE;
  END IF;

  -- We don't need to recreate existing policies as they are already defined in migrations 13-15
  -- Just check if they exist and create them if they don't
  
  -- Check if upload policy exists
  IF NOT EXISTS (
    SELECT 1 FROM storage.policies 
    WHERE name = 'Users can upload their own photos' AND bucket_id = bucket_name
  ) THEN
    -- Create upload policy
    CREATE POLICY "Users can upload their own photos" ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (
      bucket_id = bucket_name AND
      (storage.foldername(name))[1] = 'user_' || auth.uid()
    );
  END IF;
  
  -- Check if view policy exists
  IF NOT EXISTS (
    SELECT 1 FROM storage.policies 
    WHERE name = 'Users can view their own photos' AND bucket_id = bucket_name
  ) THEN
    -- Create view policy
    CREATE POLICY "Users can view their own photos" ON storage.objects
    FOR SELECT TO authenticated
    USING (
      bucket_id = bucket_name AND
      (storage.foldername(name))[1] = 'user_' || auth.uid()
    );
  END IF;
  
  -- Check if admin view policy exists
  IF NOT EXISTS (
    SELECT 1 FROM storage.policies 
    WHERE name = 'Admins can view all photos' AND bucket_id = bucket_name
  ) THEN
    -- Create admin view policy
    CREATE POLICY "Admins can view all photos" ON storage.objects
    FOR SELECT TO authenticated
    USING (
      bucket_id = bucket_name AND
      EXISTS (
        SELECT 1 FROM public.users
        WHERE users.id = auth.uid() AND users.role = 'admin'
      )
    );
  END IF;
  

  RETURN TRUE;
END;
$$;

-- Grant execute permission on the function to authenticated users
GRANT EXECUTE ON FUNCTION public.ensure_storage_permissions TO authenticated;

-- Make sure users can insert their own data
DROP POLICY IF EXISTS users_insert_own ON public.users;
CREATE POLICY users_insert_own ON public.users 
    FOR INSERT 
    TO authenticated
    WITH CHECK (auth.uid() = id);

-- Make sure users can update their own data
DROP POLICY IF EXISTS users_update_own ON public.users;
CREATE POLICY users_update_own ON public.users 
    FOR UPDATE 
    TO authenticated
    USING (auth.uid() = id);
    
-- Create a function to check if a user has the required photo URLs based on their role
CREATE OR REPLACE FUNCTION public.check_user_photos(user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_role TEXT;
  has_required_photos BOOLEAN;
BEGIN
  -- Get the user's role
  SELECT role INTO user_role FROM public.users WHERE id = user_id;
  
  -- Check if the user has the required photos based on their role
  IF user_role = 'buyer_seller' THEN
    -- Buyer/seller doesn't need photos
    has_required_photos := TRUE;
  ELSIF user_role IN ('merchant', 'mediator') THEN
    -- Merchant and mediator need all three photos
    SELECT 
      selfie_photo_url IS NOT NULL AND 
      front_id_photo_url IS NOT NULL AND 
      back_id_photo_url IS NOT NULL 
    INTO has_required_photos 
    FROM public.users 
    WHERE id = user_id;
  ELSE
    -- Default to false for unknown roles
    has_required_photos := FALSE;
  END IF;
  
  RETURN has_required_photos;
END;
$$;

-- Grant execute permission on the function to authenticated users
GRANT EXECUTE ON FUNCTION public.check_user_photos TO authenticated;

-- Commit transaction
COMMIT;
