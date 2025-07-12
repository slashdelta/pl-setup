# pl-setup: Self-Hosted Service Stacks

This repository provides a complete set of Docker and Docker Swarm stacks for running popular self-hosted services. It is designed to be modular, secure, and easy to deploy for both home labs and small businesses.

---

## 📁 Folder Overview

- **docker/**  
  Standard Docker Compose stacks for local or single-node setups.

- **docker-swarm/**  
  Docker Swarm stacks for multi-node, high-availability deployments.

- **egress-stack/**  
  Foundation stack for secure external access, reverse proxy, and SSL.

- **media-stack/**  
  Media management and automation (Jellyfin, Sonarr, Radarr, etc.).

- **tools-stack/**  
  Productivity and development tools (Gitea, Nextcloud, Portainer, etc.).

---

## ⚡ Prerequisites

- **Docker**  
  [Install Docker](https://docs.docker.com/get-docker/) on your host(s).

- **Docker Compose**  
  [Install Docker Compose](https://docs.docker.com/compose/install/) for local stacks.

- **Docker Swarm**  
  (Optional) [Initialize Docker Swarm](https://docs.docker.com/engine/swarm/) for multi-node orchestration:
  ```bash
  docker swarm init
  ```

- **Domain Name**  
  For external access and SSL certificates.

- **Cloudflare Account**  
  For secure tunnels and DNS-based SSL certificate automation.

---

## 🚀 Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/slashdelta/pl-setup.git
   cd pl-setup
   ```

2. **Choose your deployment method**
   - For local/single-node: use the `docker/` stacks.
   - For multi-node/high-availability: use the `docker-swarm/` stacks.

3. **Configure environment variables**
   ```bash
   cp [stack]/.env.example [stack]/.env
   nano [stack]/.env
   ```

4. **Deploy your stack**
   - **Docker Compose:**
     ```bash
     cd docker/[stack]
     docker-compose up -d
     ```
   - **Docker Swarm:**
     ```bash
     cd docker-swarm/[stack]
     docker stack deploy -c docker-compose.yml [stack]
     ```

---

## 📚 Documentation

- Each stack folder contains its own `README.md` with service details and configuration instructions.
- See [docker/README.md](docker/README.md) and [docker-swarm/README.md](docker-swarm/README.md) for advanced usage, scaling, and troubleshooting.

---

## 🛡️ Security & Best Practices

- Change all default passwords before deploying.
- Use HTTPS and Cloudflare tunnels for secure remote access.
- Regularly backup your data and configuration.

---

## 🧑‍💻 Support

- Issues and feature requests: [GitHub Issues](https://github.com/slashdelta/pl-setup/issues)
- Community: [Discussions](https://github.com/slashdelta/pl-setup/discussions)

---

This project makes it easy to run your own cloud, media server, and development tools with modern container orchestration. Happy self-hosting!
