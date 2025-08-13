# Fuel Surcharge Master System

## Overview
The Fuel Surcharge Master system is a comprehensive solution for managing dynamic fuel surcharge calculations in TL transportation. It automatically calculates fuel surcharges based on current diesel prices using predefined price slabs and maintains historical tracking for audit and analysis.

## System Architecture

### 1. **Core Tables**

#### `fuel_surcharge_master`
Main table containing fuel surcharge slabs and calculation rules.

#### `fuel_price_tracking`
Historical tracking of fuel prices from various sources (IOC, HP, BP, etc.).

#### `fuel_surcharge_calculation_history`
Audit trail of all surcharge calculations for compliance and analysis.

### 2. **Database Views**

#### `active_fuel_surcharges`
Shows all currently active fuel surcharge slabs.

#### `current_fuel_surcharge_calculator`
Helper view for understanding calculation methods.

#### `fuel_price_trend_analysis`
Analyzes fuel price trends and changes over time.

#### `surcharge_impact_analysis`
Summary statistics of surcharge impact across regions.

#### `latest_fuel_prices`
Most recent fuel prices by region and currency.

### 3. **Stored Procedure**

#### `CalculateFuelSurcharge`
Automated calculation of fuel surcharge with audit logging.

## Table Structure

### `fuel_surcharge_master`

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | BIGINT | Primary key | Auto-generated |
| `effective_date` | DATE | When surcharge comes into effect | `2025-06-01` |
| `fuel_price_min` | DECIMAL(8,2) | Lower bound of price slab | `85.00` |
| `fuel_price_max` | DECIMAL(8,2) | Upper bound of price slab | `89.99` |
| `fuel_surcharge_percentage` | DECIMAL(5,2) | Surcharge percentage | `2.00` |
| `base_fuel_price` | DECIMAL(8,2) | Reference price (no surcharge) | `80.00` |
| `change_per_rupee` | DECIMAL(5,2) | Variable surcharge per ₹1 | `0.50` |
| `currency` | ENUM | Currency for calculations | `INR` |
| `applicable_region` | VARCHAR(100) | Region-specific rules | `All India` |
| `is_active` | ENUM('Yes', 'No') | Active status | `Yes` |
| `surcharge_type` | ENUM | Calculation type | `Fixed`, `Variable`, `Hybrid` |
| `min_surcharge_amount` | DECIMAL(10,2) | Minimum surcharge amount | `100.00` |
| `max_surcharge_amount` | DECIMAL(10,2) | Maximum surcharge amount | `5000.00` |
| `surcharge_calculation_method` | ENUM | How surcharge is calculated | `Percentage` |
| `notes` | TEXT | Business rules and exceptions | `Subject to IOC rates` |

### `fuel_price_tracking`

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | BIGINT | Primary key | Auto-generated |
| `tracking_date` | DATE | Date of price tracking | `2025-06-01` |
| `fuel_price` | DECIMAL(8,2) | Current diesel price | `96.50` |
| `source` | VARCHAR(100) | Price source | `IOC`, `HP`, `BP` |
| `region` | VARCHAR(100) | Region for price | `All India` |
| `currency` | ENUM | Currency | `INR` |
| `is_official` | BOOLEAN | Official published rate | `TRUE` |
| `notes` | TEXT | Additional information | `Official IOC rate` |

### `fuel_surcharge_calculation_history`

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | BIGINT | Primary key | Auto-generated |
| `calculation_date` | DATE | Date of calculation | `2025-06-01` |
| `lane_id` | VARCHAR(100) | Lane identifier | `LANE-001` |
| `base_freight_amount` | DECIMAL(12,2) | Base freight | `10000.00` |
| `current_fuel_price` | DECIMAL(8,2) | Fuel price used | `96.50` |
| `applicable_surcharge_percentage` | DECIMAL(5,2) | Applied percentage | `6.00` |
| `surcharge_amount` | DECIMAL(12,2) | Calculated surcharge | `600.00` |
| `total_amount` | DECIMAL(12,2) | Total with surcharge | `10600.00` |
| `calculation_method` | VARCHAR(100) | Method used | `Stored Procedure` |

