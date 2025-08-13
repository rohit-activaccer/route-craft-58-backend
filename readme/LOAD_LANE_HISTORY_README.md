# Load/Lane History Table Documentation

## Overview

The `load_lane_history` table is a comprehensive master data table designed to capture and analyze historical transportation data for truckload (TL) transportation procurement. This data is critical for understanding past shipping patterns and making informed decisions about:

- **Carrier Selection**: Identify reliable carriers based on performance history
- **Rate Benchmarking**: Compare rates across different lanes, carriers, and time periods
- **Lane Optimization**: Analyze route efficiency and identify optimization opportunities
- **Bid Package Creation**: Use historical data to create competitive bid packages

## Table Structure

### Core Fields

| Field | Type | Description | Required | Default |
|-------|------|-------------|----------|---------|
| `id` | UUID | Primary key | Yes | Auto-generated |
| `load_id` | VARCHAR(100) | Unique load identifier | Yes | - |
| `contract_reference` | VARCHAR(100) | Contract or rate agreement ID | No | - |

### Origin Information

| Field | Type | Description | Required | Default |
|-------|------|-------------|----------|---------|
| `origin_location` | VARCHAR(200) | Origin city, state, or location | Yes | - |
| `origin_country` | VARCHAR(10) | Origin country code | Yes | 'IN' |
| `origin_facility_id` | VARCHAR(100) | Internal plant/warehouse code | No | - |
| `origin_latitude` | DECIMAL(10,8) | Origin latitude coordinate | No | - |
| `origin_longitude` | DECIMAL(11,8) | Origin longitude coordinate | No | - |

### Destination Information

| Field | Type | Description | Required | Default |
|-------|------|-------------|----------|---------|
| `destination_location` | VARCHAR(200) | Destination city, state, or location | Yes | - |
| `destination_country` | VARCHAR(10) | Destination country code | Yes | 'IN' |
| `destination_facility_id` | VARCHAR(100) | Internal plant/warehouse code | No | - |
| `destination_latitude` | DECIMAL(10,8) | Destination latitude coordinate | No | - |
| `destination_longitude` | DECIMAL(11,8) | Destination longitude coordinate | No | - |

### Shipment Details

| Field | Type | Description | Required | Default |
|-------|------|-------------|----------|---------|
| `load_date` | TIMESTAMP | Shipment pickup date | Yes | - |
| `delivery_date` | TIMESTAMP | Delivery date at destination | Yes | - |
| `mode` | VARCHAR(20) | Transportation mode | No | 'TL' |
| `equipment_type` | VARCHAR(100) | Equipment type (e.g., 32ft SXL) | No | - |
| `commodity_type` | VARCHAR(100) | Product category | No | - |
| `weight_kg` | DECIMAL(10,2) | Shipment weight in kilograms | No | - |
| `volume_cbm` | DECIMAL(10,2) | Shipment volume in cubic meters | No | - |
| `distance_km` | DECIMAL(10,2) | Route distance in kilometers | No | - |

### Carrier Information

| Field | Type | Description | Required | Default |
|-------|------|-------------|----------|---------|
| `carrier_id` | UUID | Reference to carriers table | No | - |
| `carrier_name` | VARCHAR(200) | Name of the transporter/carrier | No | - |

### Financial Information

| Field | Type | Description | Required | Default |
|-------|------|-------------|----------|---------|
| `rate_type` | VARCHAR(20) | Rate type (per_km, per_trip, flat) | No | - |
| `total_cost` | DECIMAL(12,2) | Total freight cost | Yes | - |
| `rate_per_km` | DECIMAL(10,2) | Rate per kilometer | No | - |
| `accessorial_charges` | DECIMAL(10,2) | Additional charges | No | 0.00 |
| `fuel_surcharge_percentage` | DECIMAL(5,2) | Fuel surcharge percentage | No | 0.00 |

### Procurement Details

| Field | Type | Description | Required | Default |
|-------|------|-------------|----------|---------|
| `tender_type` | VARCHAR(20) | Tender type (contracted, spot, adhoc) | No | 'spot' |
| `carrier_response` | VARCHAR(20) | Carrier response status | No | 'accepted' |

