# Flash Request - Setup and Run Guide

## Quick Start

### Windows (PowerShell)
```powershell
.\start-all.ps1
```

### Linux/Mac (Bash)
```bash
chmod +x start-all.sh
./start-all.sh
```

### Manual Start

#### 1. Install Dependencies

**Python Dependencies:**
```bash
pip install -r requirements.txt
```

**Frontend Dependencies:**
```bash
npm install
```

**Gemini Service Dependencies:**
```bash
cd json-parsing-gemini
npm install
cd ..
```

#### 2. Start Services

**Terminal 1 - Gemini Service (Port 3001):**
```bash
cd json-parsing-gemini
# Set GEMINI_API_KEY environment variable if not in .env
export GEMINI_API_KEY=your-api-key-here  # Linux/Mac
# OR
$env:GEMINI_API_KEY="your-api-key-here"  # Windows PowerShell
npm run dev
```

**Terminal 2 - Backend API (Port 8000):**
```bash
python -m uvicorn backend.app:app --reload --port 8000
# OR
npm run dev:backend
```

**Terminal 3 - Frontend (Port 5173):**
```bash
npm run dev
```

#### 3. Open Browser

Navigate to: **http://localhost:5173**

## Environment Variables

### Backend (.env or environment)
- `MONGODB_URI` - MongoDB connection string (default: provided in code)
- `DB_NAME` - Database name (default: flashrequest)
- `SECRET_KEY` - JWT secret key (default: development key)
- `GEMINI_SERVICE_URL` - Gemini service URL (default: http://127.0.0.1:3001)

### Gemini Service (json-parsing-gemini/.env)
- `GEMINI_API_KEY` - Your Gemini API key

### Frontend (.env)
- `VITE_API_BASE_URL` - Backend API URL (default: http://127.0.0.1:8000)

## First Time Setup

### 1. Seed Default Profiles (Optional)
```bash
curl -X POST http://localhost:8000/api/users/seed-defaults
```

### 2. Register a New User
1. Go to http://localhost:5173/login
2. Click "Don't have an account? Sign up"
3. Fill in:
   - Name
   - Email
   - Password
   - Location (City, State)
   - Bio (this will be processed by AI to create your seller profile)
4. Click "Create Account"

### 3. View Your Profile
- After registration, you'll be redirected to your profile
- View your seller profile with sales history
- Check the "Sales History" tab to see your categories

## Troubleshooting

### MongoDB Connection Issues
- Make sure the MongoDB connection string is correct
- Check your internet connection (MongoDB Atlas requires internet)
- The app will start even if MongoDB is not connected, but user features won't work

### Gemini Service Not Starting
- Make sure you have a valid GEMINI_API_KEY
- Check that port 3001 is not already in use
- Verify Node.js is installed: `node --version`

### Backend Not Starting
- Make sure Python 3.8+ is installed: `python --version`
- Install dependencies: `pip install -r requirements.txt`
- Check that port 8000 is not already in use

### Frontend Not Starting
- Make sure Node.js is installed: `node --version`
- Install dependencies: `npm install`
- Check that port 5173 is not already in use

### CORS Issues
- Make sure the backend is running on port 8000
- Check that VITE_API_BASE_URL is set correctly
- The backend has CORS enabled for all origins in development

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### User Profile
- `GET /api/users/{user_id}/profile` - Get user profile
- `GET /api/seller-profiles/{user_id}` - Get seller profile
- `POST /api/seller-profiles/process-bio` - Process bio

### Utilities
- `POST /api/users/seed-defaults` - Seed default profiles
- `GET /health` - Health check

## Features

✅ User registration with bio processing
✅ Automatic seller profile generation via AI
✅ MongoDB storage for users and profiles
✅ JWT authentication
✅ Profile viewing with sales history
✅ Default profile seeding

## Next Steps

1. Register a user at `/login`
2. View your profile at `/profile`
3. Explore the seller profile data
4. Check the sales history tab

## Support

If you encounter any issues:
1. Check the terminal output for error messages
2. Verify all services are running on the correct ports
3. Check the browser console for frontend errors
4. Verify MongoDB connection is working

## Ports Used

- **3001** - Gemini Parsing Service
- **8000** - Backend API
- **5173** - Frontend Dev Server

Make sure these ports are available before starting the services.

