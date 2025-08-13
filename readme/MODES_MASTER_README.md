# Modes Master Table Documentation

## 📋 Overview

The **Modes Master** table is a comprehensive reference system for transport procurement that defines different transportation modes, their operational characteristics, and how they're applied in lane planning or carrier selection. This table serves as the foundation for:

- **Mode Selection**: Choosing the right transportation mode for specific shipments
- **Cost Modeling**: Understanding cost implications of different modes
- **Carrier Capability Matching**: Matching carriers to appropriate modes
- **Multi-leg Route Planning**: Supporting complex routing scenarios
- **Service Level Integration**: Linking modes with service level requirements

## 🏗️ Table Structure

### Core Table: `modes_master`

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| `id` | INT AUTO_INCREMENT | Primary key | 1, 2, 3... |
| `mode_id` | VARCHAR(20) | Unique identifier | MODE-TL-01 |
| `mode_name` | VARCHAR(100) | Descriptive name | Full Truckload Standard |
| `mode_type` | ENUM | Transportation classification | TL, LTL, Rail, Air, Multimodal, Dedicated, Containerized, Specialized |
| `description` | TEXT | Mode explanation and use cases | Standard full truckload service for general cargo |
| `transit_time_days` | DECIMAL(4,1) | Average transit time | 2.5 days |
| `typical_use_cases` | TEXT | Common applications | High-volume outbound, long-haul shipments |
| `cost_efficiency_level` | ENUM | Cost efficiency rating | High, Medium, Low |
| `speed_level` | ENUM | Speed classification | Fast, Moderate, Slow |
| `suitable_commodities` | TEXT | Compatible goods | General cargo, palletized goods, bulk materials |
| `equipment_type_required` | VARCHAR(100) | Required equipment | 53ft Dry Van, 48ft Flatbed |
| `carrier_pool_available` | ENUM | Carrier availability | Yes, No |
| `supports_time_definite` | ENUM | Time-definite capability | Yes, No |
| `supports_multileg_planning` | ENUM | Multi-leg routing support | Yes, No |
| `real_time_tracking_support` | ENUM | Tracking capability | Yes, No |
| `green_score_emission_class` | VARCHAR(50) | Environmental rating | Euro 6, Low emissions |
| `penalty_matrix_linked` | ENUM | Penalty system link | Yes, No |
| `contract_type_default` | ENUM | Default contract type | Spot, Rate Card, Tendered, Contract |
| `active` | ENUM | Current availability | Yes, No |
| `priority_level` | ENUM | Planning priority | High, Medium, Low |
| `seasonal_availability` | ENUM | Seasonal restrictions | Year-round, Seasonal, Limited |
| `minimum_volume_requirement` | DECIMAL(10,2) | Minimum volume | 10,000.00 kg |
| `maximum_volume_capacity` | DECIMAL(10,2) | Maximum capacity | 45,000.00 kg |
| `weight_restrictions` | VARCHAR(100) | Weight limitations | Up to 45,000 lbs |
| `dimension_restrictions` | VARCHAR(100) | Size limitations | 53ft x 8.5ft x 8.5ft |
| `base_cost_multiplier` | DECIMAL(4,2) | Cost multiplier | 1.00 (baseline) |
| `fuel_surcharge_applicable` | ENUM | Fuel surcharge | Yes, No |
| `detention_charges_applicable` | ENUM | Detention charges | Yes, No |
| `customs_clearance_required` | ENUM | Customs requirements | Yes, No |
| `special_permits_required` | TEXT | Special permits | CDL required, DOT compliance |
| `insurance_requirements` | TEXT | Insurance coverage | Minimum $1M liability coverage |
| `on_time_performance_target` | DECIMAL(4,1) | Performance target | 95.0% |
| `damage_claim_rate` | DECIMAL(4,2) | Damage rate | 0.5% |
| `remarks` | TEXT | Additional notes | Most cost-effective for full loads |
| `created_by` | VARCHAR(100) | Creator | System |
| `updated_by` | VARCHAR(100) | Last updater | System |
| `created_at` | TIMESTAMP | Creation time | Auto-generated |
| `updated_at` | TIMESTAMP | Last update time | Auto-generated |

## 🎯 Mode Types and Categories

### 1. **Full Truckload (TL)**
- **Standard TL**: Cost-effective general cargo transport
- **Express TL**: Time-critical shipments with premium service
- **Dedicated TL**: Guaranteed capacity for contract customers

### 2. **Less Than Truckload (LTL)**
- **Standard LTL**: Cost-efficient small shipments
- **Express LTL**: Time-sensitive small shipments

### 3. **Rail and Intermodal**
- **Rail Freight**: Long-distance bulk shipments
- **Rail + Truck**: Combined service for optimal cost/speed

### 4. **Air Freight**
- **Air Express**: Fastest delivery for urgent shipments
- **Air Economy**: Cost-conscious urgent shipments

### 5. **Specialized Services**
- **Temperature Controlled**: Refrigerated transport
- **Oversized Cargo**: Heavy and oversized equipment
- **White Glove**: High-touch handling for valuable items

### 6. **Containerized**
- **Containerized TL**: Container-based truck service
- **Intermodal Container**: Rail + truck container service

## 📊 Database Views

### 1. **active_modes_summary**
Provides a high-level summary of all active modes by type:
```sql
SELECT * FROM active_modes_summary;
```

### 2. **mode_capabilities**
Shows core capabilities of each mode:
```sql
SELECT * FROM mode_capabilities;
```

### 3. **cost_effective_modes**
Lists modes with high or medium cost efficiency:
```sql
SELECT * FROM cost_effective_modes;
```