### Performance Metrics

| Field | Type | Description | Required | Default |
|-------|------|-------------|----------|---------|
| `on_time_pickup` | BOOLEAN | On-time pickup indicator | No | - |
| `on_time_delivery` | BOOLEAN | On-time delivery indicator | No | - |
| `billing_accuracy` | BOOLEAN | Billing accuracy flag | No | true |

### Metadata

| Field | Type | Description | Required | Default |
|-------|------|-------------|----------|---------|
| `notes` | TEXT | Additional notes | No | - |
| `created_by` | UUID | User who created the record | No | - |
| `created_at` | TIMESTAMP | Record creation timestamp | Yes | Auto-generated |
| `updated_at` | TIMESTAMP | Record update timestamp | Yes | Auto-generated |

## Data Validation Rules

### Constraints
- **Valid Dates**: `delivery_date` must be after `load_date`
- **Coordinate Pairs**: If latitude is provided, longitude must also be provided (and vice versa)
- **Mode Values**: Must be one of: 'TL', 'FTL', 'LTL', 'Rail', 'Air', 'Sea'
- **Rate Types**: Must be one of: 'per_km', 'per_trip', 'flat'
- **Tender Types**: Must be one of: 'contracted', 'spot', 'adhoc'
- **Carrier Responses**: Must be one of: 'accepted', 'declined', 'auto_assigned'

### Business Rules
- Load IDs must be unique across the system
- Total cost must be positive
- Weight and volume should be positive if provided
- Distance should be positive if provided

## Indexes for Performance

The table includes several strategic indexes to optimize common query patterns:

```sql
-- Origin-based queries
CREATE INDEX idx_load_lane_history_origin ON load_lane_history(origin_location, origin_country);

-- Destination-based queries
CREATE INDEX idx_load_lane_history_destination ON load_lane_history(destination_location, destination_country);

-- Date-based queries
CREATE INDEX idx_load_lane_history_dates ON load_lane_history(load_date, delivery_date);

-- Carrier-based queries
CREATE INDEX idx_load_lane_history_carrier ON load_lane_history(carrier_id, carrier_name);

-- Mode and equipment queries
CREATE INDEX idx_load_lane_history_mode ON load_lane_history(mode, equipment_type);

-- Commodity-based queries
CREATE INDEX idx_load_lane_history_commodity ON load_lane_history(commodity_type);

-- Contract-based queries
CREATE INDEX idx_load_lane_history_contract ON load_lane_history(contract_reference);
```

## API Endpoints

### CRUD Operations

- **POST** `/api/v1/load-lane-history/` - Create new load history record
- **GET** `/api/v1/load-lane-history/` - List load history with filtering
- **GET** `/api/v1/load-lane-history/{load_id}` - Get specific load by ID
- **PUT** `/api/v1/load-lane-history/{load_id}` - Update existing load record
- **DELETE** `/api/v1/load-lane-history/{load_id}` - Delete load record

### Analytics Endpoints

- **GET** `/api/v1/load-lane-history/analytics/summary` - Get summary statistics
- **GET** `/api/v1/load-lane-history/analytics/lane-performance` - Get lane performance analytics

## Sample Data

The table comes pre-populated with sample data demonstrating typical usage patterns:

```sql
-- Sample load from Mumbai to Delhi
INSERT INTO load_lane_history (
    load_id, contract_reference, origin_location, destination_location,
    load_date, delivery_date, mode, equipment_type, commodity_type,
    weight_kg, volume_cbm, distance_km, carrier_name,
    rate_type, total_cost, rate_per_km, accessorial_charges
) VALUES (
    'LOAD-001', 'CONTRACT-2024-001', 'Mumbai', 'Delhi',
    '2024-01-15T08:00:00Z', '2024-01-17T18:00:00Z', 'TL', '32ft SXL', 'FMCG',
    15000.00, 45.50, 1400.00, 'Sample Carrier',
    'per_trip', 28000.00, 20.00, 2000.00
);
```

## Use Cases

