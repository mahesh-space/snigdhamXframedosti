# 15 - Testing Strategy

Testing types:
- Unit tests: SQL policy validations (psql scripts), Edge Function unit tests
- Integration tests: supabase-js client flows for auth, profile creation, uploads
- E2E tests: simulate user signup, event registration, upload, approval using Playwright or Cypress against staging
- Security tests: RLS policy fuzzing, role escalation checks
- Performance tests: DB query profiling for list endpoints (gallery, events)

Test data:
- Create seed users for each role (guest, student, member, exec, faculty, admin)
- Seed sample events, registrations, media items

Automated checks in CI:
- Run DB migrations and policy checks
- Run SQL-based RLS tests that assert expected allow/deny
- Run subset of E2E smoke tests (auth, create post, upload)

Manual checks:
- Verify email flows, certificate generation, and signed URL expirations

Monitoring & observability:
- Add logs for Edge Functions
- Monitor DB slow queries and storage usage

Acceptance criteria (sample):
- Auth flows verified and profiles created
- Events CRUD works with role-limited access
- Gallery public content visible; private content protected
- Appreciation wall realtime updates received by clients

Notes:
- Start with minimal test suite and expand as features are implemented.
- Store test fixtures under `tests/fixtures` and use CI to run migrations and tests against ephemeral Supabase projects or local Postgres testbed.