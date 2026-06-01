#!/bin/bash

# HashiCups Setup Script
# This script starts HashiCups API and creates the default user

set -e

echo "🚀 Starting HashiCups API..."

# Start docker-compose
docker-compose up -d

echo "⏳ Waiting for services to be ready..."
sleep 10

# Check if API is responding
echo "🔍 Checking API health..."
if curl -s http://localhost:19090/health > /dev/null 2>&1; then
    echo "✅ API is running"
else
    echo "❌ API is not responding. Check docker-compose logs"
    exit 1
fi

# Create default user
echo "👤 Creating default user (education/test123)..."
RESPONSE=$(curl -s -X POST http://localhost:19090/signup \
    -H "Content-Type: application/json" \
    -d '{"username":"education","password":"test123"}')

if echo "$RESPONSE" | grep -q "token"; then
    echo "✅ User created successfully"
    echo ""
    echo "📋 Credentials:"
    echo "   Username: education"
    echo "   Password: test123"
    echo ""
    echo "🎉 HashiCups is ready!"
    echo ""
    echo "Test the API:"
    echo "  curl http://localhost:19090/coffees"
    echo ""
    echo "Sign in:"
    echo "  curl -X POST http://localhost:19090/signin -H 'Content-Type: application/json' -d '{\"username\":\"education\",\"password\":\"test123\"}'"
else
    # User might already exist, try to sign in
    SIGNIN_RESPONSE=$(curl -s -X POST http://localhost:19090/signin \
        -H "Content-Type: application/json" \
        -d '{"username":"education","password":"test123"}')
    
    if echo "$SIGNIN_RESPONSE" | grep -q "token"; then
        echo "✅ User already exists and credentials are valid"
        echo ""
        echo "🎉 HashiCups is ready!"
    else
        echo "⚠️  Could not create or verify user"
        echo "Response: $RESPONSE"
        echo ""
        echo "You may need to create a user manually:"
        echo "  curl -X POST http://localhost:19090/signup -H 'Content-Type: application/json' -d '{\"username\":\"education\",\"password\":\"test123\"}'"
    fi
fi

echo ""
echo "To stop HashiCups:"
echo "  docker-compose down"

# Made with Bob
