# Cloudflare Deployment Checklist

Use this checklist to ensure all steps are completed for a successful deployment.

## Pre-Deployment Setup

### MongoDB Atlas
- [ ] Create MongoDB Atlas account
- [ ] Create a new cluster (M0 Free or higher)
- [ ] Create database user with credentials
- [ ] Whitelist IP address (0.0.0.0/0 for Cloudflare Workers)
- [ ] Get connection string
- [ ] Test connection locally

### Google Gemini API
- [ ] Create Google Cloud account
- [ ] Enable Gemini API
- [ ] Create API key
- [ ] Test API key locally

### Cloudflare Account
- [ ] Create Cloudflare account
- [ ] Note your account ID
- [ ] Install Wrangler CLI: `npm install -g wrangler`
- [ ] Login to Wrangler: `wrangler login`

### Local Environment
- [ ] Copy `.env.example` to `.env`
- [ ] Fill in MongoDB connection string
- [ ] Generate JWT secret: `openssl rand -hex 32`
- [ ] Add Gemini API key
- [ ] Test application locally:
  - [ ] Frontend: `npm run dev`
  - [ ] Backend: `npm run dev:backend`
  - [ ] Gemini service: `cd json-parsing-gemini && npm run dev`

## Deployment Steps

### 1. Deploy Gemini Service (Cloudflare Worker)
- [ ] Navigate to project root
- [ ] Install dependencies: `cd json-parsing-gemini && npm install && cd ..`
- [ ] Update `wrangler.gemini.toml` if needed
- [ ] Set Gemini API key secret:
  ```bash
  echo "your-key" | wrangler secret put GEMINI_API_KEY --config wrangler.gemini.toml
  ```
- [ ] Deploy: `npm run deploy:gemini`
- [ ] Copy the deployed Worker URL
- [ ] Test endpoint:
  ```bash
  curl -X POST https://your-worker.workers.dev/api/parse-request \
    -H "Content-Type: application/json" \
    -d '{"text":"test"}'
  ```

### 2. Deploy Backend API

