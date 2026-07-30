# 07 - Supabase Architecture

Components to use:
- Supabase Auth: user management, email/password, magic links if desired
- Supabase Postgres: primary relational DB with schema from database-design
- Supabase Storage: object storage for avatars, posters, media, certificates
- Realtime (Postgres replication/Realtime): subscriptions for appreciation wall and announcements
- Edge Functions: background jobs (certificate generation, email sending, scheduled tasks)
- Database Functions & Triggers: maintain derived data (registration counts), send notifications, audit logs
- RLS & Policies: enforce permissions per row
- Backups & Monitoring: automated DB snapshots, project settings

Why each service:
- Auth: built-in secure flows, token management, easy client integration with vanilla JS
- Postgres: normalized schema, strong relational guarantees, index support
- Storage: scalable media handling with access policies and signed URLs
- Realtime: live appreciation wall and notifications with minimal client polling
- Edge Functions: tasks needing secrets (SMTP sending), or heavy compute (PDF certificate generation)

Project Structure (logical):
- db/
  - migrations/
  - functions/
  - triggers/
  - policies/
  - seed/
- edge-functions/
  - issue_certificate/
  - send_announcement_email/
- storage/
  - buckets definition (avatars, gallery, events, certificates, submissions, temp)
- client/
  - supabase-init.js (wrapper to centralize supabase client calls, auth handling, caching)

Database Triggers & Functions (examples):
- trigger: on event_registrations insert/update -> increment/decrement registration counts (or use materialized view)
- trigger: on media_items approved -> insert into public_media_view
- function: issue_certificate(user_id, event_id) -> store PDF in certificates bucket and create certificates row

Policies: implement RLS (detailed in rbac.md). Use JWT claims from Supabase to check role membership.

Operational notes:
- Use migrations (pg_dump/supabase migrations) to track schema
- Use service_role key only for server/edge functions — never expose in browser
- Configure daily backups and retention according to college policy
- Create staging and production Supabase projects

Environment variables (Edge Functions):
- SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, SMTP_* (host, user, pass), CERTIFICATE_TEMPLATE_PATH

Access control:
- Buckets: public for gallery (only approved media), private for submissions & certificates
- Signed URLs used for client downloads

Monitoring & SLOs:
- Set usage alerts for storage and DB size
- Enable email alerts on DB errors and function failures

Migration approach:
- Start with schema + minimal seed data (roles, clubs)
- Migrate static media to storage buckets
- Flip frontend to read from Supabase endpoints gradually (see roadmap)
