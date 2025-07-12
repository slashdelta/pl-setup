# *-arr Media Management Stack

This docker-compose configuration sets up a comprehensive media management stack with the complete *-arr suite of applications, download clients, and media server.

## Included Applications

- **Prowlarr** (Port 9696) - Indexer management for all *-arr applications
- **Sonarr** (Port 8989) - TV series management and automation
- **Radarr** (Port 7878) - Movie management and automation
- **Lidarr** (Port 8686) - Music management and automation
- **SABnzbd** (Port 8080) - Usenet download client
- **Deluge** (Port 8112) - BitTorrent download client
- **Overseerr** (Port 5055) - Request management interface
- **Plex** (Port 32400) - Media server for streaming content

## Directory Structure

The compose file creates the following local directory structure based on your `.env` configuration:

```
docker-swarm/media-stack/
├── docker-compose.yml
├── .env
├── README.md
├── extract-api-info.sh
├── config/
│   ├── prowlarr/
│   ├── sonarr/
│   ├── radarr/
│   ├── lidarr/
│   ├── sabnzbd/
│   ├── deluge/
│   ├── overseerr/
│   └── plex/
├── downloads/
│   ├── sab/ (SABnzbd downloads)
│   └── incomplete/ (incomplete downloads)
├── media/
│   ├── tv/
│   ├── movies/
│   └── music/
```

**Note:** All paths are relative to the current directory by default, making it portable and self-contained.

## Getting Started

1. **Navigate to the media-stack directory:**
   ```bash
   cd docker-swarm/media-stack
   ```

2. **Edit the environment variables (optional):**
   ```bash
   nano .env
   ```

3. **Deploy the stack:**
   ```bash
   docker stack deploy -c docker-compose.yml media-stack
   ```

4. **Check service status:**
   ```bash
   docker service ls
   ```

5. **Extract API keys and configuration (after containers are initialized):**
   ```bash
   ./extract-api-info.sh
   ```

## Environment Variables

The configuration uses environment variables defined in the `.env` file:

- `PUID=1000` - User ID for file permissions
- `PGID=1000` - Group ID for file permissions
- `TZ=UTC` - Timezone setting
- `MEDIA_MOUNT_POINT=./media` - Local path for media files
- `CONFIG_MOUNT_POINT=./config` - Local path for configuration files
- `DOWNLOADS_MOUNT_POINT=./downloads` - Local path for downloads
- `TRAEFIK_NETWORK=traefik` - External Traefik network name
- `PLEX_CLAIM=claim-your-plex-token-here` - Plex claim token for server setup

**Default Configuration:** All directories are created locally within the docker-swarm/media-stack folder, making the setup portable and self-contained.

**To customize paths:**
```bash
# Edit the .env file
nano .env

# Example: Use system-wide paths
MEDIA_MOUNT_POINT=/mnt/media
CONFIG_MOUNT_POINT=/opt/media-stack/config
DOWNLOADS_MOUNT_POINT=/mnt/downloads
```

## Download Client Configuration

### SABnzbd Configuration
- **Web UI:** http://localhost:8080
- **Download Path in container:** `/downloads/sab`
- **Local Path:** `./downloads/sab/`
- **Incomplete Path in container:** `/incomplete`
- **Local Path:** `./downloads/incomplete/`

### Deluge Configuration  
- **Web UI:** http://localhost:8112
- **Default Password:** deluge
- **Download Path in container:** `/downloads/deluge`
- **Local Path:** `./downloads/` (Note: Deluge maps the entire downloads folder)

## API Key Extraction and Service Integration

### Extract Configuration Information
Use the included script to extract API keys and configuration:

```bash
./extract-api-info.sh
```

This creates `api-keys-and-config.md` with:
- API keys for all *-arr applications
- SABnzbd API and NZB keys
- Overseerr API key and client ID
- Plex server token and machine ID
- Deluge authentication hash
- Service URLs for container communication

### Integration Setup Guide

#### 1. Prowlarr → *-arr Applications
In each *-arr app (Sonarr, Radarr, Lidarr):
1. Go to Settings → Indexers
2. Add "Prowlarr" indexer:
   - **URL:** `http://prowlarr:9696`
   - **API Key:** [From extract-api-info.sh output]

#### 2. Download Clients → *-arr Applications
In each *-arr app, go to Settings → Download Clients:

**For SABnzbd:**
- **Name:** SABnzbd
- **Host:** `sabnzbd`
- **Port:** `8080`
- **API Key:** [From extract-api-info.sh output]
- **Category:** tv/movies/music (set appropriately)

**For Deluge:**
- **Name:** Deluge
- **Host:** `deluge`
- **Port:** `8112`
- **Password:** `deluge` (change after setup)

#### 3. Overseerr Integration
**Connect to Plex:**
1. In Overseerr, go to Settings → Plex
2. Configure:
   - **Server URL:** `http://plex:32400`
   - **Server Token:** [From extract-api-info.sh output or Plex settings]

