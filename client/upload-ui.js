import { supabase } from './supabase-init.js'

const fileInput = document.getElementById('file')
const captionInput = document.getElementById('caption')
const uploadBtn = document.getElementById('uploadBtn')
const status = document.getElementById('status')
const preview = document.getElementById('preview')

// Configure the Edge Function URL in window.__ENV__.VALIDATE_UPLOAD_URL or replace below.
const VALIDATE_UPLOAD_URL = window.__ENV__?.VALIDATE_UPLOAD_URL || '<VALIDATE_UPLOAD_FUNCTION_URL>'
const TEMP_BUCKET = 'temp'
const TARGET_BUCKET = 'gallery'

function setStatus(msg, isError = false) {
  status.textContent = msg
  status.style.color = isError ? '#f87171' : '#9ae6b4'
}

fileInput.addEventListener('change', () => {
  const f = fileInput.files[0]
  preview.innerHTML = ''
  if (f) {
    const img = document.createElement('img')
    img.src = URL.createObjectURL(f)
    preview.appendChild(img)
  }
})

uploadBtn.addEventListener('click', async () => {
  const f = fileInput.files[0]
  const caption = captionInput.value
  if (!f) return setStatus('Select a file first', true)
  setStatus('Uploading to temp storage...')

  // Get current user id (if logged in)
  let userId = null
  try {
    const { data: { user } } = await supabase.auth.getUser()
    userId = user?.id
  } catch (e) {
    // anonymous allowed
  }
  if (!userId) userId = 'anon'

  const tempPath = `uploads/${userId}/${Date.now()}_${f.name}`
  const { error: uploadError } = await supabase.storage.from(TEMP_BUCKET).upload(tempPath, f, { upsert: false })
  if (uploadError) return setStatus('Upload failed: ' + uploadError.message, true)

  setStatus('File uploaded to temp. Requesting validation...')

  // Call Edge Function to validate and move the file
  try {
    const resp = await fetch(VALIDATE_UPLOAD_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ temp_path: tempPath, uploader_id: userId, intended_bucket: TARGET_BUCKET, caption })
    })
    const body = await resp.json()
    if (!resp.ok) {
      setStatus('Validation failed: ' + (body.error || resp.statusText), true)
      return
    }

    // Success
    setStatus('File validated and moved to gallery')
    const imgUrl = body.url || null
    if (imgUrl) {
      const a = document.createElement('a')
      a.href = imgUrl
      a.target = '_blank'
      a.textContent = 'Open uploaded image'
      preview.appendChild(a)
    }
  } catch (err) {
    setStatus('Validation request failed: ' + err.message, true)
  }
})
