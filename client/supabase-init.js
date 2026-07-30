// supabase-init.js
// Lightweight wrapper for supabase client (vanilla JS)
// Replace the placeholders with environment variables at build time or use a config file.

import { createClient } from '@supabase/supabase-js'

const SUPABASE_URL = window.__ENV__?.SUPABASE_URL || '<YOUR_SUPABASE_URL>'
const SUPABASE_ANON_KEY = window.__ENV__?.SUPABASE_ANON_KEY || '<YOUR_SUPABASE_ANON_KEY>'

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

// Auth helpers
export async function signUp(email, password) {
  return await supabase.auth.signUp({ email, password })
}

export async function signIn(email, password) {
  return await supabase.auth.signInWithPassword({ email, password })
}

export async function signOut() {
  return await supabase.auth.signOut()
}

export function onAuthChange(callback) {
  // supabase-js v2
  return supabase.auth.onAuthStateChange((event, session) => {
    callback(event, session)
  })
}

// Data helpers (examples)
export async function fetchPublicMedia({ limit = 20, offset = 0 } = {}) {
  const { data, error } = await supabase
    .from('media_items')
    .select('id, storage_path, caption, created_at')
    .eq('approved', true)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)
  if (error) throw error
  return data
}

export async function postAppreciation({ text, stickers = [], color = null }) {
  const user = supabase.auth.getUser ? (await supabase.auth.getUser()).data.user : null
  const payload = {
    user_id: user?.id || null,
    text,
    stickers,
    color,
  }
  const { data, error } = await supabase.from('appreciation_posts').insert(payload).select().single()
  if (error) throw error
  return data
}

export function subscribeToAppreciation(onInsert) {
  // Realtime subscription using Supabase Realtime
  return supabase.channel('public:appreciation_posts')
    .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'appreciation_posts' }, (payload) => {
      onInsert(payload.new)
    })
    .subscribe()
}

// Note: adjust APIs if using different supabase-js versions. Keep service_role key ONLY on server/Edge Functions.
