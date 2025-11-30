# FutureX Technical Challenge - Full Stack Solution

This repository contains a complete full-stack solution with 4 parts:

1. **Part 1**: Node.js/Express Backend API
2. **Part 2**: React Frontend Dashboard
3. **Part 3**: Flutter Mobile App
4. **Part 4**: Django Reporting Microservice

## Quick Start

### Part 1: Backend (Node.js)
```bash
cd part1-backend
npm install
# Configure .env file
npm run migrate
npm run dev
```

### Part 2: Frontend (React)
```bash
cd part2-frontend
npm install
# Configure .env file
npm run dev
```

### Part 3: Mobile (Flutter)
```bash
cd part3-flutter
flutter pub get
# Update API URL in lib/services/api_service.dart
flutter run
```

### Part 4: Reporting (Django)
```bash
cd part4-django
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
# Configure .env file
python manage.py migrate
python manage.py runserver
```

## Project Structure

```
futureX/
├── part1-backend/          # Node.js/Express API
│   ├── config/             # Database configuration
│   ├── controllers/        # Route controllers
│   ├── middleware/         # Auth & upload middleware
│   ├── migrations/         # Sequelize migrations
│   ├── models/             # Sequelize models
│   ├── routes/             # API routes
│   ├── seeders/            # Database seeders
│   ├── services/           # Business logic
│   └── validators/         # Joi validators
│
├── part2-frontend/         # React Dashboard
│   ├── src/
│   │   ├── components/     # React components
│   │   ├── pages/          # Page components
│   │   ├── services/       # API services
│   │   └── utils/          # Utilities
│
├── part3-flutter/          # Flutter Mobile App
│   ├── lib/
│   │   ├── bloc/           # BLoC state management
│   │   ├── models/        # Data models
│   │   ├── screens/       # App screens
│   │   └── services/      # API & storage services
│
└── part4-django/           # Django Reporting Service
    ├── reporting_service/  # Django project settings
    └── reports/            # Reports app
        ├── services/       # Business logic
        ├── serializers/    # DRF serializers
        └── views/          # API views
```

## Features Implemented

### Part 1: Backend ✅
- JWT-based authentication (register/login)
- User CRUD operations
- Avatar image upload
- Video metadata management
- Sequelize migrations & seeders
- Proper folder structure
- Joi validation
- Protected routes middleware

### Part 2: Frontend ✅
- Login page with JWT
- User list with search & pagination
- Video upload with YouTube integration
- Material UI components
- Responsive design
- Secure token storage

### Part 3: Flutter ✅
- Login screen with JWT
- Home screen with video list
- Video details with YouTube player
- Profile screen for user updates
- BLoC state management
- Secure storage for tokens
- Offline handling with retry

### Part 4: Django ✅
- Summary report API
- User activity report API
- DRF serializers & viewsets
- HTTP clients (requests & aiohttp)
- Unit tests (3+ test cases)
- Proper error handling

## API Documentation

### Backend Endpoints

**Authentication:**
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

**Users:**
- `GET /api/users` - Get all users (protected)
- `GET /api/users/:id` - Get user by ID (protected)
- `PUT /api/users/:id` - Update user (protected)
- `DELETE /api/users/:id` - Delete user (protected)

**Videos:**
- `POST /api/videos` - Create video (protected)
- `GET /api/videos?search=&category=` - Get videos with filters
- `GET /api/videos/:id` - Get video by ID
- `PUT /api/videos/:id` - Update video (protected)
- `DELETE /api/videos/:id` - Delete video (protected)

### Reporting Endpoints

- `GET /api/report/summary/` - Summary report
- `GET /api/report/user/<id>/` - User activity report

## Environment Variables

Each part has its own `.env` template file. Copy and configure as needed:

- **Backend**: `env.template` → `.env` (Database credentials, JWT secret)
- **Frontend**: Create `.env` (API URL, YouTube API key)
- **Flutter**: Create `.env` if needed (API URL)
- **Django**: Create `.env` (Node API URL, Django secret key)

⚠️ **Important**: All `.env` files are automatically ignored by git to protect sensitive information. See [SECURITY.md](SECURITY.md) for details.

## Testing

- **Backend**: Manual testing via API endpoints
- **Frontend**: Manual testing in browser
- **Flutter**: Run on emulator/device
- **Django**: `python manage.py test`

## Notes

- All parts are configured to work together
- Make sure MySQL is running for the backend
- Update API URLs for your environment
- YouTube API key is optional for frontend
- Flutter app needs network access to backend

## License

This is a technical challenge solution.

