# RouteCraft Database Documentation

This folder contains detailed documentation for all database tables and components in the RouteCraft transportation procurement system.

## 📋 Table Documentation Index

### 🚛 Core Transportation Tables
- **[ACCESSORIAL_DEFINITIONS_MASTER_README.md](./ACCESSORIAL_DEFINITIONS_MASTER_README.md)** - Additional charges and fees definitions
- **[CARRIER_HISTORICAL_METRICS_README.md](./CARRIER_HISTORICAL_METRICS_README.md)** - Carrier performance tracking and metrics
- **[COMMODITIES_MASTER_README.md](./COMMODITIES_MASTER_README.md)** - Commodity types and classifications
- **[EQUIPMENT_TYPES_MASTER_README.md](./EQUIPMENT_TYPES_MASTER_README.md)** - Equipment specifications and types
- **[FUEL_SURCHARGE_README.md](./FUEL_SURCHARGE_README.md)** - Fuel surcharge calculations and management
- **[LANES_MASTER_README.md](./LANES_MASTER_README.md)** - Transport routes and corridors
- **[LOAD_LANE_HISTORY_README.md](./LOAD_LANE_HISTORY_README.md)** - Historical load data and analytics
- **[LOCATIONS_MASTER_README.md](./LOCATIONS_MASTER_README.md)** - Geographic locations and facilities
- **[MODES_MASTER_README.md](./MODES_MASTER_README.md)** - Transportation modes and types
- **[SEASONS_MASTER_README.md](./SEASONS_MASTER_README.md)** - Seasonal variations and pricing
- **[SERVICE_LEVELS_MASTER_README.md](./SERVICE_LEVELS_MASTER_README.md)** - Service level definitions and SLAs
- **[TARGETED_CARRIERS_README.md](./TARGETED_CARRIERS_README.md)** - Carrier targeting and selection

## 🏗️ Database Architecture Overview

### Core Tables
- **Users & Authentication** - User management and access control
- **Carriers** - Transportation provider information
- **Lanes** - Transport routes and corridors
- **Bids** - Transportation procurement requests
- **Bid Responses** - Carrier proposals and responses

### Master Tables
- **Accessorial Definitions** - Additional charges and fees
- **Carrier Historical Metrics** - Performance tracking
- **Commodities** - Cargo types and classifications
- **Equipment Types** - Vehicle and equipment specifications
- **Fuel Surcharge** - Dynamic pricing calculations
- **Lanes Master** - Detailed route information
- **Locations** - Geographic location database
- **Modes Master** - Transportation modes
- **Routing Guides** - Carrier selection rules
- **Seasons Master** - Seasonal variations
- **Service Levels** - Service level agreements

### Analysis Tables
- **Carrier Historical Metrics** - Performance analytics
- **Load Lane History** - Historical data analysis
- **Transport Contracts** - Contract management

## 📊 Quick Reference

### Table Categories
| Category | Tables | Purpose |
|----------|--------|---------|
| **Core** | users, carriers, lanes, bids, bid_responses | Basic application functionality |
| **Master** | All `*_master` tables | Reference data and configurations |
| **Analysis** | carrier_historical_metrics, load_lane_history | Business intelligence and reporting |
| **Contracts** | transport_contracts, routing_guides | Contract and procurement management |

### Key Relationships
- **Users** → **Carriers** (one-to-many)
- **Lanes** → **Bids** (one-to-many)
- **Bids** → **Bid Responses** (one-to-many)
- **Carriers** → **Historical Metrics** (one-to-many)
- **Lanes** → **Load History** (one-to-many)

## 🔧 Setup and Maintenance

### Database Setup
1. Run `sql/setup_mysql.sql` for basic tables
2. Execute master table creation scripts
3. Populate reference data using Python scripts
4. Run analysis table creation scripts

### Data Population
- Master tables contain reference data for the application
- Sample data is included for testing and development
- Production data should be loaded according to business requirements

### Maintenance
- Regular backup of all tables
- Monitor performance metrics
- Update reference data as needed
- Archive historical data periodically

## 📈 Business Intelligence

### Key Metrics Tracked
- **Carrier Performance** - On-time delivery, acceptance rates
- **Cost Analysis** - Rate trends, fuel surcharge impact
- **Lane Performance** - Volume, frequency, profitability
- **Seasonal Patterns** - Demand fluctuations, pricing variations

### Reporting Capabilities
- Carrier scorecards and ratings
- Cost analysis and optimization
- Route performance analytics
- Seasonal trend analysis
- Contract compliance monitoring

## 🛠️ Development Guidelines

### Adding New Tables
1. Create table schema in `sql/` folder
2. Add corresponding README documentation
3. Update this index file
4. Create Python scripts for data population
5. Update application models and APIs

### Documentation Standards
- Each table should have a dedicated README
- Include table schema, relationships, and business rules
- Document sample data and use cases
- Provide setup and maintenance instructions

## 📞 Support

For questions about specific tables or database design:
1. Check the individual table README files
2. Review the SQL schema files in `sql/` folder
3. Consult the main project README.md
4. Check the application code for implementation details 