#!/usr/bin/env bash
# deploy_supabase.sh
# Orchestrates Supabase deployment: migrations, policies, functions, and optional bucket creation.
# Usage: SUPABASE_PROJECT_REF=your-ref SUPABASE_URL=https://xyz.supabase.co SUPABASE_SERVICE_ROLE_KEY=key ./scripts/deploy_supabase.sh
set -euo pipefail

: ${SUPABASE_PROJECT_REF:?Need SUPABASE_PROJECT_REF}
: ${SUPABASE_URL:?Need SUPABASE_URL}
: ${SUPABASE_SERVICE_ROLE_KEY:?Need SUPABASE_SERVICE_ROLE_KEY}

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

echo "Deploying to Supabase project: $SUPABASE_PROJECT_REF"

# 1) Apply SQL migrations using psql to SUPABASE_DATABASE_URL if provided, else suggest supabase db push
if [ -n "${SUPABASE_DATABASE_URL-}" ]; then
  echo "Applying SQL migrations using psql..."
  for f in "$ROOT_DIR/db/migrations"/*.sql; do
    echo "Applying: $f"
    psql "$SUPABASE_DATABASE_URL" -f "$f"
  done
else
  echo "SUPABASE_DATABASE_URL not set. Attempting 'supabase db push' (requires supabase CLI linked to project)."
  supabase db push --project-ref "$SUPABASE_PROJECT_REF"
fi

# 2) Apply policy SQL (RLS) via psql or supabase sql
if [ -n "${SUPABASE_DATABASE_URL-}" ]; then
  echo "Applying policies via psql..."
  for f in "$ROOT_DIR/db/policies"/*.sql; do
    echo "Applying policy: $f"
    psql "$SUPABASE_DATABASE_URL" -f "$f"
  done
else
  echo "Applying policies via supabase sql..."
  for f in "$ROOT_DIR/db/policies"/*.sql; do
    echo "Applying policy: $f"
    supabase sql query --file "$f" --project-ref "$SUPABASE_PROJECT_REF"
  done
fi

# 3) Create storage buckets (best-effort via REST API using service_role key)
echo "Creating storage buckets (temp, gallery, certificates, submissions)..."
for BUCKET in temp gallery certificates submissions avatars; do
  echo "Creating bucket: $BUCKET"
  curl -s -X POST "$SUPABASE_URL/storage/v1/bucket" \
    -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$BUCKET\", \"public\": false}" | jq -r '.message // .id // .name' || true
done

# 4) Deploy Edge Functions
echo "Deploying Edge Functions from edge-functions/..."
for fn_dir in "$ROOT_DIR/edge-functions"/*; do
  if [ -d "$fn_dir" ]; then
    fn_name=$(basename "$fn_dir")
    echo "Deploying function: $fn_name"
    supabase functions deploy "$fn_name" --project-ref "$SUPABASE_PROJECT_REF" --no-verify
  fi
done

# 5) Set secrets for functions
echo "Setting SUPABASE_SERVICE_ROLE_KEY secret for functions"
supabase secrets set SUPABASE_SERVICE_ROLE_KEY="$SUPABASE_SERVICE_ROLE_KEY" --project-ref "$SUPABASE_PROJECT_REF"

# 6) Final notes
cat <<EOF
Deployment finished (or requested). Next steps:
- Verify buckets and their access policies in Supabase Dashboard.
- Ensure 'temp' bucket is private; set public=true only for gallery if desired.
- Seed admin/faculty accounts and assign roles (use db/seed scripts or SQL).
- Test Edge Functions: call validate_upload with a real temp_path (upload a small test file first).
EOF
