# Route Craft 58 Backend

A FastAPI-based backend for the Route Craft transportation management system, providing comprehensive APIs for managing carriers, lanes, bids, and network analysis.

## 🚀 Features

- **User Management**: Authentication, authorization, and user role management
- **Carrier Management**: CRUD operations for transportation carriers
- **Lane Management**: Route and lane configuration
- **Bid Management**: Transportation bid creation and management
- **Bid Responses**: Carrier responses to transportation bids
- **Insurance Claims**: Claims management and tracking
- **Network Analysis**: Advanced analytics and route optimization
- **Dashboard**: Comprehensive reporting and insights
- **RESTful APIs**: Clean, documented API endpoints
- **Role-based Access Control**: Secure endpoint protection
- **Database Integration**: MySQL database integration

## 🛠️ Tech Stack

- **Framework**: FastAPI (Python 3.8+)
- **Database**: MySQL
- **Authentication**: JWT tokens with OAuth2
- **Validation**: Pydantic models
- **Documentation**: Auto-generated OpenAPI/Swagger docs
- **Server**: Uvicorn ASGI server

## 📋 Prerequisites

- Python 3.8 or higher
- pip (Python package installer)
- MySQL Server
- Git

## 🔧 Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd route-craft-58-backend
```

### 2. Create Virtual Environment

```bash
# On macOS/Linux
python3 -m venv venv
source venv/bin/activate

# On Windows
python -m venv venv
venv\Scripts\activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Environment Configuration

Copy the example environment file and configure your settings:

```bash
cp env.example .env
```

Edit `.env` file with your configuration:

```env
# MySQL Configuration
MYSQL_HOST=localhost
MYSQL_USER=routecraft_user
MYSQL_PASSWORD=routecraft_password
MYSQL_DATABASE=routecraft
MYSQL_PORT=3306

# Application Configuration
DEBUG=True
HOST=0.0.0.0
PORT=8000
SECRET_KEY=your_secret_key_here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# CORS Configuration
ALLOWED_ORIGINS=["http://localhost:3000", "http://localhost:8080"]
```

### 5. MySQL Setup

1. Install MySQL Server on your system
2. Create a new database and user:
```sql
CREATE DATABASE routecraft;
CREATE USER 'routecraft_user'@'localhost' IDENTIFIED BY 'routecraft_password';
GRANT ALL PRIVILEGES ON routecraft.* TO 'routecraft_user'@'localhost';
FLUSH PRIVILEGES;
```
3. Import the required database schema (see Database Schema section below)

## 🗄️ Database Schema

The application requires the following tables in your MySQL database:

