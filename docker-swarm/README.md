# Docker Swarm Stacks

This directory contains Docker Swarm versions of all the self-hosted service stacks. These have been converted from the original Docker Compose files to work with Docker Swarm mode for improved orchestration, scaling, and high availability.

## Prerequisites

### Docker Swarm Setup
1. **Initialize Docker Swarm** (on manager node):
   ```bash
   docker swarm init
   ```

2. **Add Worker Nodes** (optional, run on each worker):
   ```bash
   docker swarm join --token <worker-token> <manager-ip>:2377
   ```

3. **Label Nodes** for database placement:
   ```bash
   # Label nodes that should run databases
   docker node update --label-add database=true <node-name>
   ```

### Network Setup
Create the external Traefik network:
```bash
docker network create --driver overlay --attachable traefik
```

## Stack Overview

### Egress Stack
**Foundation stack** - Must be deployed first
- **Traefik**: Reverse proxy with automatic SSL/TLS
- **Cloudflared**: Cloudflare tunnel for external access
- **Whoami**: Test service for validation

### Media Stack
**Media management and streaming**
- **Jellyfin**: Media server
- **Sonarr**: TV series management
- **Radarr**: Movie management
- **Lidarr**: Music management
- **Prowlarr**: Indexer management
- **SABnzbd**: Usenet downloader
- **Deluge**: BitTorrent client
- **Jellyseerr**: Request management

### Tools Stack
**Productivity and development tools**
- **Gitea**: Git hosting
- **Nextcloud**: File sharing and collaboration
- **Portainer**: Docker Swarm management
- **Homepage**: Application dashboard
- **IT-Tools**: Online utilities
- **Guacamole**: Remote desktop gateway
- **Shepherd**: Automatic Docker Swarm service updates

## Deployment Order

Deploy stacks in this order to ensure proper dependencies:

1. **Egress Stack** (required first)
2. **Media Stack** and/or **Tools Stack** (can be deployed in any order)

## Quick Start

### 1. Configure Environment
Copy and configure environment files for each stack:

```bash
# Egress Stack
cd egress-stack
cp .env.example .env
nano .env

# Media Stack
cd ../media-stack
cp .env.example .env
nano .env

# Tools Stack
cd ../tools-stack
cp .env.example .env
nano .env
```

### 2. Deploy Stacks

```bash
# Deploy egress stack first
cd egress-stack
docker stack deploy -c docker-compose.yml egress

# Deploy media stack
cd ../media-stack
docker stack deploy -c docker-compose.yml media

# Deploy tools stack
cd ../tools-stack
docker stack deploy -c docker-compose.yml tools
```

### 3. Verify Deployment

```bash
# Check stack status
docker stack ls

# Check services in each stack
docker stack services egress
docker stack services media
docker stack services tools

# Check service logs
docker service logs egress_traefik
docker service logs media_jellyfin
docker service logs tools_nextcloud
```

## Key Differences from Docker Compose

### Docker Swarm Features
- **Service Discovery**: Automatic service discovery across the swarm
- **Load Balancing**: Built-in load balancing for services
- **Rolling Updates**: Zero-downtime updates with `docker service update`
- **Scaling**: Easy horizontal scaling with `docker service scale`
- **High Availability**: Services automatically restart on node failure

### Configuration Changes
- **Version 3.8**: Uses Docker Compose file format version 3.8
- **Deploy Section**: Added deployment configurations with replicas and restart policies
- **Overlay Networks**: Uses overlay networks for cross-node communication
- **Volume Mounts**: Configured for bind mounts with proper paths
- **Placement Constraints**: Database services pinned to labeled nodes
- **Manager Constraints**: Services requiring Docker socket access run on manager nodes

### Networking
- **Overlay Networks**: All internal networks use `driver: overlay`
- **Attachable Networks**: Networks are attachable for debugging
- **External Networks**: Traefik network is shared across all stacks

## Scaling Services

Scale services up or down as needed:

```bash
# Scale Jellyfin to 2 replicas
docker service scale media_jellyfin=2

# Scale Nextcloud to 3 replicas
docker service scale tools_nextcloud=3

# Scale multiple services
docker service scale media_sonarr=2 media_radarr=2
```

## Updates

Update services with rolling updates:

```bash
# Update a single service
docker service update --image lscr.io/linuxserver/jellyfin:latest media_jellyfin

# Update entire stack
docker stack deploy -c docker-compose.yml media
```

## Monitoring

### Check Service Status
```bash
# List all services
docker service ls

# Inspect a specific service
docker service inspect media_jellyfin

# Check service logs
docker service logs -f media_jellyfin

# Check which nodes services are running on
docker service ps media_jellyfin
```

### Node Management
```bash
# List swarm nodes
docker node ls

# Check node details
docker node inspect <node-name>

# Drain a node for maintenance
docker node update --availability drain <node-name>
```

## Troubleshooting

### Common Issues

1. **Services not starting**: Check node constraints and available resources
2. **Network connectivity**: Ensure overlay networks are properly created
3. **Volume mounts**: Verify paths exist on target nodes
4. **Resource limits**: Check available memory and CPU on nodes

### Useful Commands
```bash
# Check swarm status
docker info

# Force service restart
docker service update --force media_jellyfin

# Remove a stack
docker stack rm media

# Check container logs on specific node
docker logs <container-id>
```

## Security Considerations

- **Manager nodes**: Limit manager nodes to trusted servers
- **Secrets management**: Use Docker secrets for sensitive data
- **Network isolation**: Services isolated in overlay networks
- **Access control**: Traefik provides centralized access control

## Backup Strategy

Important data to backup:
- **Volume bind mounts**: All data in configured mount points
- **Environment files**: `.env` files for each stack
- **Docker compose files**: The `docker-compose.yml` files
- **Swarm configuration**: Manager node tokens and certificates

This Docker Swarm setup provides enterprise-grade orchestration for your self-hosted services with improved reliability, scalability, and management capabilities!
