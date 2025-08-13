-- Seasons Master Table Schema
-- This table manages seasonal variations in transport procurement including costs, capacity, and SLA adjustments

-- Drop table if exists (for development)
DROP TABLE IF EXISTS seasons_master;

-- Create the main table
CREATE TABLE seasons_master (
    id INT AUTO_INCREMENT PRIMARY KEY,
    season_id VARCHAR(30) NOT NULL UNIQUE COMMENT 'Unique season identifier (e.g., SEASON-01)',
    season_name VARCHAR(100) NOT NULL COMMENT 'Human-readable season name (e.g., Monsoon, Peak Festive)',
    start_date DATE NOT NULL COMMENT 'Season start date',
    end_date DATE NOT NULL COMMENT 'Season end date',
    impact_type ENUM('Cost Increase', 'Capacity Shortage', 'SLA Risk', 'None', 'Mixed') NOT NULL COMMENT 'Primary impact of the season',
    affected_regions TEXT NOT NULL COMMENT 'Comma-separated list of affected regions/states',
    affected_lanes TEXT COMMENT 'Optional list of Lane IDs impacted (comma-separated)',
    rate_multiplier_percent DECIMAL(5,2) COMMENT 'Rate premium percentage (e.g., 5.00 for 5%)',
    sla_adjustment_days INT DEFAULT 0 COMMENT 'Buffer days to add to SLA (can be negative)',
    capacity_risk_level ENUM('High', 'Medium', 'Low') DEFAULT 'Medium' COMMENT 'Expected capacity risk level',
    carrier_participation_impact DECIMAL(5,2) COMMENT 'Expected drop in carrier availability (%)',
    applicable_equipment_types TEXT COMMENT 'Comma-separated list of affected equipment types',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'Whether this season is currently active',
    notes TEXT COMMENT 'Additional descriptive information about the season',
    created_by VARCHAR(50) DEFAULT 'system' COMMENT 'User who created the record',
    updated_by VARCHAR(50) DEFAULT 'system' COMMENT 'User who last updated the record',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record update timestamp',
    
    -- Constraints
    CONSTRAINT chk_dates CHECK (end_date >= start_date),
    CONSTRAINT chk_rate_multiplier CHECK (rate_multiplier_percent >= -50.00 AND rate_multiplier_percent <= 100.00),
    CONSTRAINT chk_carrier_impact CHECK (carrier_participation_impact >= -100.00 AND carrier_participation_impact <= 100.00),
    
    -- Indexes for performance
    INDEX idx_season_id (season_id),
    INDEX idx_season_name (season_name),
    INDEX idx_start_date (start_date),
    INDEX idx_end_date (end_date),
    INDEX idx_impact_type (impact_type),
    INDEX idx_capacity_risk (capacity_risk_level),
    INDEX idx_is_active (is_active),
    INDEX idx_date_range (start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Master table for seasonal variations in transport procurement';

-- Create analytical views for business intelligence

-- 1. Active Seasons Overview
CREATE OR REPLACE VIEW active_seasons_overview AS
SELECT 
    season_id,
    season_name,
    start_date,
    end_date,
    impact_type,
    capacity_risk_level,
    rate_multiplier_percent,
    sla_adjustment_days,
    affected_regions
FROM seasons_master 
WHERE is_active = TRUE 
ORDER BY start_date;

-- 2. High Impact Seasons
CREATE OR REPLACE VIEW high_impact_seasons AS
SELECT 
    season_id,
    season_name,
    start_date,
    end_date,
    impact_type,
    rate_multiplier_percent,
    capacity_risk_level,
    carrier_participation_impact,
    affected_regions
FROM seasons_master 
WHERE is_active = TRUE 
AND (capacity_risk_level = 'High' OR rate_multiplier_percent > 5.00)
ORDER BY start_date;

-- 3. Seasonal Cost Analysis
CREATE OR REPLACE VIEW seasonal_cost_analysis AS
SELECT 
    season_id,
    season_name,
    start_date,
    end_date,
    impact_type,
    rate_multiplier_percent,
    CASE 
        WHEN rate_multiplier_percent > 0 THEN 'Cost Increase'
        WHEN rate_multiplier_percent < 0 THEN 'Cost Decrease'
        ELSE 'No Change'
    END as cost_impact,
    affected_regions
FROM seasons_master 
WHERE is_active = TRUE 
AND rate_multiplier_percent IS NOT NULL
ORDER BY rate_multiplier_percent DESC;

-- 4. Regional Season Impact
CREATE OR REPLACE VIEW regional_season_impact AS
SELECT 
    affected_regions,
    COUNT(*) as total_seasons,
    SUM(CASE WHEN capacity_risk_level = 'High' THEN 1 ELSE 0 END) as high_risk_seasons,
    SUM(CASE WHEN capacity_risk_level = 'Medium' THEN 1 ELSE 0 END) as medium_risk_seasons,
    AVG(rate_multiplier_percent) as avg_rate_impact,
    AVG(sla_adjustment_days) as avg_sla_adjustment
FROM seasons_master 
WHERE is_active = TRUE 
GROUP BY affected_regions
ORDER BY total_seasons DESC;

-- 5. Equipment-Specific Seasons
CREATE OR REPLACE VIEW equipment_specific_seasons AS
SELECT 
    season_id,
    season_name,
    start_date,
    end_date,
    applicable_equipment_types,
    impact_type,
    capacity_risk_level,
    rate_multiplier_percent
FROM seasons_master 
WHERE is_active = TRUE 
AND applicable_equipment_types IS NOT NULL 
AND applicable_equipment_types != ''
ORDER BY start_date;

-- Insert sample data for Indian logistics seasons

INSERT INTO seasons_master (
    season_id, season_name, start_date, end_date, impact_type, 
    affected_regions, affected_lanes, rate_multiplier_percent, 
    sla_adjustment_days, capacity_risk_level, carrier_participation_impact,
    applicable_equipment_types, is_active, notes, created_by, updated_by
) VALUES 
-- Monsoon Season (July-September)
('SEASON-MONSOON-2025', 'Monsoon Season', '2025-07-01', '2025-09-30', 'SLA Risk',
 'Maharashtra, Karnataka, Kerala, Goa, Coastal Regions', 'MUM-BLR, MUM-GOA, BLR-MAA', 3.50,
 2, 'High', 15.00, 'Container, Open Body, Flatbed', TRUE,
 'Heavy rainfall affects road conditions, especially in Western Ghats and coastal areas', 'system', 'system'),

-- Festive Peak (October-November)
('SEASON-FESTIVE-2025', 'Diwali Peak', '2025-10-15', '2025-11-10', 'Cost Increase',
 'All India', 'All Major Lanes', 8.00, 1, 'High', 25.00,
 'Container, Box Truck, Reefer', TRUE,
 'Festival congestion + high FMCG/e-commerce demand, peak retail season', 'system', 'system'),

-- Harvest Season (March-May)
('SEASON-HARVEST-2025', 'Harvest Season', '2025-03-01', '2025-05-31', 'Capacity Shortage',
 'Punjab, Haryana, Uttar Pradesh, Madhya Pradesh, Maharashtra', 'DEL-CHD, MUM-NAG, BLR-HYD', 5.00,
 1, 'Medium', 20.00, 'Open Body, Flatbed, Container', TRUE,
 'Agricultural freight spikes for grains, cotton, sugarcane; rural road congestion', 'system', 'system'),

-- Year-End Rush (February-March)
('SEASON-YEAREND-2025', 'Year-End Rush', '2025-02-01', '2025-03-31', 'Cost Increase',
 'All India', 'All Major Lanes', 4.00, 1, 'Medium', 15.00,
 'All Equipment Types', TRUE,
 'Quarter-end and fiscal year-end push; corporate shipping deadlines', 'system', 'system'),

-- Summer Peak (April-June)
('SEASON-SUMMER-2025', 'Summer Peak', '2025-04-01', '2025-06-30', 'Mixed',
 'North India, Central India', 'DEL-MUM, DEL-BLR, DEL-CHD', 2.50,
 0, 'Low', 10.00, 'Reefer, Container', TRUE,
 'High temperature affects perishable goods; increased reefer demand', 'system', 'system'),

-- Pre-Monsoon (June)
('SEASON-PRE-MONSOON-2025', 'Pre-Monsoon', '2025-06-01', '2025-06-30', 'SLA Risk',
 'Western India, Southern India', 'MUM-BLR, MUM-GOA, BLR-MAA', 1.50,
 1, 'Medium', 8.00, 'All Equipment Types', TRUE,
 'Road preparation and pre-monsoon maintenance affects transit times', 'system', 'system'),

-- Post-Monsoon (October)
('SEASON-POST-MONSOON-2025', 'Post-Monsoon', '2025-10-01', '2025-10-14', 'SLA Risk',
 'Maharashtra, Karnataka, Kerala', 'MUM-BLR, BLR-MAA, MUM-GOA', 2.00,
 1, 'Medium', 12.00, 'All Equipment Types', TRUE,
 'Road damage assessment and repair work affects certain routes', 'system', 'system'),

-- Winter Peak (December-January)
('SEASON-WINTER-2025', 'Winter Peak', '2025-12-01', '2026-01-31', 'Cost Increase',
 'North India, Northeast India', 'DEL-CHD, DEL-KOL, DEL-GUW', 3.00,
 1, 'Medium', 18.00, 'Container, Box Truck, Reefer', TRUE,
 'Winter weather affects northern routes; increased heating fuel transport', 'system', 'system'),

-- Election Season (Variable)
('SEASON-ELECTION-2025', 'Election Season', '2025-04-01', '2025-05-31', 'Capacity Shortage',
 'All India', 'All Major Lanes', 6.00, 2, 'High', 30.00,
 'All Equipment Types', TRUE,
 'Political rallies and security measures affect road transport and capacity', 'system', 'system'),

-- Export Peak (September-December)
('SEASON-EXPORT-2025', 'Export Peak', '2025-09-01', '2025-12-31', 'Cost Increase',
 'Mumbai, Chennai, Kolkata, Cochin', 'MUM-JNPT, CHN-PORT, KOL-PORT', 4.50,
 1, 'Medium', 20.00, 'Container, Reefer', TRUE,
 'Peak export season; port congestion and container shortage', 'system', 'system'),

-- Construction Season (March-June)
('SEASON-CONSTRUCTION-2025', 'Construction Season', '2025-03-01', '2025-06-30', 'Capacity Shortage',
 'Metro Cities, Industrial Zones', 'MUM-PUN, BLR-HYD, DEL-NCR', 3.50,
 1, 'Medium', 15.00, 'Flatbed, Open Body, Heavy Equipment', TRUE,
 'Infrastructure projects peak; heavy equipment and material transport', 'system', 'system'),

-- E-commerce Peak (November-December)
('SEASON-ECOMMERCE-2025', 'E-commerce Peak', '2025-11-01', '2025-12-31', 'Cost Increase',
 'All India', 'All Major Lanes', 7.00, 1, 'High', 25.00,
 'Box Truck, Container, Last Mile Vehicles', TRUE,
 'Black Friday, Cyber Monday, and holiday shopping peak', 'system', 'system'),

-- Agricultural Off-Season (January-February)
('SEASON-AGRI-OFF-2025', 'Agricultural Off-Season', '2025-01-01', '2025-02-28', 'None',
 'Rural Areas, Agricultural States', 'Rural Routes', 0.00, 0, 'Low', 5.00,
 'Open Body, Flatbed', TRUE,
 'Low agricultural activity; reduced rural freight demand', 'system', 'system'),

-- Monsoon Recovery (October)
('SEASON-MONSOON-RECOVERY-2025', 'Monsoon Recovery', '2025-10-01', '2025-10-31', 'SLA Risk',
 'Western India, Southern India', 'MUM-BLR, BLR-MAA', 1.00,
 1, 'Low', 8.00, 'All Equipment Types', TRUE,
 'Post-monsoon road recovery; gradual improvement in transit times', 'system', 'system');

-- Verify the data insertion
SELECT 
    COUNT(*) as total_seasons,
    SUM(CASE WHEN is_active = TRUE THEN 1 ELSE 0 END) as active_seasons,
    SUM(CASE WHEN capacity_risk_level = 'High' THEN 1 ELSE 0 END) as high_risk_seasons,
    AVG(rate_multiplier_percent) as avg_rate_impact
FROM seasons_master; 