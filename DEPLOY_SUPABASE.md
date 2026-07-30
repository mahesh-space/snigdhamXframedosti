# Deploying Supabase for Singhdham XFrameDosti

This document guides deploying the Supabase backend (migrations, policies, storage buckets, Edge Functions).

Prerequisites
- Install supabase CLI: https://supabase.com/docs/guides/cli
- Install psql (optional, for psql-based migrations)
- Install jq and curl
- Ensure you have the Supabase project ref and Service Role key (keep secret)

Repository layout
- db/migrations/ - SQL migration files (applied in order)
- db/policies/ - RLS and policy SQL
- edge-functions/ - Edge Function source folders (validate_upload, generate_certificate)
- client/ - frontend JS wrappers (supabase-init.js, graffiti.js, upload-ui.js)
- scripts/deploy_supabase.sh - orchestrates deployment

Quick deploy (recommended)
1. Copy env example and fill values:
   cp scripts/setup_env.example .env
   Edit .env and export or source it:
   source .env

2. Login to supabase CLI (interactive):
   supabase login

3. Link to project (optional):
   supabase link --project-ref $SUPABASE_PROJECT_REF

4. Run deployment script:
   ./scripts/deploy_supabase.sh

What the script does
- Applies SQL migrations: db/migrations/*.sql (via psql or supabase db push)
- Applies policies: db/policies/*.sql
- Attempts to create storage buckets (temp, gallery, certificates, submissions, avatars) via REST API
- Deploys edge-functions/* using supabase functions deploy
- Sets SUPABASE_SERVICE_ROLE_KEY as a secret for functions

Manual alternatives & checks
- If you prefer psql-based migrations, set SUPABASE_DATABASE_URL in .env to your database URL. The script will use psql then.
- To create buckets manually: open Supabase Dashboard -> Storage -> Create bucket. Recommended settings:
  - temp: private, public=false, lifecycle policy for cleanup (24h)
  - gallery: public or restricted depending on policy
  - certificates: private
  - submissions: private
  - avatars: private

Edge Functions
- After deploying: set VALIDATE_UPLOAD_URL in your frontend to the function URL (see supabase functions list or dashboard)
- Ensure functions have SUPABASE_SERVICE_ROLE_KEY set as a secret (the script attempts to set it)

Testing
- Upload a small image via upload.html to temp bucket, then call the validate_upload function to move and insert the media record.
- Use Postgres client or Supabase SQL editor to verify tables and rows.

Rollback
- To rollback DB changes, manually revert migrations (SQL) or restore from Supabase backups. Use soft-delete where possible.

Security notes
- Never commit SUPABASE_SERVICE_ROLE_KEY to git. Keep it in CI secrets or environment variables.
- Run RLS policy tests before flipping UI to production.

If you want, I can:
- Create GitHub Actions to run the deploy script on push to main (requires storing secrets in GitHub).
- Add idempotent seed scripts for admin/faculty users.

