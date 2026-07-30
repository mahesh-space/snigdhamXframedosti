# 03 - User Flows (Inferred from frontend)

High-level actors: Guest, Student, Club Member, Club Executive, Faculty Coordinator, Administrator

1) Guest (no auth)
- Browse Home, Gallery, Achievements, FrameDosti, Contact
- Submit contact form (should create a support/ticket entry)
- View public gallery and achievements

2) Student / Authenticated Member
- Sign up / Sign in (email)
- Create profile (name, department, roll number, phone, avatar)
- Browse events & workshops
- Register for events (sign up form, optional attachments)
- Post to Appreciation Wall (non-anonymous option if signed in)
- React to appreciation posts
- Upload photos to personal submissions (optional)
- View own registrations, certificates

3) Club Member (verified by exec)
- Edit own profile
- Create gallery submissions
- Participate in contests and view own results

4) Club Executive (Photography / Cultural)
- Create and manage events (title, description, venue, capacity, poster upload, dates)
- Manage gallery: create albums, approve/reject submissions, feature images
- Publish announcements/notifications
- View and approve event registrations
- Manage member list of their club

5) Faculty Coordinator
- Approve events created by executives
- Manage club executives (assign/unassign)
- Publish high-priority announcements
- View reports and logs (registrations, attendance)

6) Administrator
- Full CRUD on users, roles, clubs, events, announcements
- Manage storage, backups, RLS overrides
- Audit logs access

Edge workflows inferred:
- Event registration approval (exec reviews registrations for curated events)
- Photo competition submission -> exec review -> judge selection -> publish winners
- Certificate issuance (post-event) -> generate certificate record + downloadable file

Notifications & Realtime:
- New appreciation posts notify wall subscribers (client realtime)
- Event creation/announcement push to subscribed users (realtime or email)
- Registration status changes (approved/rejected) -> notification

Audit & Activity:
- Track who created/edited/deleted critical resources with timestamps
- Soft-delete resources to allow recovery

These flows map directly to database tables and Supabase features (Auth, Realtime, Storage, Edge Functions).