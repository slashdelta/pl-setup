# Tools Stack Docker Compose

A comprehensive Docker Compose setup for various development and productivity tools.

## Services Included

### Core Services
- **Gitea** (Port 3000) - Git hosting service with web interface
- **Guacamole** (Port 8083) - Remote desktop gateway *Note: Changed from default port 8080 to avoid conflict with SABnzbd in media-stack*
- **IT-Tools** (Port 8082) - Collection of handy online tools
- **Portainer** (Port 9000) - Docker management UI
- **Watchtower** - Automatic container updates
- **Nextcloud** (Port 8081) - File sharing and collaboration platform
- **Homepage** (Port 3001) - Application dashboard and homepage

### Supporting Services
- **MySQL** - Database for Gitea
- **PostgreSQL** - Database for Nextcloud
- **Redis** - Caching for Nextcloud
- **Guacd** - Guacamole daemon

## Quick Start

1. **Configure environment variables**:
   ```bash
   cp .env.example .env
   nano .env
   ```

2. **Update the `.env` file** with your preferred settings:
   - Change default passwords
   - Set your timezone
   - Configure email settings for Watchtower (optional)

3. **Start the stack**:
   ```bash
   docker-compose up -d
   ```

4. **Check status**:
   ```bash
   docker-compose ps
   ```

## Service Access

| Service | URL | Default Credentials |
|---------|-----|-------------------|
| Gitea | http://localhost:3000 | Set during first-time setup |
| Guacamole | http://localhost:8083/guacamole | guacadmin / guacadmin |
| IT-Tools | http://localhost:8082 | No authentication required |
| Portainer | http://localhost:9000 | Set during first-time setup |
| Nextcloud | http://localhost:8081 | admin / changeme789 (from .env) |
| Homepage | http://localhost:3001 | No authentication required |

## Initial Setup

### Gitea
1. Access http://localhost:3000
2. Complete the installation wizard
3. Database settings are pre-configured via environment variables

### Guacamole
1. Access http://localhost:8083/guacamole
2. Login with: `guacadmin` / `guacadmin`
3. Change the default password immediately
4. Configure your remote connections

### Portainer
1. Access http://localhost:9000
2. Create an admin user during first visit
3. Connect to the local Docker environment

### Nextcloud
1. Access http://localhost:8081
2. Login with admin credentials from `.env` file
3. Complete the setup wizard
4. Configure additional settings as needed

### Homepage
1. Access http://localhost:3001
2. Configure your dashboard by editing configuration files in `./config/homepage/`
3. Add widgets for your services and customize the layout
4. Homepage can integrate with Docker to show container status

## Configuration

### Environment Variables
Key variables in `.env`:
- `PUID/PGID` - User/Group IDs for file permissions
- `TZ` - Timezone setting
- Database passwords
- Nextcloud admin credentials

### Volumes
Data is persisted in:
- `./config/` - Configuration files
- `./data/` - Application data and databases

### Watchtower Configuration
Watchtower is configured to:
- Run daily at 4 AM
- Clean up old images
- Send email notifications (configure SMTP settings in .env)

## Security Considerations

1. **Change default passwords** in `.env` before starting
2. **Update Guacamole default credentials** after first login
3. **Configure HTTPS** for production use
4. **Review firewall settings** if accessing remotely
5. **Regular backups** of the `./data/` directory

## Backup

Important directories to backup:
- `./data/` - All persistent data
- `./config/` - Configuration files
- `.env` - Environment configuration

## Useful Commands

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f [service_name]

# Update containers
docker-compose pull
docker-compose up -d

# Backup data
tar -czf tools-backup-$(date +%Y%m%d).tar.gz data/ config/ .env
```

## Troubleshooting

### Common Issues
1. **Port conflicts**: Ensure ports 3000, 3001, 8081, 8082, 8083, 9000 are available
   - *Note: Guacamole uses port 8083 instead of default 8080 to avoid conflict with SABnzbd from media-stack*
2. **Permission issues**: Check PUID/PGID settings match your user
3. **Database connection errors**: Wait for databases to fully initialize

### Service Dependencies
- Gitea requires MySQL to be ready
- Nextcloud requires PostgreSQL and Redis
- Guacamole requires Guacd daemon

## Network

All services communicate on the `tools` bridge network. Internal communication uses container names:
- `mysql:3306`
- `nextcloud-db:5432`
- `nextcloud-redis:6379`
- `guacd:4822`

## Updates

Watchtower automatically updates containers daily. To manually update:
```bash
docker-compose pull
docker-compose up -d
