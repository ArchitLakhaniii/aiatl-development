# AIATL - Flash Request Marketplace

A modern marketplace platform for buying and selling items within campus communities, powered by AI for intelligent listing parsing and matching.

## 🚀 Quick Links

- **[Start Here](./DEPLOYMENT_SUMMARY.md)** - Overview of deployment setup
- **[Quick Deploy (5 min)](./QUICK_DEPLOY.md)** - Fast deployment guide
- **[Complete Guide](./CLOUDFLARE_DEPLOYMENT.md)** - Detailed deployment instructions
- **[Deployment Checklist](./DEPLOYMENT_CHECKLIST.md)** - Step-by-step verification

## 📋 Features

- **AI-Powered Parsing**: Automatically parse natural language listings using Google Gemini
- **Smart Matching**: ML-based recommendation system for buyer-seller matching
- **User Authentication**: Secure JWT-based authentication system
- **Real-time Search**: Fast search and filtering capabilities
- **Responsive Design**: Modern UI with Tailwind CSS and Framer Motion
- **Cloud-Native**: Deployed on Cloudflare with MongoDB Atlas

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│          Cloudflare Global CDN              │
└─────────────────┬───────────────────────────┘
                  │
    ┌─────────────┴─────────────┐
    │                           │
┌───▼────┐                 ┌────▼─────┐
│Frontend│                 │ Backend  │
│ Pages  │                 │   API    │
│(React) │                 │(FastAPI) │
└───┬────┘                 └────┬─────┘
    │                           │
    │    ┌──────────────────────┤
    │    │                      │
┌───▼────▼───┐           ┌──────▼──────┐
│  Gemini    │           │  MongoDB    │
│  Service   │           │   Atlas     │
│  (Worker)  │           │ (Database)  │
└────────────┘           └─────────────┘
```

## 🛠️ Tech Stack

### Frontend
- **React 18** - UI library
- **TypeScript** - Type safety
- **Vite** - Build tool
- **Tailwind CSS** - Styling
- **Framer Motion** - Animations
- **Zustand** - State management
- **React Router** - Navigation
- **React Hook Form** - Form handling

### Backend
- **FastAPI** - Python web framework
- **MongoDB** - NoSQL database
- **Motor** - Async MongoDB driver
- **JWT** - Authentication
- **scikit-learn** - ML model
- **NumPy** - Numerical computing

### AI/ML
- **Google Gemini API** - Natural language processing
- **Custom ML Model** - Buyer-seller matching
- **Feature Engineering** - Smart recommendations

### Infrastructure
- **Cloudflare Pages** - Frontend hosting
- **Cloudflare Workers** - Serverless functions
- **MongoDB Atlas** - Managed database
- **Render.com/Railway** - Backend hosting (recommended)

## 📦 Installation

### Prerequisites
- Node.js 20+
- Python 3.11+
- MongoDB Atlas account
- Google Gemini API key
- Cloudflare account

### Local Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/aiatl.git
   cd aiatl
   ```

2. **Install frontend dependencies**
   ```bash
   npm install
   ```

3. **Install backend dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Install Gemini service dependencies**
   ```bash
   cd json-parsing-gemini
   npm install
   cd ..
   ```

5. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your credentials
   ```

6. **Start development servers**
   ```bash
   # Terminal 1 - Frontend
   npm run dev

   # Terminal 2 - Backend
   npm run dev:backend

   # Terminal 3 - Gemini service
   cd json-parsing-gemini && npm run dev
   ```

7. **Open in browser**
   - Frontend: http://localhost:5173
   - Backend: http://localhost:8000
   - Gemini: http://localhost:3001

## 🚀 Deployment

### Option 1: Quick Deploy (Recommended)
```bash
./deploy-cloudflare.sh
```

### Option 2: Manual Deploy

1. **Deploy Gemini Service**
   ```bash
   npm run deploy:gemini
   ```

2. **Deploy Backend to Render.com**
   - See [CLOUDFLARE_DEPLOYMENT.md](./CLOUDFLARE_DEPLOYMENT.md) for detailed instructions

3. **Deploy Frontend**
   ```bash
   npm run deploy:frontend
   ```

### Deployment Documentation
- **[Complete Deployment Guide](./CLOUDFLARE_DEPLOYMENT.md)** - All deployment options
- **[Quick Start](./QUICK_DEPLOY.md)** - Fast 5-minute setup
- **[Deployment Checklist](./DEPLOYMENT_CHECKLIST.md)** - Step-by-step guide

## 📖 API Documentation

### Authentication Endpoints
- `POST /api/register` - Register new user
- `POST /api/login` - Login user
- `GET /api/me` - Get current user

### Listing Endpoints
- `GET /api/listings` - Get all listings
- `POST /api/listings` - Create listing
- `GET /api/listings/:id` - Get listing by ID
- `PUT /api/listings/:id` - Update listing
- `DELETE /api/listings/:id` - Delete listing

### AI Parsing Endpoints
- `POST /api/parse-request` - Parse buyer request
- `POST /api/parse-profile` - Parse seller profile

### Matching Endpoints
- `POST /api/match` - Get buyer-seller matches

## 🧪 Testing

```bash
# Run linting
npm run lint

# Run type checking
npm run build

# Test backend
python -m pytest

# Test endpoints
curl http://localhost:8000/health
```

## 📊 Environment Variables

### Required Variables
```env
# MongoDB
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/
DB_NAME=flashrequest

# Authentication
JWT_SECRET=your-secret-key

# AI Service
GEMINI_API_KEY=your-gemini-api-key

# Service URLs
GEMINI_SERVICE_URL=https://your-gemini-worker.workers.dev
VITE_API_URL=https://your-backend-url.com
```

See [`.env.example`](./.env.example) for complete list.

## 🔒 Security

- JWT-based authentication
- Password hashing with bcrypt
- CORS configuration
- Environment variable protection
- MongoDB connection encryption
- HTTPS enforcement via Cloudflare

## 📈 Performance

### Free Tier
- **Response Time**: 200-500ms
- **Uptime**: 99%+
- **Requests/day**: 100,000

### Paid Tier
- **Response Time**: 50-200ms
- **Uptime**: 99.9%+
- **Requests/day**: Millions

## 💰 Cost Estimates

### Free Tier
- Cloudflare: **$0**
- MongoDB M0: **$0**
- Render Free: **$0**
- **Total: $0/month**

### Production
- Cloudflare Paid: **$5/month**
- MongoDB M10: **$57/month**
- Render Basic: **$7/month**
- **Total: ~$69/month**

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Google Gemini for AI parsing
- Cloudflare for hosting infrastructure
- MongoDB Atlas for database
- Georgia Tech community

## 📞 Support

- **Documentation**: See the `/docs` folder
- **Issues**: [GitHub Issues](https://github.com/your-username/aiatl/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/aiatl/discussions)

## 🗺️ Roadmap

- [ ] Mobile app (React Native)
- [ ] Real-time chat
- [ ] Payment integration
- [ ] Rating system
- [ ] Advanced analytics
- [ ] Multi-campus support
- [ ] Image upload and processing
- [ ] Email notifications
- [ ] Social media integration

## 🔄 Recent Updates

- ✅ Cloudflare deployment configuration
- ✅ MongoDB Atlas integration
- ✅ Gemini AI worker setup
- ✅ Comprehensive deployment documentation
- ✅ Automated deployment scripts

---

**Ready to deploy?** Start with [DEPLOYMENT_SUMMARY.md](./DEPLOYMENT_SUMMARY.md)

**Need help?** Check out [CLOUDFLARE_DEPLOYMENT.md](./CLOUDFLARE_DEPLOYMENT.md)

**Quick start?** Use [QUICK_DEPLOY.md](./QUICK_DEPLOY.md)
