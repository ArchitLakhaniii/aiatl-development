# 🚀 Run in Browser - Complete Guide

## ✅ Quick Start (Recommended)

### Windows PowerShell:

1. **Open PowerShell in the project folder**

2. **Run the startup script:**
   ```powershell
   .\start-all.ps1
   ```

3. **Wait 10-15 seconds** for all services to start (3 terminal windows will open)

4. **Open your browser and go to:**
   ```
   http://localhost:5173
   ```

5. **Click "Login / Sign Up"** or go directly to:
   ```
   http://localhost:5173/login
   ```

## 📋 What Gets Started

The script automatically starts:

1. **Gemini Service** (Port 3001) - AI parsing service
2. **Backend API** (Port 8000) - FastAPI server with MongoDB
3. **Frontend** (Port 5173) - React app (this is what you see in browser)

## 🎯 First Time Using the App

### Step 1: Register a New User

1. Go to http://localhost:5173/login
2. Click "Don't have an account? Sign up"
3. Fill in the form:
   - **Name**: Your full name
   - **Email**: Your email address
   - **Password**: Choose a password
   - **Location**: City, State (e.g., "Boston, MA")
   - **Bio**: Describe yourself and what you like to buy/sell
     - Example: "Computer Science student selling textbooks and electronics. Love vintage tech and gaming gear."
4. Click "Create Account"

### Step 2: View Your Profile

After registration, you'll be automatically redirected to your profile page where you can:
- See your bio and seller profile
- View AI-generated sales history
- Check your keywords and interests
- See your trust score and rating

### Step 3: Explore the App

- **Homepage**: http://localhost:5173
- **Create Request**: http://localhost:5173/request/create
- **Browse Listings**: http://localhost:5173/listings
- **Your Profile**: http://localhost:5173/profile
- **Messages**: http://localhost:5173/messages

## 🔧 Manual Setup (If Script Doesn't Work)

### Prerequisites

- **Node.js** (v18 or higher): https://nodejs.org/
- **Python** (v3.8 or higher): https://www.python.org/
- **pip** (Python package manager)

### Step 1: Install Dependencies

**Python Dependencies:**
```powershell
pip install -r requirements.txt
```

**Frontend Dependencies:**
```powershell
npm install
```

**Gemini Service Dependencies:**
```powershell
cd json-parsing-gemini
npm install
cd ..
```

### Step 2: Start Services Manually

You need **3 separate terminal windows**:

**Terminal 1 - Gemini Service:**
```powershell
cd json-parsing-gemini
$env:GEMINI_API_KEY="AIzaSyB-Iy3KkF7m8Iape1M5aFGMJungEzsXYNc"
npm run dev
```
Wait for: `Server listening on port 3001`

**Terminal 2 - Backend:**
```powershell
python -m uvicorn backend.app:app --reload --port 8000
```
Wait for: `Uvicorn running on http://127.0.0.1:8000`

**Terminal 3 - Frontend:**
```powershell
npm run dev
```
Wait for: `Local: http://localhost:5173/`

### Step 3: Open Browser

Go to: **http://localhost:5173**

## ✅ Verify Everything is Working

### Check Backend:
Open: http://localhost:8000/health
- Should show: `{"status":"ok","modelLoaded":"matchmaker_model.joblib",...}`

### Check Gemini Service:
Open: http://localhost:3001
- Should show the service is running or an error page (that's OK)

### Check Frontend:
Open: http://localhost:5173
- Should show the Flash Request homepage

## 🐛 Troubleshooting

### Problem: "Port already in use"

**Solution:**
```powershell
# Find process using port 8000
Get-NetTCPConnection -LocalPort 8000 | Select-Object OwningProcess

# Kill the process (replace PID with actual process ID)
Stop-Process -Id <PID> -Force
```

Or close the application using that port manually.

### Problem: "MongoDB connection error"

**Solution:**
- The app will still work for browsing, but user registration won't work
- Check your internet connection (MongoDB Atlas requires internet)
- The connection string is already configured in the code
- User features will work once MongoDB is connected

### Problem: "Cannot find module" errors

**Solution:**
```powershell
# Reinstall dependencies
pip install -r requirements.txt
npm install
cd json-parsing-gemini
npm install
cd ..
```

### Problem: "Gemini API error"

**Solution:**
- Make sure the GEMINI_API_KEY is set
- The API key is already in the startup script
- Check that the Gemini service is running on port 3001

### Problem: Frontend shows blank page

**Solution:**
1. Check browser console (F12) for errors
2. Make sure all 3 services are running
3. Verify frontend is on port 5173
4. Try hard refresh: Ctrl+Shift+R

### Problem: Can't register user

**Solution:**
1. Check that MongoDB is connected (check backend terminal)
2. Make sure backend is running on port 8000
3. Check browser console for API errors
4. Verify Gemini service is running (needed for bio processing)

## 📝 Important Notes

1. **All 3 services must be running** for the app to work properly
2. **MongoDB connection is required** for user registration and profiles
3. **Gemini service is required** for bio processing
4. **Ports 3001, 8000, and 5173** must be available
5. **Internet connection** is needed for MongoDB Atlas

## 🎉 Success Indicators

You'll know everything is working when:

✅ All 3 terminal windows show services running
✅ Backend health check returns OK
✅ Frontend loads at http://localhost:5173
✅ You can register a new user
✅ You can view your profile with seller data
✅ Sales history appears on your profile

## 🚀 Next Steps

Once everything is running:

1. **Register a user** at `/login`
2. **View your profile** to see AI-generated seller profile
3. **Create a flash request** to test the matching system
4. **Browse listings** to see available items
5. **Seed default profiles** (optional):
   ```powershell
   curl -X POST http://localhost:8000/api/users/seed-defaults
   ```

## 📞 Need Help?

1. Check the terminal output for error messages
2. Verify all services are running
3. Check browser console (F12) for frontend errors
4. Verify MongoDB connection in backend terminal
5. Make sure all dependencies are installed

## 🎊 You're Ready!

Open http://localhost:5173 in your browser and start using Flash Request! 🚀

