-- 01_enable_rls_and_policies.sql
-- Enable Row-Level Security and create example policies for core tables.

-- Enable RLS for tables
ALTER TABLE IF EXISTS profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS media_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS events ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS event_registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS appreciation_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS announcements ENABLE ROW LEVEL SECURITY;

-- Helper function to check role membership
CREATE OR REPLACE FUNCTION public.user_has_role(p_user UUID, role_slug TEXT, p_club UUID DEFAULT NULL) RETURNS BOOLEAN LANGUAGE sql STABLE AS $$
  SELECT EXISTS(
    SELECT 1 FROM user_roles ur JOIN roles r ON r.id = ur.role_id
    WHERE ur.user_id = p_user AND r.slug = role_slug AND (p_club IS NULL OR ur.club_id IS NULL OR ur.club_id = p_club)
  );
$$;

-- profiles: users can manage own profile; admins (role 'admin') can manage all
CREATE POLICY profiles_manage_own ON profiles FOR ALL USING (user_id = auth.uid OR public.user_has_role(auth.uid, 'admin')) WITH CHECK (user_id = auth.uid OR public.user_has_role(auth.uid, 'admin'));

-- media_items: public SELECT only if approved; uploader or exec/faculty/admin can modify
CREATE POLICY media_select_public ON media_items FOR SELECT USING (
  approved = TRUE OR user_id = auth.uid OR public.user_has_role(auth.uid, 'admin') OR public.user_has_role(auth.uid, 'exec_cultural') OR public.user_has_role(auth.uid, 'exec_photography') OR public.user_has_role(auth.uid, 'faculty')
);
CREATE POLICY media_insert ON media_items FOR INSERT USING (auth.uid IS NOT NULL) WITH CHECK (user_id = auth.uid OR auth.uid IS NULL);
CREATE POLICY media_update ON media_items FOR UPDATE USING (user_id = auth.uid OR public.user_has_role(auth.uid, 'admin') OR public.user_has_role(auth.uid, 'faculty') OR public.user_has_role(auth.uid, 'exec_cultural') OR public.user_has_role(auth.uid, 'exec_photography'));

-- events: public SELECT for approved events; creators and execs/faculty/admin can modify
CREATE POLICY events_public_select ON events FOR SELECT USING (status = 'approved' OR created_by = auth.uid OR public.user_has_role(auth.uid, 'admin') OR public.user_has_role(auth.uid, 'faculty') OR public.user_has_role(auth.uid, 'exec_cultural') OR public.user_has_role(auth.uid, 'exec_photography'));
CREATE POLICY events_insert ON events FOR INSERT USING (auth.uid IS NOT NULL) WITH CHECK (created_by = auth.uid OR public.user_has_role(auth.uid, 'admin'));
CREATE POLICY events_update ON events FOR UPDATE USING (created_by = auth.uid OR public.user_has_role(auth.uid, 'admin') OR public.user_has_role(auth.uid, 'faculty'));

-- event_registrations: user can create own registration; event owners, execs, faculty, admin can view/update
CREATE POLICY reg_insert ON event_registrations FOR INSERT USING (auth.uid IS NOT NULL) WITH CHECK (user_id = auth.uid OR auth.uid IS NULL);
CREATE POLICY reg_select_owner ON event_registrations FOR SELECT USING (user_id = auth.uid OR public.user_has_role(auth.uid, 'admin') OR public.user_has_role(auth.uid, 'faculty') OR EXISTS (SELECT 1 FROM events e WHERE e.id = event_registrations.event_id AND e.created_by = auth.uid));
CREATE POLICY reg_update ON event_registrations FOR UPDATE USING (user_id = auth.uid OR public.user_has_role(auth.uid, 'admin') OR public.user_has_role(auth.uid, 'faculty') OR EXISTS (SELECT 1 FROM events e WHERE e.id = event_registrations.event_id AND e.created_by = auth.uid));

-- appreciation_posts: anyone can insert; delete/update only owner or admin
CREATE POLICY posts_insert ON appreciation_posts FOR INSERT USING (true) WITH CHECK (user_id = auth.uid OR user_id IS NULL);
CREATE POLICY posts_select ON appreciation_posts FOR SELECT USING (true);
CREATE POLICY posts_update_delete ON appreciation_posts FOR UPDATE USING (user_id = auth.uid OR public.user_has_role(auth.uid, 'admin'));

-- announcements: draft visible to creators and execs/faculty/admin; published visible to all
CREATE POLICY announcements_select ON announcements FOR SELECT USING (status = 'published' OR created_by = auth.uid OR public.user_has_role(auth.uid, 'admin') OR public.user_has_role(auth.uid, 'faculty') OR public.user_has_role(auth.uid, 'exec_cultural') OR public.user_has_role(auth.uid, 'exec_photography'));
CREATE POLICY announcements_insert ON announcements FOR INSERT USING (auth.uid IS NOT NULL) WITH CHECK (created_by = auth.uid OR public.user_has_role(auth.uid, 'admin'));
CREATE POLICY announcements_update ON announcements FOR UPDATE USING (created_by = auth.uid OR public.user_has_role(auth.uid, 'admin') OR public.user_has_role(auth.uid, 'faculty'));

-- Enable RLS on tables (if not already)
ALTER TABLE profiles FORCE ROW LEVEL SECURITY;
ALTER TABLE media_items FORCE ROW LEVEL SECURITY;
ALTER TABLE events FORCE ROW LEVEL SECURITY;
ALTER TABLE event_registrations FORCE ROW LEVEL SECURITY;
ALTER TABLE appreciation_posts FORCE ROW LEVEL SECURITY;
ALTER TABLE announcements FORCE ROW LEVEL SECURITY;

-- Note: Test these policies in staging thoroughly before production.
