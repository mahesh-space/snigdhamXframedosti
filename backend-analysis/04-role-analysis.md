# 04 - Role Analysis & Permission Summary

Identified Roles (recommended canonical set):
- guest (unauthenticated)
- student (authenticated basic user)
- member (verified club member)
- exec_cultural (Cultural Club Executive)
- exec_photography (Photography Club Executive)
- exec_joint (joint role if needed)
- faculty (Faculty Coordinator)
- admin (System Administrator)

Role Hierarchy (least->most permissive): guest < student < member < exec_* < faculty < admin

Permissions matrix (high level):
- guest: read public pages, submit contact messages, read public gallery/achievements
- student: everything guest + create profile, register for events, post appreciation (optionally anon), react, upload submissions to own draft
- member: student + view member-only pages, access member roster, join committees
- exec_*: member + create/edit/delete events (own club), manage gallery submissions, approve registrations, publish announcements for their club, view registrations & reports
- faculty: exec_* + approve events globally, manage executives, publish official announcements, issue certificates
- admin: full CRUD for all tables, manage roles, storage buckets, RLS overrides, backups

Table-level CRUD recommendations:
- users: admin can CRUD; faculty can view/assign; users can update own profile
- profiles: users manage own; admin/faculty can update
- events: exec create/update for own club; faculty/admin approve & manage
- registrations: student create; exec/faculty update status
- gallery/media: exec manage/approve; users upload to submissions table; public images served with bucket policies
- announcements: exec create for club; faculty/admin publish global notices

UI visibility:
- Navigation changes based on auth & role (client-side checks but server must enforce)
- Dashboards: exec & faculty have extra navigation links to management pages (to be implemented)

RLS & JWT claims:
- Store role in user_metadata and a separate user_roles table
- Use JWT custom claims or session metadata for quick RLS checks

Notes:
- Keep role checks minimal on client; enforce via RLS and Postgres policies.
- Provide admin panel or SQL-ready scripts for initial role assignments.