## Sample Data Structure

### India Fuel Surcharge Table (June 2025)

| Effective Date | Price Min | Price Max | Surcharge (%) | Base Price | Change/₹1 | Region | Notes |
|----------------|-----------|-----------|---------------|------------|-----------|---------|-------|
| 01-Jun-2025 | ₹80.00 | ₹84.99 | 0% | ₹80.00 | 0.5% | All India | No surcharge if ≤ ₹84.99 |
| 01-Jun-2025 | ₹85.00 | ₹89.99 | 2% | ₹80.00 | - | All India | Standard surcharge |
| 01-Jun-2025 | ₹90.00 | ₹94.99 | 4% | ₹80.00 | - | All India | Increased surcharge |
| 01-Jun-2025 | ₹95.00 | ₹99.99 | 6% | ₹80.00 | - | All India | Most lanes see this slab |
| 01-Jun-2025 | ₹100.00 | ₹104.99 | 8% | ₹80.00 | - | All India | High surcharge |
| 01-Jun-2025 | ₹105.00 | ₹110.00 | 10% | ₹80.00 | - | All India | Maximum surcharge cap |

### Regional Variations

| Region | Price Range | Surcharge | Notes |
|---------|-------------|-----------|-------|
| All India | ₹80-84.99 | 0% | Standard rates |
| Metro Cities | ₹80-84.99 | 0% | Higher sensitivity (0.6% per ₹1) |
| Metro Cities | ₹85-89.99 | 2.5% | Metro-specific rates |
| Metro Cities | ₹95-99.99 | 6.5% | Metro-specific rates |

## Calculation Logic

### 1. **Fixed Surcharge Calculation**
```
If Current Fuel Price = ₹96.50
→ Find slab where ₹95.00 ≤ price ≤ ₹99.99
→ Apply 6% surcharge on base freight
```

### 2. **Variable Surcharge Calculation**
```
If Base Fuel Price = ₹80.00
   Change per ₹1 = 0.5%
   Current Price = ₹96.50
   
Surcharge = (96.50 - 80.00) × 0.5% = 8.25%
```

### 3. **Hybrid Calculation**
Combines fixed slabs with variable adjustments for specific scenarios.

## Usage Examples

### 1. **Basic Surcharge Calculation**
```sql
-- Using the stored procedure
CALL CalculateFuelSurcharge(96.50, 10000.00, 'All India', 'INR', CURDATE(), 
    @surcharge_percentage, @surcharge_amount, @total_amount);

SELECT @surcharge_percentage as surcharge_percentage, 
       @surcharge_amount as surcharge_amount, 
       @total_amount as total_amount;
```

### 2. **Finding Applicable Surcharge Slab**
```sql
SELECT * FROM fuel_surcharge_master 
WHERE 96.50 BETWEEN fuel_price_min AND fuel_price_max
AND applicable_region = 'All India'
AND currency = 'INR'
AND is_active = 'Yes'
AND effective_date <= CURDATE()
ORDER BY effective_date DESC
LIMIT 1;
```

### 3. **Analyzing Fuel Price Trends**
```sql
SELECT * FROM fuel_price_trend_analysis 
WHERE region = 'All India'
ORDER BY tracking_date DESC
LIMIT 10;
```

### 4. **Surcharge Impact Analysis**
```sql
SELECT * FROM surcharge_impact_analysis 
WHERE currency = 'INR'
ORDER BY applicable_region;
```

## Integration Points

### 1. **Bidding System**
- **RFP Creation**: Include current fuel surcharge rates
- **Bid Evaluation**: Calculate total cost including surcharge
- **Rate Comparison**: Compare bids with and without surcharge

