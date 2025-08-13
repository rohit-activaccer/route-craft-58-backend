# Equipment Types Master Table

## Overview

The **Equipment Types Master** table is a comprehensive reference table that defines different types of transportation equipment used in truckload transport. This table serves as the foundation for equipment planning, carrier matching, cost modeling, and operational decision-making in the transport procurement system.

## Table Structure

### Core Equipment Information
- **`equipment_id`** (VARCHAR(20)): Unique equipment code (e.g., EQP-32FT-CNTNR)
- **`equipment_name`** (VARCHAR(100)): Human-readable name (e.g., 32ft Container Truck)
- **`vehicle_body_type`** (ENUM): Type of vehicle body (Container, Open Body, Flatbed, Reefer, Tanker, Box Truck, Trailer, Specialized)
- **`vehicle_length_ft`** (DECIMAL(4,1)): Vehicle length in feet (20.0, 32.0, 40.0)
- **`axle_type`** (ENUM): Axle configuration (Single, Double, Multi-axle, Tandem, Tri-axle)

### Capacity Specifications
- **`gross_vehicle_weight_tons`** (DECIMAL(5,2)): Maximum GVW in tons
- **`payload_capacity_tons`** (DECIMAL(5,2)): Net cargo capacity in tons
- **`volume_capacity_cft`** (INT): Volume capacity in cubic feet
- **`volume_capacity_cbm`** (DECIMAL(6,2)): Volume capacity in cubic meters
- **`max_height_meters`** (DECIMAL(4,2)): Maximum height in meters
- **`max_width_meters`** (DECIMAL(4,2)): Maximum width in meters

### Operational Features
- **`door_type`** (ENUM): Type of loading doors (Side-opening, Rear-opening, Top-loading, Roll-up, Side-roll, Multiple, Side-loading)
- **`temperature_controlled`** (BOOLEAN): Whether vehicle has temperature control
- **`hazmat_certified`** (BOOLEAN): If vehicle is permitted to carry hazardous goods
- **`has_gps`** (BOOLEAN): Whether vehicle has GPS for tracking
- **`refrigeration_capacity_btu`** (INT): Refrigeration capacity in BTU (for reefers)

### Compatibility & Requirements
- **`dock_type_compatibility`** (ENUM): Dock compatibility (Ground-level, Elevated, Ramp-access, All, Specialized)
- **`ideal_commodities`** (TEXT): Comma-separated list of ideal commodities
- **`fuel_type`** (ENUM): Primary fuel type (Diesel, CNG, Electric, Hybrid, Biodiesel)
- **`common_routes`** (TEXT): Common routes or lanes where this equipment is used

### Business & Regulatory
- **`standard_rate_per_km`** (DECIMAL(8,2)): Internal planning rate per kilometer
- **`security_features`** (TEXT): Security features like locks, seals, etc.
- **`maintenance_requirements`** (TEXT): Maintenance schedule and requirements
- **`regulatory_compliance`** (TEXT): Regulatory compliance requirements
- **`insurance_coverage_type`** (ENUM): Insurance coverage type (Basic, Comprehensive, Specialized, High-value)

### Status & Management
- **`active`** (BOOLEAN): Whether this equipment type is currently active
- **`priority_level`** (ENUM): Priority for procurement planning (High, Medium, Low)
- **`seasonal_availability`** (TEXT): Seasonal restrictions or availability
- **`remarks`** (TEXT): Additional notes and limitations

### Audit Fields
- **`created_by`** (VARCHAR(50)): User who created the record
- **`updated_by`** (VARCHAR(50)): User who last updated the record
- **`created_at`** (TIMESTAMP): Record creation timestamp
- **`updated_at`** (TIMESTAMP): Record update timestamp

## Equipment Categories

### 1. Container Trucks
- **32ft Single Axle (SXL)**: General cargo, long haul
- **32ft Multi-Axle (MXL)**: Higher capacity, better fuel efficiency
- **22ft Container**: Regional transport, smaller shipments
- **Electric Container**: Green logistics, urban delivery
- **CNG Container**: Lower emissions, cost-effective fuel
- **High Security**: Enhanced security for valuable cargo
- **Multi-Modal**: Compatible with rail and sea transport
- **Express Delivery**: Optimized for fast delivery services

### 2. Specialized Equipment
- **Reefer (Temperature-Controlled)**: Pharmaceuticals, perishable foods
- **Tanker**: Oil, chemicals, LPG, industrial liquids
- **Flatbed Trailer**: Machinery, ODC cargo, industrial equipment
- **Open Body Truck**: Construction material, bulk items
- **Box Truck**: Electronics, fragile items, last-mile delivery
- **Heavy Equipment Trailer**: Extremely heavy and specialized cargo

## Database Views

### 1. `equipment_summary`
Comprehensive overview of all active equipment types with key specifications.

