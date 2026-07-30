# 10 - Storage Design (Supabase Storage)

Buckets and purpose:
- avatars (private -> approved avatars moved to public/avatars)
- gallery (public-approved: public read; drafts: private)
- events (posters) - public read
- certificates (private) - users access via signed URLs
- submissions (private) - judges & execs access
- documents (policies, templates) - restricted to admins
- temp (short-lived upload staging, automatic cleanup)

Bucket naming and layout:
- avatars/
  - uploads/{user_id}/{uuid}.{ext}  (private by default)
  - public/{user_id}/{uuid}.{ext} (moved after approval)
- gallery/
  - albums/{album_id}/{uuid}.{ext}
- events/
  - posters/{event_id}/{uuid}.{ext}
- certificates/
  - issued/{certificate_id}.pdf
- submissions/
  - event_{event_id}/{submission_id}/{file}
- temp/
  - uploads/{random-token}

File naming conventions:
- Use {entity}_{id}_{timestamp}_{rand}.{ext} or store by UUID to avoid collisions and predictable paths
- Keep metadata in media_items table (storage_path, mime_type, size, width/height)

Access policies:
- Public read only for approved gallery and events posters
- Private for submissions and certificates; access via signed URL with expiration
- Uploads: client uploads to temp/ using a signed URL or restricted upload policy; server-side (Edge Function or DB trigger) moves file to final bucket after validation/approval

Validation & processing pipeline:
1. Client uploads file to temp/ (low-time expiration)
2. Edge Function validates mime-type, virus scan (optional), image dimensions
3. Create media_item DB row with approved=false
4. Move file to final storage path and update DB
5. For images, generate derived assets (thumbnails) and store metadata

Storage optimizations:
- Generate thumbnails and webp versions for gallery (store as derivatives)
- Use caching headers for public buckets via CDN
- Set lifecycle policies to purge temp/ after 24 hours

Security:
- Enforce max file sizes in client and server validation
- Limit accepted mime types (image/jpeg, image/png, webp, pdf for certificates)
- Scan uploads for malware if possible (third-party service or Edge Function)

Backups and retention:
- Consider exporting media to external backup if supabase storage retention is a concern

Notes:
- Use signed URLs for downloads and embed CDN URLs for public content.
- Prefer server-side move/approval to avoid exposing private buckets.