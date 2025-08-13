# Service Levels Master Table Documentation

## 📋 Overview

The **Service Levels Master** table is a comprehensive reference system for truckload (TL) transport procurement that defines service quality, speed, and operational expectations for shipments on various lanes. This table serves as the foundation for:

- Setting clear carrier expectations
- Driving SLA-based performance tracking
- Applying differential pricing (e.g., Express vs Standard)
- Defining eligibility for certain lanes
- Supporting procurement decisions

## 🏗️ Table Structure

### Core Table: `service_levels_master`

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| `id` | INT AUTO_INCREMENT | Primary key | 1, 2, 3... |
| `service_level_id` | VARCHAR(20) | Unique identifier | SL-EXP-01 |
| `service_level_name` | VARCHAR(100) | Descriptive name | Express Delivery |
| `description` | TEXT | Detailed description | Fast turnaround priority service |
| `max_transit_time_days` | DECIMAL(4,1) | Maximum transit time in days | 1.5, 3.0, 5.0 |
| `allowed_delay_buffer_hours` | DECIMAL(4,1) | Permissible delay threshold | 1.0, 2.0, 4.0 |
| `fixed_departure_time` | ENUM('Yes','No') | Fixed pickup time requirement | Yes/No |
| `fixed_delivery_time` | ENUM('Yes','No') | Fixed delivery time requirement | Yes/No |
| `mode` | VARCHAR(20) | Transport mode | TL, LTL, Rail-Road |
| `carrier_response_time_hours` | DECIMAL(4,1) | Expected carrier response time | 12.0, 24.0, 48.0 |
| `sla_type` | ENUM('Hard SLA','Soft SLA') | SLA enforcement type | Hard SLA/Soft SLA |
| `penalty_applicable` | ENUM('Yes','No') | Penalty for SLA failure | Yes/No |
| `penalty_rule_id` | VARCHAR(50) | Link to penalty definition | PEN-EXP-01 |
| `priority_tag` | ENUM('High','Medium','Low') | Planning priority | High/Medium/Low |
| `enabled_for_bidding` | ENUM('Yes','No') | Available for RFP selection | Yes/No |
| `service_category` | VARCHAR(50) | Service classification | Standard, Premium, Express |
| `pickup_time_window_start` | TIME | Pickup window start time | 08:00:00 |
| `pickup_time_window_end` | TIME | Pickup window end time | 10:00:00 |
| `delivery_time_window_start` | TIME | Delivery window start time | 14:00:00 |
| `delivery_time_window_end` | TIME | Delivery window end time | 16:00:00 |
| `weekend_operations` | ENUM('Yes','No') | Weekend service availability | Yes/No |
| `holiday_operations` | ENUM('Yes','No') | Holiday service availability | Yes/No |
| `temperature_controlled` | ENUM('Yes','No') | Temperature control requirement | Yes/No |
| `security_required` | ENUM('Yes','No') | Security escort requirement | Yes/No |
| `insurance_coverage` | DECIMAL(10,2) | Required insurance amount | 50000.00 |
| `fuel_surcharge_applicable` | ENUM('Yes','No') | Fuel surcharge applies | Yes/No |
| `detention_charges_applicable` | ENUM('Yes','No') | Detention charges apply | Yes/No |
| `remarks` | TEXT | Additional notes | Used for high-value shipments |
| `created_by` | VARCHAR(100) | Record creator | System, User123 |
| `updated_by` | VARCHAR(100) | Last updater | System, User123 |
| `created_at` | TIMESTAMP | Creation timestamp | Auto-generated |
| `updated_at` | TIMESTAMP | Last update timestamp | Auto-generated |

## 🎯 Service Level Categories

### 1. **Standard Services**
- **SL-STD-01**: Standard Delivery (3 days, Soft SLA)
- **SL-ECO-01**: Economy Service (5 days, Soft SLA)

