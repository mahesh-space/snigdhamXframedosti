# 09 - Role-Based Access Control (RBAC) & RLS

Strategy:
- Use database-enforced Row-Level Security (RLS) on every table containing user-scoped data.
- Map roles into a `user_roles` table and expose the primary role(s) in auth.user metadata where useful.
- Create Postgres policies that check membership, club scope, and ownership.

Role hierarchy recap: guest < student < member < exec_* < faculty < admin

Policy patterns (examples):
- profiles: users can SELECT/UPDATE their own profile; admin/faculty can SELECT/UPDATE any
- events: SELECT public events; exec for club_id and faculty/admin can SELECT/UPDATE/DELETE; registrations visible to event owner and the registrant
- media_items: uploader can manage own drafts; exec/faculty can approve; public SELECT only if approved
- announcements: draft visible to creator + exec; published visible to public
- appreciation_posts: anyone can create; reactions from anyone; delete only by admin/faculty or post owner

Implementation tips:
- Helper SQL function: can_manage_club(user_id UUID, club_id UUID) RETURNS BOOL -> checks user_roles
- Use session variables: set auth.role or use auth.jwt claims. E.g. policies reference auth.uid and (SELECT role FROM user_roles WHERE user_id=auth.uid LIMIT 1)

Example policy for event updates:
CREATE POLICY "exec_update_event" ON events FOR UPDATE USING (
  (exists(select 1 from user_roles ur where ur.user_id = auth.uid and ur.role_id = (select id from roles where slug in ('exec_photography','exec_cultural')) and (ur.club_id = events.club_id or ur.club_id is null)))
);

Storage policies:
- avatars/ : public read for approved avatars; put uploads to private temp path then move to public after approval
- gallery/: approved public; otherwise private
- submissions/: private; only uploaders and exec/faculty can read
- certificates/: private signed URLs for authenticated users

Admin overrides:
- Use service_role key inside Edge Functions to bypass RLS for admin tasks (do not expose to client)

Auditing & compliance:
- Add triggers to write audit_logs capturing user id, action, table, row_id, and diff for sensitive tables

Testing RLS:
- Create test accounts for each role; validate each policy via psql or Supabase SQL editor before frontend integration

Notes:
- Keep policies as small composable rules and helper SQL functions to avoid complexity duplication.
- Document each policy in the repo under db/policies/ for visibility.