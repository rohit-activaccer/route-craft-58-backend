# RouteCraft Database Setup

This folder contains all SQL schema files and Python scripts for setting up the complete RouteCraft database in MySQL.

## 📁 File Organization

### 🔧 Core Setup Files
- `setup_mysql.sql` - Basic database setup (users, carriers, lanes, bids, etc.)
- `setup_database.py` - Python script to run all database setup
- `setup_env.py` - Environment setup script

### 📊 Schema Files (SQL)
- `database_schema.sql` - Main database schema (Supabase/PostgreSQL format)
- `accessorial_definitions_master_schema.sql` - Accessorial charges definitions
- `carrier_historical_metrics_schema.sql` - Carrier performance metrics
- `contract_table_schema.sql` - Transportation contracts
- `equipment_types_master_schema.sql` - Equipment types and specifications
- `modes_master_schema.sql` - Transportation modes
- `routing_guide_schema.sql` - Routing guides and carrier selection
- `seasons_master_schema.sql` - Seasonal variations and pricing
- `service_levels_master_schema.sql` - Service level definitions

### 🐍 Python Creation Scripts
- `create_accessorial_definitions_master_table.py` - Creates accessorial charges table
- `create_accessorial_table_simple.py` - Simple accessorial table
- `create_bids_master_table.py` - Creates bids master table
- `create_bids_master_table_fixed.py` - Fixed version of bids master table
- `create_carrier_historical_metrics_table.py` - Creates carrier metrics table
- `create_carrier_master_table.py` - Creates carrier master table
- `create_commodities_master_table.py` - Creates commodities table
- `create_contract_table.py` - Creates contract table
- `create_equipment_types_master_table.py` - Creates equipment types table
- `create_fuel_surcharge_table.py` - Creates fuel surcharge table
- `create_lanes_master_table.py` - Creates lanes master table
- `create_locations_master_table.py` - Creates locations master table
- `create_modes_master_table.py` - Creates modes master table
- `create_routing_guide_table.py` - Creates routing guide table
- `create_seasons_master_table.py` - Creates seasons master table
- `create_service_levels_master_table.py` - Creates service levels table
- `create_targeted_carriers_table.py` - Creates targeted carriers table
- `create_table_direct.py` - Direct table creation utility

### 🔧 Utility Scripts
- `debug_service_levels.py` - Debug service levels table
- `fix_service_levels_table.py` - Fix service levels table issues

## 🚀 Quick Setup

### Option 1: Run Complete Setup (Recommended)
```bash
cd sql
python setup_database.py
```

### Option 2: Manual Setup
```bash
# 1. Create database and basic tables
mysql -u routecraft_user -proutecraft_password < setup_mysql.sql

# 2. Run individual schema files
mysql -u routecraft_user -proutecraft_password routecraft < accessorial_definitions_master_schema.sql
mysql -u routecraft_user -proutecraft_password routecraft < carrier_historical_metrics_schema.sql
mysql -u routecraft_user -proutecraft_password routecraft < contract_table_schema.sql
mysql -u routecraft_user -proutecraft_password routecraft < equipment_types_master_schema.sql
mysql -u routecraft_user -proutecraft_password routecraft < modes_master_schema.sql
mysql -u routecraft_user -proutecraft_password routecraft < routing_guide_schema.sql
mysql -u routecraft_user -proutecraft_password routecraft < seasons_master_schema.sql
mysql -u routecraft_user -proutecraft_password routecraft < service_levels_master_schema.sql

# 3. Run Python scripts to populate data
python create_accessorial_definitions_master_table.py
python create_carrier_master_table.py
python create_commodities_master_table.py
python create_lanes_master_table.py
python create_locations_master_table.py
python create_modes_master_table.py
python create_routing_guide_table.py
python create_seasons_master_table.py
python create_service_levels_master_table.py
```

## 📋 Database Tables Overview

### Core Tables
- `users` - User accounts and authentication
- `carriers` - Transportation carriers
- `lanes` - Transport routes
- `bids` - Transportation bids
- `bid_responses` - Carrier responses to bids
- `insurance_claims` - Insurance claims

### Master Tables
- `accessorial_definitions_master` - Additional charges definitions
- `carrier_master` - Comprehensive carrier information
- `commodities_master` - Commodity types and classifications
- `equipment_types_master` - Equipment specifications
- `lanes_master` - Detailed lane information
- `locations_master` - Location database
- `modes_master` - Transportation modes
- `routing_guides` - Carrier selection rules
- `seasons_master` - Seasonal variations
- `service_levels_master` - Service level definitions

### Analysis Tables
- `carrier_historical_metrics` - Performance metrics
- `transport_contracts` - Contract management

## 🔗 Dependencies

The tables have the following dependencies (execution order):
1. `setup_mysql.sql` (basic tables)
2. Master tables (can be created in any order)
3. Analysis tables (depend on master tables)
4. Python scripts (populate data)

## 🛠️ Troubleshooting

If you encounter issues:
1. Check MySQL connection settings in `setup_env.py`
2. Ensure all dependencies are installed
3. Run `debug_service_levels.py` for service level issues
4. Check logs for specific error messages

## 📝 Notes

- All SQL files are compatible with MySQL 8.0+
- Python scripts require the `mysql-connector-python` package
- Some tables include sample data for testing
- Views are created automatically for common queries 