# Part 3: Flutter Mobile App

A mini video learning app built with Flutter that integrates with the Node.js backend API.

## Features

- ✅ Login screen with JWT authentication
- ✅ Home screen with video list (thumbnail, title, category)
- ✅ Video details screen with YouTube player
- ✅ Profile screen for updating user information
- ✅ BLoC state management
- ✅ Secure storage for JWT tokens
- ✅ Offline handling with retry mechanism
- ✅ Network connectivity checking
- ✅ Error handling and user feedback

## Setup Instructions

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio / Xcode (for iOS)
- Backend API running (Part 1)

### Installation

1. **Install Dependencies**
   ```bash
   cd part3-flutter
   flutter pub get
   ```

2. **Configure API Base URL**

   The app automatically detects the platform and sets the base URL:
   - **Android Emulator**: `http://10.0.2.2:3000/api` (default)
   - **iOS Simulator**: `http://localhost:3000/api` (default)
   - **Physical Device**: You need to update the base URL in `lib/services/api_service.dart` with your computer's IP address

   For physical devices:
   - Find your computer's IP address (e.g., `192.168.1.100`)
   - Update the `baseUrl` getter in `lib/services/api_service.dart`:
     ```dart
     static String get baseUrl {
       // Replace with your computer's IP
       return 'http://192.168.1.100:3000/api';
     }
     ```

3. **Run the App**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── bloc/              # State management (BLoC pattern)
│   ├── auth/          # Authentication BLoC
│   ├── video/         # Video BLoC
│   └── user/          # User BLoC
├── models/            # Data models
│   ├── user.dart
│   ├── video.dart
│   └── auth_response.dart
├── screens/           # App screens
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── video_details_screen.dart
│   └── profile_screen.dart
├── services/          # API and storage services
│   ├── api_service.dart
│   └── storage_service.dart
├── widgets/           # Reusable widgets
│   └── retry_widget.dart
└── main.dart          # App entry point
```

## Key Dependencies

- **flutter_bloc**: State management using BLoC pattern
- **dio**: HTTP client for API calls
- **flutter_secure_storage**: Secure storage for JWT tokens
- **youtube_player_flutter**: YouTube video player
- **connectivity_plus**: Network connectivity checking
- **cached_network_image**: Cached image loading
- **equatable**: Value equality for state classes

## Features Implementation

### Authentication
- JWT token stored securely using `flutter_secure_storage`
- Automatic token refresh on app restart
- Logout functionality

### Video List
- Fetches videos from API
- Search functionality
- Category filtering
- Pull-to-refresh
- Thumbnail images with caching
- Error handling with retry option

### Video Details
- YouTube video player integration
- Video metadata display
- User information
- Offline error handling

### Profile
- View user information
- Update name and email
- Avatar display
- Form validation

### Offline Handling
- Network connectivity checking before API calls
- Retry mechanism on errors
- User-friendly error messages
- Automatic retry on network recovery

## State Management

The app uses BLoC (Business Logic Component) pattern for state management:

- **AuthBloc**: Manages authentication state
- **VideoBloc**: Manages video list and details
- **UserBloc**: Manages user profile operations

## API Integration

The app integrates with the following endpoints:

- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `GET /api/videos` - Get videos (with search and category filters)
- `GET /api/videos/:id` - Get video details
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user

## Testing

To test the app:

1. Make sure the backend API is running (Part 1)
2. Start the Flutter app
3. Register a new user or login with existing credentials
4. Browse videos on the home screen
5. Tap a video to view details and play YouTube video
6. Navigate to profile to update user information

## Troubleshooting

### Connection Issues

If you're having trouble connecting to the API:

1. **Android Emulator**: Make sure you're using `10.0.2.2:3000`
2. **iOS Simulator**: Make sure you're using `localhost:3000`
3. **Physical Device**: 
   - Ensure your device and computer are on the same network
   - Update the base URL with your computer's IP address
   - Make sure the backend server is accessible from your network

### YouTube Player Issues

- Ensure you have internet connectivity for YouTube videos
- Some videos may be restricted in certain regions

## Notes

- The app requires internet connectivity for API calls and YouTube videos
- JWT tokens are stored securely and persist across app restarts
- The app handles network errors gracefully with retry options
- All API calls include proper error handling and user feedback