### 1. Rate Benchmarking
```sql
-- Compare rates for the same lane across different carriers
SELECT 
    carrier_name,
    AVG(rate_per_km) as avg_rate,
    COUNT(*) as load_count
FROM load_lane_history
WHERE origin_location = 'Mumbai' 
  AND destination_location = 'Delhi'
  AND mode = 'TL'
GROUP BY carrier_name
ORDER BY avg_rate;
```

### 2. Carrier Performance Analysis
```sql
-- Analyze carrier performance metrics
SELECT 
    carrier_name,
    COUNT(*) as total_loads,
    AVG(CASE WHEN on_time_delivery THEN 1 ELSE 0 END) * 100 as on_time_rate,
    AVG(rate_per_km) as avg_rate_per_km
FROM load_lane_history
WHERE carrier_name IS NOT NULL
GROUP BY carrier_name
HAVING COUNT(*) >= 5
ORDER BY on_time_rate DESC;
```

### 3. Lane Optimization
```sql
-- Identify high-cost lanes for optimization
SELECT 
    origin_location,
    destination_location,
    AVG(total_cost) as avg_cost,
    AVG(rate_per_km) as avg_rate_per_km,
    COUNT(*) as load_count
FROM load_lane_history
GROUP BY origin_location, destination_location
HAVING COUNT(*) >= 3
ORDER BY avg_rate_per_km DESC;
```

### 4. Seasonal Rate Analysis
```sql
-- Analyze rate trends by month
SELECT 
    EXTRACT(MONTH FROM load_date) as month,
    AVG(rate_per_km) as avg_rate,
    COUNT(*) as load_count
FROM load_lane_history
WHERE rate_per_km IS NOT NULL
GROUP BY EXTRACT(MONTH FROM load_date)
ORDER BY month;
```

## Data Import Guidelines

### Excel/CSV Import
When importing data from Excel or CSV files:

1. **Standardize Location Names**: Use consistent city/state naming conventions
2. **Validate Coordinates**: Ensure latitude/longitude pairs are complete
3. **Normalize Equipment Types**: Use standardized equipment type codes
4. **Validate Dates**: Ensure dates are in ISO format
5. **Calculate Derived Fields**: Automatically calculate rate_per_km from total_cost and distance

### API Integration
For TMS (Transportation Management System) integration:

1. **Real-time Updates**: Update records as shipments progress
2. **Batch Processing**: Process multiple records in single API calls
3. **Data Validation**: Implement comprehensive validation before insertion
4. **Error Handling**: Provide detailed error messages for failed imports

## Maintenance and Performance

### Regular Maintenance
- **Data Archiving**: Archive old records (older than 3 years) to separate tables
- **Index Optimization**: Monitor and rebuild indexes as needed
- **Data Cleanup**: Remove duplicate or invalid records
- **Performance Monitoring**: Track query performance and optimize slow queries

### Performance Tips
- Use date ranges when querying large datasets
- Leverage indexes for common filter combinations
- Consider partitioning by date for very large tables
- Use materialized views for complex analytics queries

## Security and Access Control

The table is protected by Row Level Security (RLS) policies:
- **Read Access**: All authenticated users can read records
- **Write Access**: Users can create/update/delete their own records
- **Admin Access**: Administrators have full access to all records

## Future Enhancements

### Planned Features
- **Geospatial Queries**: Enhanced location-based analytics using PostGIS
- **Machine Learning**: Predictive rate modeling based on historical data
- **Real-time Analytics**: Live dashboard with real-time performance metrics
- **Integration APIs**: Direct integration with major TMS platforms

### Data Enrichment
- **Weather Data**: Correlate performance with weather conditions
- **Fuel Prices**: Track fuel surcharge trends
- **Market Conditions**: Integrate with freight market indices
- **Carrier Ratings**: Enhanced carrier performance scoring

## Support and Documentation

For technical support or questions about the load/lane history table:
- **API Documentation**: Available at `/docs` endpoint
- **Database Schema**: Full schema available in `database_schema.sql`
- **Sample Queries**: See examples above and in the API documentation
- **Performance Tuning**: Contact the database administration team

---

*This documentation is maintained by the RouteCraft development team. Last updated: August 2024* 