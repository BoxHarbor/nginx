# BoxHarbor - Nginx

[![Docker Pulls](https://img.shields.io/docker/pulls/gaetanddr/nginx)](https://hub.docker.com/r/gaetanddr/nginx)
[![GitHub](https://img.shields.io/github/license/boxharbor/nginx)](https://github.com/BoxHarbor/nginx)

A lightweight, rootless-compatible Nginx container based on BoxHarbor's Alpine base image. Perfect for serving static content, reverse proxying, or as a foundation for web applications.

## Features

- 🪶 **Lightweight**: Alpine-based
- 🔒 **Rootless Compatible**: Works with Podman and Docker rootless
- ⚡ **High Performance**: Optimized Nginx configuration
- 📁 **Persistent Config**: Store configuration in `/config`
- 🌍 **Multi-arch**: Supports amd64, arm64, armv7
- 🔧 **Easy Customization**: Simple configuration management

## Quick Start

### Docker

```bash
docker run -d \
  --name nginx \
  -p 8080:8080 \
  -v $(pwd)/config:/config \
  -v $(pwd)/web:/web \
  -e PUID=1000 \
  -e PGID=1000 \
  ghcr.io/boxharbor/nginx:latest
```

### Podman (Rootless)

```bash
podman run -d \
  --name nginx \
  -p 8080:8080 \
  -v $(pwd)/config:/config:Z \
  -v $(pwd)/web:/web:Z \
  -e PUID=1000 \
  -e PGID=1000 \
  ghcr.io/boxharbor/nginx:latest
```

### Docker Compose

```yaml
version: '3.8'

services:
  nginx:
    image: ghcr.io/boxharbor/nginx:latest
    container_name: nginx
    ports:
      - "8080:8080"
    volumes:
      - ./config:/config
      - ./web:/web
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    restart: unless-stopped
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PUID` | `1000` | User ID for file permissions |
| `PGID` | `1000` | Group ID for file permissions |
| `TZ` | `UTC` | Timezone |
| `UMASK` | `022` | File creation mask |

## Volumes

| Path | Description |
|------|-------------|
| `/config` | Nginx configuration files |
| `/web` | Web root directory (default document root) |

## Ports

| Port | Description |
|------|-------------|
| `8080` | HTTP (non-privileged port for rootless) |

## Directory Structure

```
/config/
├── nginx.conf          # Main Nginx configuration
├── sites-enabled/      # Virtual host configurations
│   └── default.conf    # Default site
└── ssl/               # SSL certificates (if needed)

/web/
└── index.html         # Your web content
```

## Configuration

### First Run

On first run, default configuration files are copied to `/config`:

- `nginx.conf` - Main Nginx configuration
- `sites-enabled/default.conf` - Default virtual host

Edit these files to customize your setup!

### Custom Site Configuration

Create a new file in `/config/sites-enabled/`:

```nginx
server {
    listen 8080;
    server_name example.com;
    
    root /web/example;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

Restart the container to apply changes:

```bash
docker restart nginx
# or
podman restart nginx
```

### SSL/TLS Configuration

Mount your certificates and update the configuration:

```yaml
volumes:
  - ./config:/config
  - ./certs:/config/ssl:ro
  - ./web:/web
```

Update `sites-enabled/default.conf`:

```nginx
server {
    listen 8443 ssl;
    ssl_certificate /config/ssl/cert.pem;
    ssl_certificate_key /config/ssl/key.pem;
    
    # ... rest of configuration
}
```

## Use Cases

### Static Website Hosting

```bash
# Place your files in ./web/
mkdir -p ./web
echo "<h1>Hello from BoxHarbor!</h1>" > ./web/index.html

# Run the container
docker run -d -p 8080:8080 -v $(pwd)/web:/web ghcr.io/boxharbor/nginx:latest
```

### Reverse Proxy

Edit `/config/sites-enabled/default.conf`:

```nginx
server {
    listen 8080;
    server_name api.example.com;
    
    location / {
        proxy_pass http://backend:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### PHP-FPM Backend

```yaml
services:
  nginx:
    image: ghcr.io/boxharbor/nginx:latest
    volumes:
      - ./config:/config
      - ./web:/web
    depends_on:
      - php-fpm
  
  php-fpm:
    image: php:fpm-alpine
    volumes:
      - ./web:/web
```

## Troubleshooting

### Permission Denied

Ensure PUID/PGID match your host user:

```bash
id -u  # Get your UID
id -g  # Get your GID
```

Set these in your docker run command or compose file.

### Port Already in Use

Change the host port:

```bash
docker run -d -p 9090:8080 ghcr.io/boxharbor/nginx:latest
```

### Configuration Errors

Check logs:

```bash
docker logs nginx
# or
podman logs nginx
```

Test configuration:

```bash
docker exec nginx nginx -t
```

## Building from Source

```bash
git clone https://github.com/BoxHarbor/nginx.git
cd nginx
docker build -t boxharbor/nginx:latest .
```

## Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting PRs.

## License

GPL-3.0 License - see [LICENSE](LICENSE) file for details.

## Support

- 💬 GitHub Issues: [Report bugs or request features](https://github.com/BoxHarbor/nginx/issues)
- 📖 Base Image: [BoxHarbor baseimage-alpine](https://github.com/BoxHarbor/baseimage-alpine)

---

Built with ❤️ by the BoxHarbor team