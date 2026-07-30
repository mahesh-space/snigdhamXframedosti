# 08 - Authentication Design (Supabase Auth)

Auth flows to implement:
- Email + password signup
- Email confirmation (required)
- Sign in (email/password)
- Forgot password (reset via email)
- Persistent sessions with secure refresh
- Logout and session revoke
- Social logins (optional: Google) — add later if required

User lifecycle:
1. Signup -> Supabase Auth user created
2. After email verification, frontend calls profile creation flow to populate profiles table
3. Admin or faculty may assign roles (user_roles row)

Client-side considerations:
- Use supabase-js in vanilla JS; wrap auth in a single module (supabase-init.js)
- Protect pages by checking session and role at load time; hide UI elements accordingly
- Do not rely on client checks for authorization; enforce via RLS

Server-side details:
- Store additional claims in JWT: role(s) or references to user_roles? Supabase allows custom JWT claims via Row-Level Security by mapping to auth.users metadata or using a view.
- Recommended: store primary_role or roles array in profiles.user_metadata and create a function to expose as JWT claim during sign-in (or read via supabase.rpc with service key when needed). Note: Supabase Auth JWT custom claims require use of gotrue/user_metadata.

Onboarding & Role Assignment:
- After first login, user directed to /complete-profile where profile record is created.
- Default role: student
- Role elevation: admin/faculty can grant exec roles via admin UI (Edge Function or direct SQL)

Security:
- Enforce email verification before allowing role-sensitive actions via RLS policies referencing auth.email_verified
- Use refresh tokens handled by supabase-js; never store service role key client-side

Edge Functions:
- send_welcome_email(user_id)
- assign_initial_role(user_id, role_slug) - callable by admin

Session management:
- On auth state change, client fetches profile and user roles to store in memory for UI.
- Implement session expiry and handle refresh errors gracefully (force re-login).

Notes:
- Keep membership verification (e.g., verifying student roll numbers) manual initially; can add verification flow later (upload of ID, faculty approval).