# Cloudflare Deployment Architecture

## System Overview

```
                                    Internet
                                       │
                    ┌──────────────────┴──────────────────┐
                    │                                     │
                    │      Cloudflare Global Network      │
                    │      (CDN + DDoS Protection)        │
                    │                                     │
                    └──────────────────┬──────────────────┘
                                       │
                 ┌─────────────────────┼─────────────────────┐
                 │                     │                     │
                 │                     │                     │
        ┌────────▼────────┐   ┌───────▼────────┐   ┌───────▼────────┐
        │                 │   │                │   │                │
        │  Cloudflare     │   │  Cloudflare    │   │  Backend API   │
        │  Pages          │   │  Worker        │   │  (Render.com/  │
        │  (Frontend)     │   │  (Gemini)      │   │   Railway)     │
        │                 │   │                │   │                │
        │  React + Vite   │   │  TypeScript    │   │  FastAPI +     │
        │  Tailwind CSS   │   │  Google AI     │   │  Python 3.11   │
        │                 │   │                │   │                │
        └────────┬────────┘   └───────┬────────┘   └───────┬────────┘
                 │                    │                    │
                 │                    │                    │
                 └────────────────────┴──────────┬─────────┘
                                                 │
                                                 │
                                     ┌───────────▼───────────┐
                                     │                       │
                                     │   MongoDB Atlas       │
                                     │   (Database)          │
                                     │                       │
                                     │   - Users             │
                                     │   - Listings          │
                                     │   - Transactions      │
                                     │                       │
                                     └───────────────────────┘
```

## Component Details

### Frontend (Cloudflare Pages)
- **Technology**: React 18 + TypeScript + Vite
- **Styling**: Tailwind CSS + Framer Motion
- **State Management**: Zustand
- **Routing**: React Router
- **Build Output**: Static files in `dist/`
- **Deployment**: Automatic via GitHub or Wrangler CLI
- **CDN**: Global edge network
- **SSL**: Automatic HTTPS
- **Cost**: Free (unlimited requests, 500 builds/month)

### Gemini Service (Cloudflare Worker)
- **Technology**: TypeScript + Google Gemini API
- **Runtime**: V8 JavaScript engine
- **Endpoints**:
  - `POST /api/parse-request` - Parse buyer requests
  - `POST /api/parse-profile` - Parse seller profiles
- **Deployment**: Wrangler CLI
- **Edge Locations**: 300+ worldwide
- **Cold Start**: ~0ms (always warm)
- **Cost**: Free (100k requests/day) or $5/month (unlimited)

### Backend API (Render.com/Railway)
- **Technology**: Python 3.11 + FastAPI
- **Database**: MongoDB via Motor (async)
- **Authentication**: JWT with bcrypt
- **ML Model**: scikit-learn + joblib
- **Endpoints**:
  - Auth: `/api/register`, `/api/login`, `/api/me`
  - Listings: `/api/listings/*`
  - Matching: `/api/match`
- **Health Check**: `/health`
- **Auto-scaling**: Yes (on paid plans)
- **SSL**: Automatic HTTPS
- **Cost**: Free (750 hrs/month) or $7/month (always on)

### Database (MongoDB Atlas)
- **Type**: NoSQL Document Database
- **Collections**:
  - `users` - User accounts and profiles
  - `listings` - Buy/sell listings
  - `transactions` - Transaction history
- **Indexes**: Optimized for common queries
- **Backup**: Automatic (M10+ plans)
- **Security**: TLS/SSL encryption, IP whitelist
- **Cost**: Free (M0, 512MB) or $57/month (M10, shared)

## Data Flow

### User Registration Flow
```
User → Frontend → Backend API → MongoDB Atlas
                      ↓
                  Hash Password
                      ↓
                  Generate JWT
                      ↓
                  Return Token
```

### Create Listing Flow
```
User → Frontend → Gemini Worker → Backend API → MongoDB Atlas
         ↓            ↓                ↓
    Natural Text → Parse with AI → Structured Data → Store
```

### Match Listings Flow
```
User → Frontend → Backend API → ML Model → MongoDB Atlas
                      ↓              ↓           ↓
                  Get Request → Calculate → Get Matches
                                Match Score
```

## Deployment Flow

### 1. Initial Setup
```
Developer Machine
    │
    ├─ cp .env.example .env
    ├─ Edit .env with credentials
    ├─ npm install
    ├─ pip install -r requirements.txt
    └─ wrangler login
```

