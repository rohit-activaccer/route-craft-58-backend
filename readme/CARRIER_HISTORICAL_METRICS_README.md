# Carrier Historical Metrics Table

## Overview

The **Carrier Historical Metrics** table is a comprehensive time-series data structure designed for Truckload (TL) transportation procurement. It captures performance data over time for each carrier, enabling data-driven decision making in carrier selection, bid weighting, and procurement strategies.

## 🎯 Purpose & Benefits

### Primary Objectives
- **Operational Reliability Assessment**: Track carrier performance consistency over time
- **Financial Discipline Evaluation**: Monitor billing accuracy and dispute patterns
- **Carrier Selection Optimization**: Use historical data for informed procurement decisions
- **Bid Weighting & Disqualification**: Apply performance-based scoring in bidding processes

### Business Value
- **Risk Mitigation**: Identify and avoid unreliable carriers
- **Cost Optimization**: Select carriers with proven performance records
- **Compliance Management**: Track regulatory and operational compliance
- **Performance Benchmarking**: Compare carriers across multiple KPIs

## 📊 Table Structure

### Core Identification Fields
| Field | Type | Description |
|-------|------|-------------|
| `carrier_id` | VARCHAR(100) | Unique carrier reference (FK to carrier_master) |
| `carrier_name` | VARCHAR(255) | Human-readable carrier name |
| `period_type` | ENUM | Time granularity (Weekly/Monthly/Quarterly/Yearly) |
| `period_start_date` | DATE | Start of reporting period |
| `period_end_date` | DATE | End of reporting period |
| `period_label` | VARCHAR(50) | Human-readable period (e.g., "May 2025", "Q1 FY25") |

### Lane & Equipment Context
| Field | Type | Description |
|-------|------|-------------|
| `lane_id` | VARCHAR(100) | Optional lane identifier |
| `origin_location` | VARCHAR(255) | Origin city/state |
| `destination_location` | VARCHAR(255) | Destination city/state |
| `equipment_type` | VARCHAR(100) | Equipment type (32ft SXL, Reefer, etc.) |

### Load Volume Metrics
| Field | Type | Description | Formula |
|-------|------|-------------|---------|
| `total_loads_assigned` | INT | Loads offered to carrier | - |
| `loads_accepted` | INT | Loads accepted by carrier | - |
| `loads_rejected` | INT | Loads rejected by carrier | Assigned - Accepted |
| `loads_cancelled_by_carrier` | INT | Loads cancelled after acceptance | - |
| `loads_completed` | INT | Successfully completed loads | - |

### Performance Rate Metrics (Percentages)
| Field | Type | Description | Formula |
|-------|------|-------------|---------|
| `acceptance_rate` | DECIMAL(5,2) | Load acceptance percentage | (Accepted / Assigned) × 100 |
| `completion_rate` | DECIMAL(5,2) | Load completion percentage | (Completed / Accepted) × 100 |
| `on_time_pickup_rate` | DECIMAL(5,2) | On-time pickup percentage | (On-time pickups / Total) × 100 |
| `on_time_delivery_rate` | DECIMAL(5,2) | On-time delivery percentage | (On-time deliveries / Total) × 100 |
| `overall_on_time_performance` | DECIMAL(5,2) | Combined OTP score | (Pickup OTP + Delivery OTP) / 2 |

### Absolute Count Metrics
| Field | Type | Description |
|-------|------|-------------|
| `late_pickup_count` | INT | Count of late pickups |
| `late_delivery_count` | INT | Count of late deliveries |
| `early_pickup_count` | INT | Count of early pickups (good) |
| `early_delivery_count` | INT | Count of early deliveries (good) |

### Financial & Billing Metrics
| Field | Type | Description |
|-------|------|-------------|
| `billing_accuracy_rate` | DECIMAL(5,2) | % of invoices without disputes |
| `billing_disputes_count` | INT | Number of billing disputes |
| `average_detention_time_hours` | DECIMAL(6,2) | Avg. waiting time during loading/unloading |
| `detention_charges_applied` | DECIMAL(10,2) | Total detention charges applied |

