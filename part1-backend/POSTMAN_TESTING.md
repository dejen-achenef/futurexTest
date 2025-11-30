# Postman API Testing Guide

## Base URL

```
http://localhost:3000/api
```

## 1. Health Check (No Auth Required)

### GET /api/health

- **Method:** GET
- **URL:** `http://localhost:3000/api/health`
- **Headers:** None
- **Expected Response:**

```json
{
  "status": "OK",
  "message": "FutureX API is running"
}
```

---

## 2. Authentication Endpoints (No Auth Required)

### POST /api/auth/register

- **Method:** POST
- **URL:** `http://localhost:3000/api/auth/register`
- **Headers:**
  - `Content-Type: application/json`
- **Body (JSON):**

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

- **Expected Response:**

```json
{
  "message": "User registered successfully",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "avatar": null
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

- **Save the token** from the response for authenticated requests!

---

### POST /api/auth/login

- **Method:** POST
- **URL:** `http://localhost:3000/api/auth/login`
- **Headers:**
  - `Content-Type: application/json`
- **Body (JSON):**

```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

- **Expected Response:**

```json
{
  "message": "Login successful",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "avatar": null
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

## 3. User Endpoints (Auth Required)

### GET /api/users

- **Method:** GET
- **URL:** `http://localhost:3000/api/users`
- **Headers:**
  - `Authorization: Bearer YOUR_TOKEN_HERE`
- **Expected Response:**

```json
[
  {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "avatar": null,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
]
```

---

### GET /api/users/:id

- **Method:** GET
- **URL:** `http://localhost:3000/api/users/1`
- **Headers:**
  - `Authorization: Bearer YOUR_TOKEN_HERE`
- **Expected Response:**

```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "avatar": null,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

---

### PUT /api/users/:id

- **Method:** PUT
- **URL:** `http://localhost:3000/api/users/1`
- **Headers:**
  - `Authorization: Bearer YOUR_TOKEN_HERE`
  - `Content-Type: application/json`
- **Body (JSON):**

```json
{
  "name": "John Updated",
  "email": "john.updated@example.com"
}
```

- **Expected Response:**

```json
{
  "id": 1,
  "name": "John Updated",
  "email": "john.updated@example.com",
  "avatar": null,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

---

### DELETE /api/users/:id

- **Method:** DELETE
- **URL:** `http://localhost:3000/api/users/1`
- **Headers:**
  - `Authorization: Bearer YOUR_TOKEN_HERE`
- **Expected Response:**

```json
{
  "message": "User deleted successfully"
}
```

---

## 4. Video Endpoints

### GET /api/videos (No Auth Required)

- **Method:** GET
- **URL:** `http://localhost:3000/api/videos`
- **Query Parameters (Optional):**
  - `search`: Search term for title/description
  - `category`: Filter by category
  - `page`: Page number (if pagination implemented)
  - `limit`: Items per page (if pagination implemented)
- **Examples:**
  - `http://localhost:3000/api/videos`
  - `http://localhost:3000/api/videos?search=flutter`
  - `http://localhost:3000/api/videos?category=programming`
  - `http://localhost:3000/api/videos?search=flutter&category=programming`
- **Expected Response:**

```json
[
  {
    "id": 1,
    "title": "Flutter Tutorial",
    "description": "Learn Flutter basics",
    "youtubeVideoId": "dQw4w9WgXcQ",
    "category": "programming",
    "duration": 600,
    "userId": 1,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
]
```

---

### GET /api/videos/:id (No Auth Required)

- **Method:** GET
- **URL:** `http://localhost:3000/api/videos/1`
- **Headers:** None
- **Expected Response:**

```json
{
  "id": 1,
  "title": "Flutter Tutorial",
  "description": "Learn Flutter basics",
  "youtubeVideoId": "dQw4w9WgXcQ",
  "category": "programming",
  "duration": 600,
  "userId": 1,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

---

### POST /api/videos (Auth Required)

- **Method:** POST
- **URL:** `http://localhost:3000/api/videos`
- **Headers:**
  - `Authorization: Bearer YOUR_TOKEN_HERE`
  - `Content-Type: application/json`
- **Body (JSON):**

```json
{
  "title": "React Tutorial",
  "description": "Learn React from scratch",
  "youtubeVideoId": "dQw4w9WgXcQ",
  "category": "programming",
  "duration": 1200
}
```

- **Expected Response:**

```json
{
  "id": 2,
  "title": "React Tutorial",
  "description": "Learn React from scratch",
  "youtubeVideoId": "dQw4w9WgXcQ",
  "category": "programming",
  "duration": 1200,
  "userId": 1,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

---

### PUT /api/videos/:id (Auth Required)

- **Method:** PUT
- **URL:** `http://localhost:3000/api/videos/1`
- **Headers:**
  - `Authorization: Bearer YOUR_TOKEN_HERE`
  - `Content-Type: application/json`
- **Body (JSON):**

```json
{
  "title": "Updated Flutter Tutorial",
  "description": "Updated description",
  "category": "mobile-development",
  "duration": 900
}
```

- **Expected Response:**

```json
{
  "id": 1,
  "title": "Updated Flutter Tutorial",
  "description": "Updated description",
  "youtubeVideoId": "dQw4w9WgXcQ",
  "category": "mobile-development",
  "duration": 900,
  "userId": 1,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

---

### DELETE /api/videos/:id (Auth Required)

- **Method:** DELETE
- **URL:** `http://localhost:3000/api/videos/1`
- **Headers:**
  - `Authorization: Bearer YOUR_TOKEN_HERE`
- **Expected Response:**

```json
{
  "message": "Video deleted successfully"
}
```

---

## Postman Setup Instructions

### Step 1: Create a Collection

1. Open Postman
2. Click "New" → "Collection"
3. Name it "FutureX API"

### Step 2: Set Collection Variables

1. Click on your collection
2. Go to "Variables" tab
3. Add these variables:
   - `base_url`: `http://localhost:3000/api`
   - `token`: (leave empty, will be set after login)

### Step 3: Create Environment (Optional but Recommended)

1. Click "Environments" → "Create Environment"
2. Name it "Local Development"
3. Add variables:
   - `base_url`: `http://localhost:3000/api`
   - `token`: (leave empty)

### Step 4: Test Authentication Flow

1. **Register a User:**

   - Create POST request to `{{base_url}}/auth/register`
   - Add JSON body with name, email, password
   - Send request
   - Copy the `token` from response

2. **Set Token Variable:**

   - In the response, right-click on the `token` value
   - Select "Set: Collection Variable" → `token`
   - Or manually set it in collection/environment variables

3. **Use Token in Requests:**
   - For authenticated requests, add header:
   - Key: `Authorization`
   - Value: `Bearer {{token}}`

### Step 5: Create Request Templates

#### For Authenticated Requests:

1. Create new request
2. In "Headers" tab, add:
   - `Authorization`: `Bearer {{token}}`
   - `Content-Type`: `application/json` (for POST/PUT)

#### For JSON Body Requests:

1. Go to "Body" tab
2. Select "raw"
3. Select "JSON" from dropdown
4. Paste your JSON body

---

## Quick Test Sequence

1. ✅ **Health Check** → `GET /api/health`
2. ✅ **Register** → `POST /api/auth/register` (save token)
3. ✅ **Login** → `POST /api/auth/login` (save token)
4. ✅ **Get Users** → `GET /api/users` (with token)
5. ✅ **Create Video** → `POST /api/videos` (with token)
6. ✅ **Get Videos** → `GET /api/videos` (no token needed)
7. ✅ **Get Video by ID** → `GET /api/videos/1` (no token needed)
8. ✅ **Update User** → `PUT /api/users/1` (with token)
9. ✅ **Delete Video** → `DELETE /api/videos/1` (with token)

---

## Common Errors

### 401 Unauthorized

- **Cause:** Missing or invalid token
- **Solution:** Make sure you're sending `Authorization: Bearer YOUR_TOKEN` header

### 400 Bad Request

- **Cause:** Invalid request body or missing required fields
- **Solution:** Check JSON format and required fields

### 500 Internal Server Error

- **Cause:** Server/database error
- **Solution:** Check server logs and database connection

---

## Tips

1. **Save Token Automatically:**

   - In Postman, you can add a test script to auto-save token:

   ```javascript
   if (pm.response.code === 200) {
     var jsonData = pm.response.json();
     if (jsonData.token) {
       pm.collectionVariables.set("token", jsonData.token);
     }
   }
   ```

2. **Use Pre-request Scripts:**

   - To automatically add Authorization header to all requests in a folder

3. **Export Collection:**
   - Share your Postman collection with team members
