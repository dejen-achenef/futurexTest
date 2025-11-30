# Flutter App Setup Guide

## Quick Start

1. **Install Flutter Dependencies**
   ```bash
   cd part3-flutter
   flutter pub get
   ```

2. **Configure API Base URL** (if needed)

   The app automatically detects the platform:
   - **Android Emulator**: Uses `http://10.0.2.2:3000/api` (default)
   - **iOS Simulator**: Uses `http://localhost:3000/api` (default)
   
   For **physical devices**, update `lib/services/api_service.dart`:
   ```dart
   static String get baseUrl {
     // Replace with your computer's IP address
     return 'http://192.168.1.100:3000/api';
   }
   ```

3. **Android Configuration** (if needed)

   Add internet permission to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <manifest xmlns:android="http://schemas.android.com/apk/res/android">
       <uses-permission android:name="android.permission.INTERNET"/>
       <!-- ... rest of manifest ... -->
   </manifest>
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

## Testing Checklist

- [ ] Backend API is running (Part 1)
- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] API base URL configured correctly
- [ ] Can register new user
- [ ] Can login with credentials
- [ ] Video list loads on home screen
- [ ] Can search videos
- [ ] Can filter by category
- [ ] Can view video details
- [ ] YouTube video plays
- [ ] Can update profile
- [ ] Offline error handling works
- [ ] Retry mechanism works

## Troubleshooting

### "Target of URI doesn't exist" errors
- Run `flutter pub get` to install dependencies

### Connection timeout
- Check backend API is running
- Verify API base URL is correct
- For physical devices, ensure device and computer are on same network

### YouTube player not working
- Ensure internet connectivity
- Some videos may be region-restricted

