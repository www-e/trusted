-- 15_allow_admin_to_view_all_photos.sql
CREATE POLICY "Admins can view all photos" ON storage.objects
FOR SELECT TO authenticated
USING (
  bucket_id = 'userphotos' AND
  EXISTS (
    SELECT 1 FROM public.users
    WHERE users.id = auth.uid() AND users.role = 'admin'
  )
);