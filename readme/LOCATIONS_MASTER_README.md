# Locations Master Table Documentation

## 📍 Overview

The `locations_master` table is a foundational dataset that defines all geographic points involved in the transportation network. It stores comprehensive information about factories, warehouses, depots, customer sites, ports, and hubs that are essential for:

- **Lane Creation**: Defining origin-destination pairs
- **Routing Guides**: Planning optimal transportation routes
- **Carrier Selection**: Matching carriers to location requirements
- **Load Planning**: Optimizing pickup and delivery schedules
- **Tender Invitations**: Targeting carriers for specific routes

## 🏗️ Table Structure

### Core Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `location_id` | VARCHAR(50) | Unique location identifier | `WH-BLR-01`, `FACTORY-CHN-01` |
| `location_name` | VARCHAR(255) | Descriptive name | `Bangalore Central Warehouse` |
| `location_type` | ENUM | Type of facility | `Warehouse`, `Factory`, `Customer`, `Port` |
| `address_line_1` | VARCHAR(255) | Street address | `Plot No. 45, Industrial Area` |
| `city` | VARCHAR(100) | City name | `Bangalore`, `Mumbai` |
| `state` | VARCHAR(100) | State/Province | `Karnataka`, `Maharashtra` |
| `pincode` | VARCHAR(10) | Postal code | `560100` |
| `country` | VARCHAR(50) | Country (defaults to India) | `India` |

### Geographic & Zonal Information

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `latitude` | DECIMAL(10,8) | GPS latitude for geofencing | `12.9352` |
| `longitude` | DECIMAL(11,8) | GPS longitude for geofencing | `77.6145` |
| `zone` | ENUM | Business zone classification | `South India`, `West India`, `Export Hub` |

### Contact & Operational Details

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `gstin` | VARCHAR(15) | GST registration number | `29ABCDE1234Z5F` |
| `location_contact_name` | VARCHAR(255) | Site supervisor or POC | `Rajesh Kumar` |
| `phone_number` | VARCHAR(20) | Contact phone | `+91-9876543210` |
| `email` | VARCHAR(255) | Contact email | `rajesh.kumar@company.com` |
| `working_hours` | VARCHAR(100) | Operating hours | `9AM-7PM, Mon-Sat` |

### Operational Parameters

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `loading_unloading_sla` | INT | Turnaround time in minutes | `90`, `120` |
| `dock_type` | ENUM | Loading facility type | `Ground-level`, `Hydraulic`, `Container` |
| `parking_available` | ENUM | Overnight parking | `Yes`, `No`, `Limited` |
| `equipment_access` | JSON | Available equipment | `["Forklift", "Crane", "Pallet Jack"]` |

### Business Logic Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `is_consolidation_hub` | ENUM | Consolidation facility | `Yes`, `No` |
| `preferred_mode` | ENUM | Transportation preference | `TL`, `LTL`, `Multimodal` |
| `hazmat_allowed` | ENUM | Hazardous materials | `Yes`, `No`, `Limited` |
| `auto_scheduling_enabled` | ENUM | API dock scheduling | `Yes`, `No` |
| `location_status` | ENUM | Operational status | `Active`, `Inactive`, `Under Maintenance` |

### Audit Fields

| Field | Type | Description |
|-------|------|-------------|
| `created_at` | TIMESTAMP | Record creation timestamp |
| `updated_at` | TIMESTAMP | Last update timestamp |
| `created_by` | VARCHAR(100) | User who created the record |
| `updated_by` | VARCHAR(100) | User who last updated the record |

## 📊 ENUM Values

### Location Types
- **Factory**: Manufacturing plants, production facilities
- **Warehouse**: Storage and distribution centers
- **Customer**: Client locations, retail stores
- **Port**: Seaports, container terminals
- **CFS**: Container Freight Stations
- **Depot**: Transit depots, cross-docking facilities
- **Hub**: Multi-modal logistics centers
- **Transit Point**: Intermediate stops, consolidation points
- **Distribution Center**: Regional distribution facilities
- **Retail Store**: Customer-facing retail locations
- **Office**: Administrative offices
- **Other**: Miscellaneous locations

### Zones
- **North India**: Delhi, Haryana, Punjab, Uttar Pradesh
- **South India**: Karnataka, Tamil Nadu, Telangana, Kerala
- **East India**: West Bengal, Bihar, Odisha, Jharkhand
- **West India**: Maharashtra, Gujarat, Rajasthan
- **Central India**: Madhya Pradesh, Chhattisgarh
- **Export Hub**: Major export-oriented locations
- **Import Hub**: Major import processing locations
- **Transit Zone**: Cross-border or intermediate locations
- **Other**: Specialized zones

### Dock Types
- **Ground-level**: Standard ground-level loading
- **Hydraulic**: Hydraulic dock levelers
- **Ramp**: Inclined ramps for loading
- **Platform**: Elevated platforms
- **Container**: Container-specific facilities
- **Bulk**: Bulk material handling
- **Other**: Specialized loading systems

