# Flutter App Troubleshooting Guide

## Sign Up / Sign In Not Working

### Fixed Issues:
1. ✅ **Android Emulator URL** - Now uses `10.0.2.2:3000` instead of `localhost`
2. ✅ **CORS Configuration** - Backend now allows all origins
3. ✅ **Error Handling** - Better error messages and logging
4. ✅ **Connection Timeout** - Increased to 30 seconds
5. ✅ **Response Parsing** - Better error handling for invalid responses

### How to Test:

#### 1. Check Backend is Running
```bash
cd part1-backend
npm run dev
```
You should see: `Server is running on port 3000`

#### 2. Test Backend in Postman First
- Test `POST /api/auth/register` - Should work
- Test `POST /api/auth/login` - Should work
- If these work, the backend is fine

#### 3. Check Flutter App Configuration

**For Android Emulator:**
- The app is configured to use: `http://10.0.2.2:3000/api`
- This is correct for Android emulator

**For iOS Simulator:**
- Change in `lib/services/api_service.dart`:
  ```dart
  return 'http://localhost:3000/api'; // Change from 10.0.2.2
  ```

**For Physical Device:**
- Find your computer's IP address:
  - Windows: `ipconfig` (look for IPv4 Address)
  - Mac/Linux: `ifconfig` or `ip addr`
- Update `lib/services/api_service.dart`:
  ```dart
  return 'http://YOUR_IP_ADDRESS:3000/api'; // e.g., 'http://192.168.1.100:3000/api'
  ```

**For Web:**
- Uses `http://localhost:3000/api` (should work)

#### 4. Check Console Logs

When you try to login/register, check the Flutter console for:
- `[API] Login response:` - Shows the response from server
- `[API] Login error:` - Shows any errors
- `[API] Error type:` - Shows the type of error

#### 5. Common Issues and Solutions

**Issue: "Cannot connect to server"**
- **Solution:** 
  - Make sure backend is running
  - Check the base URL matches your platform
  - For physical device, use computer's IP address, not localhost

**Issue: "Connection timeout"**
- **Solution:**
  - Check firewall settings
  - Make sure backend is accessible
  - Try increasing timeout in `api_service.dart`

**Issue: "Invalid response from server"**
- **Solution:**
  - Check backend logs for errors
  - Verify backend is returning correct JSON format
  - Check CORS is properly configured

**Issue: "401 Unauthorized" or "Invalid token"**
- **Solution:**
  - This is normal for login/register (they don't need tokens)
  - If you see this, the connection is working but authentication failed
  - Check email/password are correct

#### 6. Debug Steps

1. **Test Health Endpoint:**
   - In Flutter, you can add a test button to call `/api/health`
   - Or test in Postman: `GET http://localhost:3000/api/health`

2. **Check Network:**
   - Make sure your device/emulator can reach the backend
   - For emulator: `10.0.2.2` should work
   - For physical device: Use your computer's IP

3. **Check Backend Logs:**
   - Look at the terminal where backend is running
   - You should see incoming requests
   - If no requests appear, the Flutter app isn't reaching the backend

4. **Test with curl (if available):**
   ```bash
   # From your computer
   curl http://localhost:3000/api/health
   
   # Should return: {"status":"OK","message":"FutureX API is running"}
   ```

#### 7. Quick Fix: Update Base URL

If nothing works, manually set the base URL in `lib/services/api_service.dart`:

```dart
static String get baseUrl {
  // Uncomment the one that matches your setup:
  
  // For Android Emulator:
  return 'http://10.0.2.2:3000/api';
  
  // For iOS Simulator:
  // return 'http://localhost:3000/api';
  
  // For Physical Device (replace with your IP):
  // return 'http://192.168.1.100:3000/api';
  
  // For Web:
  // return 'http://localhost:3000/api';
}
```

#### 8. Verify Backend CORS

The backend should have CORS configured (already fixed):
```javascript
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));
```

### Still Not Working?

1. **Check Flutter Console:**
   - Look for `[API]` logs
   - They show exactly what's happening

2. **Check Backend Console:**
   - Should show incoming requests
   - If no requests, Flutter app can't reach backend

3. **Try Different Platform:**
   - Test on web: `flutter run -d chrome`
   - Test on emulator: `flutter run -d android`
   - See which one works

4. **Check Error Messages:**
   - The app now shows detailed error messages
   - Read them carefully - they tell you what's wrong

### Expected Behavior:

1. **Register:**
   - Enter name, email, password
   - Click Register
   - Should show loading, then navigate to home screen
   - Console shows: `[API] Register response: {...}`

2. **Login:**
   - Enter email, password
   - Click Login
   - Should show loading, then navigate to home screen
   - Console shows: `[API] Login response: {...}`

If you see error messages, they will now be more descriptive and help identify the issue.


