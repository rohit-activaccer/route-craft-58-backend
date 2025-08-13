# Seasons Master Table

## Overview

The **Seasons Master** table is a comprehensive reference table that manages seasonal variations in transport procurement, including cost impacts, capacity risks, SLA adjustments, and regional effects. This table is essential for seasonal planning, rate adjustments, and risk management in the transport procurement system.

## Table Structure

### Core Season Information
- **`season_id`** (VARCHAR(30)): Unique season identifier (e.g., SEASON-01)
- **`season_name`** (VARCHAR(100)): Human-readable season name (e.g., Monsoon, Peak Festive)
- **`start_date`** (DATE): Season start date
- **`end_date`** (DATE): Season end date
- **`impact_type`** (ENUM): Primary impact of the season (Cost Increase, Capacity Shortage, SLA Risk, None, Mixed)

### Regional and Lane Impact
- **`affected_regions`** (TEXT): Comma-separated list of affected regions/states
- **`affected_lanes`** (TEXT): Optional list of Lane IDs impacted (comma-separated)
- **`applicable_equipment_types`** (TEXT): Comma-separated list of affected equipment types

### Business Impact Parameters
- **`rate_multiplier_percent`** (DECIMAL(5,2)): Rate premium percentage (e.g., 5.00 for 5%)
- **`sla_adjustment_days`** (INT): Buffer days to add to SLA (can be negative)
- **`capacity_risk_level`** (ENUM): Expected capacity risk level (High, Medium, Low)
- **`carrier_participation_impact`** (DECIMAL(5,2)): Expected drop in carrier availability (%)

### Status and Management
- **`is_active`** (BOOLEAN): Whether this season is currently active
- **`notes`** (TEXT): Additional descriptive information about the season

### Audit Fields
- **`created_by`** (VARCHAR(50)): User who created the record
- **`updated_by`** (VARCHAR(50)): User who last updated the record
- **`created_at`** (TIMESTAMP): Record creation timestamp
- **`updated_at`** (TIMESTAMP): Record update timestamp

## Season Categories

### 1. **Weather-Based Seasons**
- **Monsoon Season** (Jul-Sep): Heavy rainfall affects road conditions
- **Summer Peak** (Apr-Jun): High temperature affects perishable goods
- **Winter Peak** (Dec-Jan): Winter weather affects northern routes
- **Pre-Monsoon** (Jun): Road preparation and maintenance
- **Post-Monsoon** (Oct): Road damage assessment and repair

### 2. **Commercial Seasons**
- **Festive Peak** (Oct-Nov): Diwali and festival season
- **E-commerce Peak** (Nov-Dec): Black Friday and holiday shopping
- **Year-End Rush** (Feb-Mar): Quarter-end and fiscal deadlines
- **Export Peak** (Sep-Dec): Peak export season with port congestion

### 3. **Agricultural Seasons**
- **Harvest Season** (Mar-May): Agricultural freight spikes
- **Agricultural Off-Season** (Jan-Feb): Low agricultural activity

### 4. **Special Events**
- **Election Season** (Apr-May): Political rallies and security measures
- **Construction Season** (Mar-Jun): Infrastructure project peaks

## Database Views

### 1. **`active_seasons_overview`**
Comprehensive overview of all active seasons with key specifications.

### 2. **`high_impact_seasons`**
Seasons with high capacity risk or significant rate impacts (>5%).

### 3. **`seasonal_cost_analysis`**
Cost impact analysis with categorization of cost increases/decreases.

### 4. **`regional_season_impact`**
Regional analysis showing season distribution and average impacts by region.

### 5. **`equipment_specific_seasons`**
Seasons that specifically affect certain equipment types.

## Sample Queries

### Basic Season Selection
```sql
-- Get all active seasons for a specific date
SELECT * FROM seasons_master 
WHERE is_active = TRUE 
AND '2025-10-20' BETWEEN start_date AND end_date;

-- Find seasons affecting specific regions
SELECT * FROM seasons_master 
WHERE is_active = TRUE 
AND affected_regions LIKE '%Maharashtra%';
```

### Advanced Filtering
```sql
-- High-risk seasons with cost impact
SELECT * FROM high_impact_seasons 
WHERE capacity_risk_level = 'High' 
AND rate_multiplier_percent > 5.00;

-- Equipment-specific seasonal impacts
SELECT * FROM equipment_specific_seasons 
WHERE applicable_equipment_types LIKE '%Reefer%';
```

### Seasonal Analysis
```sql
-- Seasonal cost impact summary
SELECT 
    impact_type,
    COUNT(*) as season_count,
    AVG(rate_multiplier_percent) as avg_rate_impact,
    AVG(sla_adjustment_days) as avg_sla_adjustment
FROM seasons_master 
WHERE is_active = TRUE 
GROUP BY impact_type;

-- Regional season distribution
SELECT 
    affected_regions,
    COUNT(*) as total_seasons,
    SUM(CASE WHEN capacity_risk_level = 'High' THEN 1 ELSE 0 END) as high_risk_count
FROM seasons_master 
WHERE is_active = TRUE 
GROUP BY affected_regions;
```

