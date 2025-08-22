# Multi-stage build for Vue.js application
FROM node:20.19-alpine AS build

# メタデータ
LABEL maintainer="kaicyou2532"
LABEL description="MathSync - Mathematical synchronization and visualization application"

# Build arguments
ARG NODE_VERSION=20.19.0
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

# Environment labels
LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.source="https://github.com/kaicyou2532/mathsync"
LABEL org.opencontainers.image.version=$VERSION
LABEL org.opencontainers.image.revision=$VCS_REF
LABEL org.opencontainers.image.title="MathSync"
LABEL org.opencontainers.image.description="Mathematical synchronization and visualization application"

# Set working directory
WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies with npm ci for faster, reproducible builds
RUN npm ci --only=production --no-audit --no-fund && \
    npm cache clean --force

# Copy source code
COPY . .

# Build the application
RUN npm run build && \
    # Remove development dependencies and source files to reduce image size
    rm -rf node_modules src public *.config.js package*.json

# Production stage
FROM nginx:1.25-alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Create non-root user
RUN addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# Copy built application from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create necessary directories and set permissions
RUN mkdir -p /var/cache/nginx /var/run /var/log/nginx && \
    chown -R nginx:nginx /var/cache/nginx /var/run /var/log/nginx /usr/share/nginx/html && \
    chmod -R 755 /var/cache/nginx /var/run /var/log/nginx /usr/share/nginx/html

# Switch to non-root user
USER nginx

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:80/health || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
