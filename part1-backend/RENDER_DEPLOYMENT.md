# Deploying to Render - Environment Variables Guide

## ⚠️ Important: Don't Use .env Files on Render

On Render, you **set environment variables through their dashboard**, not through `.env` files. The `.env` file is only for **local development**.

## Required Environment Variables

Set these in your Render service dashboard under **Environment**:

### Database Configuration
```
DB_HOST=your-database-host.render.com
DB_USER=your-database-user
DB_PASSWORD=your-database-password
DB_NAME=your-database-name
DB_PORT=3306
```

**Note:** If you're using Render's PostgreSQL (free tier), you'll need to:
1. Create a PostgreSQL database on Render
2. Get the connection details from the database dashboard
3. Update your `config/database.js` to support PostgreSQL, OR
4. Use an external MySQL service (like PlanetScale, AWS RDS, etc.)

### Server Configuration
```
PORT=10000
```
**Note:** Render automatically sets `PORT`, but you can override it. Render typically uses port 10000 or assigns one automatically.

### JWT Configuration
```
JWT_SECRET=your-super-secret-random-string-here
JWT_EXPIRES_IN=7d
```

**⚠️ Generate a strong JWT_SECRET:**
```bash
# On Linux/Mac:
openssl rand -base64 32

# Or use an online generator:
# https://randomkeygen.com/
```

### Node Environment
```
NODE_ENV=production
```

## How to Set Environment Variables on Render

1. **Go to your Render Dashboard**
2. **Select your service** (Web Service or Background Worker)
3. **Click on "Environment"** in the left sidebar
4. **Click "Add Environment Variable"**
5. **Add each variable** one by one:
   - Key: `DB_HOST`
   - Value: `your-database-host`
   - Click "Save"
6. **Repeat for all variables** listed above

## Complete List of Variables to Add

Copy and paste these into Render (replace with your actual values):

```
DB_HOST=your-database-host
DB_USER=your-database-user
DB_PASSWORD=your-database-password
DB_NAME=your-database-name
DB_PORT=3306
PORT=10000
JWT_SECRET=your-generated-secret-key-here
JWT_EXPIRES_IN=7d
NODE_ENV=production
```

## Render Build & Start Commands

### Build Command
```bash
npm install
```

### Start Command
```bash
npm start
```

Or if you need to run migrations first:
```bash
npm run migrate && npm start
```

## Database Setup on Render

### Option 1: Render PostgreSQL (Free Tier)
1. Create a PostgreSQL database on Render
2. Get connection details from the database dashboard
3. Update `config/database.js` to support PostgreSQL:
   ```javascript
   production: {
     username: process.env.DB_USER,
     password: process.env.DB_PASSWORD,
     database: process.env.DB_NAME,
     host: process.env.DB_HOST,
     port: process.env.DB_PORT || 5432, // PostgreSQL default
     dialect: "postgres", // Change from "mysql"
   }
   ```
4. Update `package.json` to include `pg` and `pg-hstore`:
   ```bash
   npm install pg pg-hstore
   ```

### Option 2: External MySQL Service
- Use PlanetScale (free tier available)
- Use AWS RDS
- Use any MySQL hosting service
- Get connection details and set them in Render environment variables

## Running Migrations on Render

You have two options:

### Option 1: Run migrations in start command
```bash
npm run migrate && npm start
```

### Option 2: Run migrations manually
1. Connect to your Render service via SSH (if available)
2. Or use Render's shell feature
3. Run: `npm run migrate`

## File Uploads on Render

**Important:** Render's filesystem is **ephemeral** (files are deleted on restart).

For production, you should:
1. Use **cloud storage** (AWS S3, Cloudinary, etc.)
2. Or use Render's **persistent disk** (paid feature)
3. Update `middleware/upload.js` to use cloud storage

For now, the `uploads/` folder will work, but files will be lost on redeploy.

## Health Check Endpoint

Render can use this for health checks:
```
GET /api/health
```

Set it in Render dashboard under **Health Check Path**: `/api/health`

## Testing Your Deployment

1. **Check health endpoint:**
   ```
   https://your-app.onrender.com/api/health
   ```

2. **Test registration:**
   ```bash
   curl -X POST https://your-app.onrender.com/api/auth/register \
     -H "Content-Type: application/json" \
     -d '{"name":"Test User","email":"test@example.com","password":"password123"}'
   ```

3. **Test login:**
   ```bash
   curl -X POST https://your-app.onrender.com/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com","password":"password123"}'
   ```

## Troubleshooting

### Database Connection Issues
- Check that `DB_HOST` includes the full hostname (not just IP)
- Verify `DB_PASSWORD` doesn't have special characters that need escaping
- Check if your database allows connections from Render's IPs

### Port Issues
- Render sets `PORT` automatically - don't hardcode it
- Your code already uses `process.env.PORT || 3000` which is correct

### JWT Issues
- Make sure `JWT_SECRET` is set and is a strong random string
- Don't use the example value from `env.template`

### Build Failures
- Check that `package.json` has correct `start` script
- Ensure all dependencies are in `package.json` (not just devDependencies)

## Security Checklist

- ✅ Never commit `.env` files (already in `.gitignore`)
- ✅ Use strong, unique `JWT_SECRET` for production
- ✅ Use different database credentials for production
- ✅ Set `NODE_ENV=production`
- ✅ Review CORS settings (currently allows all origins - consider restricting)
- ✅ Use HTTPS (Render provides this automatically)

## Example Render Environment Variables Screenshot Guide

```
┌─────────────────────────────────────────┐
│ Environment Variables                    │
├─────────────────────────────────────────┤
│ Key              │ Value                 │
├──────────────────┼───────────────────────┤
│ DB_HOST          │ your-db-host.com      │
│ DB_USER          │ your-username         │
│ DB_PASSWORD      │ your-password         │
│ DB_NAME          │ your-database        │
│ DB_PORT          │ 3306                  │
│ PORT             │ 10000                 │
│ JWT_SECRET       │ [generated-secret]    │
│ JWT_EXPIRES_IN   │ 7d                    │
│ NODE_ENV         │ production            │
└─────────────────────────────────────────┘
```

## Next Steps

1. ✅ Set all environment variables in Render dashboard
2. ✅ Configure your database (PostgreSQL or external MySQL)
3. ✅ Deploy your service
4. ✅ Run migrations
5. ✅ Test the API endpoints
6. ✅ Update frontend/Flutter app to use Render URL