### 4. **time_critical_modes**
Shows fast modes suitable for time-critical shipments:
```sql
SELECT * FROM time_critical_modes;
```

### 5. **specialized_modes**
Lists specialized and containerized modes:
```sql
SELECT * FROM specialized_modes;
```

## 🔍 Sample Queries

### Find Cost-Effective TL Modes
```sql
SELECT mode_id, mode_name, transit_time_days, base_cost_multiplier
FROM modes_master 
WHERE mode_type = 'TL' 
AND cost_efficiency_level = 'High'
AND active = 'Yes'
ORDER BY base_cost_multiplier;
```

### Find Time-Critical Modes
```sql
SELECT mode_id, mode_name, mode_type, transit_time_days, speed_level
FROM modes_master 
WHERE (speed_level = 'Fast' OR transit_time_days <= 2.0)
AND active = 'Yes'
ORDER BY transit_time_days;
```

### Find Modes Supporting Multi-leg Planning
```sql
SELECT mode_id, mode_name, mode_type, supports_multileg_planning
FROM modes_master 
WHERE supports_multileg_planning = 'Yes'
AND active = 'Yes'
ORDER BY mode_type;
```

### Compare Mode Costs
```sql
SELECT mode_type, 
       AVG(base_cost_multiplier) as avg_cost_multiplier,
       COUNT(*) as mode_count
FROM modes_master 
WHERE active = 'Yes'
GROUP BY mode_type
ORDER BY avg_cost_multiplier;
```

## 🚀 Integration Examples

### 1. **Service Level + Mode Matching**
```sql
SELECT sl.service_level_name, m.mode_name, m.transit_time_days
FROM service_levels_master sl
JOIN modes_master m ON sl.max_transit_time_days >= m.transit_time_days
WHERE sl.active = 'Yes' AND m.active = 'Yes'
ORDER BY sl.service_level_name, m.transit_time_days;
```

### 2. **Carrier Capability + Mode Matching**
```sql
-- Assuming you have a carriers table with mode capabilities
SELECT c.carrier_name, m.mode_name, m.equipment_type_required
FROM carriers c
JOIN modes_master m ON c.supported_modes LIKE CONCAT('%', m.mode_type, '%')
WHERE m.active = 'Yes' AND c.active = 'Yes';
```

### 3. **Lane Planning with Mode Selection**
```sql
-- For a specific lane, find suitable modes based on requirements
SELECT m.mode_id, m.mode_name, m.transit_time_days, m.base_cost_multiplier
FROM modes_master m
WHERE m.active = 'Yes'
AND m.transit_time_days <= [required_transit_time]
AND m.cost_efficiency_level IN ('High', 'Medium')
ORDER BY m.base_cost_multiplier, m.transit_time_days;
```

## 📈 Business Use Cases

### 1. **Procurement Planning**
- **Mode Selection**: Choose appropriate mode based on shipment characteristics
- **Cost Analysis**: Compare costs across different modes
- **Capacity Planning**: Understand volume and weight limitations

### 2. **Carrier Selection**
- **Capability Matching**: Match carriers to appropriate modes
- **Equipment Requirements**: Ensure carriers have required equipment
- **Performance Tracking**: Monitor mode-specific performance metrics

### 3. **Route Optimization**
- **Multi-leg Planning**: Design routes using multiple modes
- **Cost Optimization**: Balance cost and speed requirements
- **Risk Management**: Consider mode-specific risks and requirements

### 4. **Service Level Design**
- **Mode Integration**: Link service levels with appropriate modes
- **Performance Standards**: Set realistic performance expectations
- **Cost Modeling**: Develop accurate pricing models

## 🔧 Maintenance and Updates

### Adding New Modes
```sql
INSERT INTO modes_master (
    mode_id, mode_name, mode_type, description,
    transit_time_days, cost_efficiency_level, speed_level,
    -- ... other fields
) VALUES (
    'MODE-NEW-01', 'New Mode Name', 'TL', 'Description',
    2.0, 'High', 'Moderate'
    -- ... other values
);
```

### Updating Mode Parameters
```sql
UPDATE modes_master 
SET transit_time_days = 2.5,
    base_cost_multiplier = 1.10,
    updated_by = 'Admin'
WHERE mode_id = 'MODE-TL-01';
```

### Deactivating Modes
```sql
UPDATE modes_master 
SET active = 'No',
    updated_by = 'Admin'
WHERE mode_id = 'MODE-OLD-01';
```

## 📊 Performance Considerations

### Indexes
The table includes optimized indexes for:
- `mode_id`: Primary identifier lookups
- `mode_type`: Mode type filtering
- `active`: Active mode queries
- `cost_efficiency_level`: Cost-based filtering
- `speed_level`: Speed-based filtering
- `transit_time_days`: Transit time filtering

### Query Optimization
- Use views for common query patterns
- Filter by `active = 'Yes'` for current modes
- Use appropriate indexes for filtering operations
- Consider partitioning for large datasets

## 🔗 Related Tables

- **service_levels_master**: Service level definitions
- **carriers**: Carrier information and capabilities
- **lanes_master**: Lane definitions and requirements
- **commodities_master**: Commodity specifications
- **bids**: Bid responses and pricing

## 📝 Notes

- All modes are created with `active = 'Yes'` by default
- Cost multipliers are relative to standard TL (1.00)
- Transit times are indicative and may vary by lane
- Equipment requirements should be validated with carriers
- Performance targets are aspirational and should be monitored

---

**Last Updated**: August 2024  
**Version**: 1.0  
**Author**: RouteCraft Development Team 