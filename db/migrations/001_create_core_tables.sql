-- 001_create_core_tables.sql
-- Initial core schema for Supabase-backed Singhdham XFrameDosti

-- Enable pgcrypto for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Roles
CREATE TABLE IF NOT EXISTS roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Clubs
CREATE TABLE IF NOT EXISTS clubs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Profiles (1:1 with auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL,
  display_name TEXT,
  roll_number TEXT,
  department TEXT,
  phone TEXT,
  avatar_url TEXT,
  bio TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- User roles (many-to-many, optional club scope)
CREATE TABLE IF NOT EXISTS user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  club_id UUID REFERENCES clubs(id) ON DELETE SET NULL,
  assigned_by UUID,
  assigned_at TIMESTAMPTZ DEFAULT now(),
  expires_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(user_id);

-- Appreciation wall posts
CREATE TABLE IF NOT EXISTS appreciation_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  text TEXT NOT NULL,
  stickers TEXT[],
  color TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_appreciation_created_at ON appreciation_posts(created_at DESC);

-- Media items (gallery, posters, submissions)
CREATE TABLE IF NOT EXISTS media_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  album_id UUID,
  user_id UUID,
  storage_path TEXT NOT NULL,
  mime_type TEXT,
  caption TEXT,
  width INT,
  height INT,
  approved BOOLEAN DEFAULT FALSE,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_media_approved ON media_items(approved);

-- Contact messages
CREATE TABLE IF NOT EXISTS contact_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT,
  email TEXT,
  message TEXT,
  resolved BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Simple audit log (expandable)
CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  action TEXT NOT NULL,
  object_type TEXT,
  object_id UUID,
  diff JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Seed minimal roles and clubs
INSERT INTO roles (slug, name, description)
  SELECT 'student', 'Student', 'Default authenticated student'
  WHERE NOT EXISTS (SELECT 1 FROM roles WHERE slug = 'student');

INSERT INTO roles (slug, name)
  SELECT 'member', 'Member' WHERE NOT EXISTS (SELECT 1 FROM roles WHERE slug = 'member');

INSERT INTO roles (slug, name)
  SELECT 'exec_cultural', 'Cultural Executive' WHERE NOT EXISTS (SELECT 1 FROM roles WHERE slug = 'exec_cultural');

INSERT INTO roles (slug, name)
  SELECT 'exec_photography', 'Photography Executive' WHERE NOT EXISTS (SELECT 1 FROM roles WHERE slug = 'exec_photography');

INSERT INTO clubs (slug, name)
  SELECT 'snigdham', 'Snigdham Cultural Club' WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE slug = 'snigdham');

INSERT INTO clubs (slug, name)
  SELECT 'framedosti', 'FrameDosti Photography Club' WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE slug = 'framedosti');
