#!/bin/bash

# Set environment variables for proper networking
export HOSTNAME=0.0.0.0
export PORT=3000
export NODE_ENV=production

echo "Starting Next.js application..."
echo "Environment: NODE_ENV=$NODE_ENV"
echo "Binding to: $HOSTNAME:$PORT"

# Strategy 1: Check if we have a standalone build
# A standalone build includes a server.js file in the root directory
if [ -f "server.js" ]; then
    echo "Found standalone build, starting with server.js..."
    exec node server.js
else
    echo "No standalone build found, checking for regular Next.js build..."
    
    # Strategy 2: Check if we have a regular Next.js build
    if [ -f "package.json" ] && [ -d ".next" ]; then
        echo "Found regular Next.js build, starting with next start..."
        
        # Check if we have yarn or npm
        if [ -f "yarn.lock" ]; then
            echo "Using yarn to start the application..."
            exec yarn start
        elif [ -f "package-lock.json" ]; then
            echo "Using npm to start the application..."
            exec npm start
        else
            echo "Using npx to start the application..."
            exec npx next start
        fi
    else
        echo "Error: No valid Next.js build found!"
        echo "Contents of current directory:"
        ls -la
        echo ""
        echo "Contents of .next directory (if exists):"
        ls -la .next/ 2>/dev/null || echo "No .next directory found"
        exit 1
    fi
fi