# Targeted Carriers Table Documentation

## 📋 Overview

The `targeted_carriers` table stores information about external 3rd-party carriers sourced from platforms like TruckStop, LoadBoard, DAT, or FreightTiger. These carriers are filtered based on key parameters such as region, equipment, compliance, or performance and are used for dynamic sourcing when there is insufficient capacity or competition from incumbent carriers.

## 🎯 Purpose and Use Cases

### Primary Use Cases
- **Strategic Sourcing (Annual Bidding)**: Identify and invite qualified external carriers for long-term contracts
- **Spot Bid Events**: Quickly source carriers for immediate capacity needs
- **Lane Expansion**: Find carriers for new routes or expanded service areas
- **Backhaul Optimization**: Source carriers for return trip optimization

### Business Value
- **Capacity Augmentation**: Supplement existing carrier network during peak demand
- **Competition Enhancement**: Increase bid competition for better pricing
- **Geographic Coverage**: Expand service coverage to new regions
- **Specialized Equipment**: Access carriers with specific equipment types

## 🏗️ Table Structure

### Core Fields

| Column Name | Data Type | Description | Constraints |
|-------------|-----------|-------------|-------------|
| `id` | BIGINT | Auto-increment primary key | PRIMARY KEY, AUTO_INCREMENT |
| `carrier_id_3p` | VARCHAR(50) | Unique ID from external platform | NOT NULL, UNIQUE |
| `carrier_name` | VARCHAR(255) | Legal entity or display name | NOT NULL |
| `dot_mc_number` | VARCHAR(50) | Registration number (RC/GSTIN/MC) | NULL |
| `region_of_operation` | ENUM | Geographic region of operation | NOT NULL |
| `origin_preference` | JSON | Preferred origin regions | NULL |
| `destination_preference` | JSON | Preferred delivery zones | NULL |
| `fleet_size` | INT | Total number of trucks | NULL |
| `equipment_types` | JSON | Available equipment types | NULL |
| `mode` | ENUM | Transportation mode | NOT NULL, DEFAULT 'TL' |

### Performance & Compliance Fields

| Column Name | Data Type | Description | Constraints |
|-------------|-----------|-------------|-------------|
| `compliance_validated` | BOOLEAN | Document verification status | DEFAULT FALSE |
| `performance_score_external` | DECIMAL(3,1) | External platform rating | NULL |
| `preferred_commodity_types` | JSON | Preferred cargo types | NULL |
| `technology_enabled` | BOOLEAN | GPS/ePOD support | DEFAULT FALSE |
| `rating_threshold_met` | BOOLEAN | Meets minimum rating criteria | DEFAULT FALSE |
| `last_active` | DATE | Last activity date | NULL |
| `invited_to_bid` | BOOLEAN | Current RFP invitation status | DEFAULT FALSE |

### Metadata Fields

| Column Name | Data Type | Description | Constraints |
|-------------|-----------|-------------|-------------|
| `remarks` | TEXT | Additional notes and metadata | NULL |
| `created_at` | TIMESTAMP | Record creation timestamp | DEFAULT CURRENT_TIMESTAMP |
| `updated_at` | TIMESTAMP | Last update timestamp | AUTO UPDATE |

## 🌍 Region of Operation Values

### India Regions
- `North India`: Delhi NCR, Haryana, Punjab, Uttar Pradesh, Himachal Pradesh, Jammu & Kashmir
- `South India`: Tamil Nadu, Karnataka, Kerala, Andhra Pradesh, Telangana
- `East India`: West Bengal, Bihar, Odisha, Jharkhand, Assam
- `West India`: Maharashtra, Gujarat, Madhya Pradesh, Rajasthan
- `Central India`: Madhya Pradesh, Chhattisgarh, parts of Uttar Pradesh
- `PAN India`: Nationwide coverage

### US Regions
- `East Coast`: New York, New Jersey, Pennsylvania, Maryland, Virginia, North Carolina, South Carolina, Georgia, Florida
- `West Coast`: California, Oregon, Washington
- `Central US`: Illinois, Indiana, Ohio, Michigan, Wisconsin, Minnesota, Iowa, Missouri
- `Northeast US`: Maine, New Hampshire, Vermont, Massachusetts, Rhode Island, Connecticut
- `Southeast US`: Kentucky, Tennessee, Alabama, Mississippi, Arkansas, Louisiana
- `Northwest US`: Montana, Idaho, Wyoming, North Dakota, South Dakota
- `Southwest US`: Texas, Oklahoma, New Mexico, Arizona, Nevada, Utah, Colorado

## 🚛 Equipment Types

### Common Equipment Categories
- **Dry Vans**: 32ft SXL, 53ft Dry Van, 20ft Container
- **Refrigerated**: Reefer, Cold Chain
- **Specialized**: Flatbed, Step Deck, Power Only
- **Container**: 20ft, 40ft, High Cube
- **Heavy Haul**: Lowboy, Extendable

### JSON Format Example
```json
["32ft SXL", "Reefer", "Flatbed"]
```

## 📊 Performance Scoring

### Score Ranges
- **4.5+**: Premium carriers with exceptional performance
- **4.0-4.4**: High-performing carriers with reliable service
- **3.5-3.9**: Good carriers meeting most requirements
- **3.0-3.4**: Average carriers with some limitations
- **<3.0**: Below average, requires close monitoring

