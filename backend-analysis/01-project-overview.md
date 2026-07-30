# 01 - Project Overview

Project: Singhdham XFrameDosti (Snigdham Cultural Club & FrameDosti Photography Club)

Type: Frontend-only static site (HTML, CSS, Vanilla JS). No backend or database; all content hardcoded in HTML and script.js.

Scope of this analysis: Produce a production-ready Supabase backend blueprint covering data modeling (Postgres), authentication, RBAC, storage, realtime, API mapping, security, migration, and a phased implementation roadmap tied to the existing frontend.

Assumptions:
- Visual design and UI flows must remain unchanged.
- Frontend pages observed: index.html, gallery.html, framedosti.html, achievements.html, certificates.html, contact.html.
- Interactivity currently in script.js (graffiti wall messaging + reactions) with in-memory state.
- No JavaScript frameworks; integration will be via Supabase client (vanilla JS).

Constraints:
- Keep client-side changes minimal and non-invasive; prefer service wrappers and migration adapters.
- All data currently static/hardcoded must become database-driven.

Primary goals:
- Secure auth and session handling (Supabase Auth).
- Normalized Postgres schema supporting club workflows, events, registrations, gallery, announcements, profiles, RBAC.
- Supabase Storage for media and file handling.
- Row-Level Security policies and permission matrix.
- A clear incremental implementation roadmap that another developer/AI can follow step-by-step.