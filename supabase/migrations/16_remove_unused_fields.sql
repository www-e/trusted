-- Migration to remove unused fields from the users table
-- This migration removes fields that are no longer needed after the enhanced signup flow implementation

-- Start transaction
BEGIN;

-- Remove secondary_phone_number if it's not used in the new signup flow
ALTER TABLE public.users DROP COLUMN IF EXISTS secondary_phone_number;

-- Remove associate_ids if the "working solo" concept is no longer relevant
ALTER TABLE public.users DROP COLUMN IF EXISTS associate_ids;

-- Remove working_solo if this concept is no longer used
ALTER TABLE public.users DROP COLUMN IF EXISTS working_solo;

-- Commit transaction
COMMIT;

-- Rollback function in case we need to revert this migration
COMMENT ON MIGRATION '16_remove_unused_fields' IS $$
-- To rollback this migration, run the following SQL:
BEGIN;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS secondary_phone_number TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS associate_ids TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS working_solo BOOLEAN;
COMMIT;
$$;