### 2. `temperature_controlled_equipment`
Specialized view for temperature-controlled equipment with refrigeration details.

### 3. `high_capacity_equipment`
Equipment with payload capacity ≥15 tons, sorted by capacity.

### 4. `specialized_equipment`
Hazmat-certified and specialized equipment types with security features.

### 5. `cost_effective_equipment`
Equipment sorted by cost efficiency (tons per rupee ratio).

## Sample Queries

### Basic Equipment Selection
```sql
-- Get all active container trucks
SELECT * FROM equipment_types_master 
WHERE vehicle_body_type = 'Container' AND active = TRUE;

-- Find equipment for specific payload requirements
SELECT * FROM equipment_types_master 
WHERE payload_capacity_tons >= 15 AND active = TRUE;
```

### Advanced Filtering
```sql
-- Temperature-controlled equipment for pharma
SELECT * FROM temperature_controlled_equipment 
WHERE ideal_commodities LIKE '%Pharmaceuticals%';

-- Cost-effective equipment for high-volume routes
SELECT * FROM cost_effective_equipment 
WHERE vehicle_length_ft >= 32;
```

### Equipment Analysis
```sql
-- Equipment distribution by body type
SELECT vehicle_body_type, COUNT(*) as count
FROM equipment_types_master 
WHERE active = TRUE 
GROUP BY vehicle_body_type;

-- Capacity analysis by axle type
SELECT axle_type, 
       AVG(payload_capacity_tons) as avg_payload,
       AVG(volume_capacity_cft) as avg_volume
FROM equipment_types_master 
WHERE active = TRUE 
GROUP BY axle_type;
```

## Integration Examples

### 1. Service Level Matching
```sql
-- Match equipment to service level requirements
SELECT e.*, s.service_level_name
FROM equipment_types_master e
JOIN service_levels_master s ON e.vehicle_body_type = s.mode
WHERE s.active = TRUE AND e.active = TRUE;
```

### 2. Mode Compatibility
```sql
-- Equipment compatible with specific modes
SELECT e.*, m.mode_name
FROM equipment_types_master e
JOIN modes_master m ON e.equipment_type_required = e.equipment_id
WHERE m.active = TRUE AND e.active = TRUE;
```

### 3. Cost Analysis
```sql
-- Equipment cost comparison for routes
SELECT e.equipment_name, 
       e.standard_rate_per_km,
       e.payload_capacity_tons,
       (e.standard_rate_per_km / e.payload_capacity_tons) as cost_per_ton_km
FROM equipment_types_master e
WHERE e.active = TRUE
ORDER BY cost_per_ton_km;
```

## Business Use Cases

### 1. **Procurement Planning**
- Equipment selection based on cargo specifications
- Cost optimization through capacity matching
- Seasonal equipment availability planning

### 2. **Carrier Matching**
- Equipment capability assessment
- Specialized equipment requirements
- Compliance and certification verification

### 3. **Route Optimization**
- Equipment suitability for specific routes
- Dock compatibility planning
- Multi-modal transport coordination

### 4. **Cost Modeling**
- Rate benchmarking and analysis
- Equipment cost per ton calculations
- Fuel efficiency considerations

### 5. **Compliance Management**
- Regulatory requirement tracking
- Insurance coverage verification
- Safety feature documentation

## Maintenance and Updates

### Regular Updates
- Equipment specifications and capabilities
- Rate updates and market adjustments
- Regulatory compliance changes
- New equipment type additions

### Data Quality
- Validate equipment specifications
- Update capacity measurements
- Verify regulatory compliance
- Maintain rate accuracy

## Performance Considerations

### Indexes
- Primary key on `id`
- Unique index on `equipment_id`
- Composite indexes on frequently queried combinations
- Boolean indexes for active/inactive filtering

### Query Optimization
- Use views for common analysis scenarios
- Leverage ENUM constraints for efficient filtering
- Consider partitioning for large datasets
- Regular statistics updates

## Related Tables

- **`service_levels_master`**: Service level requirements and equipment compatibility
- **`modes_master`**: Transportation modes and equipment requirements
- **`carrier_master`**: Carrier equipment capabilities
- **`lanes_master`**: Route-specific equipment requirements
- **`commodities_master`**: Commodity-specific equipment needs

## Notes

1. **Equipment ID Convention**: Follows EQP-[Length][Type] format for easy identification
2. **Capacity Units**: Both imperial (feet, tons) and metric (meters, CBM) units supported
3. **Active Status**: Only active equipment types are available for procurement
4. **Priority Levels**: High priority equipment gets preference in planning tools
5. **Compliance**: All equipment must meet regulatory and safety requirements
6. **Integration**: Designed to work seamlessly with other master tables in the system

## Future Enhancements

- Equipment availability tracking
- Maintenance schedule integration
- Fuel consumption analytics
- Environmental impact scoring
- Equipment lifecycle management
- Predictive maintenance alerts 