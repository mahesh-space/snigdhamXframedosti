# 11 - API Mapping (Frontend -> Supabase)

Approach: Prefer direct supabase-js calls from frontend for read/public endpoints and use Edge Functions for sensitive operations (emailing, certificate generation, admin tasks). All DB mutations must be protected by RLS; sensitive admin ops via Edge Functions with service_role key.

Mapping by page:

Home (index.html)
- Required data: public announcements, featured events, appreciation posts (recent)
- Queries:
  - SELECT * FROM announcements WHERE published_at <= now() ORDER BY published_at DESC LIMIT 10
  - SELECT * FROM appreciation_posts ORDER BY created_at DESC LIMIT 20
- Inserts:
  - INSERT INTO appreciation_posts (user_id NULLABLE, text, stickers, color)
- Realtime:
  - subscribe to appreciation_posts inserts for live update

Gallery (gallery.html / framedosti.html)
- Required data: public media_items where approved = true (optionally filter by album/club)
- Queries:
  - SELECT id, storage_path, caption, created_at FROM media_items WHERE approved = true ORDER BY created_at DESC LIMIT ? OFFSET ?
- Inserts:
  - Upload flow: upload to temp -> call edge function to validate -> insert media_items row with approved=false
- Realtime: subscribe to media_items approvals to update client

Events (framedosti upcoming workshops)
- Queries:
  - SELECT * FROM events WHERE status = 'approved' AND start_ts >= now() ORDER BY start_ts
- Inserts (exec):
  - INSERT events (club_id, title, description, start_ts, poster_url, status = 'pending')
- Updates (faculty to approve): UPDATE events SET status='approved' WHERE id = ?
- Registrations:
  - INSERT event_registrations (event_id, user_id, metadata)
  - Update registration status by exec/faculty

Contact form (contact.html)
- Inserts:
  - INSERT INTO contact_messages (name, email, message, resolved=false)
- Optional: Edge Function to send email notification to coordinators

Achievements (achievements.html)
- Queries: static content initially; migrate to announcements/achievements table for dynamic content
- Schema: achievements table or announcements with category='achievement'

Appreciation Wall (script.js)
- Create: POST to appreciation_posts (user_id optional)
- Read: GET recent posts
- Realtime: Subscribe to appreciation_posts for new inserts
- Reactions: POST reaction rows referencing subject_type='appreciation' and subject_id

Authentication flows (all pages)
- Supabase Auth client usage: signUp, signIn, signOut, onAuthStateChange
- After sign-in: fetch profile and user roles, set client state

Pagination, Filtering, Sorting
- Implement server-side pagination via LIMIT/OFFSET for media, events, posts
- Add text search for events/media using Postgres full-text search or indexes

Caching
- Use client-side in-memory cache with TTL for public endpoints (e.g., announcements)
- Consider SWR pattern or small local caching layer

Rate limits & abuse prevention
- Throttle appreciation posts per-user/IP (Edge Function or DB constraint + trigger)
- Require account for non-anonymous posts or enforce captcha on guest posts

Notes:
- Favor direct supabase-js calls for simple CRUD; use Edge Functions for email, certificate gen, and admin-only actions.
- Ensure all client requests validate inputs and handle RLS-denied responses gracefully.