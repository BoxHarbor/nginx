# BoxHarbor Nginx Image
FROM ghcr.io/boxharbor/baseimage-alpine:latest

# Build arguments
ARG BUILD_DATE
ARG VERSION
ARG VCS_REF
ARG NGINX_VERSION

# Labels
LABEL org.opencontainers.image.created="${BUILD_DATE}" \
  org.opencontainers.image.title="BoxHarbor Nginx" \
  org.opencontainers.image.description="Lightweight, rootless-compatible Nginx server" \
  org.opencontainers.image.url="https://github.com/BoxHarbor/nginx" \
  org.opencontainers.image.source="https://github.com/BoxHarbor/nginx" \
  org.opencontainers.image.version="${VERSION}" \
  org.opencontainers.image.revision="${VCS_REF}" \
  org.opencontainers.image.vendor="BoxHarbor" \
  org.opencontainers.image.licenses="GPL-3.0" \
  maintainer="BoxHarbor Team"

# Install Nginx
RUN apk add --no-cache \
  nginx \
  nginx-mod-http-headers-more \
  && rm -rf /var/cache/apk/* /tmp/*

# Create necessary directories
RUN mkdir -p \
  /web \
  /var/lib/nginx/tmp \
  /var/log/nginx \
  /run/nginx \
  /config/sites-enabled \
  /config/ssl

# Copy default configurations
COPY rootfs/ /

# Set permissions for rootless operation
RUN chown -R appuser:appuser \
  /web \
  /var/lib/nginx \
  /var/log/nginx \
  /run/nginx \
  /config/sites-enabled \
  /config/ssl \
  && chmod -R 755 /var/lib/nginx \
  && chmod -R 755 /var/log/nginx \
  && chmod -R 755 /run/nginx

# Expose non-privileged HTTP port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/ || exit 1

# Use base image init
CMD []