### Transportation Modes
- **TL**: Truckload transportation
- **LTL**: Less-than-truckload
- **Rail**: Railway transportation
- **Multimodal**: Multiple transportation modes
- **Any**: No specific preference

## 🔍 Sample Data

The table includes 5 sample locations covering different types and zones:

1. **WH-BLR-01**: Bangalore Central Warehouse (South India)
2. **WH-MUM-01**: Mumbai Western Warehouse (West India)
3. **FACTORY-CHN-01**: Chennai Manufacturing Plant (South India)
4. **CUST-HYD-01**: Hyderabad Customer DC (South India)
5. **PORT-MUM-01**: Mumbai Port Terminal (Export Hub)

## 👁️ Analytical Views

### 1. `active_locations_by_type`
Shows count and average SLA by location type for active locations.

### 2. `locations_by_zone`
Provides zone-wise breakdown of locations by type.

### 3. `equipment_availability`
Lists available equipment and facilities at each location.

## 🧠 Use Cases

### Lane Creation
```sql
-- Find all warehouse pairs for lane creation
SELECT 
    w1.location_id as origin_id,
    w1.location_name as origin_name,
    w2.location_id as destination_id,
    w2.location_name as destination_name,
    ST_Distance_Sphere(
        POINT(w1.longitude, w1.latitude),
        POINT(w2.longitude, w2.latitude)
    ) / 1000 as distance_km
FROM locations_master w1
JOIN locations_master w2 ON w1.location_type = 'Warehouse' 
    AND w2.location_type = 'Warehouse'
WHERE w1.location_id < w2.location_id;
```

### Carrier Matching
```sql
-- Find locations compatible with HAZMAT carriers
SELECT location_id, location_name, city, state, hazmat_allowed
FROM locations_master
WHERE hazmat_allowed IN ('Yes', 'Limited')
    AND location_status = 'Active';
```

### Route Optimization
```sql
-- Find consolidation hubs for route planning
SELECT location_id, location_name, city, zone, preferred_mode
FROM locations_master
WHERE is_consolidation_hub = 'Yes'
    AND location_status = 'Active'
ORDER BY zone, city;
```

## 🔧 Maintenance

### Regular Updates
- **Location Status**: Update operational status based on current conditions
- **Contact Information**: Keep contact details current
- **Working Hours**: Update for seasonal changes or special events
- **Equipment Access**: Reflect current equipment availability

### Data Quality
- **Coordinates**: Ensure GPS coordinates are accurate for distance calculations
- **GSTIN**: Validate GST registration numbers
- **Contact Details**: Verify phone numbers and email addresses
- **Addresses**: Keep addresses current and standardized

## 🔗 Integration Points

### Primary Dependencies
- **Lanes Table**: References origin and destination locations
- **Routing Guides**: Uses location pairs for route planning
- **Load History**: Tracks pickup and delivery locations
- **Carrier Assignments**: Matches carriers to location requirements

### API Endpoints
- `GET /api/locations` - List all locations
- `GET /api/locations/{id}` - Get specific location details
- `GET /api/locations/type/{type}` - Filter by location type
- `GET /api/locations/zone/{zone}` - Filter by business zone
- `POST /api/locations` - Create new location
- `PUT /api/locations/{id}` - Update location details

## 🚀 Future Enhancements

### Planned Features
1. **Geofencing**: Real-time location tracking and alerts
2. **Capacity Planning**: Dynamic capacity allocation based on demand
3. **Route Optimization**: AI-powered route planning algorithms
4. **Integration**: Connect with external mapping services
5. **Analytics**: Advanced location performance metrics

### Advanced Capabilities
- **Real-time Updates**: Live status updates from location systems
- **Predictive Analytics**: Forecast location capacity needs
- **Automated Scheduling**: AI-driven dock appointment scheduling
- **Compliance Monitoring**: Automated regulatory compliance checks

## 📋 Best Practices

### Data Entry
1. **Standardize Addresses**: Use consistent address formats
2. **Validate Coordinates**: Ensure GPS coordinates are accurate
3. **Complete Information**: Fill all required fields
4. **Regular Updates**: Keep information current

### Performance
1. **Index Usage**: Leverage created indexes for queries
2. **Batch Operations**: Use bulk operations for large datasets
3. **Connection Pooling**: Implement proper database connection management
4. **Query Optimization**: Use efficient SQL queries

### Security
1. **Access Control**: Implement role-based access to location data
2. **Data Validation**: Validate all input data
3. **Audit Logging**: Track all changes to location records
4. **Backup Strategy**: Regular database backups

## 🆘 Troubleshooting

### Common Issues
1. **Duplicate Location IDs**: Ensure unique location identifiers
2. **Invalid Coordinates**: Validate latitude/longitude values
3. **Missing Required Fields**: Check all NOT NULL constraints
4. **Enum Value Errors**: Verify ENUM values match defined options

### Performance Issues
1. **Slow Queries**: Check index usage and query optimization
2. **Connection Timeouts**: Monitor database connection health
3. **Memory Usage**: Optimize JSON field storage

---

*This documentation covers the Locations Master table implementation for RouteCraft's TL transportation system. For additional support or questions, please refer to the development team.* 