### 2. **Premium Services**
- **SL-TD-01**: Time-Definite (2 days, Hard SLA)
- **SL-SCH-01**: Scheduled Pickup/Delivery (2.5 days, Hard SLA)

### 3. **Express Services**
- **SL-EXP-01**: Express Delivery (1.5 days, Hard SLA)

### 4. **Dedicated Services**
- **SL-DED-01**: Dedicated Service (4 days, Soft SLA)

### 5. **Specialized Services**
- **SL-TEMP-01**: Temperature Controlled (2.5 days, Hard SLA)
- **SL-WG-01**: White Glove Service (3.5 days, Hard SLA)
- **SL-OVS-01**: Oversized Cargo (5 days, Soft SLA)
- **SL-INT-01**: Intermodal Service (7 days, Soft SLA)

## 📊 Database Views

### 1. **service_level_summary**
Aggregated view showing service level statistics by category:
```sql
SELECT * FROM service_level_summary;
```

**Output Columns:**
- `service_category`: Service classification
- `total_service_levels`: Count of services in category
- `penalty_applicable_count`: Services with penalties
- `hard_sla_count`: Services with Hard SLA
- `avg_transit_time`: Average transit time
- `avg_response_time`: Average carrier response time

### 2. **active_service_levels**
View of all enabled service levels for bidding:
```sql
SELECT * FROM active_service_levels;
```

### 3. **time_critical_services**
View of services with strict time requirements:
```sql
SELECT * FROM time_critical_services;
```

### 4. **service_level_pricing_tiers**
View for pricing tier management (future enhancement)

## 🔧 Usage Examples

### 1. **Find Services by Transit Time**
```sql
SELECT service_level_id, service_level_name, max_transit_time_days
FROM service_levels_master
WHERE max_transit_time_days <= 2.0
ORDER BY max_transit_time_days;
```

### 2. **Find Hard SLA Services**
```sql
SELECT service_level_id, service_level_name, penalty_applicable
FROM service_levels_master
WHERE sla_type = 'Hard SLA';
```

### 3. **Find Services by Category**
```sql
SELECT service_level_id, service_level_name, service_category
FROM service_levels_master
WHERE service_category = 'Premium'
AND enabled_for_bidding = 'Yes';
```

### 4. **Find Temperature-Controlled Services**
```sql
SELECT service_level_id, service_level_name, max_transit_time_days
FROM service_levels_master
WHERE temperature_controlled = 'Yes';
```

## 🚀 Implementation Details

### Table Creation
The table is created using the SQL script: `service_levels_master_schema.sql`

### Data Population
Sample data is inserted using: `create_service_levels_master_table.py`

### Key Features
- **Auto-incrementing ID**: Primary key for internal references
- **Audit Trail**: Created/updated timestamps and user tracking
- **Flexible Enums**: Structured choices for categorical fields
- **Comprehensive Coverage**: All major service level parameters included

## 🔗 Related Tables

This table serves as a master reference for:
- **Bid Management**: Service level selection during procurement
- **Carrier Performance**: SLA tracking and measurement
- **Pricing Models**: Service level-based pricing tiers
- **Route Planning**: Service level compatibility with lanes

## 📈 Future Enhancements

1. **Dynamic Pricing**: Integration with pricing engine
2. **Performance Analytics**: Historical SLA performance tracking
3. **Carrier Matching**: Automated carrier-service level compatibility
4. **Market Intelligence**: Service level demand analysis
5. **Compliance Tracking**: Regulatory requirement mapping

## 🛠️ Maintenance

### Regular Tasks
- Review and update service level definitions
- Monitor SLA performance metrics
- Update penalty rules and amounts
- Validate carrier compliance

### Data Quality
- Ensure unique service level IDs
- Validate transit time ranges
- Check SLA type consistency
- Monitor enabled/disabled status

---

**Last Updated**: January 2025  
**Version**: 1.0  
**Maintained By**: RouteCraft Development Team 