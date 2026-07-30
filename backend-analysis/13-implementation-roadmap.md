# 13 - Implementation Roadmap (Phased)

Phases are ordered to enable incremental deployment and testing. Each phase lists objectives, files affected, DB changes, frontend changes, tests.

Phase 1 — Project cleanup & prep
- Objectives: branch rename (done), create backend-analysis docs, add supabase-init placeholder
- Files affected: add backend-analysis/ (this commit)
- DB: none
- Frontend: add minimal supabase client init stub (supabase-init.js)
- Tests: lint, smoke load pages
- Complexity: Low

Phase 2 — Supabase project setup
- Objectives: create Supabase project (staging), create buckets, setup Auth
- Files: infrastructure README, env example
- DB: create initial migrations for roles, clubs, users/profiles
- Frontend: integrate supabase-js configuration
- Tests: connect client to test project, verify auth endpoints
- Complexity: Low-Medium

Phase 3 — Authentication & Profiles
- Objectives: signup/login flows, profile creation page
- DB: users/profiles tables, user_roles
- Frontend: /login, /signup, profile completion modal or page; update nav to show auth state
- Tests: create user, verify email flow, profile record created
- Complexity: Medium

Phase 4 — RBAC & RLS
- Objectives: implement roles, RLS policies for core tables
- DB: roles, user_roles, policy SQL
- Frontend: role-aware nav and guard components
- Tests: role-based unit tests using test accounts (psql)
- Complexity: Medium-High

Phase 5 — Storage & Media pipeline
- Objectives: buckets creation, upload temp->validation->move, thumbnail generation
- DB: media_items, gallery_albums
- Edge Functions: validate_upload
- Frontend: upload UI, gallery now reads from DB
- Tests: upload flow & signed URL access
- Complexity: High

Phase 6 — Events & Registrations
- Objectives: event CRUD, registration workflow, approval flow
- DB: events, event_registrations
- Frontend: events listing, event detail, registration form; exec pages to manage
- Tests: register/unregister, approval flows
- Complexity: High

Phase 7 — Gallery & Submissions
- Objectives: user submissions, exec approvals, public gallery
- DB: submissions, media_items
- Frontend: submission flow, gallery pagination
- Tests: submission lifecycle, approval moves to public gallery
- Complexity: High

Phase 8 — Announcements & Notifications (Realtime)
- Objectives: announcements table, realtime subscriptions for appreciation wall
- DB: announcements
- Frontend: subscribe to Realtime channels for new posts and announcements
- Tests: realtime updates arrive on clients
- Complexity: Medium

Phase 9 — Appreciation Wall & Reactions
- Objectives: persist posts & reactions, anonymous support, rate limits
- DB: appreciation_posts, reactions
- Frontend: replace script.js dynamic DOM with DB-driven flow
- Tests: realtime posts, reaction counts consistency
- Complexity: Medium

Phase 10 — Certificates & Reports
- Objectives: generate certificates post-event, store PDFs, issue to users
- DB: certificates table
- Edge Functions: generate_certificate (PDF), send_email
- Frontend: download certificates page
- Tests: generate and retrieve certificate, access control
- Complexity: High

Phase 11 — Admin & Faculty tools
- Objectives: admin dashboards, role assignment UI, audit log viewer
- DB: audit_logs, activity_logs
- Frontend: admin-only pages (protected by RLS & client checks)
- Tests: admin-only flows
- Complexity: Medium

Phase 12 — Testing & Hardening
- Objectives: security audit, performance tests, backup tests
- Tools: migration tests, policy tests, penetration checks
- Complexity: Medium

Phase 13 — Production rollout & monitoring
- Objectives: swap endpoints to production Supabase, enable backups/alerts, run smoke tests
- Complexity: Medium

Per-phase deliverables include migration SQL, Edge Functions, minimal UI changes, and test checklist. Each phase should be implemented and validated before moving on.

Dependencies: Auth & RLS must be established before content with permissions (events, media) go live.

Estimated total timeline: 4–10 weeks depending on team size (1–3 devs).