### Rating Threshold Logic
- **TRUE**: Meets minimum performance criteria (typically >80% rating)
- **FALSE**: Below threshold, not eligible for automatic invitation

## 🔍 Analytical Views

### 1. `eligible_carriers_for_bidding`
**Purpose**: Identify carriers eligible for immediate bidding
**Filters**: Compliant, meets rating threshold, recently active
**Use Case**: Quick sourcing for urgent capacity needs

### 2. `regional_carrier_distribution`
**Purpose**: Analyze carrier distribution across regions
**Metrics**: Total carriers, compliant count, average performance, fleet capacity
**Use Case**: Strategic planning and regional analysis

### 3. `equipment_type_analysis`
**Purpose**: Analyze carriers by primary equipment type
**Metrics**: Carrier count, performance averages, compliance rates
**Use Case**: Equipment-specific sourcing decisions

### 4. `performance_tier_analysis`
**Purpose**: Categorize carriers by performance tiers
**Tiers**: Premium, High, Good, Average, Below Average
**Use Case**: Tiered invitation strategies

### 5. `sourcing_recommendations`
**Purpose**: Provide prioritized sourcing recommendations
**Priorities**: Priority 1-5 based on performance, compliance, and fleet size
**Use Case**: Strategic sourcing and invitation planning

## 🎯 Filter Logic Examples

### Example 1: Equipment-Specific Sourcing
```sql
-- Target carriers for 32ft SXL equipment in West India
SELECT * FROM targeted_carriers 
WHERE region_of_operation = 'West India'
  AND JSON_CONTAINS(equipment_types, '"32ft SXL"')
  AND compliance_validated = TRUE
  AND performance_score_external >= 4.0
  AND fleet_size >= 20;
```

### Example 2: Regional Expansion
```sql
-- Find carriers for new South India routes
SELECT * FROM targeted_carriers 
WHERE region_of_operation = 'South India'
  AND rating_threshold_met = TRUE
  AND last_active >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY performance_score_external DESC;
```

### Example 3: Commodity-Specific Sourcing
```sql
-- Source carriers for pharmaceutical shipments
SELECT * FROM targeted_carriers 
WHERE JSON_CONTAINS(preferred_commodity_types, '"Pharma"')
  AND compliance_validated = TRUE
  AND technology_enabled = TRUE
  AND performance_score_external >= 4.5;
```

## 📈 Sample Data

The table includes 8 sample carriers covering:
- **India**: 6 carriers across all regions (North, South, East, West, Central)
- **US**: 2 carriers (East Coast, West Coast)
- **Equipment Types**: Various combinations of dry van, reefer, flatbed, container
- **Performance Scores**: Range from 3.2 to 4.9
- **Fleet Sizes**: Range from 18 to 156 trucks

## 🔧 Maintenance and Updates

### Regular Updates
- **Performance Scores**: Monthly updates from external platforms
- **Activity Status**: Weekly updates based on platform activity
- **Compliance Status**: Quarterly verification updates
- **Fleet Information**: Bi-annual updates

### Data Quality Checks
- **Duplicate Prevention**: Unique constraint on `carrier_id_3p`
- **Data Validation**: JSON format validation for preference fields
- **Performance Monitoring**: Regular review of low-performing carriers
- **Compliance Tracking**: Ongoing verification of regulatory compliance

## 🚀 Integration Points

### Procurement Systems
- **RFP Management**: Automatic carrier invitation based on criteria
- **Bid Evaluation**: Performance scoring integration
- **Contract Management**: Historical performance tracking

### External Platforms
- **TruckStop**: Primary US market data source
- **LoadBoard**: Secondary US market data
- **DAT**: US market analytics and scoring
- **FreightTiger**: Indian market data source

### Internal Systems
- **Carrier Management**: Integration with incumbent carrier database
- **Performance Analytics**: Historical metrics correlation
- **Risk Management**: Compliance and performance risk assessment

## 📋 Best Practices

### Sourcing Strategy
1. **Tiered Approach**: Prioritize carriers by performance and compliance
2. **Regional Balance**: Maintain geographic diversity in carrier network
3. **Equipment Coverage**: Ensure adequate equipment type coverage
4. **Performance Monitoring**: Regular review of carrier performance

### Data Management
1. **Regular Updates**: Keep external data current and accurate
2. **Quality Control**: Validate data from external sources
3. **Performance Tracking**: Monitor actual vs. expected performance
4. **Feedback Loop**: Incorporate performance feedback into future decisions

### Risk Management
1. **Compliance Verification**: Regular verification of regulatory compliance
2. **Performance Thresholds**: Maintain minimum performance standards
3. **Backup Planning**: Maintain alternative carrier options
4. **Continuous Monitoring**: Ongoing performance and compliance tracking

## 🔮 Future Enhancements

### Planned Features
- **AI-Powered Matching**: Machine learning for optimal carrier selection
- **Real-time Updates**: Live integration with external platforms
- **Predictive Analytics**: Performance trend analysis and forecasting
- **Mobile Integration**: Field team access to carrier information

### Scalability Considerations
- **Geographic Expansion**: Support for additional regions and countries
- **Platform Integration**: Additional external data sources
- **Advanced Analytics**: Enhanced reporting and decision support
- **API Development**: RESTful API for external system integration

---

*This documentation provides comprehensive guidance for understanding, implementing, and maintaining the targeted_carriers table within the RouteCraft transportation procurement system.* 