### Claims & Quality Metrics
| Field | Type | Description | Formula |
|-------|------|-------------|---------|
| `claim_incidents_count` | INT | Count of damage/loss claims | - |
| `claim_percentage` | DECIMAL(5,2) | Claims per load percentage | (Claims / Loads) × 100 |
| `customer_complaints_count` | INT | Count of customer complaints | - |
| `quality_issues_count` | INT | Other quality-related issues | - |

### Rating & Scoring
| Field | Type | Description | Range |
|-------|------|-------------|-------|
| `performance_rating` | DECIMAL(3,1) | Internal performance score | 1.0 - 5.0 |
| `scorecard_grade` | ENUM | Letter grade classification | A+, A, A-, B+, B, B-, C+, C, C-, D, E |
| `risk_score` | DECIMAL(5,2) | Risk assessment score | 0-100 (lower = better) |

### Additional Performance Metrics
| Field | Type | Description |
|-------|------|-------------|
| `average_transit_time_hours` | DECIMAL(6,2) | Average pickup to delivery time |
| `fuel_efficiency_score` | DECIMAL(5,2) | Fuel consumption efficiency rating |
| `driver_behavior_score` | DECIMAL(5,2) | Driver conduct and professionalism |

### Status & Flags
| Field | Type | Description |
|-------|------|-------------|
| `is_blacklisted` | BOOLEAN | Whether carrier is blacklisted |
| `is_preferred_carrier` | BOOLEAN | Whether carrier was preferred |
| `compliance_status` | ENUM | Compliance status (Compliant/Non-Compliant/Under Review) |

## 🔗 Relationships

### Foreign Keys
- `carrier_id` → `carrier_master.carrier_id` (CASCADE DELETE)

### Unique Constraints
- Composite unique key: `(carrier_id, period_type, period_start_date, lane_id)`
- Prevents duplicate metrics for the same carrier, period, and lane combination

## 📈 Analytical Views

### 1. `active_carriers_recent_performance`
- **Purpose**: Recent performance snapshot for active carriers
- **Timeframe**: Last 3 months
- **Use Case**: Quick carrier assessment for immediate procurement needs

### 2. `carrier_performance_summary`
- **Purpose**: Aggregated performance over 6 months
- **Metrics**: Averages, totals, and grade ranges
- **Use Case**: Long-term carrier evaluation and strategic planning

### 3. `lane_performance_analysis`
- **Purpose**: Performance analysis by specific routes
- **Metrics**: Lane-specific averages and carrier counts
- **Use Case**: Route optimization and carrier allocation

### 4. `carrier_risk_assessment`
- **Purpose**: Risk categorization and assessment
- **Categories**: Low, Medium-Low, Medium, High, Very High Risk
- **Use Case**: Risk management and compliance monitoring

### 5. `procurement_decision_support`
- **Purpose**: Automated procurement recommendations
- **Recommendations**: 
  - Preferred - High Priority
  - Preferred - Standard Priority
  - Acceptable - Monitor
  - Review Required - Low Priority
- **Use Case**: Automated carrier selection and bid weighting

## 🚀 Usage Examples

### 1. Carrier Selection for New Load
```sql
SELECT 
    carrier_id,
    carrier_name,
    avg_acceptance_rate,
    avg_otp,
    procurement_recommendation
FROM procurement_decision_support
WHERE equipment_type = '32ft SXL'
  AND origin_location LIKE '%Mumbai%'
  AND destination_location LIKE '%Delhi%'
ORDER BY avg_otp DESC;
```

### 2. Performance Trend Analysis
```sql
SELECT 
    period_label,
    acceptance_rate,
    overall_on_time_performance,
    performance_rating
FROM carrier_historical_metrics
WHERE carrier_id = 'CAR-001'
  AND period_start_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
ORDER BY period_start_date;
```

