#!/bin/bash

# Docker Swarm Stack Deployment Script
# This script helps deploy the self-hosted service stacks in Docker Swarm mode

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker Swarm is initialized
check_swarm() {
    if ! docker info --format '{{.Swarm.LocalNodeState}}' | grep -q "active"; then
        print_error "Docker Swarm is not initialized. Please run 'docker swarm init' first."
        exit 1
    fi
    print_success "Docker Swarm is active"
}

# Function to create Traefik network if it doesn't exist
create_traefik_network() {
    if ! docker network ls --filter name=traefik | grep -q traefik; then
        print_status "Creating Traefik overlay network..."
        docker network create --driver overlay --attachable traefik
        print_success "Traefik network created"
    else
        print_success "Traefik network already exists"
    fi
}

# Function to check if .env file exists
check_env_file() {
    local stack_dir=$1
    if [[ ! -f "$stack_dir/.env" ]]; then
        print_warning ".env file not found in $stack_dir"
        print_status "Copying .env.example to .env..."
        cp "$stack_dir/.env.example" "$stack_dir/.env"
        print_warning "Please edit $stack_dir/.env with your configuration before deploying"
        return 1
    fi
    return 0
}

# Function to deploy a stack
deploy_stack() {
    local stack_name=$1
    local stack_dir=$2
    
    print_status "Deploying $stack_name stack..."
    
    if ! check_env_file "$stack_dir"; then
        print_error "Please configure $stack_dir/.env file first"
        return 1
    fi
    
    cd "$stack_dir"
    if docker stack deploy -c docker-compose.yml "$stack_name"; then
        print_success "$stack_name stack deployed successfully"
        cd ..
        return 0
    else
        print_error "Failed to deploy $stack_name stack"
        cd ..
        return 1
    fi
}

# Function to show stack status
show_stack_status() {
    local stack_name=$1
    print_status "Checking $stack_name stack status..."
    docker stack services "$stack_name" 2>/dev/null || {
        print_warning "$stack_name stack not found"
        return 1
    }
}

# Function to remove a stack
remove_stack() {
    local stack_name=$1
    print_status "Removing $stack_name stack..."
    if docker stack rm "$stack_name"; then
        print_success "$stack_name stack removed"
        # Wait for stack to be fully removed
        print_status "Waiting for stack removal to complete..."
        while docker stack ls --format "{{.Name}}" | grep -q "^$stack_name$"; do
            sleep 2
        done
        print_success "$stack_name stack fully removed"
    else
        print_error "Failed to remove $stack_name stack"
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND] [STACK]"
    echo ""
    echo "Commands:"
    echo "  deploy [stack]    Deploy a specific stack (egress, media, tools) or all"
    echo "  status [stack]    Show status of a specific stack or all stacks"
    echo "  remove [stack]    Remove a specific stack"
    echo "  logs [stack]      Show logs for all services in a stack"
    echo "  update [stack]    Update a specific stack"
    echo "  init             Initialize Docker Swarm and create networks"
    echo ""
    echo "Examples:"
    echo "  $0 init                    # Initialize swarm and networks"
    echo "  $0 deploy egress          # Deploy egress stack"
    echo "  $0 deploy all             # Deploy all stacks in order"
    echo "  $0 status                 # Show status of all stacks"
    echo "  $0 logs egress            # Show logs for egress stack"
    echo "  $0 remove media           # Remove media stack"
}

# Main script logic
case "${1:-}" in
    "init")
        print_status "Initializing Docker Swarm environment..."
        check_swarm
        create_traefik_network
        print_success "Docker Swarm environment ready!"
        ;;
        
    "deploy")
        check_swarm
        create_traefik_network
        
        case "${2:-}" in
            "egress")
                deploy_stack "egress" "egress-stack"
                ;;
            "media")
                deploy_stack "media" "media-stack"
                ;;
            "tools")
                deploy_stack "tools" "tools-stack"
                ;;
            "all"|"")
                print_status "Deploying all stacks in order..."
                deploy_stack "egress" "egress-stack" && \
                sleep 10 && \
                deploy_stack "media" "media-stack" && \
                deploy_stack "tools" "tools-stack"
                print_success "All stacks deployed!"
                ;;
            *)
                print_error "Unknown stack: $2"
                show_usage
                exit 1
                ;;
        esac
        ;;
        
    "status")
        case "${2:-}" in
            "egress")
                show_stack_status "egress"
                ;;
            "media")
                show_stack_status "media"
                ;;
            "tools")
                show_stack_status "tools"
                ;;
            ""|"all")
                print_status "Showing all stack status..."
                docker stack ls
                echo ""
                show_stack_status "egress"
                echo ""
                show_stack_status "media"
                echo ""
                show_stack_status "tools"
                ;;
            *)
                print_error "Unknown stack: $2"
                show_usage
                exit 1
                ;;
        esac
        ;;
        
    "remove")
        case "${2:-}" in
            "egress"|"media"|"tools")
                remove_stack "$2"
                ;;
            *)
                print_error "Please specify a stack to remove: egress, media, or tools"
                show_usage
                exit 1
                ;;
        esac
        ;;
        
    "logs")
        case "${2:-}" in
            "egress"|"media"|"tools")
                print_status "Showing logs for $2 stack..."
                docker stack services "$2" --format "{{.Name}}" | while read service; do
                    echo -e "\n${BLUE}=== Logs for $service ===${NC}"
                    docker service logs --tail 20 "$service" 2>/dev/null || true
                done
                ;;
            *)
                print_error "Please specify a stack: egress, media, or tools"
                show_usage
                exit 1
                ;;
        esac
        ;;
        
    "update")
        case "${2:-}" in
            "egress")
                deploy_stack "egress" "egress-stack"
                ;;
            "media")
                deploy_stack "media" "media-stack"
                ;;
            "tools")
                deploy_stack "tools" "tools-stack"
                ;;
            *)
                print_error "Please specify a stack to update: egress, media, or tools"
                show_usage
                exit 1
                ;;
        esac
        ;;
        
    "help"|"-h"|"--help")
        show_usage
        ;;
        
    *)
        print_error "Unknown command: ${1:-}"
        show_usage
        exit 1
        ;;
esac
