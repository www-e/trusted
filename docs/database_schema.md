# Trusted App Database Schema

This document outlines the current database schema for the Trusted application, including all tables, fields, constraints, and relationships.

## Users Table

The `users` table stores information about all users in the system, including their role, status, and profile details.

### Fields

| Field Name | Type | Description | Required | Notes |
|------------|------|-------------|----------|-------|
| id | UUID | Primary key | Yes | References auth.users(id) |
| email | TEXT | User's email address | Yes | Unique |
| name | TEXT | User's full name | Yes | |
| role | TEXT | User's role in the system | Yes | One of: 'buyer_seller', 'merchant', 'mediator', 'admin' |
| phone_number | TEXT | User's primary phone number | Yes | |
| secondary_phone_number | TEXT | User's secondary phone number | No | |
| whatsapp_number | TEXT | User's WhatsApp number | Conditional | Required for mediators |
| vodafone_cash_number | TEXT | User's Vodafone Cash number | No | |
| nickname | TEXT | User's nickname or business name | Yes | |
| country | TEXT | User's country | Yes | |
| status | TEXT | User's account status | Yes | One of: 'active', 'pending', 'rejected' |
| selfie_photo_url | TEXT | URL to user's selfie photo | Conditional | Required for merchants and mediators |
| front_id_photo_url | TEXT | URL to front of user's ID | Conditional | Required for merchants and mediators |
| back_id_photo_url | TEXT | URL to back of user's ID | Conditional | Required for merchants and mediators |
| business_name | TEXT | Name of the merchant's business | Conditional | Required for merchants |
| business_description | TEXT | Description of the merchant's business | Conditional | Required for merchants |
| working_solo | BOOLEAN | Whether merchant works alone | Conditional | Required for merchants |
| associate_ids | TEXT | IDs of merchant's associates | Conditional | Required for merchants not working solo |
| username | TEXT | Username for secondary login | No | Unique |
| created_at | TIMESTAMP WITH TIME ZONE | When the user was created | Yes | Default: NOW() |
| updated_at | TIMESTAMP WITH TIME ZONE | When the user was last updated | Yes | Default: NOW() |
| accepted_at | TIMESTAMP WITH TIME ZONE | When the user was accepted | No | Set when status changes to 'active' |

### Constraints

1. **Primary Key**: `id` is the primary key and references `auth.users(id)` with CASCADE on delete.
2. **Unique Constraints**:
   - `email` must be unique
   - `username` must be unique
3. **Check Constraints**:
   - `role` must be one of: 'buyer_seller', 'merchant', 'mediator', 'admin'
   - `status` must be one of: 'active', 'pending', 'rejected'
   - `merchant_fields_check`: Ensures merchants have required fields (business_name, business_description, working_solo, selfie_photo_url, front_id_photo_url, back_id_photo_url)
   - `mediator_fields_check`: Ensures mediators have required fields (whatsapp_number, selfie_photo_url, front_id_photo_url, back_id_photo_url)

### Indexes

1. `users_role_status_idx` on `(role, status)` - For faster queries filtering by role and status
2. `users_email_idx` on `(email)` - For faster lookups by email
3. `users_username_idx` on `(username)` - For faster lookups by username

## Storage

The Supabase storage is configured with a bucket named `userphotos` for storing user-related images.

### Buckets

1. `userphotos` - Stores all user-related photos (selfies, ID cards)

### Storage Structure

Photos are organized in the following structure:
```
userphotos/
  └── user_{user_id}/
      ├── {user_id}_selfie_{uuid}.{extension}
      ├── {user_id}_front_id_{uuid}.{extension}
      └── {user_id}_back_id_{uuid}.{extension}
```

### RLS Policies

1. **Users can upload their own photos**:
   - Applies to: INSERT operations
   - For: authenticated users
   - Condition: bucket_id = 'userphotos' AND (storage.foldername(name))[1] = 'user_' || auth.uid()

2. **Users can view their own photos**:
   - Applies to: SELECT operations
   - For: authenticated users
   - Condition: bucket_id = 'userphotos' AND (storage.foldername(name))[1] = 'user_' || auth.uid()

3. **Admins can view all photos**:
   - Applies to: SELECT operations
   - For: authenticated users
   - Condition: bucket_id = 'userphotos' AND EXISTS (SELECT 1 FROM public.users WHERE users.id = auth.uid() AND users.role = 'admin')

## Functions

### User Management Functions

1. **is_admin()**:
   - Returns: BOOLEAN
   - Description: Checks if the current user is an admin
   - Security: SECURITY DEFINER

2. **update_user_status(user_id UUID, new_status TEXT)**:
   - Returns: VOID
   - Description: Updates a user's status (admin only)
   - Parameters:
     - `user_id`: The ID of the user to update
     - `new_status`: The new status ('active', 'pending', or 'rejected')
   - Security: SECURITY DEFINER

3. **get_all_users()**:
   - Returns: SETOF public.users
   - Description: Returns all users (admin only)
   - Security: SECURITY DEFINER

4. **update_user_data(user_id UUID, user_name TEXT, user_phone_number TEXT, user_secondary_phone_number TEXT, user_nickname TEXT, user_country TEXT, user_business_name TEXT, user_business_description TEXT, user_whatsapp_number TEXT, user_vodafone_cash_number TEXT, user_selfie_photo_url TEXT, user_front_id_photo_url TEXT, user_back_id_photo_url TEXT, user_username TEXT)**:
   - Returns: VOID
   - Description: Updates a user's data (admin only)
   - Security: SECURITY DEFINER

5. **username_exists(username TEXT)**:
   - Returns: BOOLEAN
   - Description: Checks if a username already exists
   - Security: SECURITY DEFINER

### Utility Functions

1. **update_updated_at_column()**:
   - Returns: TRIGGER
   - Description: Updates the updated_at column to the current timestamp
   - Used by: Trigger on users table

## Triggers

1. **update_users_updated_at**:
   - Fires: BEFORE UPDATE on public.users
   - For: EACH ROW
   - Function: public.update_updated_at_column()

## Recommendations for Cleanup

Based on the current schema and the enhancements made, here are fields that can be safely removed if not needed:

1. **secondary_phone_number**: If this is no longer used in the new signup flow, it can be removed.
2. **associate_ids**: If the "working solo" concept is no longer relevant, this field can be removed.

## Migration Path

When making changes to the database schema, follow these steps:

1. Create a new migration file in the `supabase/migrations` directory with a sequential number
2. Include both the changes and any necessary rollback statements
3. Test the migration in a development environment before applying to production
4. Apply the migration using the Supabase SQL editor

## Security Considerations

1. All sensitive operations are protected by RLS policies
2. Admin functions use SECURITY DEFINER to ensure they run with the privileges of the function creator
3. User data is protected by RLS policies that restrict access to the user's own data
4. Photos are stored in a private bucket with appropriate access controls
