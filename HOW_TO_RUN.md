# 🚀 How to Run Flash Request in Your Browser

## ✅ Quick Start (Easiest Way)

1. **Open PowerShell in the project folder**

2. **Run this command:**
   ```powershell
   .\START.ps1
   ```

3. **Wait 10-15 seconds** for all services to start

4. **Open your browser and go to:**
   ```
   http://localhost:5173
   ```

## 📋 What Gets Started

The script starts 3 services:
- **Gemini Service** (port 3001) - AI parsing service
- **Backend API** (port 8000) - FastAPI server
- **Frontend** (port 5173) - React app (what you see in browser)

## 🎯 First Steps

1. **Go to Login Page:**
   - Click "Login / Sign Up" on homepage
   - OR go directly to: http://localhost:5173/login

2. **Register a New User:**
   - Click "Don't have an account? Sign up"
   - Fill in:
     - Name
     - Email
     - Password
     - Location (e.g., "Boston, MA")
     - Bio (e.g., "Computer Science student selling textbooks")
   - Click "Create Account"

3. **View Your Profile:**
   - You'll be redirected to your profile
   - Check the "Sales History" tab to see your AI-generated seller profile

## ✅ Verify Services Are Running

- **Backend Health:** http://localhost:8000/health
- **Backend API Docs:** http://localhost:8000/docs
- **Frontend:** http://localhost:5173
- **Gemini Service:** http://localhost:3001

## 🐛 Troubleshooting

### "Site cannot be reached" Error

**Wait a bit longer** - Services need 10-15 seconds to start.

**Check if services are running:**
1. Look for 3 PowerShell windows (one for each service)
2. Check if you see error messages in those windows
3. Verify ports are not blocked by firewall

### Backend Not Starting

**Check for errors:**
- Look at the Backend PowerShell window
- Common issues:
  - MongoDB connection (app will still work without it)
  - Port 8000 already in use
  - Missing Python dependencies

**Fix:**
```powershell
# Install dependencies
pip install -r requirements.txt

# Check if port is in use
Get-NetTCPConnection -LocalPort 8000
```

### Frontend Not Starting

**Check for errors:**
- Look at the Frontend PowerShell window
- Common issues:
  - Vite not installed
  - Port 5173 already in use
  - Missing Node dependencies

**Fix:**
```powershell
# Install dependencies
npm install

# Install vite if missing
npm install vite --save-dev
```

### Gemini Service Not Starting

**Check:**
- Make sure `.env` file exists in `json-parsing-gemini` folder
- Check the Gemini PowerShell window for errors

**Fix:**
```powershell
# Create .env file (if missing)
Set-Content -Path "json-parsing-gemini\.env" -Value "GEMINI_API_KEY=AIzaSyB-Iy3KkF7m8Iape1M5aFGMJungEzsXYNc"
```

## 🔧 Manual Start (If Script Doesn't Work)

### Terminal 1 - Gemini Service:
```powershell
cd json-parsing-gemini
npm run dev
```

### Terminal 2 - Backend:
```powershell
python -m uvicorn backend.app:app --reload --port 8000
```

### Terminal 3 - Frontend:
```powershell
npm run dev
```

## 📝 Environment Setup

### Gemini Service (.env file)
Location: `json-parsing-gemini/.env`
```
GEMINI_API_KEY=AIzaSyB-Iy3KkF7m8Iape1M5aFGMJungEzsXYNc
```

✅ **This file has been created for you!**

## 🎉 Success Indicators

You'll know everything is working when:

✅ Backend health check returns: `{"status":"ok",...}`
✅ Frontend loads at http://localhost:5173
✅ You can see the Flash Request homepage
✅ You can register a new user
✅ You can view your profile with seller data

## 🚀 Next Steps

Once everything is running:

1. **Register a user** at http://localhost:5173/login
2. **View your profile** to see AI-generated seller profile
3. **Create a flash request** to test the matching system
4. **Browse listings** to see available items
5. **Seed default profiles** (optional):
   ```powershell
   curl -X POST http://localhost:8000/api/users/seed-defaults
   ```

## 💡 Tips

- Keep the 3 PowerShell windows open while using the app
- Check the windows for any error messages
- The app will work even if MongoDB connection fails (but user features won't work)
- All services auto-reload when you change code

## 🎊 You're Ready!

Run `.\START.ps1` and open http://localhost:5173 in your browser!

