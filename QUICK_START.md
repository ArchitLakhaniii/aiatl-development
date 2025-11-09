# Quick Start Guide - Run in Browser

## 🚀 Fastest Way to Start (Windows)

1. **Open PowerShell in the project folder**

2. **Run the startup script:**
   ```powershell
   .\start-all.ps1
   ```

3. **Wait for all services to start** (3 terminal windows will open)

4. **Open your browser and go to:**
   ```
   http://localhost:5173
   ```

That's it! The app should now be running in your browser.

## 📋 Manual Start (If script doesn't work)

### Step 1: Install Dependencies

Open PowerShell and run:
```powershell
# Install Python dependencies
pip install -r requirements.txt

# Install frontend dependencies
npm install

# Install Gemini service dependencies
cd json-parsing-gemini
npm install
cd ..
```

### Step 2: Start Services (3 Terminal Windows)

**Terminal 1 - Gemini Service:**
```powershell
cd json-parsing-gemini
$env:GEMINI_API_KEY="AIzaSyB-Iy3KkF7m8Iape1M5aFGMJungEzsXYNc"
npm run dev
```

**Terminal 2 - Backend:**
```powershell
python -m uvicorn backend.app:app --reload --port 8000
```

**Terminal 3 - Frontend:**
```powershell
npm run dev
```

### Step 3: Open Browser

Go to: **http://localhost:5173**

## ✅ Verify Everything is Working

1. **Check Backend:** http://localhost:8000/health
   - Should show: `{"status":"ok",...}`

2. **Check Gemini Service:** http://localhost:3001
   - Should show the service is running

3. **Check Frontend:** http://localhost:5173
   - Should show the Flash Request homepage

## 🎯 First Steps After Starting

1. **Go to Login Page:** http://localhost:5173/login

2. **Register a New User:**
   - Click "Don't have an account? Sign up"
   - Fill in: Name, Email, Password, Location, Bio
   - Click "Create Account"

3. **View Your Profile:**
   - You'll be redirected to your profile
   - Check the "Sales History" tab to see your seller profile

## 🐛 Troubleshooting

### Port Already in Use
If you get "port already in use" errors:
- Close other applications using ports 3001, 8000, or 5173
- Or kill the process: `Get-Process -Id (Get-NetTCPConnection -LocalPort 8000).OwningProcess | Stop-Process`

### MongoDB Connection Error
- The app will still start, but user registration won't work
- Check your internet connection (MongoDB Atlas requires internet)
- The connection string is already configured in the code

### Gemini Service Not Working
- Make sure the GEMINI_API_KEY is set
- Check that port 3001 is available
- The API key is already in the startup script

### Can't See the Login Page
- Make sure all 3 services are running
- Check browser console for errors (F12)
- Verify frontend is running on port 5173

## 📝 Notes

- All services need to be running for the app to work
- MongoDB connection is optional for basic testing
- User registration requires MongoDB to be connected
- The app uses in-memory data for flash requests (works without MongoDB)

## 🎉 You're Ready!

Once all services are running, you can:
- Register new users
- View profiles
- See seller profiles with AI-generated data
- Explore the sales history

Enjoy! 🚀

