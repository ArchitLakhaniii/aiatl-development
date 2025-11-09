# Cloudflare Deployment Guide

This guide will walk you through deploying your AIATL application to Cloudflare with MongoDB Atlas as the database.

## Architecture Overview

The application is deployed across multiple Cloudflare services:
- **Frontend**: Cloudflare Pages (React/Vite)
- **Backend API**: Cloudflare Workers (Python - Alternative approach recommended)
- **Gemini Service**: Cloudflare Workers (TypeScript)
- **Database**: MongoDB Atlas (cloud-hosted)
- **Static Assets**: Cloudflare CDN

## Prerequisites

1. **Cloudflare Account**: Sign up at [cloudflare.com](https://cloudflare.com)
2. **MongoDB Atlas Account**: Sign up at [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas)
3. **Google Gemini API Key**: Get from [makersuite.google.com](https://makersuite.google.com/app/apikey)
4. **Node.js 20+**: Install from [nodejs.org](https://nodejs.org)
5. **Python 3.11+**: Install from [python.org](https://python.org)
6. **Wrangler CLI**: Install with `npm install -g wrangler`

## Step 1: MongoDB Atlas Setup

### 1.1 Create MongoDB Cluster
1. Go to [MongoDB Atlas Dashboard](https://cloud.mongodb.com/)
2. Click **"Create"** to create a new cluster
3. Choose **M0 Free tier** (or your preferred tier)
4. Select your preferred cloud provider and region
5. Name your cluster (e.g., `flashrequest-cluster`)
6. Click **"Create Cluster"**

### 1.2 Configure Database Access
1. Navigate to **Database Access** in the left sidebar
2. Click **"Add New Database User"**
3. Choose **Password** authentication
4. Create a username and password (save these securely!)
5. Set **Database User Privileges** to "Atlas admin" or "Read and write to any database"
6. Click **"Add User"**

### 1.3 Configure Network Access
1. Navigate to **Network Access** in the left sidebar
2. Click **"Add IP Address"**
3. Click **"Allow Access from Anywhere"** (0.0.0.0/0)
   - ⚠️ **Note**: This allows Cloudflare Workers to connect. In production, consider using MongoDB's Cloudflare integration
4. Click **"Confirm"**

### 1.4 Get Connection String
1. Navigate to **Database** in the left sidebar
2. Click **"Connect"** on your cluster
3. Choose **"Connect your application"**
4. Copy the connection string (e.g., `mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/`)
5. Replace `<username>` and `<password>` with your database user credentials
6. Save this connection string for later

## Step 2: Environment Configuration

### 2.1 Create Local Environment File
```bash
cp .env.example .env
```

### 2.2 Update `.env` with Your Values
```env
# MongoDB Configuration
MONGODB_URI=mongodb+srv://your-username:your-password@your-cluster.mongodb.net/?retryWrites=true&w=majority
DB_NAME=flashrequest

# JWT Secret (generate with: openssl rand -hex 32)
JWT_SECRET=your-generated-secret-key

# Gemini API Key
GEMINI_API_KEY=your-gemini-api-key

# Service URLs (update after deployment)
GEMINI_SERVICE_URL=https://aiatl-gemini-service.your-account.workers.dev
VITE_API_URL=https://aiatl-backend.your-account.workers.dev
```

## Step 3: Deploy Gemini Service (Cloudflare Worker)

The Gemini service is the easiest to deploy and has no external dependencies.

### 3.1 Login to Cloudflare
```bash
wrangler login
```

### 3.2 Update Wrangler Configuration
Edit `wrangler.gemini.toml` and update the route or enable workers.dev:
```toml
name = "aiatl-gemini-service"
main = "json-parsing-gemini/src/worker.ts"
compatibility_date = "2024-11-01"

# For testing, enable workers_dev
workers_dev = true

# For production with custom domain, use routes:
# routes = [
#   { pattern = "gemini.your-domain.com/*" }
# ]
```

### 3.3 Add Gemini API Key Secret
```bash
wrangler secret put GEMINI_API_KEY --config wrangler.gemini.toml
# Paste your Gemini API key when prompted
```

### 3.4 Deploy the Gemini Worker
```bash
cd json-parsing-gemini
npm install
cd ..
wrangler deploy --config wrangler.gemini.toml
```

### 3.5 Note Your Gemini Worker URL
After deployment, you'll see output like:
```
Published aiatl-gemini-service (X.XX sec)
  https://aiatl-gemini-service.your-account.workers.dev
```

Save this URL - you'll need it for the backend configuration.

## Step 4: Deploy Backend API (Alternative Approach)

⚠️ **Important**: Cloudflare Workers Python runtime is still in beta and has limitations. We recommend one of these alternatives:

### Option A: Deploy Backend to Render.com (Recommended)

Render.com offers free Python hosting and works well with Cloudflare.

1. Sign up at [render.com](https://render.com)
2. Create a new **Web Service**
3. Connect your GitHub repository
4. Configure:
   - **Name**: `aiatl-backend`
   - **Environment**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn backend.app:app --host 0.0.0.0 --port $PORT`
   - **Region**: Choose closest to your users
5. Add environment variables:
   - `MONGODB_URI`: Your MongoDB connection string
   - `DB_NAME`: `flashrequest`
   - `JWT_SECRET`: Your JWT secret
   - `GEMINI_SERVICE_URL`: Your Gemini Worker URL from Step 3.5
6. Click **Create Web Service**
7. Note your Render URL (e.g., `https://aiatl-backend.onrender.com`)

### Option B: Deploy Backend to Railway.app

Similar to Render, Railway offers easy Python deployment:

1. Sign up at [railway.app](https://railway.app)
2. Create a new project from GitHub repo
3. Configure environment variables (same as Render)
4. Deploy and note your Railway URL

### Option C: Cloudflare Workers Python (Experimental)

⚠️ **Warning**: This is experimental and may have limitations.

```bash
# Add secrets
wrangler secret put MONGODB_URI --config wrangler.backend.toml
wrangler secret put DB_NAME --config wrangler.backend.toml
wrangler secret put JWT_SECRET --config wrangler.backend.toml
wrangler secret put GEMINI_SERVICE_URL --config wrangler.backend.toml

# Deploy
wrangler deploy --config wrangler.backend.toml
```

## Step 5: Deploy Frontend (Cloudflare Pages)

### 5.1 Build Configuration

The `.cloudflarerc.json` file is already configured, but ensure your `vite.config.ts` has the correct API URL:

Create a `.env.production` file:
```env
VITE_API_URL=https://your-backend-url.com
```

### 5.2 Deploy via GitHub (Recommended)

1. Push your code to GitHub
2. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
3. Navigate to **Pages** > **Create a project**
4. Click **Connect to Git**
5. Select your repository
6. Configure build settings:
   - **Production branch**: `main`
   - **Framework preset**: `Vite`
   - **Build command**: `npm run build`
   - **Build output directory**: `dist`
7. Add environment variables:
   - `VITE_API_URL`: Your backend URL from Step 4
   - `NODE_VERSION`: `20`
8. Click **Save and Deploy**

### 5.3 Deploy via Wrangler CLI (Alternative)

```bash
# Install dependencies and build
npm install
npm run build

# Deploy to Pages
npx wrangler pages deploy dist --project-name=aiatl-frontend
```

### 5.4 Note Your Pages URL
After deployment, you'll see:
```
✨ Deployment complete! Your site is live at:
https://aiatl-frontend.pages.dev
```

## Step 6: Configure Custom Domain (Optional)

### 6.1 Add Custom Domain to Pages
1. In Cloudflare Dashboard, go to your Pages project
2. Click **Custom domains** tab
3. Click **Set up a custom domain**
4. Enter your domain (e.g., `app.yourdomain.com`)
5. Follow DNS configuration instructions

### 6.2 Add Custom Domain to Workers
1. Go to **Workers & Pages** > Your worker
2. Click **Triggers** tab
3. Click **Add Custom Domain**
4. Enter your subdomain (e.g., `api.yourdomain.com` for backend, `gemini.yourdomain.com` for Gemini)
5. Follow DNS configuration instructions

## Step 7: Update Environment Variables

After all services are deployed, update the URLs:

### 7.1 Update Backend Environment
If using Render/Railway, update these environment variables:
- `GEMINI_SERVICE_URL`: Your Gemini Worker URL

### 7.2 Update Frontend Environment
In Cloudflare Pages settings:
- `VITE_API_URL`: Your backend URL

Redeploy the frontend if needed:
```bash
npm run build
npx wrangler pages deploy dist --project-name=aiatl-frontend
```

## Step 8: Test Your Deployment

### 8.1 Test Gemini Service
```bash
curl -X POST https://your-gemini-worker.workers.dev/api/parse-request \
  -H "Content-Type: application/json" \
  -d '{"text":"Looking to buy a laptop under $500"}'
```

### 8.2 Test Backend API
```bash
curl https://your-backend-url.com/api/health
```

### 8.3 Test Frontend
Open your Pages URL in a browser and test the full application flow:
1. Register a new account
2. Login
3. Create a listing
4. Search for listings

## Troubleshooting

### MongoDB Connection Issues
- Verify your IP is whitelisted (or 0.0.0.0/0 is allowed)
- Check username/password in connection string
- Ensure connection string includes `?retryWrites=true&w=majority`

### CORS Errors
- Verify backend CORS settings allow your frontend domain
- Check that the Gemini worker has correct CORS headers

### Worker Deployment Issues
- Run `wrangler tail` to view real-time logs
- Check that all secrets are set correctly
- Verify Node.js and Python versions match requirements

### Build Failures
- Clear build cache: `rm -rf dist node_modules && npm install`
- Check Node.js version: `node --version` (should be 20+)
- Review build logs in Cloudflare Dashboard

## Monitoring and Logs

### View Worker Logs
```bash
# Gemini service logs
wrangler tail --config wrangler.gemini.toml

# Backend logs (if using Workers)
wrangler tail --config wrangler.backend.toml
```

### Cloudflare Analytics
- Go to Cloudflare Dashboard
- Navigate to **Analytics & Logs**
- View real-time traffic, errors, and performance metrics

## Security Best Practices

1. **Rotate Secrets Regularly**: Change JWT_SECRET and API keys periodically
2. **Use Environment Variables**: Never commit secrets to git
3. **Enable Rate Limiting**: Configure Cloudflare rate limiting rules
4. **Monitor Access**: Review MongoDB Atlas access logs
5. **Use HTTPS**: Ensure all services use HTTPS (Cloudflare provides this automatically)
6. **Restrict MongoDB Access**: Consider MongoDB Atlas's Cloudflare integration for more secure access

## Scaling Considerations

### Free Tier Limits
- **Cloudflare Workers**: 100,000 requests/day
- **Cloudflare Pages**: Unlimited requests, 500 builds/month
- **MongoDB Atlas M0**: 512 MB storage, shared resources
- **Render Free**: 750 hours/month, sleeps after 15 minutes of inactivity

### Upgrading
- **Workers**: Paid plan removes limits
- **Pages**: Paid plans offer more builds and advanced features
- **MongoDB**: Upgrade to M10+ for dedicated resources
- **Render/Railway**: Paid plans prevent sleeping and offer more resources

## Maintenance

### Update Dependencies
```bash
# Frontend
npm update

# Gemini service
cd json-parsing-gemini && npm update && cd ..

# Backend (if deploying Python yourself)
pip install --upgrade -r requirements.txt
```

### Database Backups
- MongoDB Atlas M10+ clusters have automated backups
- For M0, export data regularly using `mongodump` or Atlas UI

## Cost Estimate (Monthly)

### Free Tier
- Cloudflare Workers: $0
- Cloudflare Pages: $0
- MongoDB Atlas M0: $0
- Render/Railway Free: $0
- **Total: $0/month** (with limitations)

### Production-Ready
- Cloudflare Workers Paid: $5/month
- MongoDB Atlas M10: $57/month (varies by region)
- Render/Railway Starter: $7/month
- **Total: ~$69/month** (supports significant traffic)

## Support and Resources

- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)
- [Cloudflare Pages Docs](https://developers.cloudflare.com/pages/)
- [MongoDB Atlas Docs](https://docs.atlas.mongodb.com/)
- [Render Docs](https://render.com/docs)
- [Railway Docs](https://docs.railway.app/)

## Next Steps

1. **Set up monitoring**: Configure alerts for errors and downtime
2. **Configure analytics**: Add analytics tracking to your frontend
3. **Add CI/CD**: Set up automated testing and deployment
4. **Performance optimization**: Enable Cloudflare caching and optimization features
5. **Security hardening**: Implement rate limiting, input validation, and security headers

---

**Need Help?** Check the troubleshooting section or refer to the official documentation links above.
