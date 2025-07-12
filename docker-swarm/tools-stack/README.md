# Tools Stack Docker Swarm

A comprehensive Docker Swarm stack for various development and productivity tools with enterprise-grade orchestration.

## Services Included

### Core Services
- **Gitea** - Git hosting service with web interface
- **Guacamole** - Remote desktop gateway
- **IT-Tools** - Collection of handy online tools
- **Portainer** - Docker Swarm management UI
- **Shepherd** - Automatic Docker Swarm service updates
- **Nextcloud** - File sharing and collaboration platform
- **Homepage** - Application dashboard and homepage

### Supporting Services
- **MySQL** - Database for Gitea
- **PostgreSQL** - Database for Nextcloud
- **Redis** - Caching for Nextcloud
- **Guacd** - Guacamole daemon

## Quick Start

1. **Initialize Docker Swarm** (if not already done):
   ```bash
   docker swarm init
   ```

2. **Configure environment variables**:
   ```bash
   cp .env.example .env
   nano .env
   ```

3. **Update the `.env` file** with your preferred settings:
   - Change default passwords
   - Set your timezone
   - Configure email settings for Shepherd (optional)

4. **Deploy the stack**:
   ```bash
   docker stack deploy -c docker-compose.yml tools
   ```

5. **Check status**:
   ```bash
   docker stack services tools
   ```

## Service Access

| Service | URL | Default Credentials |
|---------|-----|-------------------|
| Gitea | https://gitea.yourdomain.com | Set during first-time setup |
| Guacamole | https://guacamole.yourdomain.com | guacadmin / guacadmin |
| IT-Tools | https://it-tools.yourdomain.com | No authentication required |
| Portainer | https://portainer.yourdomain.com | Set during first-time setup |
| Nextcloud | https://nextcloud.yourdomain.com | admin / changeme789 (from .env) |
| Homepage | https://homepage.yourdomain.com | No authentication required |

*Note: Services are accessed via Traefik reverse proxy with automatic SSL certificates*

## Initial Setup

### Gitea
1. Access https://gitea.yourdomain.com
2. Complete the installation wizard
3. Database settings are pre-configured via environment variables

### Guacamole
1. Access https://guacamole.yourdomain.com
2. Login with: `guacadmin` / `guacadmin`
3. Change the default password immediately
4. Configure your remote connections

### Portainer
1. Access https://portainer.yourdomain.com
2. Create an admin user during first visit
3. Connect to the Docker Swarm environment

### Nextcloud
1. Access https://nextcloud.yourdomain.com
2. Login with admin credentials from `.env` file
3. Complete the setup wizard
4. Configure additional settings as needed

### Homepage
1. Access https://homepage.yourdomain.com
2. Configure your dashboard by editing configuration files in `./config/homepage/`
3. Add widgets for your services and customize the layout
4. Homepage can integrate with Docker Swarm to show service status

## Configuration

### Environment Variables
Key variables in `.env`:
- `PUID/PGID` - User/Group IDs for file permissions
- `TZ` - Timezone setting
- Database passwords
- Nextcloud admin credentials
- Shepherd notification settings

### Volumes
Data is persisted in bind mounts:
- `./config/` - Configuration files
- `./data/` - Application data and databases

### Shepherd Configuration
Shepherd is configured to:
- Check for updates daily (24 hours)
- Only update services with `shepherd.enable=true` label
- Send email notifications (configure SMTP settings in .env)
- Perform rolling updates with zero downtime

### Service Labels for Updates
To enable automatic updates for a service, add this label:
```yaml
deploy:
  labels:
    - "shepherd.enable=true"
```

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
# Deploy the stack
docker stack deploy -c docker-compose.yml tools

# Remove the stack
docker stack rm tools

# View service status
docker stack services tools

# View service logs
docker service logs tools_[service_name]

# Scale a service
docker service scale tools_nextcloud=2

# Update a service
docker service update --image nextcloud:latest tools_nextcloud

# Backup data
tar -czf tools-backup-$(date +%Y%m%d).tar.gz data/ config/ .env
```

## Troubleshooting

### Common Issues
1. **Services not starting**: Check node constraints and resource availability
2. **Permission issues**: Check PUID/PGID settings and bind mount paths
3. **Database connection errors**: Wait for databases to fully initialize
4. **Network connectivity**: Ensure overlay networks are properly configured

### Service Dependencies
- Gitea requires MySQL to be ready
- Nextcloud requires PostgreSQL and Redis
- Guacamole requires Guacd daemon
- Database services are constrained to nodes with `database=true` label

### Node Labels
Label nodes appropriately for database placement:
```bash
docker node update --label-add database=true <node-name>
```

## Network

All services communicate on the `tools` overlay network. Internal communication uses service names:
- `mysql:3306`
- `nextcloud-db:5432`
- `nextcloud-redis:6379`
- `guacd:4822`

## Updates

Shepherd automatically checks for updates daily and performs rolling updates. To manually trigger updates:
```bash
# Force update a specific service
docker service update --force tools_shepherd

# Check Shepherd logs
docker service logs tools_shepherd
```

## Scaling and High Availability

Scale services horizontally:
```bash
# Scale Nextcloud to 3 replicas
docker service scale tools_nextcloud=3

# Scale IT-Tools to 2 replicas
docker service scale tools_it-tools=2
```

Database services are typically kept at 1 replica for data consistency.