**Connect to *-arr Applications:**
1. In Overseerr, go to Settings → Services
2. Add each service:
   - **Sonarr:** `http://sonarr:8989` + API key
   - **Radarr:** `http://radarr:7878` + API key
   - **Lidarr:** `http://lidarr:8686` + API key

## Volume Mappings

Based on the current `.env` configuration:

### Configuration Files
- **Prowlarr:** `./config/prowlarr/` → `/config`
- **Sonarr:** `./config/sonarr/` → `/config`
- **Radarr:** `./config/radarr/` → `/config`
- **Lidarr:** `./config/lidarr/` → `/config`
- **SABnzbd:** `./config/sabnzbd/` → `/config`
- **Deluge:** `./config/deluge/` → `/config`
- **Overseerr:** `./config/overseerr/` → `/config`
- **Plex:** `./config/plex/` → `/config`

### Media Files
- **TV Shows:** `./media/tv/` → `/tv` (Sonarr & Plex)
- **Movies:** `./media/movies/` → `/movies` (Radarr & Plex)
- **Music:** `./media/music/` → `/music` (Lidarr & Plex)

### Downloads
- **SABnzbd Complete:** `./downloads/sab/` → `/downloads/sab`
- **SABnzbd Incomplete:** `./downloads/incomplete/` → `/incomplete`
- **Deluge:** `./downloads/` → `/downloads/deluge`
- **General Downloads:** `./downloads/` → `/downloads` (for *-arr apps)

## Service Details

### Web Interfaces
- **Prowlarr:** http://localhost:9696
- **Sonarr:** http://localhost:8989
- **Radarr:** http://localhost:7878
- **Lidarr:** http://localhost:8686
- **SABnzbd:** http://localhost:8080
- **Deluge:** http://localhost:8112 (password: deluge)
- **Overseerr:** http://localhost:5055
- **Plex:** http://localhost:32400/web

### Container Communication URLs
Use these URLs when configuring services to communicate with each other:
- **Prowlarr:** `http://prowlarr:9696`
- **Sonarr:** `http://sonarr:8989`
- **Radarr:** `http://radarr:7878`
- **Lidarr:** `http://lidarr:8686`
- **SABnzbd:** `http://sabnzbd:8080`
- **Deluge:** `http://deluge:8112`
- **Overseerr:** `http://overseerr:5055`
- **Plex:** `http://plex:32400`

## Initial Setup Order

1. **Prowlarr** - Add indexers that will be shared across all *-arr apps
2. **SABnzbd** - Configure Usenet servers and test download
3. **Deluge** - Change default password and test torrent download
4. **Sonarr/Radarr/Lidarr** - Add Prowlarr indexers and download clients
5. **Plex** - Complete setup wizard and add media libraries
6. **Overseerr** - Connect to Plex and *-arr applications

## Common Commands

- **Deploy stack:** `docker stack deploy -c docker-compose.yml media-stack`
- **Remove stack:** `docker stack rm media-stack`
- **View services:** `docker service ls`
- **View service logs:** `docker service logs media-stack_[service_name]`
- **Scale a service:** `docker service scale media-stack_[service_name]=2`
- **Update services:** `docker service update --force media-stack_[service_name]`
- **Extract API info:** `./extract-api-info.sh`

## Troubleshooting

**Service won't start:**
- Check logs: `docker service logs media-stack_[service_name]`
- Check service status: `docker service ps media-stack_[service_name]`
- Check file permissions on config directories

**Can't access web interface:**
- Ensure service is running: `docker service ls`
- Check if service is accessible through Traefik
- Verify Traefik network connectivity

**Services can't communicate:**
- Verify all services are on the same overlay network
- Use service names (not localhost) for internal communication
- Check that the overlay network is properly configured

**Download issues:**
- Check download client configuration in *-arr apps
- Verify download paths are correctly mapped
- Ensure SABnzbd categories match *-arr app settings

**API extraction fails:**
- Ensure containers are fully started and initialized
- Wait 2-3 minutes after `docker stack deploy`
- Run `./extract-api-info.sh` again

## Docker Swarm Specific Notes

- **Overlay Networks:** Services communicate over Docker's overlay network
- **Service Discovery:** Use service names for inter-container communication
- **High Availability:** Services can be scaled and distributed across swarm nodes
- **Secrets Management:** Consider using Docker secrets for sensitive data
- **Node Constraints:** Database services have node constraints for data persistence

## Security Notes

- **Change default passwords:** Especially Deluge (default: deluge)
- **API keys:** Keep extracted API keys secure - they provide admin access
- **File permissions:** PUID/PGID should match your user to avoid permission issues
- **Network access:** Consider firewall rules if exposing services externally
- **Traefik SSL:** Ensure SSL certificates are properly configured

## Backup Recommendations

**Essential directories to backup:**
- `./config/` - All application configurations and databases
- `./media/` - Your media library
- `.env` - Environment configuration
- `docker-compose.yml` - Service definitions

**Backup command example:**
```bash
tar -czf media-stack-backup-$(date +%Y%m%d).tar.gz config/ media/ .env docker-compose.yml
```

This Docker Swarm setup provides high availability and scalability for your media stack infrastructure.
