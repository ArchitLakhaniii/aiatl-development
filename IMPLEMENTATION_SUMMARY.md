# MongoDB User Profile System Implementation Summary

## Overview
This implementation adds a comprehensive MongoDB-based user authentication and seller profile system to the Flash Request application, as specified in `MongoDBprompt.txt`.

## What Was Implemented

### 1. Backend (Python/FastAPI)

#### Database Setup
- **`backend/database.py`**: MongoDB connection using Motor (async driver)
  - Connection string: `mongodb+srv://architlakhani20_db_user:nz1Dy6JXCmSvbaIj@flashrequest.gn6q8bx.mongodb.net/?appName=FlashRequest`
  - Database: `flashrequest`
  - Collections: `users`, `seller_profiles`

#### Models
- **`backend/models.py`**: Pydantic models for:
  - `UserSchema`: User document with location, bio, seller profile reference
  - `SellerProfileSchema`: Seller profile with sales history, keywords, etc.
  - `UserCreate`, `UserResponse`: Request/response models

#### Authentication
- **`backend/auth.py`**: Authentication utilities
  - Password hashing with bcrypt
  - JWT token generation and verification
  - Access token expiration (24 hours)

#### API Endpoints
- **`POST /api/auth/register`**: Register new user with bio processing
  - Creates user account
  - Processes bio using existing LLM service
  - Creates seller profile from LLM response
  - Returns access token

- **`POST /api/auth/login`**: Login user
  - Validates email/password
  - Returns access token and user info

- **`GET /api/users/{user_id}/profile`**: Get user profile with seller data
  - Returns user info and seller profile if available

- **`GET /api/seller-profiles/{user_id}`**: Get detailed seller profile

- **`POST /api/seller-profiles/process-bio`**: Process bio and update/create seller profile

- **`POST /api/users/seed-defaults`**: Seed default user profiles
  - Creates 3 default profiles (Evelyn Chen, Marcus Rodriguez, Sofia Kim)
  - Includes seller profiles with sales history

### 2. Frontend (React/TypeScript)

#### Login Page
- **`src/pages/LoginPage.tsx`**: New login/registration page
  - Toggle between login and registration
  - Registration fields: name, email, password, location, bio
  - Bio processing notification
  - Redirects to profile on success

#### User Profile Page
- **`src/pages/UserProfilePage.tsx`**: Enhanced profile page
  - Fetches user data from API
  - Displays bio and seller profile
  - New "Sales History" tab showing:
    - Categories with items sold
    - Average prices
    - Example items
    - Transaction types
  - Overview tab with keywords and interests

#### Routes
- **`src/routes/index.tsx`**: Added `/login` route

### 3. Dependencies

#### Python Dependencies (`requirements.txt`)
- `fastapi>=0.104.0`
- `uvicorn[standard]>=0.24.0`
- `motor>=3.3.0` (async MongoDB driver)
- `pymongo>=4.6.0`
- `bcrypt>=4.1.0`
- `pyjwt>=2.8.0`
- `pydantic>=2.0.0`
- Other existing dependencies

## Setup Instructions

### 1. Install Python Dependencies
```bash
pip install -r requirements.txt
```

### 2. Environment Variables (Optional)
Create a `.env` file or set environment variables:
```env
MONGODB_URI=mongodb+srv://architlakhani20_db_user:nz1Dy6JXCmSvbaIj@flashrequest.gn6q8bx.mongodb.net/?appName=FlashRequest
DB_NAME=flashrequest
SECRET_KEY=your-secret-key-change-in-production
GEMINI_SERVICE_URL=http://127.0.0.1:3001
```

### 3. Start Backend
```bash
uvicorn backend.app:app --reload --port 8000
```

### 4. Start Frontend
```bash
npm run dev
```

### 5. Seed Default Profiles (Optional)
```bash
curl -X POST http://localhost:8000/api/users/seed-defaults
```

## Features

### User Registration
- Users register with name, email, password, location, and bio
- Bio is automatically processed using the existing Gemini LLM service
- Seller profile is generated from bio and stored in MongoDB
- User receives JWT access token

### Seller Profile Generation
- Uses existing LLM service at `json-parsing-gemini`
- Processes bio text to extract:
  - Profile keywords
  - Inferred major
  - Location keywords
  - Sales history (if mentioned)
  - Transaction types
  - Related categories

### Profile Viewing
- Users can view their own profile or other users' profiles
- Displays:
  - Basic info (name, location, rating, trust score)
  - Bio/description
  - Seller profile with sales history
  - Categories and example items
  - Keywords and interests

## Database Schema

### Users Collection
```javascript
{
  _id: ObjectId,
  name: string,
  email: string,
  password: string (hashed),
  location: string,
  bio: string,
  seller_profile_id: ObjectId (optional),
  verified: boolean,
  trust_score: number,
  rating: number,
  past_trades: number,
  badges: string[],
  created_at: datetime,
  updated_at: datetime
}
```

### Seller Profiles Collection
```javascript
{
  _id: ObjectId,
  schema_type: "SELLER_PROFILE",
  user_id: string,
  context: {
    original_text: string
  },
  profile_keywords: string[],
  inferred_major: string | null,
  inferred_location_keywords: string[],
  sales_history_summary: [{
    category: string,
    item_examples: string[],
    total_items_sold: number,
    avg_price_per_item: number | null,
    dominant_transaction_type_in_category: "sell" | "buy" | "trade"
  }],
  overall_dominant_transaction_type: "sell" | "buy" | "trade",
  related_categories_of_interest: string[],
  created_at: datetime,
  updated_at: datetime
}
```

## API Usage Examples

### Register User
```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@university.edu",
    "password": "password123",
    "location": "Boston, MA",
    "bio": "Computer Science student selling textbooks and electronics."
  }'
```

### Login
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@university.edu",
    "password": "password123"
  }'
```

### Get User Profile
```bash
curl http://localhost:8000/api/users/{user_id}/profile
```

## Notes

1. **LLM Integration**: The system uses the existing Gemini LLM service at `http://127.0.0.1:3001`. Make sure this service is running.

2. **Transaction Types**: The existing LLM service uses "sell" | "lend" | "mixed", while the prompt specifies "sell" | "buy" | "trade". The backend accepts both formats.

3. **Password Security**: Passwords are hashed using bcrypt before storage.

4. **JWT Tokens**: Access tokens are stored in localStorage on the frontend. Consider implementing refresh tokens for production.

5. **Error Handling**: Bio processing failures don't prevent user registration. User is created but without seller profile.

## Next Steps

1. Add more default profiles (currently 3, prompt requests 10+)
2. Implement profile editing
3. Add profile picture upload
4. Implement refresh tokens
5. Add email verification
6. Add password reset functionality
7. Implement rate limiting for API endpoints
8. Add comprehensive error handling and logging

## Testing

1. Register a new user at `/login`
2. Check MongoDB to verify user and seller profile were created
3. View profile at `/profile` to see seller profile data
4. Test seeding endpoint to create default profiles
5. Test login with created account

