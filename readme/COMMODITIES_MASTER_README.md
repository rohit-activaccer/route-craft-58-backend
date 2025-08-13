# 📦 Commodities Master Table Documentation

## Overview

The **Commodities Master** table is a reference dataset that defines the types of goods being moved in truckload (TL) transportation procurement. It's crucial for carrier selection, rate calculation, tendering logic, compliance, load planning, and vehicle matching.

## 🎯 Purpose & Use Cases

### Primary Functions
- **Carrier Selection**: Identify carriers specializing in specific commodity types (fragile, hazardous, temperature-sensitive)
- **Rate Calculation**: Determine pricing based on commodity characteristics (high-value, oversized, special handling)
- **Tendering Logic**: Apply commodity-specific rules and compliance requirements
- **Load Planning**: Match commodities with appropriate vehicle types and equipment
- **Risk Assessment**: Evaluate insurance requirements and handling complexity

### Business Scenarios
- **Strategic Sourcing**: Annual bidding with commodity-specific carrier requirements
- **Spot Bid Events**: Quick capacity sourcing for specific commodity types
- **Lane Expansion**: Finding carriers for new commodity routes
- **Compliance Management**: Ensuring HAZMAT and temperature-controlled requirements
- **Insurance Planning**: Determining coverage amounts based on commodity value

## 🏗️ Table Structure

### Core Fields

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| `commodity_id` | VARCHAR(50) | Unique system-assigned code | `CMD-001` |
| `commodity_name` | VARCHAR(255) | Name of the commodity | `FMCG Cartons` |
| `commodity_category` | ENUM | Broad grouping of commodity type | `FMCG`, `Electronics`, `Hazardous` |
| `hsn_code` | VARCHAR(20) | Harmonized System Nomenclature for tax compliance | `4819` |

### Packaging & Handling

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| `typical_packaging_type` | ENUM | Typical packaging format | `Palletized`, `Drums`, `Loose Cartons` |
| `handling_instructions` | TEXT | Special handling requirements | `Fragile - Handle with care, No stacking` |
| `loading_unloading_sla` | INT | Load/unload time expectations (minutes) | `120`, `180`, `300` |

### Special Requirements

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| `temperature_controlled` | BOOLEAN | Needs reefer or climate control | `TRUE` for pharmaceuticals |
| `hazmat` | BOOLEAN | Is it a hazardous material? | `TRUE` for chemicals |
| `sensitive_cargo` | BOOLEAN | Triggers geofencing/tamper alerts | `TRUE` for electronics |
| `insurance_required` | BOOLEAN | Special insurance needed | `TRUE` for high-value items |

### Value & Planning

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| `value_category` | ENUM | Used for insurance/tender priority | `Low`, `Medium`, `High`, `Very High` |
| `avg_weight_per_load` | DECIMAL(8,2) | Average weight per load in Metric Tons | `8.5`, `25.0` |
| `avg_volume_per_load` | DECIMAL(8,2) | Average volume per load in Cubic Feet | `1200.0`, `600.0` |
| `min_insurance_amount` | DECIMAL(12,2) | Minimum insurance amount in INR | `500000.00`, `5000000.00` |

### Carrier Preferences

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| `preferred_carrier_types` | JSON | Preferred carrier types | `["32ft SXL", "Closed Body"]` |
| `restricted_carrier_types` | JSON | Restricted carrier types | `["Open Body", "Food Carriers"]` |

### Seasonal & Status

| Column Name | Data Type | Description | Example |
|-------------|-----------|-------------|---------|
| `seasonal_peak_start` | DATE | Seasonal peak start date | `2024-06-01` |
| `seasonal_peak_end` | DATE | Seasonal peak end date | `2024-09-30` |
| `commodity_status` | ENUM | Current status of commodity | `Active`, `Seasonal`, `Inactive` |

## 📊 Commodity Categories

### Available Categories
1. **Perishable**: Fresh fruits, vegetables, dairy products
2. **Industrial**: Steel coils, construction materials, machinery
3. **FMCG**: Fast-moving consumer goods, packaged items
4. **Hazardous**: Chemicals, flammable materials, toxic substances
5. **Electronics**: Gadgets, precision equipment, fragile items
6. **Textiles**: Garments, fabrics, clothing materials
7. **Automotive**: Vehicle parts, components, accessories
8. **Pharmaceuticals**: Medicines, medical supplies, temperature-sensitive drugs
9. **Construction**: Building materials, cement, aggregates
10. **Agriculture**: Grains, seeds, agricultural products

### Packaging Types
- **Palletized**: Standard pallet-based packaging
- **Drums**: Cylindrical containers for liquids/powders
- **Loose Cartons**: Individual cardboard boxes
- **Bags**: Flexible packaging for bulk materials
- **Bulk**: Unpackaged loose materials
- **Crates**: Wooden or plastic containers
- **Barrels**: Large cylindrical containers
- **Rolls**: Cylindrical rolled materials
- **Bundles**: Grouped items tied together
- **Individual Units**: Single items requiring special handling

