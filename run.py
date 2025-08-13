#!/usr/bin/env python3
"""
Route Craft 58 Backend - Startup Script
Simple script to run the FastAPI application with enhanced configuration
"""

import uvicorn
import os
import sys
import argparse
from pathlib import Path
from dotenv import load_dotenv

def load_environment():
    """Load environment variables from .env file"""
    # Look for .env file in current directory and parent directories
    env_paths = [
        Path.cwd() / ".env",
        Path.cwd().parent / ".env",
        Path(__file__).parent / ".env"
    ]
    
    env_loaded = False
    for env_path in env_paths:
        if env_path.exists():
            load_dotenv(env_path)
            print(f"✅ Loaded environment from: {env_path}")
            env_loaded = True
            break
    
    if not env_loaded:
        print("⚠️  No .env file found. Using default configuration.")
        print("   Create a .env file based on env.example for custom configuration.")

def validate_environment():
    """Validate required environment variables"""
    required_vars = [
        "SUPABASE_URL",
        "SUPABASE_KEY", 
        "SECRET_KEY"
    ]
    
    missing_vars = []
    for var in required_vars:
        if not os.getenv(var):
            missing_vars.append(var)
    
    if missing_vars:
        print(f"❌ Missing required environment variables: {', '.join(missing_vars)}")
        print("   Please check your .env file configuration.")
        return False
    
    return True

def get_configuration():
    """Get application configuration from environment"""
    config = {
        "host": os.getenv("HOST", "0.0.0.0"),
        "port": int(os.getenv("PORT", "8000")),
        "debug": os.getenv("DEBUG", "False").lower() == "true",
        "reload": os.getenv("RELOAD", "False").lower() == "true",
        "workers": int(os.getenv("WORKERS", "1")),
        "log_level": os.getenv("LOG_LEVEL", "info" if os.getenv("DEBUG", "False").lower() == "true" else "warning")
    }
    
    # Validate port range
    if not (1024 <= config["port"] <= 65535):
        print(f"⚠️  Port {config['port']} is outside valid range (1024-65535). Using default port 8000.")
        config["port"] = 8000
    
    return config

def print_startup_info(config):
    """Print startup information"""
    print("🚀 Route Craft 58 Backend")
    print("=" * 50)
    print(f"📍 Host: {config['host']}")
    print(f"🔌 Port: {config['port']}")
    print(f"🐛 Debug Mode: {config['debug']}")
    print(f"🔄 Auto-reload: {config['reload']}")
    print(f"👥 Workers: {config['workers']}")
    print(f"📝 Log Level: {config['log_level']}")
    print("-" * 50)
    print(f"📚 API Documentation: http://{config['host']}:{config['port']}/docs")
    print(f"🔍 ReDoc Documentation: http://{config['host']}:{config['port']}/redoc")
    print(f"🏥 Health Check: http://{config['host']}:{config['port']}/health")
    print(f"🌐 Root Endpoint: http://{config['host']}:{config['port']}/")
    print("=" * 50)

def check_dependencies():
    """Check if required dependencies are available"""
    try:
        import fastapi
        import uvicorn
        import supabase
        print("✅ All required dependencies are available")
        return True
    except ImportError as e:
        print(f"❌ Missing dependency: {e}")
        print("   Please run: pip install -r requirements.txt")
        return False

def main():
    """Main startup function"""
    parser = argparse.ArgumentParser(description="Route Craft 58 Backend Startup Script")
    parser.add_argument("--host", help="Host to bind to (overrides HOST env var)")
    parser.add_argument("--port", type=int, help="Port to bind to (overrides PORT env var)")
    parser.add_argument("--debug", action="store_true", help="Enable debug mode (overrides DEBUG env var)")
    parser.add_argument("--reload", action="store_true", help="Enable auto-reload (overrides RELOAD env var)")
    parser.add_argument("--workers", type=int, help="Number of workers (overrides WORKERS env var)")
    parser.add_argument("--check", action="store_true", help="Check configuration and dependencies only")
    
    args = parser.parse_args()
    
    print("🔧 Loading configuration...")
    
    # Load environment variables
    load_environment()
    
    # Check dependencies
    if not check_dependencies():
        sys.exit(1)
    
    # Validate environment
    if not validate_environment():
        print("\n❌ Environment validation failed. Please fix the issues above.")
        sys.exit(1)
    
    # Get configuration
    config = get_configuration()
    
    # Override with command line arguments
    if args.host:
        config["host"] = args.host
    if args.port:
        config["port"] = args.port
    if args.debug:
        config["debug"] = True
    if args.reload:
        config["reload"] = True
    if args.workers:
        config["workers"] = args.workers
    
    # Print startup information
    print_startup_info(config)
    
    # Exit if only checking configuration
    if args.check:
        print("✅ Configuration check completed successfully!")
        return
    
    try:
        print("🚀 Starting server...")
        print("   Press Ctrl+C to stop the server")
        print("-" * 50)
        
        # Start the server
        uvicorn.run(
            "main:app",
            host=config["host"],
            port=config["port"],
            reload=config["reload"],
            log_level=config["log_level"].lower(),
            workers=config["workers"] if config["workers"] > 1 else None
        )
        
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
    except Exception as e:
        print(f"\n❌ Error starting server: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main() 