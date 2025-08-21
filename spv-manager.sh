#!/bin/bash

# SPV Service Manager Script
# Usage: ./spv-manager.sh <action> <network>
# Actions: up, down, status, logs
# Networks: testnet3, signet, all

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TESTNET3_COMPOSE_FILE="docker-compose-testnet3.yml"
SIGNET_COMPOSE_FILE="docker-compose-signet.yml"
TESTNET3_PROJECT_NAME="spv-testnet3"
SIGNET_PROJECT_NAME="spv-signet"

# Function to print colored output
print_info() {
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

# Function to check if compose file exists
check_compose_file() {
    local file=$1
    if [[ ! -f "$file" ]]; then
        print_error "Docker compose file '$file' not found!"
        exit 1
    fi
}

# Function to start service
start_service() {
    local network=$1
    local compose_file=""
    local project_name=""
    local port=""
    
    case $network in
        testnet3)
            compose_file=$TESTNET3_COMPOSE_FILE
            project_name=$TESTNET3_PROJECT_NAME
            port="8888"
            ;;
        signet)
            compose_file=$SIGNET_COMPOSE_FILE
            project_name=$SIGNET_PROJECT_NAME
            port="8400"  # Use different port to avoid conflict
            ;;
        *)
            print_error "Unknown network: $network"
            exit 1
            ;;
    esac
    
    check_compose_file "$compose_file"
    
    print_info "Starting $network SPV service..."
    LISTEN_PORT=$port docker compose -f "$compose_file" -p "$project_name" up -d
    
    if [[ $? -eq 0 ]]; then
        print_success "$network SPV service started successfully on port $port"
    else
        print_error "Failed to start $network SPV service"
        exit 1
    fi
}

# Function to stop service
stop_service() {
    local network=$1
    local compose_file=""
    local project_name=""
    
    case $network in
        testnet3)
            compose_file=$TESTNET3_COMPOSE_FILE
            project_name=$TESTNET3_PROJECT_NAME
            ;;
        signet)
            compose_file=$SIGNET_COMPOSE_FILE
            project_name=$SIGNET_PROJECT_NAME
            ;;
        *)
            print_error "Unknown network: $network"
            exit 1
            ;;
    esac
    
    check_compose_file "$compose_file"
    
    print_info "Stopping $network SPV service..."
    docker compose -f "$compose_file" -p "$project_name" down
    
    if [[ $? -eq 0 ]]; then
        print_success "$network SPV service stopped successfully"
    else
        print_error "Failed to stop $network SPV service"
        exit 1
    fi
}

# Function to show service status
show_status() {
    local network=$1
    
    if [[ "$network" == "all" ]]; then
        print_info "Showing status for all SPV services..."
        echo
        echo -e "${YELLOW}=== TESTNET3 SPV SERVICE ===${NC}"
        docker compose -f "$TESTNET3_COMPOSE_FILE" -p "$TESTNET3_PROJECT_NAME" ps
        echo
        echo -e "${YELLOW}=== SIGNET SPV SERVICE ===${NC}"
        docker compose -f "$SIGNET_COMPOSE_FILE" -p "$SIGNET_PROJECT_NAME" ps
        return
    fi
    
    local compose_file=""
    local project_name=""
    
    case $network in
        testnet3)
            compose_file=$TESTNET3_COMPOSE_FILE
            project_name=$TESTNET3_PROJECT_NAME
            ;;
        signet)
            compose_file=$SIGNET_COMPOSE_FILE
            project_name=$SIGNET_PROJECT_NAME
            ;;
        *)
            print_error "Unknown network: $network"
            exit 1
            ;;
    esac
    
    check_compose_file "$compose_file"
    
    print_info "Showing status for $network SPV service..."
    docker compose -f "$compose_file" -p "$project_name" ps
}

# Function to show logs
show_logs() {
    local network=$1
    local compose_file=""
    local project_name=""
    
    case $network in
        testnet3)
            compose_file=$TESTNET3_COMPOSE_FILE
            project_name=$TESTNET3_PROJECT_NAME
            ;;
        signet)
            compose_file=$SIGNET_COMPOSE_FILE
            project_name=$SIGNET_PROJECT_NAME
            ;;
        *)
            print_error "Unknown network: $network"
            exit 1
            ;;
    esac
    
    check_compose_file "$compose_file"
    
    print_info "Showing logs for $network SPV service (Press Ctrl+C to exit)..."
    docker compose -f "$compose_file" -p "$project_name" logs -f
}

# Function to show usage
show_usage() {
    echo "SPV Service Manager"
    echo
    echo "Usage: $0 <action> <network>"
    echo
    echo "Actions:"
    echo "  up       - Start the SPV service"
    echo "  down     - Stop the SPV service"
    echo "  status   - Show service status"
    echo "  logs     - Show service logs (follow mode)"
    echo
    echo "Networks:"
    echo "  testnet3 - CKB Testnet3 SPV service (port 8888)"
    echo "  signet   - Bitcoin Signet SPV service (port 8889)"
    echo "  all      - All services (only for status action)"
    echo
    echo "Examples:"
    echo "  $0 up testnet3      # Start testnet3 service"
    echo "  $0 down signet      # Stop signet service"
    echo "  $0 status all       # Show status of all services"
    echo "  $0 logs testnet3    # Show testnet3 logs"
    echo
    echo "Special commands:"
    echo "  $0 up all           # Start both services"
    echo "  $0 down all         # Stop both services"
}

# Main script logic
main() {
    local action=$1
    local network=$2
    
    # Check if docker and docker compose are available
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not available"
        exit 1
    fi
    
    # Validate arguments
    if [[ -z "$action" ]] || [[ -z "$network" ]]; then
        show_usage
        exit 1
    fi
    
    case $action in
        up)
            if [[ "$network" == "all" ]]; then
                start_service "testnet3"
                echo
                start_service "signet"
                echo
                print_success "Both SPV services started successfully"
                echo
                show_status "all"
            else
                start_service "$network"
            fi
            ;;
        down)
            if [[ "$network" == "all" ]]; then
                stop_service "testnet3"
                echo
                stop_service "signet"
                echo
                print_success "Both SPV services stopped successfully"
            else
                stop_service "$network"
            fi
            ;;
        status)
            show_status "$network"
            ;;
        logs)
            if [[ "$network" == "all" ]]; then
                print_error "Cannot show logs for 'all'. Please specify 'testnet3' or 'signet'"
                exit 1
            fi
            show_logs "$network"
            ;;
        *)
            print_error "Unknown action: $action"
            echo
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"