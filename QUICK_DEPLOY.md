# Quick Cloudflare Deployment Guide

## Prerequisites Checklist
- [ ] Cloudflare account created
- [ ] MongoDB Atlas cluster created and connection string obtained
- [ ] Google Gemini API key obtained
- [ ] Wrangler CLI installed (`npm install -g wrangler`)
- [ ] Logged into Wrangler (`wrangler login`)

## Quick Setup (5 minutes)

### 1. Configure Environment
```bash
# Copy and edit environment variables
cp .env.example .env
# Edit .env with your MongoDB URI, JWT secret, and Gemini API key
```

### 2. Deploy Services
```bash
# Option A: Use the interactive script
./deploy-cloudflare.sh

# Option B: Deploy individually
npm run deploy:gemini      # Deploy Gemini AI service
npm run deploy:frontend    # Deploy React frontend
```

### 3. Deploy Backend
**Recommended**: Use Render.com or Railway.app for the Python backend (see CLOUDFLARE_DEPLOYMENT.md)

**Alternative**: Deploy to Cloudflare Workers (experimental)
```bash
npm run deploy:backend
```

## Post-Deployment

### Update Environment Variables
After deploying, update these URLs in your `.env`:
```env
GEMINI_SERVICE_URL=https://aiatl-gemini-service.your-account.workers.dev
VITE_API_URL=https://your-backend-url.com
```

Then redeploy the frontend:
```bash
npm run deploy:frontend
```

## Testing Deployment

### Test Gemini Service
```bash
curl -X POST https://your-gemini-worker.workers.dev/api/parse-request \
  -H "Content-Type: application/json" \
  -d '{"text":"Looking to buy a laptop"}'
```

### Test Backend
```bash
curl https://your-backend-url.com/api/health
```

### Test Frontend
Open your Pages URL in a browser: `https://aiatl-frontend.pages.dev`

## Viewing Logs

```bash
# Gemini service logs
npm run logs:gemini

# Backend logs (if using Workers)
npm run logs:backend
```

## Common Issues

### "GEMINI_API_KEY not set"
```bash
echo "your-api-key" | wrangler secret put GEMINI_API_KEY --config wrangler.gemini.toml
```

### "MONGODB_URI not set"
Update your `.env` file and redeploy, or set as a secret:
```bash
echo "your-mongodb-uri" | wrangler secret put MONGODB_URI --config wrangler.backend.toml
```

### CORS Errors
Make sure VITE_API_URL in `.env` matches your deployed backend URL, then rebuild:
```bash
npm run deploy:frontend
```

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Cloudflare CDN                     │
└─────────────────────────────────────────────────────┘
                        │
        ┌───────────────┴───────────────┐
        │                               │
   ┌────▼────┐                    ┌─────▼──────┐
   │ Frontend │                    │  Backend   │
   │  Pages  │                    │   Worker   │
   │ (React) │                    │  (Python)  │
   └────┬────┘                    └─────┬──────┘
        │                               │
        │         ┌─────────────────────┤
        │         │                     │
   ┌────▼─────────▼──┐           ┌─────▼────────┐
   │  Gemini Service │           │   MongoDB    │
   │     Worker      │           │    Atlas     │
   │  (TypeScript)   │           │  (Database)  │
   └─────────────────┘           └──────────────┘
```

## Cost Breakdown

### Free Tier (Good for testing)
- Cloudflare Workers: 100k requests/day - **$0**
- Cloudflare Pages: Unlimited requests - **$0**
- MongoDB Atlas M0: 512MB storage - **$0**
- Render.com: 750 hours/month - **$0**
- **Total: $0/month**

### Production Tier
- Cloudflare Workers: Paid plan - **$5/month**
- MongoDB Atlas M10: Shared cluster - **$57/month**
- Render.com: Basic plan - **$7/month**
- **Total: ~$69/month**

## Next Steps

1. **Custom Domain**: Add your domain in Cloudflare Pages and Workers settings
2. **Monitoring**: Set up alerts for errors and downtime
3. **CI/CD**: Connect GitHub for automatic deployments
4. **Security**: Review and implement security best practices
5. **Performance**: Enable Cloudflare caching and optimization

## Need More Help?

- Full documentation: `CLOUDFLARE_DEPLOYMENT.md`
- Cloudflare Docs: https://developers.cloudflare.com/
- MongoDB Atlas: https://docs.atlas.mongodb.com/

## Support

If you encounter issues:
1. Check the logs: `npm run logs:gemini` or `npm run logs:backend`
2. Review the troubleshooting section in `CLOUDFLARE_DEPLOYMENT.md`
3. Check Cloudflare Dashboard for deployment status
4. Verify all environment variables are set correctly
