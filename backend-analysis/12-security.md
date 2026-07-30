# 12 - Security Review & Recommendations

Authentication risks:
- Missing email verification -> risk of fake accounts
  - Enforce email verification before sensitive actions
- Session hijacking -> use secure cookies and refresh tokens from Supabase client

Authorization risks:
- Client-side role checks only: must enforce via RLS policies
- Leaked service keys: keep service_role key only in Edge Functions or server

Input validation & client trust:
- Never trust client-side validation for forms and uploads
- Validate all fields server-side (Edge Function or DB constraints)

Storage & file upload security:
- Validate mime types, max size, dimensions server-side
- Use virus/malware scans for submitted files (optional)
- Upload to temp bucket, validate, then move to final bucket

SQL risks:
- Use parameterized queries or supabase-js to avoid injection
- Use least-privilege for DB roles; service_role only for server

Rate limiting & spam protection:
- Throttle rapid appreciation posts and contact messages per IP/user
- Add CAPTCHA for guest submissions

Audit logging:
- Log create/update/delete actions in audit_logs with user id and diff
- Keep immutable logs for critical admin actions

Soft delete & recovery:
- Use deleted_at timestamp for soft deletes
- Provide admin scripts to restore rows

Backups & DR:
- Regular DB backups and storage backup snapshots
- Test restore process quarterly

Additional recommendations:
- Enforce HTTPS and HSTS
- Use CSP and secure headers in frontend
- Monitor usage spikes and set billing alerts on Supabase
- Run RLS policy tests as part of CI (psql scripts) to prevent regressions

Privacy & compliance:
- Limit storage of PII; only store necessary profile fields
- Allow users to request account deletion; remove personal files and anonymize records

Notes on quick fixes required before production:
- Replace anonymous-only appreciation with optional authenticated posting and rate limits
- Add server-side contact form handling to avoid spam via email notifications/Edge Functions