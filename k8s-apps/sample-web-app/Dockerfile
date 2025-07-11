# Multi-stage build for optimized image
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files (if you have them)
# COPY package*.json ./
# RUN npm ci --only=production

# Production stage
FROM nginx:alpine

# Remove default nginx configuration
RUN rm -f /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy static files from builder stage or directly
COPY index.html /usr/share/nginx/html/

# Set proper permissions for existing nginx user
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    # Create nginx PID directory
    mkdir -p /var/run/nginx && \
    chown -R nginx:nginx /var/run/nginx && \
    # Create log directory
    touch /var/log/nginx/access.log /var/log/nginx/error.log && \
    chown nginx:nginx /var/log/nginx/access.log /var/log/nginx/error.log && \
    # Remove default nginx config that might override our PID setting
    rm -f /etc/nginx/nginx.conf.default

# Switch to non-root user
USER nginx

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