## 🔧 Equipment Requirements

### Temperature Controlled Commodities
- **Equipment**: Reefer trailers, climate-controlled containers
- **Examples**: Pharmaceuticals, fresh produce, dairy products
- **Requirements**: Temperature monitoring, humidity control

### HAZMAT Commodities
- **Equipment**: HAZMAT-certified vehicles, safety equipment
- **Examples**: Industrial chemicals, flammable materials
- **Requirements**: Special permits, driver certification, safety protocols

### Fragile Commodities
- **Equipment**: Air suspension trucks, careful handling
- **Examples**: Electronics, glass products, precision instruments
- **Requirements**: Smooth roads, gentle handling, secure packaging

### Heavy Commodities
- **Equipment**: Heavy-duty trucks, crane access
- **Examples**: Steel coils, construction materials, machinery
- **Requirements**: Weight distribution, specialized loading equipment

## 💰 Value Categories & Insurance

### Value Classification
- **Low**: Basic materials, construction supplies (₹100K - ₹500K insurance)
- **Medium**: Standard goods, FMCG items (₹500K - ₹2M insurance)
- **High**: Electronics, automotive parts (₹2M - ₹5M insurance)
- **Very High**: Pharmaceuticals, precious items (₹5M+ insurance)

### Insurance Requirements
- **Mandatory**: High-value, hazardous, sensitive cargo
- **Optional**: Standard goods, low-value items
- **Coverage**: Cargo damage, theft, transit risks
- **Amounts**: Based on commodity value and risk factors

## 📅 Seasonal Patterns

### Peak Seasons
- **Monsoon (Jun-Sep)**: Fresh produce, perishable items
- **Festival (Oct-Dec)**: Textiles, consumer goods, electronics
- **Construction (Mar-Jun)**: Building materials, construction supplies
- **Harvest (Oct-Feb)**: Agricultural products, grains

### Planning Considerations
- **Capacity Planning**: Increased carrier requirements during peaks
- **Rate Variations**: Higher rates during peak seasons
- **Equipment Availability**: Limited specialized equipment during peaks
- **Lead Time**: Extended planning for seasonal commodities

## 🚛 Carrier Selection Logic

### Example Filter Logic
```sql
-- For FMCG Cartons
SELECT * FROM commodities_master 
WHERE commodity_id = 'CMD-001'
  AND hazmat = FALSE
  AND temperature_controlled = FALSE;

-- Preferred carrier requirements:
-- - 32ft SXL or Closed Body trucks
-- - Tarpaulin coverage
-- - No mixing with industrial chemicals
-- - Minimum ₹50 lakh cargo insurance
```

### Carrier Matching Rules
1. **Equipment Compatibility**: Match commodity requirements with carrier equipment
2. **Certification**: Ensure HAZMAT, temperature control certifications
3. **Insurance Coverage**: Verify minimum insurance requirements
4. **Handling Capability**: Assess loading/unloading expertise
5. **Geographic Coverage**: Confirm origin/destination service areas

## 📈 Analytical Views

### 1. Active Commodities by Category
```sql
SELECT commodity_category, COUNT(*) as count,
       AVG(avg_weight_per_load) as avg_weight,
       COUNT(CASE WHEN temperature_controlled = TRUE THEN 1 END) as temp_controlled_count
FROM commodities_master 
WHERE commodity_status = 'Active'
GROUP BY commodity_category 
ORDER BY count DESC;
```

### 2. High-Value Commodities
```sql
SELECT commodity_id, commodity_name, commodity_category, value_category,
       min_insurance_amount, temperature_controlled, hazmat
FROM commodities_master 
WHERE value_category IN ('High', 'Very High') 
  AND commodity_status = 'Active'
ORDER BY min_insurance_amount DESC;
```

### 3. Equipment Requirements
```sql
SELECT commodity_id, commodity_name, commodity_category,
       CASE WHEN temperature_controlled = TRUE THEN 'Reefer Required'
            WHEN hazmat = TRUE THEN 'HAZMAT Certified'
            ELSE 'Standard Equipment' END as equipment_requirement,
       preferred_carrier_types, restricted_carrier_types
FROM commodities_master 
WHERE commodity_status = 'Active';
```

## 🔍 Sample Data Examples

### FMCG Cartons (CMD-001)
- **Category**: FMCG
- **Packaging**: Loose Cartons
- **Handling**: Stack max 5 layers, Keep dry
- **Requirements**: Closed body truck, no mixing with chemicals
- **Insurance**: ₹5 lakh minimum

