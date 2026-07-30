# 05 - Database Design (Relational Schema)

Design goals:
- Normalize data (3NF where reasonable)
- Use surrogate UUID PKs
- Audit columns: created_at, created_by, updated_at, updated_by, deleted_at (soft delete)
- Indexes for common queries (by created_at, event_date, club_id, user_id)
- Use enumerated types for statuses where useful

Core tables (summary):
- users (auth users reference)
- profiles (1:1 with users)
- roles (master role list)
- user_roles (many-to-many user <-> role with club scope)
- clubs (cultural, photography, joint)
- events
- event_registrations
- announcements
- gallery_albums
- media_items
- submissions (competition submissions)
- reactions (generic reaction entity for posts/media)
- appreciation_posts (graffiti wall posts)
- contact_messages
- certificates
- departments
- committees
- audit_logs
- activity_logs

Schemas (selected definitions):

users
- id UUID PK (references auth.users via Supabase)
- email TEXT (redundant but convenient)
- is_active BOOL
- created_at TIMESTAMP

profiles
- id UUID PK
- user_id UUID FK -> users.id UNIQUE
- display_name TEXT
- roll_number TEXT
- department_id UUID
- phone TEXT
- avatar_url TEXT (storage path)
- bio TEXT
- joined_at TIMESTAMP
- metadata JSONB

roles
- id UUID PK
- slug TEXT UNIQUE (student, member, exec_cultural...)
- name TEXT
- description TEXT

user_roles
- id UUID PK
- user_id FK
- role_id FK
- club_id FK NULLABLE
- assigned_by UUID
- assigned_at TIMESTAMP
- expires_at TIMESTAMP NULLABLE

clubs
- id UUID PK
- slug TEXT
- name TEXT
- description TEXT
- created_at

events
- id UUID PK
- club_id FK
- title TEXT
- description TEXT
- venue TEXT
- capacity INT
- start_ts TIMESTAMP
- end_ts TIMESTAMP
- poster_url TEXT (storage path)
- status TEXT (draft/pending/approved/cancelled/completed)
- created_by UUID
- created_at, updated_at, deleted_at

event_registrations
- id UUID PK
- event_id FK
- user_id FK
- status TEXT (pending/approved/rejected/cancelled)
- metadata JSONB (answers, attachments)
- created_at, updated_at

announcements
- id UUID PK
- club_id FK NULL for global
- title TEXT
- body TEXT
- published_at TIMESTAMP NULL
- created_by
- status TEXT (draft/published/archived)

gallery_albums
- id UUID
- club_id FK NULL for shared
- title, description
- cover_media_id FK
- created_by

media_items
- id UUID PK
- album_id FK
- user_id FK (uploader)
- storage_path TEXT
- mime_type TEXT
- width INT, height INT
- caption TEXT
- approved BOOL
- created_at

submissions
- id UUID
- media_item_id FK
- event_id FK NULL
- user_id
- status (submitted/approved/rejected/winner)
- judge_notes TEXT

reactions
- id UUID
- subject_type TEXT (appreciation, media, announcement)
- subject_id UUID
- user_id NULLABLE (anonymous reactions allowed)
- reaction_type TEXT (heart, clap)
- created_at

appreciation_posts
- id UUID
- user_id NULLABLE (anon allowed)
- text TEXT
- stickers TEXT[]
- color TEXT
- reactions_count JSONB or computed view
- created_at

contact_messages
- id UUID
- name, email, message, resolved BOOL
- created_at

certificates
- id UUID
- user_id FK
- event_id FK
- storage_path
- issued_at
- issued_by

audit_logs
- id UUID
- user_id
- action TEXT
- object_type
- object_id
- diff JSONB
- created_at

Indexes & constraints:
- PK on id (UUID with gen_random_uuid())
- Index on events (club_id, start_ts)
- Index on media_items (album_id, approved)
- Unique constraint on profiles.user_id
- FK cascade rules carefully: use SET NULL for user deletes or restrict

Views and materialized views:
- event_summary (counts of registrations)
- media_public_view (only approved media + public metadata)

Notes:
- Use JSONB for extensible metadata and form answers.
- Use soft delete via deleted_at to allow recovery and audit.
- Enforce referential integrity but avoid cascading deletes for user data (GDPR concerns).