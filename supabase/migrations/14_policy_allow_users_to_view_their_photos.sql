-- 14_policy_allow_users_to_view_their_photos.sql
CREATE POLICY "Users can view their own photos" ON storage.objects
FOR SELECT TO authenticated
USING (
  bucket_id = 'userphotos' AND
  (storage.foldername(name))[1] = 'user_' || auth.uid()
);