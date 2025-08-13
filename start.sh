#!/bin/bash

# Route Craft 58 Backend - Startup Script
# Simple shell script to run the FastAPI application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Check if Python is available
check_python() {
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed or not in PATH"
        exit 1
    fi
    
    python_version=$(python3 --version 2>&1 | awk '{print $2}')
    print_status "Python version: $python_version"
}

# Check if virtual environment exists
check_venv() {
    if [ ! -d "venv" ]; then
        print_warning "Virtual environment not found. Creating one..."
        python3 -m venv venv
        print_status "Virtual environment created"
    fi
}

# Activate virtual environment
activate_venv() {
    print_status "Activating virtual environment..."
    source venv/bin/activate
    print_status "Virtual environment activated"
}

# Install dependencies
install_deps() {
    print_status "Checking dependencies..."
    if ! pip show fastapi &> /dev/null; then
        print_warning "Dependencies not installed. Installing..."
        pip install -r requirements.txt
        print_status "Dependencies installed"
    else
        print_status "Dependencies already installed"
    fi
}

# Check environment file
check_env() {
    if [ ! -f ".env" ]; then
        if [ -f "env.example" ]; then
            print_warning ".env file not found. Creating from env.example..."
            # Create a clean .env file from env.example
            cat env.example | grep -v "SUPABASE\|DATABASE_URL" > .env
            # Add MySQL configuration
            cat >> .env << 'EOF'

# MySQL Configuration
MYSQL_HOST=localhost
MYSQL_USER=routecraft_user
MYSQL_PASSWORD=routecraft_password
MYSQL_DATABASE=routecraft
MYSQL_PORT=3306
EOF
            print_warning "Created .env file with MySQL configuration"
            print_warning "Please edit .env file with your actual MySQL credentials before running the application"
            print_warning "Make sure your MySQL server is running and accessible"
            exit 1
        else
            print_error "No .env file or env.example found"
            exit 1
        fi
    fi
}

# Check MySQL connection (optional)
check_mysql() {
    print_status "Checking MySQL connection..."
    if command -v mysql &> /dev/null; then
        # Safely source .env file and extract MySQL config
        if [ -f ".env" ]; then
            # Extract MySQL config safely without sourcing the entire file
            MYSQL_HOST=$(grep "^MYSQL_HOST=" .env | cut -d'=' -f2 | tr -d '"' | tr -d "'" 2>/dev/null || echo "")
            MYSQL_USER=$(grep "^MYSQL_USER=" .env | cut -d'=' -f2 | tr -d '"' | tr -d "'" 2>/dev/null || echo "")
            MYSQL_PASSWORD=$(grep "^MYSQL_PASSWORD=" .env | cut -d'=' -f2 | tr -d '"' | tr -d "'" 2>/dev/null || echo "")
            MYSQL_DATABASE=$(grep "^MYSQL_DATABASE=" .env | cut -d'=' -f2 | tr -d '"' | tr -d "'" 2>/dev/null || echo "")
            
            if [ -n "$MYSQL_HOST" ] && [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ] && [ -n "$MYSQL_DATABASE" ]; then
                if mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "USE $MYSQL_DATABASE;" 2>/dev/null; then
                    print_status "MySQL connection successful"
                else
                    print_warning "MySQL connection failed. Please check your database configuration."
                    print_warning "Make sure MySQL server is running and credentials are correct."
                fi
            else
                print_warning "MySQL configuration incomplete in .env file"
            fi
        fi
    else
        print_warning "MySQL client not found. Skipping connection check."
    fi
}

# Main function
main() {
    print_header "🚀 Route Craft 58 Backend Startup (MySQL)"
    echo "=================================================="
    
    # Check prerequisites
    check_python
    check_venv
    check_env
    
    # Activate virtual environment
    activate_venv
    
    # Install dependencies
    install_deps
    
    # Optional MySQL check
    check_mysql
    
    echo ""
    print_status "Starting the application..."
    echo "=================================================="
    
    # Run the application
    python main.py "$@"
}

# Handle script arguments
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --help, -h     Show this help message"
    echo "  --check         Check configuration only"
    echo "  --debug         Enable debug mode"
    echo "  --reload        Enable auto-reload"
    echo "  --port PORT     Specify port number"
    echo "  --host HOST     Specify host address"
    echo ""
    echo "Examples:"
    echo "  $0                    # Start with default settings"
    echo "  $0 --debug --reload   # Start in debug mode with auto-reload"
    echo "  $0 --port 8080        # Start on port 8080"
    echo "  $0 --check            # Check configuration only"
    echo ""
    echo "Note: This application now uses MySQL instead of Supabase"
    exit 0
fi

# Run main function with all arguments
main "$@" 