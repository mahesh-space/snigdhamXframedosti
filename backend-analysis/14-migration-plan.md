# 14 - Migration Plan (From Static to DB-driven)

High-level migration steps:
1. Seed roles and clubs
2. Create users and profiles for coordinators (manual or import)
3. Migrate static pages content to DB where appropriate (achievements -> announcements table)
4. Media migration: copy existing repo images into gallery/ or events/ buckets, create media_items rows pointing to new storage paths
5. Migrate graffiti wall: optionally import existing DOM messages (if desired) into appreciation_posts with created_at approximations
6. Replace static event placeholders with events table rows
7. Update frontend to fetch from Supabase endpoints; keep fallback to static content during phased rollout

Detailed steps for media migration:
- Create script that uploads files from project/images to Supabase storage via service_role key
- For each upload: generate media_items row with approved=true and created_by as coordinator

Data migration scripts & safety:
- Write idempotent migration scripts (insert unless exists)
- Run migrations in staging and validate before production

Rollback strategy:
- Keep original static repo untouched (git)
- Use soft-delete patterns and transaction-safe migration scripts
- For media, retain a copy of original assets

Cutover checklist:
- All public read endpoints now returning DB-driven content
- Auth/Profiles verified
- RLS tested with role accounts
- Backups enabled

Notes:
- Keep a feature flag in the frontend to toggle between static assets and Supabase-driven content during the migration window.