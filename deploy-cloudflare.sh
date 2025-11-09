#!/bin/bash

# Cloudflare Deployment Script
# This script helps you deploy the AIATL application to Cloudflare

set -e

echo "🚀 AIATL Cloudflare Deployment Script"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo -e "${RED}Error: Wrangler CLI is not installed${NC}"
    echo "Install it with: npm install -g wrangler"
    exit 1
fi

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Warning: .env file not found${NC}"
    echo "Creating .env from .env.example..."
    cp .env.example .env
    echo -e "${YELLOW}Please edit .env with your configuration before continuing${NC}"
    exit 1
fi

# Load environment variables
export $(cat .env | grep -v '^#' | xargs)

echo "Select what to deploy:"
echo "1) Gemini Service (Worker)"
echo "2) Backend API (Worker - Experimental)"
echo "3) Frontend (Pages)"
echo "4) All services"
echo "5) Configure secrets only"
read -p "Enter your choice (1-5): " choice

deploy_gemini() {
    echo -e "${GREEN}Deploying Gemini Service...${NC}"
    
    # Install dependencies
    cd json-parsing-gemini
    npm install
    cd ..
    
    # Check if secret exists
    echo "Setting GEMINI_API_KEY secret..."
    if [ -z "$GEMINI_API_KEY" ]; then
        echo -e "${YELLOW}GEMINI_API_KEY not found in .env${NC}"
        read -p "Enter your Gemini API key: " GEMINI_API_KEY
    fi
    
    echo "$GEMINI_API_KEY" | wrangler secret put GEMINI_API_KEY --config wrangler.gemini.toml
    
    # Deploy
    wrangler deploy --config wrangler.gemini.toml
    
    echo -e "${GREEN}✅ Gemini Service deployed!${NC}"
    echo "Note the Worker URL from the output above"
}

deploy_backend() {
    echo -e "${YELLOW}⚠️  Warning: Python Workers support is experimental${NC}"
    echo -e "${YELLOW}Consider using Render.com or Railway.app instead${NC}"
    read -p "Continue with Workers deployment? (y/n): " confirm
    
    if [ "$confirm" != "y" ]; then
        echo "Skipping backend deployment"
        return
    fi
    
    echo -e "${GREEN}Deploying Backend API...${NC}"
    
    # Set secrets
    echo "Setting backend secrets..."
    echo "$MONGODB_URI" | wrangler secret put MONGODB_URI --config wrangler.backend.toml
    echo "$DB_NAME" | wrangler secret put DB_NAME --config wrangler.backend.toml
    echo "$JWT_SECRET" | wrangler secret put JWT_SECRET --config wrangler.backend.toml
    echo "$GEMINI_SERVICE_URL" | wrangler secret put GEMINI_SERVICE_URL --config wrangler.backend.toml
    
    # Deploy
    wrangler deploy --config wrangler.backend.toml
    
    echo -e "${GREEN}✅ Backend API deployed!${NC}"
}

deploy_frontend() {
    echo -e "${GREEN}Deploying Frontend...${NC}"
    
    # Check for backend URL
    if [ -z "$VITE_API_URL" ]; then
        echo -e "${RED}Error: VITE_API_URL not set in .env${NC}"
        read -p "Enter your backend API URL: " VITE_API_URL
        echo "VITE_API_URL=$VITE_API_URL" >> .env
    fi
    
    # Install and build
    npm install
    npm run build
    
    # Deploy to Pages
    echo "Deploying to Cloudflare Pages..."
    wrangler pages deploy dist --project-name=aiatl-frontend
    
    echo -e "${GREEN}✅ Frontend deployed!${NC}"
}

configure_secrets() {
    echo -e "${GREEN}Configuring secrets...${NC}"
    
    # Gemini Service
    echo "Configuring Gemini Service secrets..."
    if [ ! -z "$GEMINI_API_KEY" ]; then
        echo "$GEMINI_API_KEY" | wrangler secret put GEMINI_API_KEY --config wrangler.gemini.toml
    else
        echo -e "${YELLOW}GEMINI_API_KEY not found in .env, skipping...${NC}"
    fi
    
    # Backend
    echo "Configuring Backend secrets..."
    if [ ! -z "$MONGODB_URI" ]; then
        echo "$MONGODB_URI" | wrangler secret put MONGODB_URI --config wrangler.backend.toml
    fi
    if [ ! -z "$DB_NAME" ]; then
        echo "$DB_NAME" | wrangler secret put DB_NAME --config wrangler.backend.toml
    fi
    if [ ! -z "$JWT_SECRET" ]; then
        echo "$JWT_SECRET" | wrangler secret put JWT_SECRET --config wrangler.backend.toml
    fi
    if [ ! -z "$GEMINI_SERVICE_URL" ]; then
        echo "$GEMINI_SERVICE_URL" | wrangler secret put GEMINI_SERVICE_URL --config wrangler.backend.toml
    fi
    
    echo -e "${GREEN}✅ Secrets configured!${NC}"
}

case $choice in
    1)
        deploy_gemini
        ;;
    2)
        deploy_backend
        ;;
    3)
        deploy_frontend
        ;;
    4)
        deploy_gemini
        echo ""
        deploy_backend
        echo ""
        deploy_frontend
        ;;
    5)
        configure_secrets
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}======================================"
echo "🎉 Deployment Complete!"
echo "======================================${NC}"
echo ""
echo "Next steps:"
echo "1. Test your deployed services"
echo "2. Update environment variables with the new URLs"
echo "3. Configure custom domains (optional)"
echo "4. Set up monitoring and alerts"
echo ""
echo "For detailed instructions, see CLOUDFLARE_DEPLOYMENT.md"
