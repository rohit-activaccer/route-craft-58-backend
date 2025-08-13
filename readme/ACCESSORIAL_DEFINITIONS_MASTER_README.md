# Accessorial Definitions Master Table

## Overview
The `accessorial_definitions_master` table is a comprehensive master data table that defines all accessorial charges applicable to TL (Truck Load) transportation services. This table serves as the single source of truth for accessorial charge definitions, rates, and business rules.

## Table Structure

### Core Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `accessorial_id` | VARCHAR(100) | Unique identifier for the accessorial charge | `ACC-DET-2025` |
| `accessorial_name` | VARCHAR(255) | Descriptive name of the charge | `Detention – Delivery Site` |
| `description` | TEXT | Detailed explanation of when and how the charge applies | `Charged when truck waits beyond free time at delivery location` |
| `applies_to` | ENUM | When the charge applies | `Pickup`, `Delivery`, `In-Transit`, `General` |
| `trigger_condition` | TEXT | Specific condition that triggers this charge | `After 2 hours of free time` |

### Rate and Pricing Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `rate_type` | ENUM | How the rate is calculated | `Flat Fee`, `Per Hour`, `Per KM`, `Per Attempt`, `Per Pallet`, `Per MT`, `Per Stop` |
| `rate_value` | DECIMAL(10,2) | Numeric amount for the rate | `400.00` |
| `unit` | ENUM | Unit of measurement for the rate | `Hours`, `KM`, `Pallet`, `Stop`, `Attempt`, `MT`, `Trip` |
| `taxable` | ENUM('Yes', 'No') | Whether GST or other taxes apply | `Yes` |
| `included_in_base` | ENUM('Yes', 'No') | Whether charge is bundled in base rate | `No` |

### Business Logic Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `invoice_code` | VARCHAR(100) | Code for invoice/GL mapping systems | `DET-DEL` |
| `gl_mapping` | VARCHAR(100) | General Ledger account mapping | `GL-4001` |
| `applicable_equipment_types` | TEXT | Equipment types this charge applies to | `All equipment types`, `Reefer, insulated trailers only` |
| `carrier_editable_in_bid` | ENUM('Yes', 'No') | Whether carriers can propose their own rates | `No` |
| `is_active` | ENUM('Yes', 'No') | Whether this accessorial is currently active | `Yes` |

### Temporal and Audit Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `effective_from` | DATE | Date from which this accessorial is effective | `2025-08-09` |
| `effective_to` | DATE | Date until which this accessorial is effective (NULL for indefinite) | `NULL` |
| `created_at` | TIMESTAMP | Record creation timestamp | Auto-generated |
| `updated_at` | TIMESTAMP | Record update timestamp | Auto-generated |
| `created_by` | VARCHAR(100) | User who created the record | `System` |
| `updated_by` | VARCHAR(100) | User who last updated the record | `System` |

## Common Accessorial Charges in Indian TL Logistics

### 1. Detention Charges
- **Purpose**: Compensate for time lost due to delays at pickup/delivery locations
- **Rate Type**: Per Hour
- **Typical Rates**: ₹350-400 per hour
- **Free Time**: Usually 1.5-2 hours before charges apply

### 2. Multi-stop Fees
- **Purpose**: Additional charges for deliveries at multiple drop-off points
- **Rate Type**: Per Stop or Flat Fee
- **Typical Rates**: ₹500-800 per additional stop
- **Negotiable**: Often negotiable based on distance and complexity

### 3. Loading/Unloading Assistance
- **Purpose**: When driver or vehicle helps with loading/unloading operations
- **Rate Type**: Per MT (Metric Ton)
- **Typical Rates**: ₹150 per MT
- **Documentation**: Usually requires supervisor signature

### 4. Toll Charges
- **Purpose**: Highway and bridge toll fees for certain routes
- **Rate Type**: Flat Fee
- **Typical Rates**: ₹250-800 per trip
- **Route Specific**: Varies by expressway/state highway

### 5. Escort Fees
- **Purpose**: For high-value or over-dimensional cargo requiring escort
- **Rate Type**: Flat Fee
- **Typical Rates**: ₹2000-5000 per trip
- **Requirements**: Special permits and route approval

### 6. Fuel Surcharge
- **Purpose**: Variable percentage based on diesel price index
- **Rate Type**: Per KM
- **Typical Rates**: ₹2.50 per KM
- **Variability**: Changes monthly based on fuel price index

### 7. Night Delivery Charges
- **Purpose**: For delivery outside regular business hours
- **Rate Type**: Flat Fee
- **Typical Rates**: ₹800 per trip
- **Time Window**: 8 PM to 6 AM

### 8. Reattempt Fees
- **Purpose**: When delivery is unsuccessful and retried
- **Rate Type**: Per Attempt
- **Typical Rates**: ₹300 per attempt
- **Documentation**: Proof of failed attempt required

### 9. Weighbridge Fees
- **Purpose**: Charged when weighing is mandatory at checkpoints
- **Rate Type**: Flat Fee
- **Typical Rates**: ₹200 per trip
- **Mandatory**: Required at borders and checkpoints

### 10. Temperature Monitoring
- **Purpose**: Additional charge for temperature-controlled shipments
- **Rate Type**: Per Hour
- **Typical Rates**: ₹50 per hour
- **Equipment**: Only for reefer and insulated trailers

## Business Rules and Logic

### 1. Taxability Rules
- **Standard Charges**: Most accessorial charges are taxable (GST applicable)
- **Fuel Surcharge**: Always taxable
- **Toll Charges**: Usually non-taxable (government charges)
- **Documentation**: Taxable as service charges

