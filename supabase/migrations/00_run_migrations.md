# Supabase Migration Guide

This document explains how to run the migration files in the correct order to set up your Supabase database.

## Migration Files Overview

The migrations have been split into multiple files for better organization and to avoid errors when re-running migrations:

1. `01_create_users_table.sql` - Creates the users table with all necessary columns and constraints
2. `02_create_admin_functions.sql` - Creates the is_admin() function (must run before RLS)
3. `03_enable_rls.sql` - Enables Row Level Security on the users table
4. `04_create_user_policies.sql` - Creates basic user access policies
5. `05_create_admin_policies.sql` - Creates admin-specific policies
6. `06_create_user_management_functions.sql` - Creates functions for user management
7. `07_create_triggers.sql` - Sets up triggers for automatic behaviors
8. `08_grant_permissions.sql` - Grants necessary permissions to authenticated users

## How to Run Migrations

### Initial Setup

If you're setting up the database for the first time, run all migrations in order:

1. Log in to your Supabase dashboard at https://app.supabase.com/
2. Navigate to your project (https://lzpkoyncbxomznlnnktf.supabase.co)
3. Go to the "SQL Editor" section
4. Run each migration file in numerical order (01 through 08)

### Fixing the Infinite Recursion Error

If you're specifically trying to fix the infinite recursion error:

1. Run `02_create_admin_functions.sql` to update the is_admin() function
2. Run `05_create_admin_policies.sql` to update the admin policies

### Adding New Features

When adding new features in the future, create new migration files with higher numbers (09, 10, etc.) to maintain a clean migration history.

## Troubleshooting

If you encounter errors like "policy already exists":
- Use the `IF NOT EXISTS` clause (already included in these migrations)
- Or drop the existing policy first with `DROP POLICY IF EXISTS policy_name ON table_name;`

For other database errors, check the Supabase logs in the dashboard under "Database" > "Logs".