### 2. Deploy Gemini Service
```
Developer Machine
    │
    ├─ cd json-parsing-gemini
    ├─ npm install
    ├─ cd ..
    │
    ├─ Set secret:
    │  echo "key" | wrangler secret put GEMINI_API_KEY --config wrangler.gemini.toml
    │
    └─ Deploy:
       wrangler deploy --config wrangler.gemini.toml
           │
           └─→ Cloudflare Workers
                  │
                  └─→ Returns URL: https://aiatl-gemini-service.workers.dev
```

### 3. Deploy Backend
```
Developer Machine
    │
    ├─ Push to GitHub
    │
    └─→ Render.com / Railway.app
           │
           ├─ Detect Python
           ├─ Install dependencies
           ├─ Set environment variables
           ├─ Build container
           │
           └─→ Deploy to cloud
                  │
                  └─→ Returns URL: https://aiatl-backend.onrender.com
```

### 4. Deploy Frontend
```
Developer Machine
    │
    ├─ Update .env.production with backend URL
    ├─ npm install
    ├─ npm run build
    │      │
    │      └─→ Creates dist/ folder
    │
    └─ Deploy:
       wrangler pages deploy dist --project-name=aiatl-frontend
           │
           └─→ Cloudflare Pages
                  │
                  ├─ Upload static files
                  ├─ Configure routes
                  ├─ Enable SSL
                  │
                  └─→ Returns URL: https://aiatl-frontend.pages.dev
```

## Request Flow Examples

### Example 1: User Visits Website
```
1. User enters URL → https://aiatl-frontend.pages.dev
2. DNS resolves to Cloudflare edge server (nearest location)
3. Edge server serves cached HTML/CSS/JS
4. Browser renders React application
5. Total time: ~50-200ms
```

### Example 2: Create New Listing
```
1. User fills form with: "Selling MacBook Pro 2020, $800"
2. Frontend sends to Gemini Worker:
   POST https://aiatl-gemini-service.workers.dev/api/parse-request
   Body: { "text": "Selling MacBook Pro 2020, $800" }
3. Gemini Worker calls Google AI API
4. AI returns structured data:
   {
     "category": "Electronics",
     "item": "MacBook Pro 2020",
     "price": 800,
     "type": "sell"
   }
5. Frontend sends to Backend API:
   POST https://aiatl-backend.onrender.com/api/listings
   Body: { ...parsedData, userId: "..." }
6. Backend validates and saves to MongoDB
7. Backend returns listing ID
8. Frontend updates UI
9. Total time: ~500-1500ms
```

### Example 3: Search Listings
```
1. User enters search: "laptop under $1000"
2. Frontend sends to Backend:
   GET https://aiatl-backend.onrender.com/api/listings?q=laptop&maxPrice=1000
3. Backend queries MongoDB with filters
4. Backend runs ML model for personalized ranking
5. Backend returns sorted results
6. Frontend displays listings
7. Total time: ~200-800ms
```

## Security Architecture

### Authentication Flow
```
1. User Login
   ↓
2. Backend verifies credentials (bcrypt)
   ↓
3. Backend generates JWT with secret
   ↓
4. Frontend stores JWT in memory/localStorage
   ↓
5. All subsequent requests include JWT in Authorization header
   ↓
6. Backend verifies JWT signature
   ↓
7. Backend extracts user ID from JWT
   ↓
8. Backend processes request with user context
```

### Security Layers
```
┌─────────────────────────────────────────────┐
│  Layer 1: Cloudflare DDoS Protection       │
│  - Rate limiting                            │
│  - Bot detection                            │
│  - IP filtering                             │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│  Layer 2: HTTPS/TLS Encryption              │
│  - Automatic SSL certificates               │
│  - TLS 1.3                                  │
│  - HSTS enabled                             │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│  Layer 3: Application Authentication        │
│  - JWT validation                           │
│  - Password hashing (bcrypt)                │
│  - CORS policies                            │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│  Layer 4: Database Security                 │
│  - TLS/SSL encryption                       │
│  - IP whitelist                             │
│  - User authentication                      │
│  - Role-based access control                │
└─────────────────────────────────────────────┘
```

## Monitoring & Observability

### Cloudflare Analytics
```
Workers Analytics
├─ Request count
├─ Success rate
├─ Error rate
├─ P50/P95/P99 latency
└─ CPU time

Pages Analytics
├─ Page views
├─ Unique visitors
├─ Bandwidth usage
├─ Geographic distribution
└─ Device types
```

