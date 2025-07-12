# Egress Stack Docker Compose

A comprehensive egress solution using Traefik as a reverse proxy and Cloudflared for secure tunneling to the internet via Cloudflare.

## Services Included

### Core Services
- **Traefik** (Ports 80, 443) - Reverse proxy with automatic SSL/TLS certificates
- **Cloudflared** - Cloudflare tunnel for secure external access
- **Whoami** - Test service for validating Traefik configuration

## Features

### Traefik Reverse Proxy
- **Automatic SSL/TLS**: Let's Encrypt integration with automatic certificate management
- **Docker Integration**: Automatic service discovery via Docker labels
- **Dashboard**: Web-based management interface with basic authentication
- **HTTP to HTTPS Redirect**: Automatic redirection for security
- **Custom Routing**: Host-based routing to different services

### Cloudflare Tunnel
- **Secure Access**: No open ports on your firewall required
- **Zero Trust**: Traffic routed through Cloudflare's secure network
- **DDoS Protection**: Built-in protection via Cloudflare
- **Global CDN**: Fast access from anywhere in the world

## Prerequisites

### Cloudflare Setup
1. **Domain**: You need a domain managed by Cloudflare (e.g., `example.com`)
2. **Cloudflare Account**: Access to Cloudflare dashboard
3. **Tunnel Token**: Create a tunnel in Cloudflare Zero Trust
4. **DNS API Token**: Create API token for automatic SSL certificate generation

### Creating a Cloudflare Tunnel
1. Go to [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/)
2. Navigate to **Access** → **Tunnels**
3. Click **Create a tunnel**
4. Choose **Cloudflared** and give it a name (e.g., "homelab")
5. Install the connector and copy the tunnel token
6. Configure public hostnames in the tunnel settings

