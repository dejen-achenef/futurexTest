# Part 1: Node.js Backend API

## Setup Instructions

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Configure Environment**
   - Copy `.env.example` to `.env`
   - Update database credentials and JWT secret

3. **Database Setup**
   ```bash
   # Run migrations
   npm run migrate
   
   # Run seeders (optional)
   npm run seed
   ```

4. **Start Server**
   ```bash
   # Development
   npm run dev
   
   # Production
   npm start
   ```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### Users
- `GET /api/users` - Get all users (protected)
- `GET /api/users/:id` - Get user by ID (protected)
- `PUT /api/users/:id` - Update user (protected, with avatar upload)
- `DELETE /api/users/:id` - Delete user (protected)

### Videos
- `POST /api/videos` - Create video (protected)
- `GET /api/videos?search=&category=&page=&limit=` - Get videos with filters
- `GET /api/videos/:id` - Get video by ID
- `PUT /api/videos/:id` - Update video (protected)
- `DELETE /api/videos/:id` - Delete video (protected)

## Features

- ✅ JWT-based authentication
- ✅ User CRUD operations
- ✅ Avatar image upload
- ✅ Video metadata management
- ✅ Sequelize migrations & seeders
- ✅ Proper folder structure (controllers, services, models)
- ✅ Joi validation
- ✅ Protected routes middleware