### 3. Risk Assessment Report
```sql
SELECT 
    carrier_name,
    risk_category,
    COUNT(*) as periods_at_risk
FROM carrier_risk_assessment
WHERE risk_category IN ('High Risk', 'Very High Risk')
GROUP BY carrier_name, risk_category
ORDER BY periods_at_risk DESC;
```

## 📊 KPI Thresholds & Scoring

### Acceptance Rate Tiers
- **Excellent**: ≥ 90%
- **Good**: 80-89%
- **Acceptable**: 70-79%
- **Poor**: < 70%

### On-Time Performance Tiers
- **Excellent**: ≥ 95%
- **Good**: 90-94%
- **Acceptable**: 85-89%
- **Poor**: < 85%

### Performance Rating to Grade Mapping
- **A+**: 4.8-5.0
- **A**: 4.5-4.7
- **A-**: 4.2-4.4
- **B+**: 3.8-4.1
- **B**: 3.5-3.7
- **B-**: 3.2-3.4
- **C+**: 2.8-3.1
- **C**: 2.5-2.7
- **C-**: 2.2-2.4
- **D**: 1.5-2.1
- **E**: < 1.5

## 🔧 Implementation

### Python Script
- **File**: `create_carrier_historical_metrics_table.py`
- **Features**: 
  - Table creation
  - Sample data generation
  - View creation
  - Comprehensive reporting

### SQL Schema
- **File**: `carrier_historical_metrics_schema.sql`
- **Features**: 
  - Direct MySQL execution
  - View definitions
  - Index optimization

### Sample Data
- **Coverage**: 12 months of historical data
- **Carriers**: 5 sample carriers
- **Lanes**: 5 major routes
- **Equipment**: Multiple types (SXL, Trailer, Container, Reefer)

## 📋 Maintenance & Updates

### Data Refresh Frequency
- **Weekly**: For high-volume carriers
- **Monthly**: Standard practice for most carriers
- **Quarterly**: For seasonal analysis
- **Yearly**: For annual performance reviews

### Data Quality Checks
- Validate percentage calculations
- Ensure date range consistency
- Check for negative values in count fields
- Verify foreign key relationships

### Performance Optimization
- Regular index maintenance
- Partitioning for large datasets
- Archive old data (older than 2 years)
- Monitor query performance

## 🎯 Procurement Integration

### Bid Weighting Formula
```
Carrier Score = (Acceptance Rate × 0.25) + 
                (OTP × 0.30) + 
                (Billing Accuracy × 0.20) + 
                (Performance Rating × 0.15) + 
                (Risk Factor × 0.10)
```

### Auto-Disqualification Rules
- Acceptance Rate < 70% (3 consecutive periods)
- OTP < 85% (3 consecutive periods)
- Risk Score > 80 (2 consecutive periods)
- Compliance Status = 'Non-Compliant'

### Preferred Carrier Criteria
- Acceptance Rate ≥ 90%
- OTP ≥ 95%
- Billing Accuracy ≥ 95%
- Performance Rating ≥ 4.0
- Risk Score ≤ 30

## 🔍 Troubleshooting

### Common Issues
1. **Foreign Key Violations**: Ensure carrier exists in carrier_master
2. **Duplicate Records**: Check unique constraint violations
3. **Data Type Mismatches**: Verify decimal precision for percentage fields
4. **Date Range Errors**: Ensure period_end_date > period_start_date

### Performance Issues
1. **Slow Queries**: Check index usage with EXPLAIN
2. **Large Result Sets**: Use pagination and date filtering
3. **View Performance**: Consider materialized views for complex aggregations

## 📚 Related Documentation

- [Carrier Master Table](../README.md#carrier-master-table)
- [Routing Guide Schema](../routing_guide_schema.sql)
- [Database Configuration](../app/config/database.py)
- [API Endpoints](../app/api/)

## 🤝 Support & Contributions

For questions, issues, or contributions:
1. Review existing documentation
2. Check database logs for errors
3. Validate data integrity
4. Test with sample data first

---

**Last Updated**: August 2024  
**Version**: 1.0  
**Author**: RouteCraft Development Team 