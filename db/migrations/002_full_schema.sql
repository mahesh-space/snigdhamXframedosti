-- 002_full_schema.sql
-- Extended schema for events, registrations, announcements, reactions, submissions, certificates

-- Events
CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  club_id UUID REFERENCES clubs(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  venue TEXT,
  capacity INT,
  start_ts TIMESTAMPTZ,
  end_ts TIMESTAMPTZ,
  poster_path TEXT,
  status TEXT DEFAULT 'draft', -- draft/pending/approved/cancelled/completed
  created_by UUID,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_events_club_start ON events(club_id, start_ts);

-- Event registrations
CREATE TABLE IF NOT EXISTS event_registrations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID,
  status TEXT DEFAULT 'pending', -- pending/approved/rejected/cancelled
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_reg_event_user ON event_registrations(event_id, user_id);

-- Announcements
CREATE TABLE IF NOT EXISTS announcements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  club_id UUID REFERENCES clubs(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  body TEXT,
  category TEXT,
  published_at TIMESTAMPTZ,
  created_by UUID,
  status TEXT DEFAULT 'draft', -- draft/published/archived
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Submissions (competitions)
CREATE TABLE IF NOT EXISTS submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  media_item_id UUID REFERENCES media_items(id) ON DELETE CASCADE,
  event_id UUID REFERENCES events(id) ON DELETE SET NULL,
  user_id UUID,
  status TEXT DEFAULT 'submitted',
  judge_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Reactions (generic)
CREATE TABLE IF NOT EXISTS reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_type TEXT NOT NULL,
  subject_id UUID NOT NULL,
  user_id UUID,
  reaction_type TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_reactions_subject ON reactions(subject_type, subject_id);

-- Certificates
CREATE TABLE IF NOT EXISTS certificates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  event_id UUID REFERENCES events(id),
  storage_path TEXT,
  issued_at TIMESTAMPTZ,
  issued_by UUID,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Simple trigger for audit logs
CREATE OR REPLACE FUNCTION public.log_audit() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO audit_logs(user_id, action, object_type, object_id, diff, created_at)
  VALUES (COALESCE(current_setting('request.jwt.claims', true)::json->>'sub', NULL), TG_OP || ' ' || TG_TABLE_NAME, TG_TABLE_NAME, NEW.id, row_to_json(NEW), now());
  RETURN NEW;
END;
$$;

-- Attach audit trigger to key tables
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'audit_events_trigger') THEN
    CREATE TRIGGER audit_events_trigger AFTER INSERT OR UPDATE ON events FOR EACH ROW EXECUTE PROCEDURE public.log_audit();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'audit_media_trigger') THEN
    CREATE TRIGGER audit_media_trigger AFTER INSERT OR UPDATE ON media_items FOR EACH ROW EXECUTE PROCEDURE public.log_audit();
  END IF;
END$$;
