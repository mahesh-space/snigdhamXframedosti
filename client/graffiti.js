import { supabase, postAppreciation, subscribeToAppreciation } from './supabase-init.js'

const graffitiWall = document.querySelector('.graffiti-wall')
const canvas = document.querySelector('.drawing-canvas')
const postBtn = document.querySelector('.graffiti-btn')
const alertEl = document.querySelector('.update-alert')

// Render a post node
function renderPost(p) {
  const newMessage = document.createElement('div')
  newMessage.className = 'graffiti-message'
  newMessage.style.setProperty('--color', `hsl(${Math.random() * 360}, 70%, 60%)`)
  newMessage.innerHTML = `
    <div class="message-content">
      <span class="spray-effect">${escapeHtml(p.text)}</span>
      <div class="message-footer">
        <span class="author">- ${escapeHtml(p.user_id ? p.user_id.slice(0,6) : 'Anonymous')}</span>
        <div class="reactions">
          <button class="react-btn" data-id="${p.id}">❤️ 0</button>
        </div>
      </div>
      <div class="sticker">${p.stickers?.[0] || ''}</div>
    </div>
  `
  graffitiWall.prepend(newMessage)
}

function escapeHtml(s){ if(!s) return ''; return s.replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;') }

// Load recent posts from DB
async function loadPosts(){
  try{
    const { data, error } = await supabase.from('appreciation_posts').select('*').order('created_at',{ascending:false}).limit(30)
    if(error) throw error
    data.forEach(renderPost)
  }catch(e){ console.error('load posts', e) }
}

// Handle new post submission
async function handlePost(e){
  e.preventDefault()
  const text = canvas.textContent.trim()
  if(!text) return
  try{
    await postAppreciation({ text, stickers: [], color: null })
    showTemporaryAlert()
    canvas.textContent = ''
  }catch(err){ console.error(err); alert('Failed to post') }
}

function showTemporaryAlert(){ alertEl.style.display='block'; setTimeout(()=>alertEl.style.display='none',2500) }

postBtn.addEventListener('click', handlePost)
postBtn.addEventListener('touchend', handlePost)

graffitiWall.addEventListener('click', (e)=>{
  if(e.target.classList.contains('react-btn')){
    const id = e.target.getAttribute('data-id')
    handleReaction(id, e.target)
  }
})

async function handleReaction(postId, btn){
  try{
    const user = (await supabase.auth.getUser()).data.user
    const payload = { subject_type: 'appreciation', subject_id: postId, user_id: user?.id || null, reaction_type: 'heart' }
    const { error } = await supabase.from('reactions').insert(payload)
    if(error) throw error
    // naive increment UI
    let count = parseInt(btn.textContent.match(/\d+/))||0
    btn.textContent = `❤️ ${++count}`
  }catch(e){ console.error('react',e) }
}

// Subscribe to realtime inserts
const sub = subscribeToAppreciation((newRow)=>{
  renderPost(newRow)
  showTemporaryAlert()
})

// Initial load
loadPosts()

// Cleanup on unload
window.addEventListener('beforeunload', ()=>{ if(sub && sub.unsubscribe) sub.unsubscribe() })