### Creating a Cloudflare DNS API Token
1. Go to [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Click **Create Token**
3. Use **Custom token** template
4. Configure the token:
   - **Token name**: `Traefik DNS Challenge`
   - **Permissions**: 
     - Zone:Read for all zones
     - DNS:Edit for your specific zone
   - **Zone Resources**: Include specific zone
5. Click **Continue to summary** and **Create Token**
6. Copy the token and add it to your `.env` file as `CLOUDFLARE_DNS_API_TOKEN`

## Quick Start

1. **Configure environment variables**:
   ```bash
   cp .env.example .env
   nano .env
   ```

2. **Update the `.env` file**:
   - Set your `CLOUDFLARE_TUNNEL_TOKEN` from Cloudflare dashboard
   - Set your `CLOUDFLARE_DNS_API_TOKEN` for automatic SSL certificates
   - Verify `DOMAIN=*your-domain**`
   - Change `TRAEFIK_BASIC_AUTH` credentials if needed

3. **Start the stack**:
   ```bash
   docker compose up -d
   ```

4. **Check status**:
   ```bash
   docker compose ps
   ```

## Service Access

| Service | Internal URL | External URL (via tunnel) | Credentials |
|---------|-------------|---------------------------|-------------|
| Traefik Dashboard | http://localhost:80 | https://traefik.*your-domain* | admin / [configured] |
| Whoami Test | N/A | https://whoami.*your-domain* | No authentication |

## Configuration

### Environment Variables
Key variables in `.env`:
- `DOMAIN` - Your domain name
- `CLOUDFLARE_TUNNEL_TOKEN` - Token from Cloudflare tunnel setup
- `TRAEFIK_BASIC_AUTH` - Basic auth credentials for Traefik dashboard
- `TRAEFIK_NETWORK` - Docker network name for Traefik

### Cloudflare Tunnel Configuration
In your Cloudflare tunnel dashboard, configure these public hostnames:

**Important**: Configure the tunnel to use HTTPS and disable TLS verification to avoid redirect loops:

- `traefik.example.com` → `https://traefik:443`
  - **Origin Request Settings**: Enable `noTLSVerify` or disable `TLS Verify`
- `whoami.example.com` → `https://traefik:443` 
  - **Origin Request Settings**: Enable `noTLSVerify` or disable `TLS Verify`

**Why HTTPS with noTLSVerify?**
- Traefik is configured to redirect all HTTP traffic to HTTPS
- Using `http://traefik:80` creates a redirect loop: HTTP → HTTPS → tunnel → HTTP → HTTPS
- Using `https://traefik:443` with `noTLSVerify` bypasses the redirect while maintaining encryption
- The `noTLSVerify` setting only affects the internal tunnel connection, not external user security

### Adding Services to Traefik

To expose other services through Traefik, add these labels to their docker-compose services:

```yaml
services:
  your-service:
    # ... other configuration
    networks:
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.your-service.rule=Host(`your-service.example.com`)"
      - "traefik.http.routers.your-service.entrypoints=websecure"
      - "traefik.http.routers.your-service.tls.certresolver=cloudflare"

networks:
  traefik:
    external: true
    name: traefik
```

## Connecting Other Stacks

### Media Stack Integration
To expose media services via Traefik, add the traefik network to your media-stack services:

```yaml
# In media-stack/docker-compose.yml
networks:
  media:
    driver: bridge
  traefik:
    external: true
    name: traefik

services:
  jellyfin:
    # ... existing config
    networks:
      - media
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.jellyfin.rule=Host(`jellyfin.example.com`)"
      - "traefik.http.routers.jellyfin.entrypoints=websecure"
      - "traefik.http.routers.jellyfin.tls.certresolver=cloudflare"
```

### Tools Stack Integration
Similarly for tools-stack services:

```yaml
# In tools-stack/docker-compose.yml
networks:
  tools:
    driver: bridge
  traefik:
    external: true
    name: traefik

services:
  homepage:
    # ... existing config
    networks:
      - tools
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.homepage.rule=Host(`home.example.com`)"
      - "traefik.http.routers.homepage.entrypoints=websecure"
      - "traefik.http.routers.homepage.tls.certresolver=cloudflare"
```

## Security Features

### Built-in Security
- **Automatic HTTPS**: All traffic encrypted with Let's Encrypt certificates
- **Basic Authentication**: Traefik dashboard protected with username/password
- **Network Isolation**: Services only accessible through Traefik
- **No Open Ports**: Cloudflare tunnel eliminates need for port forwarding

### Recommended Security Practices
1. **Change Default Credentials**: Update `TRAEFIK_BASIC_AUTH` in `.env`
2. **Limit Dashboard Access**: Consider restricting Traefik dashboard to specific IPs
3. **Monitor Access Logs**: Review Traefik access logs regularly
4. **Keep Updated**: Regularly update container images

## Troubleshooting

### Common Issues

1. **Cloudflare Tunnel Not Connecting**:
   - Verify `CLOUDFLARE_TUNNEL_TOKEN` is correct
   - Check tunnel status in Cloudflare dashboard
   - Review cloudflared container logs: `docker compose logs cloudflared`

2. **SSL Certificate Issues**:
   - Ensure domain DNS points to Cloudflare
   - Check Let's Encrypt rate limits
   - Verify email address in ACME configuration

3. **Service Not Accessible**:
   - Confirm service is on `traefik` network
   - Check Traefik labels are correct
   - Verify hostname in Cloudflare tunnel configuration

4. **Dashboard Access Issues**:
   - Verify basic auth credentials
   - Check if `traefik.example.com` is configured in Cloudflare tunnel
   - Ensure Traefik container is running

5. **Redirect Loop Issues**:
   - **Problem**: Getting 301/308 redirects or redirect loops when accessing services
   - **Cause**: Cloudflare tunnel configured to use `http://traefik:80` while Traefik redirects HTTP to HTTPS
   - **Solution**: 
     - Change tunnel service URL to `https://traefik:443`
     - Enable `noTLSVerify` in Origin Request settings
     - This maintains security while avoiding internal certificate hostname mismatches

### Useful Commands

```bash
# Check all container status
docker compose ps

# View Traefik logs
docker compose logs traefik

# View Cloudflared logs
docker compose logs cloudflared

# Restart specific service
docker compose restart traefik

# Check Traefik configuration
docker compose exec traefik traefik version

# Test internal connectivity
docker compose exec traefik ping whoami
```

## Data Persistence

Important directories that contain persistent data:
- `./config/traefik/letsencrypt/` - SSL certificates and ACME data
- `./config/traefik/config/` - Dynamic Traefik configuration files

## Backup

Important files to backup:
- `.env` - Environment configuration
- `./config/traefik/letsencrypt/acme.json` - SSL certificates
- `docker-compose.yml` - Service configuration

```bash
# Backup important configuration
tar -czf egress-backup-$(date +%Y%m%d).tar.gz config/ .env docker-compose.yml
```

## Updates

Update containers:
```bash
docker compose pull
docker compose up -d
```

## Network Architecture

### External Access (via Cloudflare Tunnel)
```
Internet → Cloudflare → Cloudflare Tunnel → Traefik → Internal Services
```

### Local Access (via Local DNS)
```
Local Clients → UDM-SE DNS → Traefik → Internal Services
```

1. **External Traffic**: Comes through Cloudflare's network for remote access
2. **Local Traffic**: Resolved by local DNS for faster internal access
3. **Cloudflare Tunnel**: Establishes secure connection for external users
4. **Traefik**: Routes traffic to appropriate internal services
5. **Internal Services**: Accessible via subdomains (e.g., jellyfin.no404.ca)

## Local DNS Configuration (UDM-SE)

For faster local access and reduced internet dependency, configure your UDM-SE to resolve `*.no404.ca` locally:

### Setup Local DNS Records
1. **Access UniFi Network Console**
2. **Navigate to**: Settings → Internet → Advanced → Custom DNS Records
3. **Add A records** for each service:
   ```
   traefik.no404.ca    → [server-IP]
   whoami.no404.ca     → [server-IP]
   jellyfin.no404.ca   → [server-IP]
   homepage.no404.ca   → [server-IP]
   ```

### Benefits of Local DNS
- **Faster Response**: No external DNS lookup required
- **Offline Access**: Services work even without internet
- **Reduced Bandwidth**: Traffic stays on your LAN
- **Better Performance**: Direct connection to your server

### SSL Certificates with Local DNS
Your Let's Encrypt certificates will still work for local access since they're issued for your actual domain. The only difference is that DNS resolution happens locally instead of through Cloudflare.

This setup provides enterprise-grade security and performance for both local and remote access to your self-hosted services!