### Users Table
```sql
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    role VARCHAR(50) DEFAULT 'user',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Carriers Table
```sql
CREATE TABLE carriers (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    carrier_type VARCHAR(100) NOT NULL,
    service_level VARCHAR(100) NOT NULL,
    operating_radius INT,
    rating DECIMAL(3,2),
    status VARCHAR(50) DEFAULT 'pending',
    contact_info JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Lanes Table
```sql
CREATE TABLE lanes (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    origin_city VARCHAR(255) NOT NULL,
    destination_city VARCHAR(255) NOT NULL,
    lane_type VARCHAR(100) NOT NULL,
    estimated_cost DECIMAL(10,2),
    estimated_duration INT,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Bids Table
```sql
CREATE TABLE bids (
    id VARCHAR(36) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    lane_id VARCHAR(36),
    estimated_cost DECIMAL(10,2),
    status VARCHAR(50) DEFAULT 'draft',
    created_by VARCHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (lane_id) REFERENCES lanes(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);
```

### Bid Responses Table
```sql
CREATE TABLE bid_responses (
    id VARCHAR(36) PRIMARY KEY,
    bid_id VARCHAR(36),
    carrier_id VARCHAR(36),
    proposed_cost DECIMAL(10,2),
    proposed_duration INT,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (bid_id) REFERENCES bids(id),
    FOREIGN KEY (carrier_id) REFERENCES carriers(id)
);
```

### Insurance Claims Table
```sql
CREATE TABLE insurance_claims (
    id VARCHAR(36) PRIMARY KEY,
    claim_number VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    amount DECIMAL(10,2),
    status VARCHAR(50) DEFAULT 'pending',
    filed_by VARCHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (filed_by) REFERENCES users(id)
);
```

### Network Analysis Table
```sql
CREATE TABLE network_analysis (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    analysis_type VARCHAR(100) NOT NULL,
    description TEXT,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    metrics JSON,
    filters JSON,
    parameters JSON,
    status VARCHAR(50) DEFAULT 'pending',
    created_by VARCHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id)
);
```

## 🚀 Running the Application

### Quick Start (Recommended)

#### On macOS/Linux:
```bash
# Make script executable (first time only)
chmod +x start.sh

# Start the application
./start.sh

# Or with options
./start.sh --debug --reload
./start.sh --port 8080
```

#### On Windows:
```cmd
# Start the application
start.bat

# Or with options
start.bat --debug --reload
start.bat --port 8080
```

### Manual Startup

#### Development Mode

```bash
# Activate virtual environment (if not already activated)
source venv/bin/activate  # On macOS/Linux
# or
venv\Scripts\activate     # On Windows

# Run the application
python main.py

# Or with options
python main.py --debug --reload
python main.py --port 8080 --host 127.0.0.1
```

#### Production Mode

```bash
# Using uvicorn directly
uvicorn main:app --host 0.0.0.0 --port 8000

# With reload for development
uvicorn main:app --host 0.0.0.0 --port 8000 --reload

# With multiple workers
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

### Startup Script Options

The startup scripts support the following options:

- `--help, -h`: Show help message
- `--check`: Check configuration and dependencies only
- `--debug`: Enable debug mode
- `--reload`: Enable auto-reload
- `--port PORT`: Specify port number
- `--host HOST`: Specify host address
- `--workers N`: Specify number of workers (production)

### Docker (Optional)

```bash
# Build the image
docker build -t route-craft-backend .

# Run the container
docker run -p 8000:8000 route-craft-backend
```

## 📚 API Documentation

Once the application is running, you can access:

- **Interactive API Docs**: http://localhost:8000/docs (Swagger UI)
- **ReDoc Documentation**: http://localhost:8000/redoc
- **OpenAPI Schema**: http://localhost:8000/openapi.json

## 🔐 Authentication

The API uses JWT-based authentication. To access protected endpoints:

1. **Register a user**: `POST /api/v1/register`
2. **Login**: `POST /api/v1/login`
3. **Use the access token** in the Authorization header: `Bearer <token>`

## 📁 Project Structure

```
route-craft-58-backend/
├── app/
│   ├── __init__.py
│   ├── api/
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── users.py
│   │   ├── carriers.py
│   │   ├── lanes.py
│   │   ├── bids.py
│   │   ├── bid_responses.py
│   │   ├── insurance_claims.py
│   │   ├── network_analysis.py
│   │   └── dashboard.py
│   ├── auth/
│   │   ├── __init__.py
│   │   └── dependencies.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── carrier.py
│   │   ├── lane.py
│   │   ├── bid.py
│   │   ├── bid_response.py
│   │   ├── insurance_claim.py
│   │   └── network_analysis.py
│   ├── config.py
│   └── database_mysql.py
├── main.py
├── requirements.txt
├── env.example
└── README.md
```

## 🧪 Testing

### Run Tests

```bash
# Install test dependencies
pip install pytest pytest-asyncio httpx

# Run tests
pytest

# Run with coverage
pytest --cov=app
```

### Test Endpoints

You can test the API endpoints using:

- **Swagger UI** (http://localhost:8000/docs)
- **Postman** or similar API testing tools
- **cURL** commands

Example cURL commands:

```bash
# Health check
curl http://localhost:8000/health

# Register user
curl -X POST "http://localhost:8000/api/v1/register" \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com","password":"password123","full_name":"Test User"}'

# Login
curl -X POST "http://localhost:8000/api/v1/login" \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "username=test@example.com&password=password123"
```

## 🔧 Configuration Options

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DEBUG` | Enable debug mode | `False` |
| `HOST` | Server host | `0.0.0.0` |
| `PORT` | Server port | `8000` |
| `SECRET_KEY` | JWT secret key | Required |
| `ALGORITHM` | JWT algorithm | `HS256` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | Token expiration time | `30` |
| `MYSQL_HOST` | MySQL server host | `localhost` |
| `MYSQL_USER` | MySQL username | Required |
| `MYSQL_PASSWORD` | MySQL password | Required |
| `MYSQL_DATABASE` | MySQL database name | Required |
| `MYSQL_PORT` | MySQL server port | `3306` |

## 🚨 Troubleshooting

### Common Issues

1. **Import Errors**: Ensure virtual environment is activated
2. **Database Connection**: Verify MySQL credentials in `.env`
3. **Port Already in Use**: Change port in `.env` or kill existing process
4. **Missing Dependencies**: Run `pip install -r requirements.txt`

### Logs

Check application logs for detailed error information:

```bash
# View logs in real-time
tail -f logs/app.log
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:

- Create an issue in the repository
- Contact the development team
- Check the API documentation at `/docs`

## 🔄 Updates

Keep your dependencies updated:

```bash
# Update all packages
pip install --upgrade -r requirements.txt

# Check for outdated packages
pip list --outdated
```

---

**Happy Coding! 🚀** 
>>>>>>> 80d68b2 (Add new folder with initial files)
