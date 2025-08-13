# Lanes Master Table Documentation

## 📋 Overview

The `lanes_master` table is a critical component in truckload (TL) transportation procurement that defines unique Origin-Destination (O-D) transport corridors. This table serves as the foundation for rate benchmarking, carrier allocation, bid structuring, route optimization, and cost analysis.

## 🎯 Purpose and Use Cases

### Primary Functions
- **Rate Benchmarking**: Compare current rates against market benchmarks
- **Carrier Allocation**: Assign preferred carriers to specific routes
- **Bid Structuring**: Define lane-specific requirements and constraints
- **Route Optimization**: Analyze distance, transit time, and cost efficiency
- **Service Level Management**: Track different service offerings (Standard, Express, Scheduled, Premium)

### Business Scenarios
- **Strategic Sourcing**: Annual bidding and contract negotiations
- **Spot Bid Events**: Dynamic pricing for immediate capacity needs
- **Lane Expansion**: Identifying new routes for business growth
- **Backhaul Optimization**: Maximizing return trip utilization
- **Seasonal Planning**: Managing peak/off-peak route variations

## 🏗️ Table Structure

### Core Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `lane_id` | VARCHAR(50) | Unique identifier | LANE-BHW-HYD-001 |
| `origin_location_id` | VARCHAR(50) | Reference to Locations Master | WH-MUM-01 |
| `origin_city` | VARCHAR(100) | Origin city name | Bhiwandi |
| `origin_state` | VARCHAR(100) | Origin state name | Maharashtra |
| `destination_location_id` | VARCHAR(50) | Reference to Locations Master | CUST-HYD-01 |
| `destination_city` | VARCHAR(100) | Destination city name | Hyderabad |
| `destination_state` | VARCHAR(100) | Destination state name | Telangana |

### Operational Characteristics

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `lane_type` | ENUM | Lane classification | Primary, Return, Backhaul, Inbound, Outbound |
| `distance_km` | DECIMAL(8,2) | Road distance in kilometers | 725.50 |
| `transit_time_days` | INT | Standard delivery lead time | 2 |
| `avg_load_frequency_month` | DECIMAL(5,2) | Average loads per month | 30.0 |
| `avg_load_volume_tons` | DECIMAL(8,2) | Average load size in tons | 15.5 |
| `avg_load_volume_cft` | DECIMAL(8,2) | Average load volume in cubic feet | 450.0 |

### Equipment and Service

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `preferred_equipment_type` | ENUM | Preferred equipment | 32ft SXL, 32ft Container, Reefer, Flatbed |
| `mode` | ENUM | Transportation mode | TL, LTL, Rail, Multimodal |
| `service_level` | ENUM | Service level offered | Standard, Express, Scheduled, Premium |
| `seasonality` | BOOLEAN | Peak/off-peak trends | TRUE |
| `peak_months` | VARCHAR(100) | Peak months (comma-separated) | March,October |

### Financial and Rate Information

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `primary_carriers` | JSON | Preferred carriers | ["ABC Logistics", "XYZ Transport"] |
| `current_rate_trip` | DECIMAL(10,2) | Current rate per trip (INR) | 28000.00 |
| `current_rate_ton` | DECIMAL(8,2) | Current rate per ton (INR) | 1806.45 |
| `benchmark_rate_trip` | DECIMAL(10,2) | Market benchmark rate per trip | 30000.00 |
| `benchmark_rate_ton` | DECIMAL(8,2) | Market benchmark rate per ton | 1935.48 |
| `fuel_surcharge_applied` | BOOLEAN | Dynamic fuel surcharge | TRUE |

### Operational Details

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `accessorials_expected` | JSON | Expected accessorials | ["Unloading", "Waiting", "Escort"] |
| `is_active` | BOOLEAN | Lane status flag | TRUE |
| `last_used_date` | DATE | Last shipment date | 2024-12-15 |
| `remarks` | TEXT | Operational notes | "High volume lane, toll-heavy route" |

## 🔧 ENUM Values

### Lane Type
- **Primary**: Main route between origin and destination
- **Return**: Return journey from destination to origin
- **Backhaul**: Alternative return route for better utilization
- **Inbound**: Route bringing goods into the network
- **Outbound**: Route sending goods out of the network

### Equipment Type
- **32ft SXL**: Standard 32-foot semi-trailer
- **32ft Container**: 32-foot shipping container
- **Reefer**: Refrigerated trailer
- **Flatbed**: Open flatbed trailer
- **20ft Container**: 20-foot shipping container
- **40ft Container**: 40-foot shipping container
- **Other**: Specialized equipment

### Mode
- **TL**: Truckload (default)
- **LTL**: Less-than-truckload
- **Rail**: Railway transportation
- **Multimodal**: Multiple transportation modes

### Service Level
- **Standard**: Regular service with standard transit time
- **Express**: Expedited service with faster transit
- **Scheduled**: Fixed schedule service
- **Premium**: High-priority service with additional features

## 📊 Analytical Views

### 1. `active_lanes_by_type`
Aggregates lanes by type, showing average distance, transit time, and monthly frequency.

### 2. `high_volume_lanes`
Identifies lanes with high monthly load frequency (≥20 loads/month).

### 3. `seasonal_lanes`
Shows lanes with seasonal variations and their peak months.

### 4. `equipment_requirements`
Analyzes equipment distribution across lanes with average distance and rates.

### 5. `rate_analysis`
Compares current rates against benchmarks, showing variance percentages.

## 🧠 Lane Auto-Creation Logic

### From Historical Load Data
1. **Group by Origin + Destination**: Aggregate loads by O-D pairs
2. **Calculate Metrics**: Frequency, average volume, rates, distance
3. **Match Locations**: Auto-fill city/state from locations master
4. **Flag for Review**: Present aggregated data for user confirmation
5. **Create Lane**: Generate new lane record with calculated metrics

