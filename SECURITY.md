# Security Guide - Protecting Sensitive Information

This project uses `.gitignore` files to prevent sensitive information from being committed to version control.

## ⚠️ IMPORTANT: Never Commit These Files

The following files contain sensitive information and are **automatically ignored** by git:

### Environment Variables (`.env` files)
- `part1-backend/.env` - Database credentials, JWT secrets, API keys
- `part2-frontend/.env` - API endpoints, API keys
- `part3-flutter/.env` - API endpoints, configuration
- `part4-django/.env` - Database credentials, Django secret key

### Other Sensitive Files
- Upload directories (`part1-backend/uploads/`)
- Build artifacts and compiled code
- IDE configuration files
- Log files
- Database files (`.sqlite`, `.db`)

## 📋 Setup Instructions

### Backend (part1-backend)
1. Copy the template: `cp env.template .env`
2. Fill in your actual values:
   - Database credentials
   - JWT secret (use a strong random string)
   - Port number

### Frontend (part2-frontend)
1. Create `.env` file if needed
2. Add any API keys or configuration

### Flutter (part3-flutter)
1. Create `.env` file if needed for API endpoints
2. Configure Android/iOS keys if needed

### Django (part4-django)
1. Create `.env` file
2. Add Django secret key and database credentials

## ✅ What IS Committed

- `env.template` files (templates only, no real values)
- Source code
- Configuration files (without secrets)
- Documentation

## 🔒 Best Practices

1. **Never commit `.env` files** - They contain secrets
2. **Use strong secrets** - Generate random strings for JWT secrets
3. **Rotate secrets regularly** - Especially in production
4. **Use different secrets** - Dev, staging, and production should have different values
5. **Review before committing** - Always check `git status` before committing

## 🚨 If You Accidentally Committed Sensitive Data

If you accidentally committed a `.env` file or other sensitive data:

1. **Immediately rotate all secrets** in the committed file
2. Remove the file from git history:
   ```bash
   git rm --cached <file>
   git commit -m "Remove sensitive file"
   ```
3. If already pushed, consider the secrets compromised and rotate them immediately

## 📝 Template Files

Template files (like `env.template`) are safe to commit as they contain no real values. Always use these as a reference when setting up a new environment.