### 2. Equipment Type Applicability
- **Universal**: `All equipment types` - applies to all vehicles
- **Specialized**: `Reefer, insulated trailers only` - specific equipment requirements
- **Restricted**: `Specialized equipment only` - limited applicability

### 3. Carrier Editability
- **Fixed Rates**: `No` - carriers cannot modify in bids (e.g., toll charges, detention)
- **Negotiable Rates**: `Yes` - carriers can propose rates (e.g., multi-stop, loading assistance)

### 4. Base Rate Inclusion
- **Separate Billing**: `No` - charged separately from base freight
- **Bundled**: `Yes` - included in base rate (e.g., fuel surcharge)

## Database Views

### 1. `active_accessorials`
Shows all currently active accessorials with key information for bidding and operations.

### 2. `accessorial_summary_by_category`
Provides summary statistics grouped by `applies_to` category for reporting and analysis.

### 3. `rate_type_analysis`
Analyzes accessorial charges by rate type with statistical information.

### 4. `taxable_accessorials_analysis`
Compares taxable vs non-taxable accessorials across different categories.

### 5. `carrier_editable_accessorials`
Lists all accessorials that carriers can modify during the bidding process.

### 6. `high_value_accessorials`
Identifies accessorials with rates above ₹1000 for special attention.

### 7. `equipment_specific_accessorials`
Shows accessorials that apply only to specific equipment types.

## Usage Examples

### 1. Finding All Detention-Related Charges
```sql
SELECT * FROM accessorial_definitions_master 
WHERE accessorial_name LIKE '%Detention%' 
AND is_active = 'Yes';
```

### 2. Calculating Total Accessorial Cost for a Route
```sql
SELECT 
    applies_to,
    SUM(rate_value) as total_cost,
    COUNT(*) as charge_count
FROM accessorial_definitions_master 
WHERE is_active = 'Yes' 
AND applies_to IN ('Pickup', 'Delivery', 'In-Transit')
GROUP BY applies_to;
```

### 3. Finding Negotiable Accessorials
```sql
SELECT * FROM accessorial_definitions_master 
WHERE carrier_editable_in_bid = 'Yes' 
AND is_active = 'Yes'
ORDER BY applies_to, accessorial_name;
```

### 4. Taxable vs Non-Taxable Summary
```sql
SELECT 
    taxable,
    COUNT(*) as total_charges,
    AVG(rate_value) as avg_rate
FROM accessorial_definitions_master 
WHERE is_active = 'Yes'
GROUP BY taxable;
```

## Data Maintenance

### Adding New Accessorials
1. Ensure unique `accessorial_id` following naming convention
2. Set appropriate `effective_from` date
3. Configure business rules (taxable, carrier editable, etc.)
4. Set `is_active = 'Yes'`

### Modifying Existing Accessorials
1. Update `updated_at` timestamp automatically
2. Track changes in `updated_by` field
3. Consider versioning for rate changes
4. Maintain audit trail

### Deactivating Accessorials
1. Set `is_active = 'No'`
2. Set `effective_to` date if applicable
3. Ensure no active shipments are affected
4. Communicate changes to stakeholders

## Integration Points

### 1. Bidding System
- Provides accessorial definitions for RFP creation
- Enables carriers to understand applicable charges
- Supports rate negotiation for editable accessorials

### 2. Invoice Generation
- Maps accessorial charges to invoice codes
- Supports GL account mapping for accounting
- Enables tax calculation based on taxable flag

### 3. Route Planning
- Considers accessorial charges in total cost calculation
- Identifies equipment-specific requirements
- Supports multi-stop optimization

### 4. Contract Management
- Defines accessorial terms and conditions
- Supports rate negotiation and approval workflows
- Enables SLA compliance tracking

## Best Practices

### 1. Naming Conventions
- Use consistent prefix (e.g., `ACC-` for accessorial)
- Include category identifier (e.g., `DET` for detention)
- Add year suffix for versioning (e.g., `-2025`)

### 2. Rate Management
- Review and update rates quarterly
- Consider seasonal variations
- Monitor market trends and competitor rates

### 3. Documentation
- Maintain clear trigger conditions
- Document exceptions and special cases
- Keep remarks field updated with latest information

### 4. Performance
- Use appropriate indexes for common queries
- Monitor view performance
- Archive historical data for long-term analysis

## Troubleshooting

### Common Issues

1. **Duplicate Accessorial IDs**: Ensure unique constraints are enforced
2. **Invalid Rate Types**: Validate against ENUM values
3. **Missing Effective Dates**: Always set `effective_from` date
4. **Inactive Accessorials**: Check `is_active` flag before using

### Data Validation
- Ensure all required fields are populated
- Validate rate values are positive numbers
- Check date ranges for logical consistency
- Verify equipment type references

### Performance Optimization
- Monitor query performance on large datasets
- Use appropriate indexes for common filters
- Consider partitioning for historical data
- Optimize view definitions for complex queries

## Future Enhancements

### 1. Advanced Rate Structures
- Support for tiered pricing
- Seasonal rate variations
- Dynamic rate calculations

### 2. Geographic Variations
- Region-specific rates
- Zone-based pricing
- Distance-based calculations

### 3. Equipment Specialization
- Detailed equipment type hierarchies
- Equipment-specific rate variations
- Capacity-based pricing

### 4. Integration Capabilities
- API endpoints for external systems
- Real-time rate updates
- Automated rate synchronization

---

**Last Updated**: August 9, 2025  
**Version**: 1.0  
**Maintained By**: RouteCraft Development Team 