### Backend Monitoring (Render/Railway)
```
Service Metrics
├─ CPU usage
├─ Memory usage
├─ Request count
├─ Response times
├─ Error rates
└─ Uptime percentage
```

### Database Monitoring (MongoDB Atlas)
```
Cluster Metrics
├─ Storage size
├─ Connections
├─ Operations per second
├─ Query performance
├─ Index usage
└─ Replication lag
```

## Scaling Strategy

### Phase 1: MVP (Free Tier)
- **Users**: 0-1,000
- **Requests/day**: 0-10,000
- **Cost**: $0/month
- **Infrastructure**:
  - Cloudflare Workers: Free
  - Cloudflare Pages: Free
  - MongoDB M0: Free
  - Render Free: Free

### Phase 2: Growth (Paid Tier)
- **Users**: 1,000-10,000
- **Requests/day**: 10,000-100,000
- **Cost**: ~$69/month
- **Infrastructure**:
  - Cloudflare Workers: $5/month
  - MongoDB M10: $57/month
  - Render Basic: $7/month
  - Cloudflare Pages: Free

### Phase 3: Scale (Production)
- **Users**: 10,000-100,000+
- **Requests/day**: 100,000-1,000,000+
- **Cost**: ~$200-500/month
- **Infrastructure**:
  - Cloudflare Workers: $5/month
  - MongoDB M30: $180/month
  - Render Pro: Multiple instances
  - Redis/Cloudflare KV: Caching layer
  - Cloudflare Load Balancer

## Disaster Recovery

### Backup Strategy
```
Automated Backups
├─ MongoDB Atlas: Daily snapshots (M10+)
├─ Code: GitHub repository
├─ Configuration: .env.example + documentation
└─ Deployment: Infrastructure as code

Manual Backups
├─ Database: Export via mongodump
├─ Static assets: Download from Pages
└─ Worker code: Version control in Git
```

### Rollback Procedure
```
1. Identify issue via monitoring
2. Check recent deployments
3. Rollback affected service:
   ├─ Workers: wrangler rollback
   ├─ Pages: Select previous deployment in dashboard
   └─ Backend: Redeploy previous version
4. Verify service health
5. Investigate root cause
6. Apply fix
7. Redeploy
```

## Performance Optimization

### CDN Caching Strategy
```
Static Assets (Frontend)
├─ HTML: Cache for 1 hour
├─ CSS/JS: Cache for 1 year (versioned)
├─ Images: Cache for 1 month
└─ API responses: No cache (dynamic)

Edge Caching (Workers)
├─ Parsed AI results: Cache for 5 minutes
├─ Public listings: Cache for 1 minute
└─ User data: No cache
```

### Database Optimization
```
Indexes
├─ users.email: Unique index
├─ listings.userId: Index
├─ listings.category: Index
├─ listings.createdAt: Descending index
└─ Compound: (category + price)

Connection Pooling
├─ Min connections: 10
├─ Max connections: 100
└─ Connection timeout: 30s
```

## Cost Breakdown (Monthly)

### Free Tier (Development/MVP)
```
Cloudflare Workers:  $0    (100k req/day)
Cloudflare Pages:    $0    (unlimited req)
MongoDB Atlas M0:    $0    (512MB storage)
Render Free:         $0    (750 hours)
───────────────────────────────────────
Total:              $0/month
```

### Production Tier (Recommended)
```
Cloudflare Workers:  $5    (unlimited req)
Cloudflare Pages:    $0    (unlimited req)
MongoDB Atlas M10:   $57   (shared, 10GB)
Render Basic:        $7    (no sleep)
───────────────────────────────────────
Total:              $69/month
```

### Enterprise Tier (High Traffic)
```
Cloudflare Workers:  $5    (unlimited req)
Cloudflare Pages:    $20   (advanced features)
MongoDB Atlas M30:   $180  (dedicated, 40GB)
Render Pro:          $85   (auto-scaling)
Redis Cloud:         $50   (caching)
───────────────────────────────────────
Total:              $340/month
```

---

## Quick Links

- **[Setup Guide](./CLOUDFLARE_DEPLOYMENT.md)** - Complete deployment instructions
- **[Quick Deploy](./QUICK_DEPLOY.md)** - 5-minute deployment guide
- **[Checklist](./DEPLOYMENT_CHECKLIST.md)** - Step-by-step verification
- **[Summary](./DEPLOYMENT_SUMMARY.md)** - Overview and quick reference
