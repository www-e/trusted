-- 07_create_triggers.sql
-- Create triggers for automatic behaviors

-- Function to set default status to 'pending' for new users
CREATE OR REPLACE FUNCTION public.set_default_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status IS NULL THEN
        NEW.status := 'pending';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically set default status
CREATE TRIGGER set_default_status_trigger
BEFORE INSERT ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.set_default_status();
