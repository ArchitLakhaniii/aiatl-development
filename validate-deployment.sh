#!/bin/bash

# Deployment Validation Script
# This script helps verify that all deployment configurations are correct

set -e

echo "🔍 AIATL Deployment Configuration Validator"
echo "==========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

checks_passed=0
checks_failed=0

check_passed() {
    echo -e "${GREEN}✓${NC} $1"
    ((checks_passed++))
}

check_failed() {
    echo -e "${RED}✗${NC} $1"
    ((checks_failed++))
}

check_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

echo -e "${BLUE}Checking Prerequisites...${NC}"
echo ""

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    if [[ ${NODE_VERSION:1:2} -ge 20 ]]; then
        check_passed "Node.js $NODE_VERSION installed"
    else
        check_failed "Node.js version should be 20+, found $NODE_VERSION"
    fi
else
    check_failed "Node.js not installed"
fi

# Check Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    check_passed "$PYTHON_VERSION installed"
else
    check_failed "Python 3 not installed"
fi

# Check Wrangler
if command -v wrangler &> /dev/null; then
    WRANGLER_VERSION=$(wrangler --version)
    check_passed "Wrangler CLI installed ($WRANGLER_VERSION)"
else
    check_failed "Wrangler CLI not installed (run: npm install -g wrangler)"
fi

echo ""
echo -e "${BLUE}Checking Configuration Files...${NC}"
echo ""

# Check .env
if [ -f .env ]; then
    check_passed ".env file exists"
    
    # Check for required variables
    if grep -q "MONGODB_URI=" .env; then
        check_passed "MONGODB_URI configured"
    else
        check_failed "MONGODB_URI not found in .env"
    fi
    
    if grep -q "JWT_SECRET=" .env; then
        check_passed "JWT_SECRET configured"
    else
        check_failed "JWT_SECRET not found in .env"
    fi
    
    if grep -q "GEMINI_API_KEY=" .env; then
        check_passed "GEMINI_API_KEY configured"
    else
        check_failed "GEMINI_API_KEY not found in .env"
    fi
else
    check_failed ".env file not found (run: cp .env.example .env)"
fi

# Check wrangler configs
if [ -f wrangler.gemini.toml ]; then
    check_passed "wrangler.gemini.toml exists"
else
    check_failed "wrangler.gemini.toml not found"
fi

if [ -f wrangler.backend.toml ]; then
    check_passed "wrangler.backend.toml exists"
else
    check_failed "wrangler.backend.toml not found"
fi

# Check deployment files
if [ -f render.yaml ]; then
    check_passed "render.yaml exists (for backend deployment)"
else
    check_warning "render.yaml not found (optional)"
fi

if [ -f Dockerfile.railway ]; then
    check_passed "Dockerfile.railway exists"
else
    check_warning "Dockerfile.railway not found (optional)"
fi

echo ""
echo -e "${BLUE}Checking Dependencies...${NC}"
echo ""

# Check node_modules
if [ -d node_modules ]; then
    check_passed "Frontend dependencies installed"
else
    check_warning "Frontend dependencies not installed (run: npm install)"
fi

# Check Gemini service dependencies
if [ -d json-parsing-gemini/node_modules ]; then
    check_passed "Gemini service dependencies installed"
else
    check_warning "Gemini service dependencies not installed (run: cd json-parsing-gemini && npm install)"
fi

# Check Python packages
if python3 -c "import fastapi" 2>/dev/null; then
    check_passed "Backend dependencies installed (FastAPI found)"
else
    check_warning "Backend dependencies not installed (run: pip install -r requirements.txt)"
fi

echo ""
echo -e "${BLUE}Checking Project Structure...${NC}"
echo ""

# Check key directories
[ -d backend ] && check_passed "backend/ directory exists" || check_failed "backend/ directory not found"
[ -d src ] && check_passed "src/ directory exists" || check_failed "src/ directory not found"
[ -d json-parsing-gemini ] && check_passed "json-parsing-gemini/ directory exists" || check_failed "json-parsing-gemini/ directory not found"
[ -d MLmodel ] && check_passed "MLmodel/ directory exists" || check_failed "MLmodel/ directory not found"

# Check key files
[ -f package.json ] && check_passed "package.json exists" || check_failed "package.json not found"
[ -f vite.config.ts ] && check_passed "vite.config.ts exists" || check_failed "vite.config.ts not found"
[ -f backend/app.py ] && check_passed "backend/app.py exists" || check_failed "backend/app.py not found"
[ -f requirements.txt ] && check_passed "requirements.txt exists" || check_failed "requirements.txt not found"

echo ""
echo -e "${BLUE}Checking Documentation...${NC}"
echo ""

[ -f CLOUDFLARE_DEPLOYMENT.md ] && check_passed "CLOUDFLARE_DEPLOYMENT.md exists" || check_failed "CLOUDFLARE_DEPLOYMENT.md not found"
[ -f QUICK_DEPLOY.md ] && check_passed "QUICK_DEPLOY.md exists" || check_failed "QUICK_DEPLOY.md not found"
[ -f DEPLOYMENT_CHECKLIST.md ] && check_passed "DEPLOYMENT_CHECKLIST.md exists" || check_failed "DEPLOYMENT_CHECKLIST.md not found"
[ -f DEPLOYMENT_SUMMARY.md ] && check_passed "DEPLOYMENT_SUMMARY.md exists" || check_failed "DEPLOYMENT_SUMMARY.md not found"
[ -f README.md ] && check_passed "README.md exists" || check_failed "README.md not found"

echo ""
echo -e "${BLUE}Checking Deployment Scripts...${NC}"
echo ""

if [ -f deploy-cloudflare.sh ]; then
    check_passed "deploy-cloudflare.sh exists"
    if [ -x deploy-cloudflare.sh ]; then
        check_passed "deploy-cloudflare.sh is executable"
    else
        check_warning "deploy-cloudflare.sh is not executable (run: chmod +x deploy-cloudflare.sh)"
    fi
else
    check_failed "deploy-cloudflare.sh not found"
fi

echo ""
echo "==========================================="
echo -e "${BLUE}Validation Summary${NC}"
echo "==========================================="
echo ""
echo -e "Checks passed: ${GREEN}$checks_passed${NC}"
echo -e "Checks failed: ${RED}$checks_failed${NC}"
echo ""

if [ $checks_failed -eq 0 ]; then
    echo -e "${GREEN}✓ All critical checks passed!${NC}"
    echo ""
    echo "You're ready to deploy! Next steps:"
    echo "1. Review and edit .env with your credentials"
    echo "2. Run: ./deploy-cloudflare.sh"
    echo "3. Follow the deployment guide: QUICK_DEPLOY.md"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Some checks failed${NC}"
    echo ""
    echo "Please fix the issues above before deploying."
    echo "Refer to CLOUDFLARE_DEPLOYMENT.md for detailed setup instructions."
    echo ""
    exit 1
fi
