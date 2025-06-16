# syntax=docker/dockerfile:1

ARG NODE_VERSION=20.11.0

################################################################################
# Base stage
FROM node:${NODE_VERSION}-slim AS base

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    bash \
    && rm -rf /var/lib/apt/lists/*

################################################################################
# Dependencies stage
FROM base AS deps

COPY package.json yarn.lock* package-lock.json* ./

RUN if [ -f yarn.lock ]; then \
        yarn install --frozen-lockfile --network-timeout 600000; \
    elif [ -f package-lock.json ]; then \
        npm ci; \
    else \
        npm install; \
    fi

################################################################################
# Build stage
FROM base AS build

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build the application
RUN if [ -f yarn.lock ]; then \
        yarn build; \
    else \
        npm run build; \
    fi

# Debug output
RUN echo "Build contents:" && find .next -type f -name "*.js" | head -10 || echo "No .next directory"

################################################################################
# Production dependencies stage
FROM base AS production-deps

WORKDIR /app

COPY package.json yarn.lock* package-lock.json* ./

RUN if [ -f yarn.lock ]; then \
        yarn install --production --frozen-lockfile --network-timeout 600000; \
    elif [ -f package-lock.json ]; then \
        npm ci --only=production; \
    else \
        npm install --only=production; \
    fi

################################################################################
# Final stage
FROM base AS final

WORKDIR /app

# Set environment variables
ENV NODE_ENV=production
ENV HOSTNAME=0.0.0.0
ENV PORT=3000

# Create non-root user
RUN groupadd --gid 1001 nodejs && \
    useradd --uid 1001 --gid nodejs --shell /bin/bash --create-home nodejs

# Copy package.json and production dependencies
COPY --from=build /app/package.json ./package.json
COPY --from=production-deps /app/node_modules ./node_modules

# Copy build output - using shell commands to handle missing directories gracefully
RUN mkdir -p .next public
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public

# Setup entrypoint
COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

# Set ownership
RUN chown -R nodejs:nodejs /app

USER nodejs

EXPOSE 3000

ENTRYPOINT ["./entrypoint.sh"]