#### Option A: Render.com (Recommended)
- [ ] Sign up at [render.com](https://render.com)
- [ ] Click "New +" → "Web Service"
- [ ] Connect GitHub repository
- [ ] Configure service:
  - [ ] Name: `aiatl-backend`
  - [ ] Environment: Python 3
  - [ ] Build Command: `pip install -r requirements.txt`
  - [ ] Start Command: `uvicorn backend.app:app --host 0.0.0.0 --port $PORT`
- [ ] Add environment variables:
  - [ ] `MONGODB_URI`: Your MongoDB connection string
  - [ ] `DB_NAME`: `flashrequest`
  - [ ] `JWT_SECRET`: Your generated secret
  - [ ] `GEMINI_SERVICE_URL`: Your Gemini Worker URL from Step 1
- [ ] Click "Create Web Service"
- [ ] Wait for deployment to complete
- [ ] Copy the deployed service URL
- [ ] Test endpoint: `curl https://your-service.onrender.com/health`

#### Option B: Railway.app
- [ ] Sign up at [railway.app](https://railway.app)
- [ ] Create new project from GitHub
- [ ] Railway will auto-detect Python
- [ ] Add environment variables (same as Render)
- [ ] Deploy and copy URL
- [ ] Test endpoint

#### Option C: Cloudflare Workers (Experimental)
- [ ] Set all secrets:
  ```bash
  echo "your-mongodb-uri" | wrangler secret put MONGODB_URI --config wrangler.backend.toml
  echo "flashrequest" | wrangler secret put DB_NAME --config wrangler.backend.toml
  echo "your-jwt-secret" | wrangler secret put JWT_SECRET --config wrangler.backend.toml
  echo "your-gemini-url" | wrangler secret put GEMINI_SERVICE_URL --config wrangler.backend.toml
  ```
- [ ] Deploy: `npm run deploy:backend`
- [ ] Copy Worker URL
- [ ] Test endpoint

### 3. Deploy Frontend (Cloudflare Pages)

#### Prepare Environment
- [ ] Update `.env` with deployed backend URL:
  ```env
  VITE_API_URL=https://your-backend-url.com
  ```
- [ ] Create `.env.production`:
  ```env
  VITE_API_URL=https://your-backend-url.com
  ```

#### Deploy via GitHub (Recommended)
- [ ] Push code to GitHub
- [ ] Go to Cloudflare Dashboard
- [ ] Navigate to Pages → Create a project
- [ ] Connect to Git → Select repository
- [ ] Configure build:
  - [ ] Framework preset: Vite
  - [ ] Build command: `npm run build`
  - [ ] Build output directory: `dist`
  - [ ] Root directory: `/`
- [ ] Add environment variable:
  - [ ] `VITE_API_URL`: Your backend URL
  - [ ] `NODE_VERSION`: `20`
- [ ] Save and Deploy
- [ ] Wait for deployment
- [ ] Copy Pages URL

#### Deploy via CLI (Alternative)
- [ ] Build project: `npm run build`
- [ ] Deploy: `wrangler pages deploy dist --project-name=aiatl-frontend`
- [ ] Copy Pages URL

### 4. Post-Deployment Configuration

#### Update Backend with Frontend URL (if needed for CORS)
- [ ] If using Render/Railway, add environment variable:
  - [ ] `FRONTEND_URL`: Your Pages URL
- [ ] Redeploy backend if needed

#### Test Full Application Flow
- [ ] Open frontend URL in browser
- [ ] Test user registration
- [ ] Test user login
- [ ] Test creating a listing
- [ ] Test searching listings
- [ ] Test Gemini AI parsing
- [ ] Check browser console for errors
- [ ] Check Network tab for failed requests

#### Monitor Services
- [ ] Set up Cloudflare Analytics
- [ ] Check Worker logs: `npm run logs:gemini`
- [ ] Check backend logs (Render/Railway dashboard)
- [ ] Set up uptime monitoring (e.g., UptimeRobot)

## Optional: Custom Domain

### Add Custom Domain to Pages
- [ ] In Cloudflare Pages project, go to "Custom domains"
- [ ] Click "Set up a custom domain"
- [ ] Enter your domain (e.g., `app.yourdomain.com`)
- [ ] Follow DNS configuration instructions
- [ ] Wait for DNS propagation (up to 48 hours)
- [ ] Verify HTTPS certificate is issued

### Add Custom Domain to Workers
- [ ] In Worker settings, go to "Triggers"
- [ ] Click "Add Custom Domain"
- [ ] Enter subdomain for Gemini (e.g., `gemini.yourdomain.com`)
- [ ] Follow DNS configuration
- [ ] Update `GEMINI_SERVICE_URL` in backend environment
- [ ] Redeploy backend

### Update Environment Variables
- [ ] Update all service URLs to use custom domains
- [ ] Redeploy services that reference changed URLs

## Security Hardening

### Cloudflare Security
- [ ] Enable Bot Fight Mode
- [ ] Set up rate limiting rules
- [ ] Enable DDoS protection
- [ ] Configure Web Application Firewall (WAF)
- [ ] Enable Always Use HTTPS

### MongoDB Security
- [ ] Review IP whitelist (consider Atlas Cloudflare integration)
- [ ] Enable audit logs (paid plans)
- [ ] Set up database backups
- [ ] Review user permissions
- [ ] Enable encryption at rest

### Application Security
- [ ] Rotate JWT secret periodically
- [ ] Review CORS settings
- [ ] Enable security headers
- [ ] Set up SSL/TLS
- [ ] Implement request validation
- [ ] Add input sanitization
- [ ] Set up logging and monitoring

## Performance Optimization

### Cloudflare
- [ ] Enable Auto Minify (JS, CSS, HTML)
- [ ] Enable Brotli compression
- [ ] Configure caching rules
- [ ] Enable Rocket Loader
- [ ] Set up Argo Smart Routing (paid)

### Database
- [ ] Create indexes for frequent queries
- [ ] Set up connection pooling
- [ ] Monitor slow queries
- [ ] Implement caching layer (Redis/KV)

### Frontend
- [ ] Enable code splitting
- [ ] Implement lazy loading
- [ ] Optimize images
- [ ] Add service worker for offline support
- [ ] Implement error boundaries

## Monitoring and Maintenance

### Set Up Alerts
- [ ] Cloudflare Workers errors
- [ ] MongoDB connection failures
- [ ] High response times
- [ ] Rate limit violations
- [ ] SSL certificate expiration

### Regular Maintenance
- [ ] Weekly: Review error logs
- [ ] Monthly: Update dependencies
- [ ] Quarterly: Security audit
- [ ] Annually: Review and optimize costs

### Backup Strategy
- [ ] Database backups (automated)
- [ ] Configuration backups (.env, wrangler.toml)
- [ ] Code repository (GitHub)
- [ ] Documentation updates

## Rollback Plan

### If Deployment Fails
- [ ] Check logs: `npm run logs:gemini` / `npm run logs:backend`
- [ ] Verify environment variables are set correctly
- [ ] Test MongoDB connection
- [ ] Check Cloudflare Dashboard for errors
- [ ] Review recent commits
- [ ] Rollback to previous deployment if needed

### Rollback Commands
```bash
# Rollback Worker
wrangler rollback --config wrangler.gemini.toml

# Rollback Pages (via dashboard)
# Pages → Deployments → Select previous deployment → Rollback

# Rollback Render/Railway (via dashboard)
# Deployments → Select previous deployment → Redeploy
```

## Cost Management

### Monitor Usage
- [ ] Cloudflare Workers requests
- [ ] Cloudflare Pages bandwidth
- [ ] MongoDB storage and operations
- [ ] Render/Railway uptime hours

### Optimize Costs
- [ ] Enable Cloudflare caching to reduce Worker requests
- [ ] Use connection pooling for database
- [ ] Implement request batching
- [ ] Consider upgrading to paid tiers for better performance

### Free Tier Limits
- Cloudflare Workers: 100,000 requests/day
- Cloudflare Pages: Unlimited requests, 500 builds/month
- MongoDB M0: 512 MB storage
- Render Free: 750 hours/month, sleeps after 15 min inactivity

## Documentation

### Update Documentation
- [ ] Update README with deployment URLs
- [ ] Document custom configurations
- [ ] Add API endpoint documentation
- [ ] Create runbook for common issues
- [ ] Document environment variables

### Share with Team
- [ ] Share deployment URLs
- [ ] Share access credentials (securely)
- [ ] Document deployment process
- [ ] Create incident response plan

## ✅ Deployment Complete!

Once all checklist items are completed:
1. Your application is live on Cloudflare
2. Database is hosted on MongoDB Atlas
3. All services are monitored
4. Security measures are in place
5. Performance is optimized

### Useful Commands
```bash
# View logs
npm run logs:gemini
npm run logs:backend

# Redeploy services
npm run deploy:gemini
npm run deploy:frontend

# Test endpoints
curl https://your-gemini-worker.workers.dev/api/parse-request \
  -H "Content-Type: application/json" \
  -d '{"text":"test"}'

curl https://your-backend.onrender.com/health
```

### Resources
- [Full Deployment Guide](./CLOUDFLARE_DEPLOYMENT.md)
- [Quick Start Guide](./QUICK_DEPLOY.md)
- [Cloudflare Docs](https://developers.cloudflare.com/)
- [MongoDB Atlas Docs](https://docs.atlas.mongodb.com/)

---

**Questions or Issues?** Refer to the troubleshooting section in `CLOUDFLARE_DEPLOYMENT.md`
