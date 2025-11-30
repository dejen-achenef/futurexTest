# Railway Database Configuration Guide

## Railway Database Connection Details

Railway provides database connection details in a specific format. Here's how to set them up correctly:

## ✅ Correct Railway Database Host Format

Railway MySQL databases typically provide a host like:
```
containers-us-west-xxx.railway.app
```
or
```
monorail.proxy.rlwy.net
```

**Important:** 
- ✅ Use the **full hostname** provided by Railway
- ✅ **Don't** include `http://` or `https://`
- ✅ **Don't** include the port in the host (port is separate)
- ✅ The host should look like: `containers-us-west-123.railway.app`

## Railway Environment Variables Setup

### In Railway Dashboard:

1. Go to your **MySQL database service** on Railway
2. Click on the **"Variables"** tab
3. Railway provides these variables automatically:
   - `MYSQLHOST` or `MYSQL_HOST`
   - `MYSQLPORT` or `MYSQL_PORT` (usually `3306`)
   - `MYSQLDATABASE` or `MYSQL_DATABASE`
   - `MYSQLUSER` or `MYSQL_USER`
   - `MYSQLPASSWORD` or `MYSQL_PASSWORD`

### For Your Backend Service:

In your **backend service** (not the database), add these environment variables:

```
DB_HOST=<value-from-MYSQLHOST>
DB_PORT=3306
DB_USER=<value-from-MYSQLUSER>
DB_PASSWORD=<value-from-MYSQLPASSWORD>
DB_NAME=<value-from-MYSQLDATABASE>
```

## Example Railway Connection Details

Railway might show something like:

```
MYSQLHOST=containers-us-west-123.railway.app
MYSQLPORT=3306
MYSQLDATABASE=railway
MYSQLUSER=root
MYSQLPASSWORD=abc123xyz456
```

**Your backend environment variables should be:**

```
DB_HOST=containers-us-west-123.railway.app
DB_PORT=3306
DB_USER=root
DB_PASSWORD=abc123xyz456
DB_NAME=railway
```

## Common Mistakes to Avoid

❌ **Wrong:**
```
DB_HOST=localhost
DB_HOST=http://containers-us-west-123.railway.app
DB_HOST=containers-us-west-123.railway.app:3306
```

✅ **Correct:**
```
DB_HOST=containers-us-west-123.railway.app
DB_PORT=3306
```

## How to Get Railway Database Connection Details

### Method 1: Railway Dashboard
1. Go to your MySQL database service
2. Click **"Variables"** tab
3. Copy the values from:
   - `MYSQLHOST` → Use for `DB_HOST`
   - `MYSQLUSER` → Use for `DB_USER`
   - `MYSQLPASSWORD` → Use for `DB_PASSWORD`
   - `MYSQLDATABASE` → Use for `DB_NAME`
   - `MYSQLPORT` → Use for `DB_PORT` (usually 3306)

### Method 2: Railway CLI
```bash
railway variables
```

### Method 3: Connection String
If Railway provides a connection string like:
```
mysql://user:password@host:port/database
```

Parse it:
- `host` → `DB_HOST`
- `port` → `DB_PORT`
- `user` → `DB_USER`
- `password` → `DB_PASSWORD`
- `database` → `DB_NAME`

## Testing Your Connection

After setting the variables, test the connection:

1. **Check your backend logs** on Railway
2. Look for: `Database connection established successfully.`
3. If you see connection errors, verify:
   - Host doesn't include `http://` or port
   - Password is correct (no extra spaces)
   - Port is `3306` (default MySQL port)

## Railway-Specific Notes

- Railway databases are **publicly accessible** (no VPN needed)
- Connection uses **SSL/TLS** by default
- Railway automatically handles connection pooling
- The database host might change on redeploy (use Railway variables)

## Complete Railway Environment Variables Checklist

For your backend service on Railway, set these:

```
# Database (from Railway MySQL service)
DB_HOST=<railway-mysql-host>
DB_PORT=3306
DB_USER=<railway-mysql-user>
DB_PASSWORD=<railway-mysql-password>
DB_NAME=<railway-mysql-database>

# Server
PORT=3000
NODE_ENV=production

# JWT
JWT_SECRET=<your-generated-secret>
JWT_EXPIRES_IN=7d
```

## Quick Verification

Your `DB_HOST` should:
- ✅ Start with a domain name (not `localhost` or `127.0.0.1`)
- ✅ End with `.railway.app` or `.rlwy.net`
- ✅ Not include `http://` or `https://`
- ✅ Not include port number
- ✅ Look like: `containers-us-west-123.railway.app`

If your `DB_HOST` looks like this, it's **correct**! ✅

