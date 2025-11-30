# Part 4: Django Reporting Microservice

## Setup Instructions

1. **Create Virtual Environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Configure Environment**
   - Copy `.env.example` to `.env`
   - Update `NODE_API_BASE_URL` to point to your Node.js backend

4. **Run Migrations**
   ```bash
   python manage.py migrate
   ```

5. **Create Superuser (Optional)**
   ```bash
   python manage.py createsuperuser
   ```

6. **Run Development Server**
   ```bash
   python manage.py runserver
   ```

7. **Run Tests**
   ```bash
   python manage.py test
   ```

## API Endpoints

### Summary Report
- `GET /api/report/summary/` - Get summary report with total users, videos, and top categories

### User Activity Report
- `GET /api/report/user/<id>/` - Get activity report for a specific user

## Example Responses

### Summary Report
```json
{
  "total_users": 10,
  "total_videos": 25,
  "top_categories": [
    {"category": "Education", "count": 10},
    {"category": "Entertainment", "count": 8},
    {"category": "Technology", "count": 7}
  ],
  "categories_count": 5
}
```

### User Activity Report
```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  },
  "total_videos": 5,
  "videos_by_category": {
    "Education": 3,
    "Technology": 2
  },
  "total_duration_seconds": 3600,
  "total_duration_formatted": "1h 0m 0s",
  "videos": [...]
}
```

## Features

- ✅ Django REST Framework serializers and viewsets
- ✅ Fetches data from Node.js API using requests and aiohttp
- ✅ Summary report endpoint
- ✅ User activity report endpoint
- ✅ Unit tests (3+ test cases)
- ✅ Proper error handling
- ✅ Async support for better performance

## Architecture

- **Services Layer**: `NodeApiClient` and `ReportService` for business logic
- **Views**: DRF ViewSets and APIViews
- **Serializers**: DRF serializers for response formatting
- **Tests**: Unit tests using Django TestCase and mocks

## Notes

- Make sure the Node.js backend is running before testing
- The service uses both synchronous (requests) and asynchronous (aiohttp) HTTP clients
- Tests use mocking to avoid actual API calls

