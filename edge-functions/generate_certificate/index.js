// Edge Function: generate_certificate
// Template to generate a PDF certificate for a user and upload to certificates bucket.
// Requires SUPABASE_SERVICE_ROLE_KEY and a PDF generation library (e.g., Puppeteer or PDFKit) in the Edge runtime.

/*
export default async function handler(req, res) {
  const { user_id, event_id, issued_by } = req.body
  // 1. Fetch user/profile and event details
  // 2. Render certificate HTML or template and convert to PDF
  // 3. Store PDF in certificates/issued/{certificate_id}.pdf using service role key
  // 4. Insert certificate row into certificates table with storage_path
  // 5. Return signed URL or DB record
}
*/

import { createClient } from '@supabase/supabase-js'

const SUPABASE_URL = process.env.SUPABASE_URL
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

export async function handler(request) {
  const body = await request.json()
  const { user_id, event_id, issued_by } = body

  if (!user_id || !event_id) {
    return new Response(JSON.stringify({ error: 'missing params' }), { status: 400 })
  }

  // Fetch user and event details (expand fields as needed)
  const { data: profile } = await supabase.from('profiles').select('*').eq('user_id', user_id).single()
  const { data: event } = await supabase.from('events').select('*').eq('id', event_id).single()

  // TODO: Render certificate (HTML -> PDF) using your chosen library
  // For now, create a placeholder text file as proof-of-concept
  const certificateId = crypto.randomUUID()
  const filename = `certificates/issued/${certificateId}.txt`
  const content = `Certificate for ${profile?.display_name || user_id} - Event: ${event?.title || event_id}`

  const { error: uploadErr } = await supabase.storage.from('certificates').upload(filename, new Blob([content]), { upsert: true })
  if (uploadErr) return new Response(JSON.stringify({ error: uploadErr }), { status: 500 })

  // Insert DB record
  const { data: certRow, error: insertErr } = await supabase.from('certificates').insert({
    user_id,
    event_id,
    storage_path: filename,
    issued_at: new Date().toISOString(),
    issued_by
  }).select().single()

  if (insertErr) return new Response(JSON.stringify({ error: insertErr }), { status: 500 })

  // Return signed URL
  const { data: urlData, error: urlErr } = await supabase.storage.from('certificates').createSignedUrl(filename, 60 * 60) // 1 hour
  if (urlErr) return new Response(JSON.stringify({ error: urlErr }), { status: 500 })

  return new Response(JSON.stringify({ certificate: certRow, url: urlData.signedUrl }), { status: 200 })
}
