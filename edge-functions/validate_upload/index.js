// Edge Function: validate_upload
// Template for validating uploads after client sends a temp path.
// This function must run server-side with the SUPABASE_SERVICE_ROLE_KEY.

// Example: Node/Express style pseudocode. Adapt to Supabase Edge Functions runtime.

/*
export default async function handler(req, res) {
  const { temp_path, uploader_id, intended_bucket, metadata } = req.body
  // 1. Validate mime type and size via HEAD or storage API
  // 2. Optionally run virus scan (third-party)
  // 3. If OK, move to final destination (use service role key)
  // 4. Insert media_items row with approved=false (or true if trusted uploader)
  // 5. Return final storage path and media record
}
*/

// Minimal illustrative implementation using fetch and supabase-js (server)
import { createClient } from '@supabase/supabase-js'

const SUPABASE_URL = process.env.SUPABASE_URL
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

export async function handler(request) {
  const body = await request.json()
  const { temp_path, uploader_id, intended_bucket = 'gallery', caption = null } = body

  // Basic checks (expand as needed)
  if (!temp_path || !uploader_id) {
    return new Response(JSON.stringify({ error: 'missing params' }), { status: 400 })
  }

  // Validate metadata using storage API
  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp']
  const MAX_SIZE_BYTES = 8 * 1024 * 1024 // 8MB

  const { data: meta, error: metaErr } = await supabase.storage.from('temp').getMetadata(temp_path)
  if (metaErr || !meta) {
    return new Response(JSON.stringify({ error: 'metadata_not_found', details: metaErr }), { status: 400 })
  }

  if (!allowedTypes.includes(meta.content_type)) {
    return new Response(JSON.stringify({ error: 'invalid_mime', mime: meta.content_type }), { status: 400 })
  }

  if (meta.size > MAX_SIZE_BYTES) {
    return new Response(JSON.stringify({ error: 'file_too_large', size: meta.size }), { status: 400 })
  }

  // Determine final path in target bucket
  const filename = temp_path.split('/').pop()
  const finalPath = `${intended_bucket}/${uploader_id}/${Date.now()}_${filename}`

  // Download from temp bucket
  const { data: downloaded, error: dlErr } = await supabase.storage.from('temp').download(temp_path)
  if (dlErr || !downloaded) {
    return new Response(JSON.stringify({ error: 'download_failed', details: dlErr }), { status: 500 })
  }

  // Upload to intended bucket
  const { error: uploadErr } = await supabase.storage.from(intended_bucket).upload(finalPath, downloaded, { upsert: false })
  if (uploadErr) {
    return new Response(JSON.stringify({ error: 'upload_failed', details: uploadErr }), { status: 500 })
  }

  // Insert DB record
  const { data, error } = await supabase.from('media_items').insert({
    user_id: uploader_id,
    storage_path: finalPath,
    caption,
    mime_type: meta.content_type,
    width: meta.metadata?.width || null,
    height: meta.metadata?.height || null,
    approved: false
  }).select().single()

  if (error) {
    // Attempt cleanup of uploaded file
    try { await supabase.storage.from(intended_bucket).remove([finalPath]) } catch (e) {}
    return new Response(JSON.stringify({ error: 'db_insert_failed', details: error }), { status: 500 })
  }

  // Remove temp file
  try { await supabase.storage.from('temp').remove([temp_path]) } catch (e) {}

  // Create signed URL for the newly uploaded file (short-lived)
  const { data: urlData, error: urlErr } = await supabase.storage.from(intended_bucket).createSignedUrl(finalPath, 60 * 60)
  if (urlErr) {
    return new Response(JSON.stringify({ error: 'signed_url_failed', details: urlErr }), { status: 500 })
  }

  return new Response(JSON.stringify({ media: data, url: urlData.signedUrl }), { status: 200 })
}