## Integration Examples

### 1. Service Level Adjustments
```sql
-- Adjust SLA based on seasonal factors
SELECT 
    s.service_level_name,
    s.max_transit_time_days,
    sm.sla_adjustment_days,
    (s.max_transit_time_days + sm.sla_adjustment_days) as adjusted_transit_time
FROM service_levels_master s
CROSS JOIN seasons_master sm
WHERE sm.is_active = TRUE 
AND sm.affected_regions LIKE '%All India%'
AND CURRENT_DATE BETWEEN sm.start_date AND sm.end_date;
```

### 2. Rate Calculations
```sql
-- Calculate seasonal rate adjustments
SELECT 
    e.equipment_name,
    e.standard_rate_per_km,
    sm.rate_multiplier_percent,
    (e.standard_rate_per_km * (1 + sm.rate_multiplier_percent / 100)) as adjusted_rate
FROM equipment_types_master e
CROSS JOIN seasons_master sm
WHERE sm.is_active = TRUE 
AND sm.applicable_equipment_types LIKE CONCAT('%', e.vehicle_body_type, '%')
AND CURRENT_DATE BETWEEN sm.start_date AND sm.end_date;
```

### 3. Capacity Risk Assessment
```sql
-- Assess capacity risk for specific routes
SELECT 
    sm.season_name,
    sm.capacity_risk_level,
    sm.carrier_participation_impact,
    sm.affected_regions
FROM seasons_master sm
WHERE sm.is_active = TRUE 
AND sm.affected_regions LIKE '%Maharashtra%'
AND CURRENT_DATE BETWEEN sm.start_date AND sm.end_date
ORDER BY sm.capacity_risk_level DESC;
```

## Business Use Cases

### 1. **Procurement Planning**
- Seasonal rate adjustments for RFPs
- Capacity risk assessment and mitigation
- Equipment availability planning
- Regional impact analysis

### 2. **Cost Management**
- Dynamic pricing based on seasonal factors
- Budget planning for seasonal variations
- Rate benchmarking across seasons
- Cost impact analysis and reporting

### 3. **Service Level Management**
- SLA adjustments for seasonal conditions
- Transit time planning with seasonal buffers
- Risk mitigation strategies
- Performance tracking by season

### 4. **Carrier Management**
- Seasonal capacity planning
- Carrier availability forecasting
- Rate negotiation based on seasonal factors
- Performance expectations by season

### 5. **Route Planning**
- Seasonal route optimization
- Regional impact consideration
- Equipment type selection by season
- Risk assessment for specific lanes

## Maintenance and Updates

### Regular Updates
- Seasonal date adjustments
- Rate multiplier updates
- Regional impact changes
- New season additions
- Historical season archiving

### Data Quality
- Validate date ranges
- Update rate multipliers based on market data
- Verify regional coverage
- Maintain equipment type mappings
- Regular impact assessment reviews

## Performance Considerations

### Indexes
- Primary key on `id`
- Unique index on `season_id`
- Date range indexes for efficient queries
- Boolean indexes for active/inactive filtering
- Composite indexes for common query patterns

### Query Optimization
- Use views for common analysis scenarios
- Leverage ENUM constraints for efficient filtering
- Consider partitioning for large datasets
- Regular statistics updates

## Related Tables

- **`service_levels_master`**: Service level requirements and seasonal adjustments
- **`modes_master`**: Transportation modes and seasonal capacity impacts
- **`equipment_types_master`**: Equipment specifications and seasonal requirements
- **`lanes_master`**: Route-specific seasonal impacts
- **`carrier_master`**: Carrier seasonal availability and performance

## Notes

1. **Season ID Convention**: Follows SEASON-[TYPE]-[YEAR] format for easy identification
2. **Date Management**: Seasons can span across calendar years
3. **Active Status**: Only active seasons are considered in procurement planning
4. **Regional Coverage**: "All India" indicates nationwide impact
5. **Equipment Specificity**: Empty equipment types means all equipment affected
6. **Rate Multipliers**: Can be negative for cost decreases during off-peak periods
7. **SLA Adjustments**: Positive values add buffer days, negative values reduce time
8. **Integration**: Designed to work seamlessly with other master tables

## Future Enhancements

- Seasonal trend analysis and forecasting
- Machine learning for impact prediction
- Integration with weather APIs
- Historical performance tracking by season
- Automated seasonal adjustment recommendations
- Multi-year seasonal pattern analysis
- Regional micro-climate considerations
- Equipment-specific seasonal performance metrics 