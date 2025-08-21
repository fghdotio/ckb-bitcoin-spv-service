#!/bin/bash

# SPV Service Quick Manager - Simplified interface
# Usage: ./spv.sh <command>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANAGER_SCRIPT="$SCRIPT_DIR/spv-manager.sh"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

case "$1" in
    # Start commands
    "up-testnet3"|"start-testnet3"|"testnet3-up")
        $MANAGER_SCRIPT up testnet3
        ;;
    "up-signet"|"start-signet"|"signet-up")
        $MANAGER_SCRIPT up signet
        ;;
    "up-all"|"start-all"|"all-up")
        $MANAGER_SCRIPT up all
        ;;
    
    # Stop commands
    "down-testnet3"|"stop-testnet3"|"testnet3-down")
        $MANAGER_SCRIPT down testnet3
        ;;
    "down-signet"|"stop-signet"|"signet-down")
        $MANAGER_SCRIPT down signet
        ;;
    "down-all"|"stop-all"|"all-down")
        $MANAGER_SCRIPT down all
        ;;
    
    # Status commands
    "status"|"ps"|"list")
        $MANAGER_SCRIPT status all
        ;;
    "status-testnet3"|"testnet3-status")
        $MANAGER_SCRIPT status testnet3
        ;;
    "status-signet"|"signet-status")
        $MANAGER_SCRIPT status signet
        ;;
    
    # Logs commands
    "logs-testnet3"|"testnet3-logs")
        $MANAGER_SCRIPT logs testnet3
        ;;
    "logs-signet"|"signet-logs")
        $MANAGER_SCRIPT logs signet
        ;;
    
    # Restart commands
    "restart-testnet3"|"testnet3-restart")
        print_info "Restarting testnet3 service..."
        $MANAGER_SCRIPT down testnet3
        sleep 2
        $MANAGER_SCRIPT up testnet3
        ;;
    "restart-signet"|"signet-restart")
        print_info "Restarting signet service..."
        $MANAGER_SCRIPT down signet
        sleep 2
        $MANAGER_SCRIPT up signet
        ;;
    "restart-all"|"all-restart")
        print_info "Restarting all services..."
        $MANAGER_SCRIPT down all
        sleep 2
        $MANAGER_SCRIPT up all
        ;;
    
    # Help and default
    "help"|"-h"|"--help"|"")
        echo "SPV Service Quick Manager"
        echo
        echo "Quick Commands:"
        echo "  Start Services:"
        echo "    ./spv.sh up-testnet3     # Start testnet3 service"
        echo "    ./spv.sh up-signet       # Start signet service"
        echo "    ./spv.sh up-all          # Start both services"
        echo
        echo "  Stop Services:"
        echo "    ./spv.sh down-testnet3   # Stop testnet3 service"
        echo "    ./spv.sh down-signet     # Stop signet service"
        echo "    ./spv.sh down-all        # Stop both services"
        echo
        echo "  Status & Logs:"
        echo "    ./spv.sh status          # Show all services status"
        echo "    ./spv.sh logs-testnet3   # Show testnet3 logs"
        echo "    ./spv.sh logs-signet     # Show signet logs"
        echo
        echo "  Restart Services:"
        echo "    ./spv.sh restart-testnet3  # Restart testnet3 service"
        echo "    ./spv.sh restart-signet    # Restart signet service"
        echo "    ./spv.sh restart-all       # Restart both services"
        echo
        echo "Aliases supported:"
        echo "  up-* | start-* | *-up"
        echo "  down-* | stop-* | *-down"
        echo "  status | ps | list"
        echo "  logs-* | *-logs"
        echo "  restart-* | *-restart"
        echo
        echo "For more detailed options, use: ./spv-manager.sh"
        ;;
    
    *)
        echo "Unknown command: $1"
        echo "Use './spv.sh help' to see available commands"
        exit 1
        ;;
esac