### Electronics & Gadgets (CMD-002)
- **Category**: Electronics
- **Packaging**: Individual Units
- **Handling**: Fragile - Handle with care, No stacking
- **Requirements**: Air suspension, GPS enabled
- **Insurance**: ₹20 lakh minimum

### Pharmaceutical Products (CMD-003)
- **Category**: Pharmaceuticals
- **Packaging**: Palletized
- **Handling**: Temperature sensitive, 15-25°C
- **Requirements**: Reefer, temperature controlled, GPS enabled
- **Insurance**: ₹50 lakh minimum

### Steel Coils (CMD-004)
- **Category**: Industrial
- **Packaging**: Rolls
- **Handling**: Heavy loads, Use cranes
- **Requirements**: Flatbed, heavy duty, crane access
- **Insurance**: ₹1 lakh minimum

### Industrial Chemicals (CMD-005)
- **Category**: Hazardous
- **Packaging**: Drums
- **Handling**: HAZMAT - Special handling required
- **Requirements**: HAZMAT certified, closed body, safety equipment
- **Insurance**: ₹30 lakh minimum

## 🛠️ Implementation Details

### Database Setup
```bash
# Run the creation script
python create_commodities_master_table.py
```

### Dependencies
- MySQL 8.0+
- Python 3.8+
- mysql-connector-python
- python-dotenv

### Table Creation
- **Engine**: InnoDB
- **Charset**: utf8mb4
- **Collation**: utf8mb4_unicode_ci
- **Auto-increment**: Primary key with auto-increment
- **Timestamps**: Created/updated timestamps with auto-update

## 🔄 Maintenance & Updates

### Regular Tasks
1. **Data Validation**: Verify HSN codes and commodity classifications
2. **Seasonal Updates**: Update seasonal peak dates annually
3. **Insurance Review**: Review and update minimum insurance amounts
4. **Carrier Preferences**: Update preferred/restricted carrier types
5. **Status Management**: Activate/deactivate commodities as needed

### Data Quality Checks
- **HSN Code Validation**: Ensure valid tax codes
- **Weight/Volume Consistency**: Verify realistic load specifications
- **Insurance Amounts**: Validate against market rates
- **Carrier Type Validation**: Ensure valid equipment specifications

## 🔗 Integration Points

### Related Tables
- **Carrier Master**: For equipment and capability matching
- **Targeted Carriers**: For external carrier sourcing
- **Carrier Historical Metrics**: For performance-based selection
- **Routing Guides**: For lane-specific commodity requirements
- **Tender Management**: For bid requirements and specifications

### API Endpoints
- `GET /api/commodities` - List all commodities
- `GET /api/commodities/{id}` - Get specific commodity details
- `GET /api/commodities/category/{category}` - Filter by category
- `GET /api/commodities/equipment/{requirement}` - Filter by equipment needs
- `POST /api/commodities` - Create new commodity
- `PUT /api/commodities/{id}` - Update commodity
- `DELETE /api/commodities/{id}` - Deactivate commodity

## 📋 Best Practices

### Data Management
1. **Unique IDs**: Use consistent naming convention (CMD-001, CMD-002)
2. **Category Standardization**: Maintain consistent category names
3. **HSN Code Accuracy**: Keep tax codes updated and validated
4. **Insurance Amounts**: Regular review against market conditions

### Business Rules
1. **Equipment Matching**: Always verify carrier equipment compatibility
2. **Insurance Requirements**: Enforce minimum coverage for high-value items
3. **HAZMAT Handling**: Strict compliance with safety regulations
4. **Temperature Control**: Monitor and maintain required conditions

### Performance Optimization
1. **Indexing**: Use appropriate indexes for frequent queries
2. **JSON Fields**: Optimize JSON queries for carrier type matching
3. **Views**: Leverage analytical views for complex reporting
4. **Partitioning**: Consider partitioning for large datasets

## 🚀 Future Enhancements

### Planned Features
1. **Commodity Scoring**: Risk-based scoring system
2. **Dynamic Pricing**: Real-time rate calculation based on commodity characteristics
3. **Market Intelligence**: Integration with commodity price indices
4. **AI Recommendations**: Machine learning for carrier-commodity matching
5. **Mobile App**: Field team access for commodity verification

### Advanced Analytics
1. **Trend Analysis**: Historical commodity movement patterns
2. **Risk Assessment**: Predictive risk modeling for commodities
3. **Cost Optimization**: AI-driven carrier selection optimization
4. **Sustainability Metrics**: Carbon footprint tracking by commodity type

## 📞 Support & Contact

For questions about the Commodities Master table:
- **Technical Issues**: Check the creation script logs
- **Data Updates**: Use the provided API endpoints
- **Schema Changes**: Review the table structure documentation
- **Business Rules**: Consult with procurement and logistics teams

---

*This documentation covers the Commodities Master table implementation for RouteCraft's TL transportation procurement system. For additional details, refer to the related table documentation and API specifications.* 