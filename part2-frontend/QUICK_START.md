# React Frontend Quick Start

## Setup & Run

1. **Install Dependencies** (if not done)
   ```bash
   cd part2-frontend
   npm install
   ```

2. **Start Development Server**
   ```bash
   npm run dev
   ```

3. **Access the App**
   - Open browser to: `http://localhost:3001`
   - The app should load automatically

## Common Issues

### Issue: "Cannot find module" or "Module not found"
**Solution:**
```bash
# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Issue: Port 3001 already in use
**Solution:**
- Kill the process using port 3001, or
- Change port in `vite.config.ts`:
  ```typescript
  server: {
    port: 3002, // Change to different port
  }
  ```

### Issue: "Backend connection failed"
**Solution:**
- Make sure backend is running on `http://localhost:3000`
- Check `src/utils/api.ts` - API URL should be `http://localhost:3000/api`
- Or create `.env` file:
  ```
  VITE_API_URL=http://localhost:3000/api
  ```

### Issue: "CORS error"
**Solution:**
- Backend CORS is already configured
- Make sure backend is running
- Check browser console for specific error

## Pages

- **Login:** `http://localhost:3001/login`
- **Users:** `http://localhost:3001/users` (requires login)
- **Upload Video:** `http://localhost:3001/videos/upload` (requires login)

## Default Route

- Root (`/`) redirects to `/users` (requires login)
- If not logged in, redirects to `/login`

## Environment Variables (Optional)

Create `.env` file in `part2-frontend/`:
```
VITE_API_URL=http://localhost:3000/api
VITE_YOUTUBE_API_KEY=your-youtube-api-key-here
```

## Build for Production

```bash
npm run build
```

Build output will be in `dist/` folder.

