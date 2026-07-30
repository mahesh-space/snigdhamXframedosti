# 02 - Feature Analysis (Complete Inventory)

Source: index.html, framedosti.html, gallery.html, achievements.html, contact.html, script.js, style.css

Pages (observed):
- Home (index.html)
  - Activity sections (Singing, Drama, Photography etc.)
  - Digital Appreciation Wall (graffiti): post messages, reactions, stickers, spray effect
- Gallery (gallery.html)
  - Static gallery grid with images and captions
- FrameDosti (framedosti.html)
  - Photo Gallery subset
  - Upcoming Workshops (event cards, "Coming Soon")
- Achievements (achievements.html)
  - Achievement cards (event/contest badges)
- Contact (contact.html)
  - Coordinators profiles
  - Contact form (name, email, message)
- certificates.html (present but not linked heavily)

Interactive Features / User Actions:
- Post appreciation message to Digital Appreciation Wall (anonymous, in-memory)
- React to existing appreciation messages (increment counters inline)
- Toolbar tools: spray effect, add sticker, color picker (cosmetic)
- Contact form: client-side form submission (no backend integration)
- Static gallery image viewing (no upload/change)

Forms:
- Contact form (name, email, message)
- Graffiti canvas (contenteditable div with 'Post' button)

CRUD operations (current, frontend-only)
- Create: appreciation message creation (in DOM only)
- Read: static pages and hardcoded lists (achievements, events, gallery)
- Update: reaction counts (DOM only), minor UI changes
- Delete: none present

Filters/Search: none observed
Notifications: transient banner for new appreciation (client-only)
Role-based navigation: none implemented; site is public and anonymous
Media uploads: none (images are static files in repo)
Mock data: All content is hardcoded in HTML or script.js; no external JSON files

Placeholders / Future UX spots:
- Event registration/workshops ("Coming Soon")
- Certificates page (static placeholder)

Notes:
- The graffiti wall is the only dynamic JS-managed feature; everything else is static content.
- No use of localStorage or backend-like abstractions detected.

Recommendation: Backend must cover users/profiles, roles, events & registrations, gallery/media upload and management, announcements, contact messages, appreciation posts, reactions, and admin interfaces for approvals and content management.