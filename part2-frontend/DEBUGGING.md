# React App Debugging Guide

## Login Not Working - Troubleshooting

### 1. Check Browser Console
- Open browser DevTools (F12)
- Go to Console tab
- Look for `[API]` and `[AuthService]` logs
- These will show exactly what's happening

### 2. Check Network Tab
- Open DevTools (F12)
- Go to Network tab
- Try to login
- Look for the `/auth/login` request
- Check:
  - Status code (should be 200)
  - Request URL (should be `http://localhost:3000/api/auth/login`)
  - Response data

### 3. Common Issues

#### Issue: "Cannot connect to server"
**Solution:**
- Make sure backend is running: `cd part1-backend && npm run dev`
- Check backend is on port 3000
- Verify API URL in browser console (should show `[API] Base URL: http://localhost:3000/api`)

#### Issue: "CORS error"
**Solution:**
- Backend CORS is configured, but check:
  - Backend is running
  - No firewall blocking
  - Check browser console for specific CORS error

#### Issue: "401 Unauthorized" or "Invalid email or password"
**Solution:**
- This means connection is working!
- Check:
  - Email/password are correct
  - User exists in database
  - Try registering a new user first

#### Issue: "Network Error" or "ERR_CONNECTION_REFUSED"
**Solution:**
- Backend is not running or not accessible
- Start backend: `cd part1-backend && npm run dev`
- Check backend logs for errors

### 4. Test Backend First
Before testing React app, verify backend works:
```bash
# In Postman or curl
POST http://localhost:3000/api/auth/login
Body: {
  "email": "test@example.com",
  "password": "password123"
}
```

### 5. Check Environment Variables
The app uses:
- `VITE_API_URL` (optional, defaults to `http://localhost:3000/api`)

Create `.env` file if needed:
```
VITE_API_URL=http://localhost:3000/api
```

### 6. What to Look For in Console

**Successful Login:**
```
[API] Base URL: http://localhost:3000/api
[AuthService] Logging in user: test@example.com
[API] Request: POST /auth/login
[API] Response: POST /auth/login 200
[AuthService] Login response: {message: "...", user: {...}, token: "..."}
Token saved, navigating to /users
```

**Failed Login:**
```
[API] Base URL: http://localhost:3000/api
[AuthService] Logging in user: test@example.com
[API] Request: POST /auth/login
[API] Error: POST /auth/login
[API] Error details: {message: "...", status: 401, data: {...}}
[AuthService] Login error: ...
```

### 7. Quick Test Steps

1. **Open React app:** `http://localhost:3001`
2. **Open browser console:** F12 → Console tab
3. **Try to login** with credentials
4. **Check console logs** - you'll see detailed logs
5. **Check Network tab** - see the actual HTTP request
6. **Read error message** - it will tell you what's wrong

### 8. Still Not Working?

Share these details:
1. Error message shown on screen
2. Browser console logs (copy all `[API]` and `[AuthService]` logs)
3. Network tab - screenshot of the `/auth/login` request
4. Backend terminal - any errors there?

