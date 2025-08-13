# RouteCraft Backend Setup Instructions

## 1. Database Setup

### Option A: Using MySQL Command Line (Recommended)
1. Install MySQL Server on your system
2. Create a new database and user:
```sql
CREATE DATABASE routecraft;
CREATE USER 'routecraft_user'@'localhost' IDENTIFIED BY 'routecraft_password';
GRANT ALL PRIVILEGES ON routecraft.* TO 'routecraft_user'@'localhost';
FLUSH PRIVILEGES;
```
3. Import the database schema:
```bash
mysql -u routecraft_user -p routecraft < database_schema.sql
```

### Option B: Using the setup script
```bash
cd route-craft-58-backend
source venv/bin/activate
python setup_database.py
```

## 2. Environment Configuration

Make sure your `.env` file has the correct MySQL credentials:

```bash
# MySQL Configuration
MYSQL_HOST=localhost
MYSQL_USER=routecraft_user
MYSQL_PASSWORD=routecraft_password
MYSQL_DATABASE=routecraft
MYSQL_PORT=3306
```

## 3. Start the Backend

```bash
cd route-craft-58-backend
source venv/bin/activate
python main.py
```

The server will start on `http://localhost:8000`

## 4. Test the API

Once the backend is running, test these endpoints:

- Health check: `http://localhost:8000/health`
- Dashboard overview: `http://localhost:8000/api/v1/dashboard-dev/overview`
- Recent activity: `http://localhost:8000/api/v1/dashboard-dev/recent-activity`

## 5. Frontend Integration

The frontend should now be able to fetch data from these endpoints:
- `GET /api/v1/dashboard-dev/overview` - Dashboard statistics
- `GET /api/v1/dashboard-dev/recent-activity` - Recent bid activities
- `GET /api/v1/bids` - List all bids
- `GET /api/v1/carriers` - List all carriers
- `GET /api/v1/lanes` - List all lanes

## Troubleshooting

### Common Issues:

1. **Database connection errors**: Check your MySQL credentials in `.env`
2. **Table not found errors**: Run the database schema SQL first
3. **CORS errors**: The backend is configured to allow all origins for development
4. **Authentication errors**: The current setup allows public access for development

### Logs:
Check the terminal where you started the backend for any error messages.

## Next Steps

After successful setup:
1. Test all API endpoints
2. Integrate with your frontend dashboard
3. Add proper authentication and authorization
4. Configure production environment variables 