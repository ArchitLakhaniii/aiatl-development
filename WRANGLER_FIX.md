# Wrangler Configuration - Quick Fix

## Issue Resolved ✅

The error "Could not find a wrangler.json, wrangler.jsonc, or wrangler.toml file" has been fixed.

## What Was Added

1. **`wrangler.toml`** - Default placeholder configuration
2. **Updated `wrangler.gemini.toml`** - Enabled workers_dev by default
3. **Updated `wrangler.backend.toml`** - Enabled workers_dev by default
4. **Updated `json-parsing-gemini/package.json`** - Added build script

## How to Deploy Now

### Option 1: Deploy Gemini Service (Recommended First)

```bash
# Set your API key as a secret
echo "your-gemini-api-key" | wrangler secret put GEMINI_API_KEY --config wrangler.gemini.toml

# Deploy
npm run deploy:gemini
```

### Option 2: Use the Interactive Script

```bash
./deploy-cloudflare.sh
```

### Option 3: Deploy Manually Step-by-Step

```bash
# 1. Deploy Gemini service
cd json-parsing-gemini
npm install
npm run build
cd ..
wrangler deploy --config wrangler.gemini.toml

# 2. Deploy frontend
npm install
npm run build
wrangler pages deploy dist --project-name=aiatl-frontend
```

## Configuration Files Explained

### `wrangler.toml` (Default)
- Placeholder for local development
- Not used for actual deployments

### `wrangler.gemini.toml`
- Configuration for Gemini AI service Worker
- Deploys TypeScript Worker to parse listings
- Uses: `npm run deploy:gemini`

### `wrangler.backend.toml`
- Configuration for Backend API Worker (experimental)
- **NOT RECOMMENDED**: Use Render.com or Railway.app instead
- See `CLOUDFLARE_DEPLOYMENT.md` for backend deployment

## Quick Test

After fixing, test that wrangler can find the configs:

```bash
# Check Gemini config
wrangler deploy --config wrangler.gemini.toml --dry-run

# Check if you're logged in
wrangler whoami
```

## Next Steps

1. **Copy environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your credentials
   ```

2. **Login to Cloudflare**
   ```bash
   wrangler login
   ```

3. **Deploy Gemini service**
   ```bash
   npm run deploy:gemini
   ```

4. **Follow the full guide**
   - Read: `QUICK_DEPLOY.md` for 5-minute setup
   - Or: `CLOUDFLARE_DEPLOYMENT.md` for complete instructions

## Common Issues

### "Not logged in"
```bash
wrangler login
```

### "Module not found"
```bash
cd json-parsing-gemini
npm install
cd ..
```

### "TypeScript errors"
```bash
cd json-parsing-gemini
npm run build
cd ..
```

## Working with Multiple Configs

Since we have multiple wrangler configs, always specify which one:

```bash
# For Gemini service
wrangler deploy --config wrangler.gemini.toml
wrangler secret put GEMINI_API_KEY --config wrangler.gemini.toml
wrangler tail --config wrangler.gemini.toml

# For backend (not recommended)
wrangler deploy --config wrangler.backend.toml
wrangler secret put MONGODB_URI --config wrangler.backend.toml
```

## Recommended Deployment Order

1. ✅ **Gemini Service** → Cloudflare Workers (easiest)
2. ✅ **Backend API** → Render.com or Railway.app (recommended)
3. ✅ **Frontend** → Cloudflare Pages (automatic)
4. ✅ **Database** → MongoDB Atlas (setup first)

---

**You're now ready to deploy!** 🚀

Start with:
```bash
wrangler login
npm run deploy:gemini
```
