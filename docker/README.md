# Docker Compose Stacks

This directory contains Docker Compose configurations for self-hosted services organized into three main stacks. Each stack is designed to work independently or together to provide a comprehensive self-hosting solution.

## Stack Overview

### Egress Stack
**Foundation stack** - Provides external access and reverse proxy
- **Traefik**: Reverse proxy with automatic SSL/TLS certificates
- **Cloudflared**: Cloudflare tunnel for secure external access
- **Whoami**: Test service for validating Traefik configuration

### Media Stack
**Media management and streaming services**
- **Jellyfin**: Media server for movies, TV shows, and music
- **Sonarr**: TV series management and automation
- **Radarr**: Movie management and automation
- **Lidarr**: Music management and automation
- **Prowlarr**: Indexer management for torrent and usenet
- **SABnzbd**: Usenet download client
- **Deluge**: BitTorrent download client
- **Jellyseerr**: Request management for media content

### Tools Stack
**Productivity and development tools**
- **Gitea**: Self-hosted Git service with web interface
- **Nextcloud**: File sharing and collaboration platform
- **Portainer**: Docker management web interface
- **Homepage**: Application dashboard and homepage
- **IT-Tools**: Collection of handy online utilities
- **Guacamole**: Remote desktop gateway
- **Watchtower**: Automatic container updates

## Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Domain name (for external access via Cloudflare tunnel)
- Cloudflare account (for tunnel and SSL certificates)

### Deployment Order
1. **Egress Stack** (required first for reverse proxy)
2. **Media Stack** and/or **Tools Stack** (can be deployed in any order)

### Basic Setup

1. **Configure each stack**:
   ```bash
   # For each stack you want to deploy
   cd [stack-name]
   cp .env.example .env
   nano .env  # Configure your settings
   ```

2. **Deploy egress stack first**:
   ```bash
   cd egress-stack
   docker-compose up -d
   ```

3. **Deploy additional stacks**:
   ```bash
   cd ../media-stack
   docker-compose up -d
   
   cd ../tools-stack
   docker-compose up -d
   ```

## Service Access

### Local Access (Development)
Services can be accessed locally via their configured ports:
- Traefik Dashboard: http://localhost:8080
- Jellyfin: http://localhost:8096
- Portainer: http://localhost:9000
- Gitea: http://localhost:3000

### External Access (Production)
Services are accessed via subdomains through Traefik:
- https://jellyfin.yourdomain.com
- https://portainer.yourdomain.com
- https://gitea.yourdomain.com

## Key Features

### Automatic Updates
- **Watchtower** (in tools-stack) automatically updates all containers
- Configurable schedule (default: daily at 4 AM)
- Email notifications for updates
- Automatic cleanup of old images

### SSL/TLS Certificates
- **Let's Encrypt** integration via Traefik
- **Cloudflare DNS Challenge** for wildcard certificates
- Automatic certificate renewal
- HTTP to HTTPS redirection

### Reverse Proxy
- **Host-based routing** via Traefik
- **Automatic service discovery** using Docker labels
- **Load balancing** for scalable services
- **Basic authentication** for sensitive services

## Configuration

### Environment Variables
Each stack uses `.env` files for configuration:
- **Sensitive data**: Passwords, API keys, tokens
- **Customization**: Paths, domains, user preferences
- **Feature toggles**: Enable/disable specific features

### Volume Mounts
Data persistence using bind mounts:
- `./config/` - Application configurations
- `./data/` - Application data and databases
- `./media/` - Media files (movies, TV, music)
- `./downloads/` - Download directories

### Networking
- **Bridge networks** for internal communication
- **External networks** for cross-stack communication
- **Traefik integration** via shared network

## Useful Commands

```bash
# Start all services in a stack
docker-compose up -d

# Stop all services in a stack
docker-compose down

# View logs for all services
docker-compose logs -f

# View logs for specific service
docker-compose logs -f [service-name]

# Update all containers
docker-compose pull
docker-compose up -d

# Check status
docker-compose ps

# Restart a specific service
docker-compose restart [service-name]
```

## Backup Strategy

### Important Data to Backup
1. **Configuration files**: `.env` files and `docker-compose.yml`
2. **Application data**: `./config/` and `./data/` directories
3. **Media files**: `./media/` directory (if applicable)
4. **Downloads**: `./downloads/` directory (optional)

### Backup Commands
```bash
# Backup configuration
tar -czf backup-config-$(date +%Y%m%d).tar.gz */docker-compose.yml */.env

# Backup data
tar -czf backup-data-$(date +%Y%m%d).tar.gz */config/ */data/

# Full backup (excluding media - too large)
tar -czf backup-full-$(date +%Y%m%d).tar.gz \
  --exclude='*/media/' \
  --exclude='*/downloads/' \
  egress-stack/ media-stack/ tools-stack/
```

## Security Considerations

1. **Change default passwords** in all `.env` files
2. **Use strong passwords** for databases and admin accounts
3. **Configure firewall** rules appropriately
4. **Regular updates** via Watchtower or manual pulls
5. **Backup encryption** for sensitive data
6. **Network isolation** using Docker networks
7. **Access control** via Traefik authentication

## Troubleshooting

### Common Issues

1. **Port conflicts**: Check if ports are already in use
   ```bash
   netstat -tlnp | grep :8080
   ```

2. **Permission errors**: Check file/directory permissions
   ```bash
   sudo chown -R $USER:$USER ./config ./data
   ```

3. **Network issues**: Verify Docker networks
   ```bash
   docker network ls
   docker network inspect traefik
   ```

4. **Service startup**: Check service dependencies
   ```bash
   docker-compose logs [service-name]
   ```

### Resource Requirements

**Minimum recommendations:**
- **CPU**: 4 cores
- **RAM**: 8GB
- **Storage**: 100GB (more for media)

**Optimal setup:**
- **CPU**: 8+ cores
- **RAM**: 16GB+
- **Storage**: 1TB+ (for media files)

## Integration with Traefik

Services use Docker labels for Traefik integration:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.service.rule=Host(`service.domain.com`)"
  - "traefik.http.routers.service.entrypoints=websecure"
  - "traefik.http.routers.service.tls.certresolver=cloudflare"
  - "traefik.http.services.service.loadbalancer.server.port=80"
```

## Support and Documentation

- **Individual stack documentation**: See README.md in each stack directory
- **Traefik documentation**: https://doc.traefik.io/traefik/
- **Docker Compose documentation**: https://docs.docker.com/compose/

This setup provides a robust, scalable, and maintainable self-hosting solution with enterprise-grade features like automatic SSL, reverse proxy, and container management.