### 2. **Lane Management**
- **Dynamic Pricing**: Update lane rates based on fuel prices
- **Cost Optimization**: Identify lanes with high fuel impact
- **Route Planning**: Consider fuel surcharge in total cost

### 3. **Invoice Generation**
- **Automatic Calculation**: Apply surcharge based on current rates
- **Audit Trail**: Log all surcharge calculations
- **Compliance**: Ensure proper surcharge application

### 4. **Reporting and Analytics**
- **Cost Analysis**: Track surcharge impact on profitability
- **Trend Analysis**: Monitor fuel price movements
- **Regional Comparison**: Compare surcharge across regions

## Business Rules

### 1. **Effective Date Management**
- Surcharge slabs become effective on specified dates
- Multiple effective dates support rate revisions
- Historical slabs remain for audit purposes

### 2. **Price Range Validation**
- No overlapping price ranges within same effective date
- Continuous coverage from base price to maximum
- Clear boundaries for each surcharge slab

### 3. **Regional Variations**
- Different rates for different regions
- Metro cities may have higher sensitivity
- Rural areas may have different base prices

### 4. **Currency Support**
- Primary support for INR (Indian Rupees)
- Extensible to USD, EUR, GBP
- Exchange rate considerations for international lanes

## Automation Features

### 1. **Fuel Price Tracking**
- Daily price updates from official sources
- Multiple source support (IOC, HP, BP)
- Automatic price validation and alerts

### 2. **Surcharge Calculation**
- Real-time calculation based on current prices
- Automatic slab selection
- Historical calculation logging

### 3. **Rate Updates**
- Monthly or weekly rate revisions
- Bulk updates for multiple slabs
- Version control for rate changes

## Best Practices

### 1. **Data Management**
- Regular price updates from official sources
- Validate price ranges for logical consistency
- Maintain audit trail for all changes

### 2. **Performance Optimization**
- Use appropriate indexes for price range queries
- Partition tables by date for large datasets
- Optimize stored procedure calls

### 3. **Business Continuity**
- Backup surcharge tables regularly
- Test calculation procedures before production
- Monitor fuel price trends proactively

### 4. **Compliance and Audit**
- Log all surcharge calculations
- Maintain price source documentation
- Regular review of surcharge rates

## Troubleshooting

### Common Issues

1. **No Applicable Surcharge Found**
   - Check if fuel price is within defined ranges
   - Verify effective dates and active status
   - Ensure region and currency match

2. **Calculation Errors**
   - Validate input parameters
   - Check for NULL values in calculations
   - Verify decimal precision

3. **Performance Issues**
   - Review index usage
   - Check for missing price ranges
   - Monitor stored procedure execution time

### Data Validation

- Ensure price ranges are continuous
- Validate effective dates are logical
- Check for duplicate price ranges
- Verify surcharge percentages are reasonable

## Future Enhancements

### 1. **Advanced Pricing Models**
- Seasonal rate variations
- Distance-based surcharge adjustments
- Equipment-specific surcharge rates

### 2. **API Integration**
- Real-time fuel price APIs
- Automated price updates
- Third-party fuel price feeds

### 3. **Machine Learning**
- Predictive fuel price modeling
- Dynamic surcharge optimization
- Risk assessment and mitigation

### 4. **Multi-Currency Support**
- Real-time exchange rates
- International surcharge calculations
- Currency hedging strategies

## Monitoring and Alerts

### 1. **Price Threshold Alerts**
- Notify when prices approach slab boundaries
- Alert for significant price changes
- Warning for rate revision due dates

### 2. **Calculation Monitoring**
- Track calculation success rates
- Monitor performance metrics
- Alert for calculation errors

### 3. **Business Impact Tracking**
- Surcharge cost trends
- Regional impact analysis
- Profitability impact assessment

---

**Last Updated**: August 9, 2025  
**Version**: 1.0  
**Maintained By**: RouteCraft Development Team  
**System**: Fuel Surcharge Master for TL Transportation 