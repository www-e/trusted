-- 13_add_photo_policy.sql

CREATE POLICY "Users can upload their own photos" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'userphotos' AND
  (storage.foldername(name))[1] = 'user_' || auth.uid()
);