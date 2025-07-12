#!/bin/bash

# Script to extract API keys and configuration information from media stack containers
# Run this after the containers have been started and initialized

OUTPUT_FILE="api-keys-and-config.md"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "# Media Stack API Keys and Configuration" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "**Generated on:** $TIMESTAMP" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "This file contains all the API keys and important configuration information extracted from the running Docker containers." >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Function to extract XML value
extract_xml_value() {
    local file="$1"
    local tag="$2"
    if [ -f "$file" ]; then
        grep -o "<$tag>.*</$tag>" "$file" | sed "s/<$tag>\(.*\)<\/$tag>/\1/"
    else
        echo "N/A (file not found)"
    fi
}

# Function to extract JSON value
extract_json_value() {
    local file="$1"
    local key="$2"
    if [ -f "$file" ] && command -v jq >/dev/null 2>&1; then
        jq -r ".$key // \"N/A\"" "$file" 2>/dev/null
    elif [ -f "$file" ]; then
        grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$file" | sed 's/.*"\([^"]*\)"/\1/' | head -1
    else
        echo "N/A (file not found)"
    fi
}

echo "## API Keys and Basic Configuration" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Prowlarr
echo "### Prowlarr" >> "$OUTPUT_FILE"
PROWLARR_CONFIG="./config/prowlarr/config.xml"
if [ -f "$PROWLARR_CONFIG" ]; then
    API_KEY=$(extract_xml_value "$PROWLARR_CONFIG" "ApiKey")
    PORT=$(extract_xml_value "$PROWLARR_CONFIG" "Port")
    SSL_PORT=$(extract_xml_value "$PROWLARR_CONFIG" "SslPort")
    AUTH_METHOD=$(extract_xml_value "$PROWLARR_CONFIG" "AuthenticationMethod")
    
    echo "- **API Key:** \`$API_KEY\`" >> "$OUTPUT_FILE"
    echo "- **Port:** $PORT" >> "$OUTPUT_FILE"
    echo "- **SSL Port:** $SSL_PORT" >> "$OUTPUT_FILE"
    echo "- **Web UI:** http://localhost:$PORT" >> "$OUTPUT_FILE"
    echo "- **Authentication Method:** $AUTH_METHOD" >> "$OUTPUT_FILE"
else
    echo "- **Status:** Configuration not found (container may not be initialized)" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# Sonarr
echo "### Sonarr" >> "$OUTPUT_FILE"
SONARR_CONFIG="./config/sonarr/config.xml"
if [ -f "$SONARR_CONFIG" ]; then
    API_KEY=$(extract_xml_value "$SONARR_CONFIG" "ApiKey")
    PORT=$(extract_xml_value "$SONARR_CONFIG" "Port")
    SSL_PORT=$(extract_xml_value "$SONARR_CONFIG" "SslPort")
    AUTH_METHOD=$(extract_xml_value "$SONARR_CONFIG" "AuthenticationMethod")
    
    echo "- **API Key:** \`$API_KEY\`" >> "$OUTPUT_FILE"
    echo "- **Port:** $PORT" >> "$OUTPUT_FILE"
    echo "- **SSL Port:** $SSL_PORT" >> "$OUTPUT_FILE"
    echo "- **Web UI:** http://localhost:$PORT" >> "$OUTPUT_FILE"
    echo "- **Authentication Method:** $AUTH_METHOD" >> "$OUTPUT_FILE"
else
    echo "- **Status:** Configuration not found (container may not be initialized)" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# Radarr
echo "### Radarr" >> "$OUTPUT_FILE"
RADARR_CONFIG="./config/radarr/config.xml"
if [ -f "$RADARR_CONFIG" ]; then
    API_KEY=$(extract_xml_value "$RADARR_CONFIG" "ApiKey")
    PORT=$(extract_xml_value "$RADARR_CONFIG" "Port")
    SSL_PORT=$(extract_xml_value "$RADARR_CONFIG" "SslPort")
    AUTH_METHOD=$(extract_xml_value "$RADARR_CONFIG" "AuthenticationMethod")
    
    echo "- **API Key:** \`$API_KEY\`" >> "$OUTPUT_FILE"
    echo "- **Port:** $PORT" >> "$OUTPUT_FILE"
    echo "- **SSL Port:** $SSL_PORT" >> "$OUTPUT_FILE"
    echo "- **Web UI:** http://localhost:$PORT" >> "$OUTPUT_FILE"
    echo "- **Authentication Method:** $AUTH_METHOD" >> "$OUTPUT_FILE"
else
    echo "- **Status:** Configuration not found (container may not be initialized)" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# Lidarr
echo "### Lidarr" >> "$OUTPUT_FILE"
LIDARR_CONFIG="./config/lidarr/config.xml"
if [ -f "$LIDARR_CONFIG" ]; then
    API_KEY=$(extract_xml_value "$LIDARR_CONFIG" "ApiKey")
    PORT=$(extract_xml_value "$LIDARR_CONFIG" "Port")
    SSL_PORT=$(extract_xml_value "$LIDARR_CONFIG" "SslPort")
    AUTH_METHOD=$(extract_xml_value "$LIDARR_CONFIG" "AuthenticationMethod")
    
    echo "- **API Key:** \`$API_KEY\`" >> "$OUTPUT_FILE"
    echo "- **Port:** $PORT" >> "$OUTPUT_FILE"
    echo "- **SSL Port:** $SSL_PORT" >> "$OUTPUT_FILE"
    echo "- **Web UI:** http://localhost:$PORT" >> "$OUTPUT_FILE"
    echo "- **Authentication Method:** $AUTH_METHOD" >> "$OUTPUT_FILE"
else
    echo "- **Status:** Configuration not found (container may not be initialized)" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# SABnzbd
echo "### SABnzbd" >> "$OUTPUT_FILE"
SABNZBD_CONFIG="./config/sabnzbd/sabnzbd.ini"
if [ -f "$SABNZBD_CONFIG" ]; then
    API_KEY=$(grep -E "^api_key\s*=" "$SABNZBD_CONFIG" 2>/dev/null | cut -d'=' -f2 | tr -d ' ' || echo "N/A")
    NZB_KEY=$(grep -E "^nzb_key\s*=" "$SABNZBD_CONFIG" 2>/dev/null | cut -d'=' -f2 | tr -d ' ' || echo "N/A")
    PORT=$(grep -E "^port\s*=" "$SABNZBD_CONFIG" 2>/dev/null | cut -d'=' -f2 | tr -d ' ' || echo "8080")
    
    echo "- **API Key:** \`$API_KEY\`" >> "$OUTPUT_FILE"
    echo "- **NZB Key:** \`$NZB_KEY\`" >> "$OUTPUT_FILE"
    echo "- **Port:** $PORT" >> "$OUTPUT_FILE"
    echo "- **Web UI:** http://localhost:$PORT" >> "$OUTPUT_FILE"
else
    echo "- **Status:** Configuration not found (container may not be initialized)" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# Overseerr
echo "### Overseerr" >> "$OUTPUT_FILE"
OVERSEERR_CONFIG="./config/overseerr/settings.json"
if [ -f "$OVERSEERR_CONFIG" ]; then
    API_KEY=$(extract_json_value "$OVERSEERR_CONFIG" "main.apiKey")
    CLIENT_ID=$(extract_json_value "$OVERSEERR_CONFIG" "clientId")
    INITIALIZED=$(extract_json_value "$OVERSEERR_CONFIG" "public.initialized")
    
    echo "- **API Key:** \`$API_KEY\`" >> "$OUTPUT_FILE"
    echo "- **Client ID:** \`$CLIENT_ID\`" >> "$OUTPUT_FILE"
    echo "- **Port:** 5055" >> "$OUTPUT_FILE"
    echo "- **Web UI:** http://localhost:5055" >> "$OUTPUT_FILE"
    echo "- **Initialized:** $INITIALIZED" >> "$OUTPUT_FILE"
else
    echo "- **Status:** Configuration not found (container may not be initialized)" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# Deluge
echo "### Deluge" >> "$OUTPUT_FILE"
DELUGE_AUTH="./config/deluge/auth"
DELUGE_WEB="./config/deluge/web.conf"
if [ -f "$DELUGE_AUTH" ]; then
    AUTH_HASH=$(cut -d':' -f2 "$DELUGE_AUTH" 2>/dev/null || echo "N/A")
    echo "- **Web UI:** http://localhost:8112" >> "$OUTPUT_FILE"
    echo "- **Default Password:** deluge" >> "$OUTPUT_FILE"
    echo "- **Auth Hash:** \`$AUTH_HASH\`" >> "$OUTPUT_FILE"
    
    if [ -f "$DELUGE_WEB" ]; then
        FIRST_LOGIN=$(extract_json_value "$DELUGE_WEB" "first_login")
        echo "- **First Login:** $FIRST_LOGIN" >> "$OUTPUT_FILE"
    fi
else
    echo "- **Status:** Configuration not found (container may not be initialized)" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# Plex
echo "### Plex" >> "$OUTPUT_FILE"
PLEX_CONFIG="./config/plex/Library/Application Support/Plex Media Server/Preferences.xml"
if [ -f "$PLEX_CONFIG" ]; then
    FRIENDLY_NAME=$(extract_xml_value "$PLEX_CONFIG" "FriendlyName")
    MACHINE_ID=$(extract_xml_value "$PLEX_CONFIG" "MachineIdentifier")
    SERVER_TOKEN=$(extract_xml_value "$PLEX_CONFIG" "PlexOnlineToken")
    
    echo "- **Web UI:** http://localhost:32400/web" >> "$OUTPUT_FILE"
    echo "- **Port:** 32400" >> "$OUTPUT_FILE"
    echo "- **Server Name:** ${FRIENDLY_NAME:-Not configured}" >> "$OUTPUT_FILE"
    echo "- **Machine ID:** \`${MACHINE_ID:-N/A}\`" >> "$OUTPUT_FILE"
    echo "- **Server Token:** \`${SERVER_TOKEN:-N/A}\`" >> "$OUTPUT_FILE"
else
    echo "- **Status:** Configuration not found (container may not be initialized)" >> "$OUTPUT_FILE"
    echo "- **Web UI:** http://localhost:32400/web" >> "$OUTPUT_FILE"
    echo "- **Port:** 32400" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# Container Communication
echo "## Container Network Communication" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "All services are on the \`media\` network and can communicate using container names:" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "- **Prowlarr:** \`prowlarr:9696\`" >> "$OUTPUT_FILE"
echo "- **Sonarr:** \`sonarr:8989\`" >> "$OUTPUT_FILE"
echo "- **Radarr:** \`radarr:7878\`" >> "$OUTPUT_FILE"
echo "- **Lidarr:** \`lidarr:8686\`" >> "$OUTPUT_FILE"
echo "- **SABnzbd:** \`sabnzbd:8080\`" >> "$OUTPUT_FILE"
echo "- **Deluge:** \`deluge:8112\`" >> "$OUTPUT_FILE"
echo "- **Overseerr:** \`overseerr:5055\`" >> "$OUTPUT_FILE"
echo "- **Plex:** \`plex:32400\`" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Directory Structure
echo "## Directory Structure" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "\`\`\`" >> "$OUTPUT_FILE"
echo "docker/media-stack/" >> "$OUTPUT_FILE"
echo "├── docker-compose.yml" >> "$OUTPUT_FILE"
echo "├── .env" >> "$OUTPUT_FILE"
echo "├── downloads/" >> "$OUTPUT_FILE"
echo "│   ├── incomplete/" >> "$OUTPUT_FILE"
echo "│   └── sab/" >> "$OUTPUT_FILE"
echo "├── media/" >> "$OUTPUT_FILE"
echo "│   ├── tv/" >> "$OUTPUT_FILE"
echo "│   ├── movies/" >> "$OUTPUT_FILE"
echo "│   └── music/" >> "$OUTPUT_FILE"
echo "└── config/" >> "$OUTPUT_FILE"
echo "    ├── prowlarr/" >> "$OUTPUT_FILE"
echo "    ├── sonarr/" >> "$OUTPUT_FILE"
echo "    ├── radarr/" >> "$OUTPUT_FILE"
echo "    ├── lidarr/" >> "$OUTPUT_FILE"
echo "    ├── sabnzbd/" >> "$OUTPUT_FILE"
echo "    ├── deluge/" >> "$OUTPUT_FILE"
echo "    ├── overseerr/" >> "$OUTPUT_FILE"
echo "    └── plex/" >> "$OUTPUT_FILE"
echo "\`\`\`" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Setup recommendations
echo "## Setup Recommendations" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "1. **Change Deluge password** from default \"deluge\"" >> "$OUTPUT_FILE"
echo "2. **Complete Plex setup wizard** at http://localhost:32400/web" >> "$OUTPUT_FILE"
echo "3. **Initialize Overseerr** at http://localhost:5055" >> "$OUTPUT_FILE"
echo "4. **Configure Prowlarr indexers** first, then connect to *arr applications" >> "$OUTPUT_FILE"
echo "5. **Set up download clients** (SABnzbd and/or Deluge) in each *arr application" >> "$OUTPUT_FILE"
echo "6. **Configure Overseerr** to connect to Plex and *arr applications" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Backup information
echo "## Important Files to Backup" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "- \`config/*/\` directories contain all application settings and databases" >> "$OUTPUT_FILE"
echo "- \`media/\` directories contain your actual media files" >> "$OUTPUT_FILE"
echo "- \`downloads/\` directory contains downloaded content" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "## Security Notes" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "- All API keys are auto-generated and unique to this installation" >> "$OUTPUT_FILE"
echo "- Change default passwords immediately after setup" >> "$OUTPUT_FILE"
echo "- Consider enabling HTTPS for production use" >> "$OUTPUT_FILE"
echo "- Review firewall settings if accessing remotely" >> "$OUTPUT_FILE"
echo "- These API keys provide full administrative access to their respective services" >> "$OUTPUT_FILE"

echo ""
echo "API information extraction complete!"
echo "Results saved to: $OUTPUT_FILE"
echo ""
echo "Note: Some services may show 'N/A' if containers haven't been fully initialized yet."
echo "Run this script again after all containers have started and completed their initial setup."