### Example Auto-Creation
```
Load History → Group by O-D → Calculate Averages → Create Lane
Bhiwandi → Hyderabad (30 loads/month, avg 15.5 tons, avg ₹28,000)
↓
LANE-BHW-HYD-001: Bhiwandi → Hyderabad | 30 loads/month | 15.5 tons | ₹28,000
```

## 📝 Sample Data

### High-Volume Primary Lane
```
Lane ID: LANE-BHW-HYD-001
Origin: Bhiwandi, Maharashtra
Destination: Hyderabad, Telangana
Distance: 725.50 km
Transit Time: 2 days
Monthly Frequency: 30 loads
Equipment: 32ft Container
Current Rate: ₹28,000/trip
Benchmark Rate: ₹30,000/trip
Seasonality: March, October peaks
```

### Express Corridor
```
Lane ID: LANE-BLR-CHN-002
Origin: Bangalore, Karnataka
Destination: Chennai, Tamil Nadu
Distance: 350.25 km
Transit Time: 1 day
Service Level: Express
Equipment: 32ft SXL
Current Rate: ₹22,000/trip
```

## 🔗 Integration Points

### Related Tables
- **`locations_master`**: Origin and destination location details
- **`carrier_historical_metrics`**: Performance data for carrier selection
- **`targeted_carriers`**: External carrier information
- **`commodities_master`**: Commodity-specific requirements

### Data Flow
1. **Load Execution** → Updates `last_used_date` and frequency metrics
2. **Rate Negotiations** → Updates `current_rate_trip` and `current_rate_ton`
3. **Carrier Performance** → Influences `primary_carriers` selection
4. **Market Intelligence** → Updates `benchmark_rate_trip` and `benchmark_rate_ton`

## 🛠️ Implementation Details

### Database Setup
```sql
-- Create table with proper indexing
CREATE TABLE lanes_master (
    -- ... field definitions ...
    INDEX idx_origin (origin_location_id),
    INDEX idx_destination (destination_location_id),
    INDEX idx_origin_city_state (origin_city, origin_state),
    INDEX idx_dest_city_state (destination_city, destination_state),
    INDEX idx_lane_type (lane_type),
    INDEX idx_distance (distance_km),
    INDEX idx_equipment (preferred_equipment_type),
    INDEX idx_mode (mode),
    INDEX idx_active (is_active),
    INDEX idx_last_used (last_used_date)
);
```

### Python Script
- **File**: `create_lanes_master_table.py`
- **Dependencies**: `mysql-connector-python`, `python-dotenv`
- **Functions**: Table creation, sample data insertion, view creation
- **Output**: Table structure, sample data, analytical views

## 🔍 Maintenance and Monitoring

### Regular Tasks
- **Weekly**: Update `last_used_date` from load execution data
- **Monthly**: Recalculate `avg_load_frequency_month` and volume metrics
- **Quarterly**: Review and update benchmark rates
- **Annually**: Assess lane performance and deactivate unused lanes

### Data Quality Checks
- **Referential Integrity**: Ensure location IDs exist in `locations_master`
- **Rate Validation**: Current rates should be within reasonable bounds
- **Distance Verification**: Validate distance against actual route data
- **Frequency Updates**: Ensure load frequency reflects recent activity

## 🚀 Best Practices

### Lane Management
1. **Unique Identification**: Use consistent naming convention (LANE-XXX-XXX-XXX)
2. **Location References**: Always link to valid locations in `locations_master`
3. **Rate Tracking**: Maintain both per-trip and per-ton rates for flexibility
4. **Seasonal Planning**: Flag seasonal lanes and document peak months
5. **Equipment Matching**: Align equipment types with commodity requirements

### Performance Optimization
1. **Indexing Strategy**: Index on frequently queried fields (origin, destination, type)
2. **JSON Fields**: Use JSON for flexible data like carriers and accessorials
3. **Partitioning**: Consider partitioning by lane type for large datasets
4. **Archiving**: Archive inactive lanes to maintain performance

### Data Governance
1. **Audit Trail**: Track creation and modification with timestamps
2. **Validation Rules**: Implement business rules for rate and distance validation
3. **Change Management**: Document significant changes to lane configurations
4. **Access Control**: Restrict lane modifications to authorized users

## 🔮 Future Enhancements

### Advanced Features
- **Dynamic Pricing**: Real-time rate adjustments based on market conditions
- **Route Optimization**: Integration with mapping services for optimal routes
- **Predictive Analytics**: Forecast lane demand and capacity requirements
- **Multi-modal Planning**: Support for rail and sea transportation options

### Integration Opportunities
- **GPS Tracking**: Real-time shipment tracking and ETA updates
- **Weather Integration**: Route adjustments based on weather conditions
- **Toll Optimization**: Route planning considering toll costs and time
- **Carbon Footprint**: Track and optimize environmental impact

### Analytics Capabilities
- **Lane Performance Dashboard**: Visual representation of lane metrics
- **Cost Trend Analysis**: Historical rate analysis and forecasting
- **Carrier Performance**: Lane-specific carrier performance metrics
- **Capacity Planning**: Predictive capacity requirements by lane

## 📚 Related Documentation

- **`LOCATIONS_MASTER_README.md`**: Origin and destination location details
- **`CARRIER_HISTORICAL_METRICS_README.md`**: Carrier performance data
- **`TARGETED_CARRIERS_README.md`**: External carrier information
- **`COMMODITIES_MASTER_README.md`**: Commodity specifications and requirements

---

*This documentation provides comprehensive information about the lanes_master table structure, usage, and maintenance. For technical implementation details, refer to the Python script `create_lanes_master_table.py`.* 