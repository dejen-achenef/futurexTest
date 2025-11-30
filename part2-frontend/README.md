# Part 2: React Frontend Dashboard

## Setup Instructions

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Configure Environment**
   - Copy `.env.example` to `.env`
   - Update `VITE_API_URL` if backend is on different port
   - Add `VITE_YOUTUBE_API_KEY` for YouTube API integration (optional)

3. **Start Development Server**
   ```bash
   npm run dev
   ```

4. **Build for Production**
   ```bash
   npm run build
   ```

## Features

- ✅ Login page with JWT authentication
- ✅ Secure token storage in localStorage
- ✅ User list page with search and pagination
- ✅ Video upload page with YouTube integration
- ✅ Auto-fetch thumbnail from YouTube ID
- ✅ Material UI components
- ✅ Responsive design
- ✅ Protected routes

## Pages

- `/login` - Login page
- `/users` - User list with search and pagination
- `/videos/upload` - Video upload form with YouTube integration

