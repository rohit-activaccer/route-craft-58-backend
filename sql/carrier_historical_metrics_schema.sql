-- Carrier Historical Metrics Table Schema
-- For TL Transportation Procurement
-- Captures performance data over time for each carrier to evaluate:
-- - Operational reliability
-- - Financial discipline
-- - Carrier selection during procurement
-- - Bid weighting and disqualification

USE routecraft;

-- Drop table if exists (for development/testing)
DROP TABLE IF EXISTS carrier_historical_metrics;

-- Create the carrier_historical_metrics table
CREATE TABLE carrier_historical_metrics (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    carrier_id VARCHAR(100) NOT NULL COMMENT 'Unique carrier reference (linked to Carrier Master)',
    carrier_name VARCHAR(255) NOT NULL COMMENT 'For readability and reporting',
    period_type ENUM('Weekly', 'Monthly', 'Quarterly', 'Yearly') NOT NULL COMMENT 'Time period granularity',
    period_start_date DATE NOT NULL COMMENT 'Start of the reporting period',
    period_end_date DATE NOT NULL COMMENT 'End of the reporting period',
    period_label VARCHAR(50) NOT NULL COMMENT 'Human readable period (e.g., May 2025, Q1 FY25)',
    lane_id VARCHAR(100) COMMENT 'Optional - performance by specific lane (Origin → Destination)',
    origin_location VARCHAR(255) COMMENT 'Origin city/state for lane-specific metrics',
    destination_location VARCHAR(255) COMMENT 'Destination city/state for lane-specific metrics',
    equipment_type VARCHAR(100) COMMENT 'Equipment type (e.g., 32ft SXL, Reefer, Container)',
    
    -- Load Volume Metrics
    total_loads_assigned INT NOT NULL DEFAULT 0 COMMENT 'Number of loads given in the period',
    loads_accepted INT NOT NULL DEFAULT 0 COMMENT 'Number of loads accepted by carrier',
    loads_rejected INT NOT NULL DEFAULT 0 COMMENT 'Number of loads rejected by carrier',
    loads_cancelled_by_carrier INT NOT NULL DEFAULT 0 COMMENT 'How many accepted loads they cancelled',
    loads_completed INT NOT NULL DEFAULT 0 COMMENT 'Successfully completed loads',
    
    -- Performance Rate Metrics (as percentages)
    acceptance_rate DECIMAL(5,2) COMMENT '= (Accepted / Assigned) * 100',
    completion_rate DECIMAL(5,2) COMMENT '= (Completed / Accepted) * 100',
    on_time_pickup_rate DECIMAL(5,2) COMMENT '% of pickups made on/before scheduled time',
    on_time_delivery_rate DECIMAL(5,2) COMMENT '% of deliveries made on/before scheduled time',
    overall_on_time_performance DECIMAL(5,2) COMMENT 'Combined pickup and delivery OTP',
    
    -- Absolute Count Metrics
    late_pickup_count INT NOT NULL DEFAULT 0 COMMENT 'Absolute count of late pickups',
    late_delivery_count INT NOT NULL DEFAULT 0 COMMENT 'Absolute count of late deliveries',
    early_pickup_count INT NOT NULL DEFAULT 0 COMMENT 'Early pickups (good performance)',
    early_delivery_count INT NOT NULL DEFAULT 0 COMMENT 'Early deliveries (good performance)',
    
    -- Financial and Billing Metrics
    billing_accuracy_rate DECIMAL(5,2) COMMENT '% of invoices with no dispute or mismatch',
    billing_disputes_count INT NOT NULL DEFAULT 0 COMMENT 'Number of billing disputes',
    average_detention_time_hours DECIMAL(6,2) COMMENT 'Time carrier waited during loading/unloading',
    detention_charges_applied DECIMAL(10,2) COMMENT 'Total detention charges applied',
    
    -- Claims and Quality Metrics
    claim_incidents_count INT NOT NULL DEFAULT 0 COMMENT 'Count of reported damage/loss claims',
    claim_percentage DECIMAL(5,2) COMMENT '(Claim Incidents / Loads) * 100',
    customer_complaints_count INT NOT NULL DEFAULT 0 COMMENT 'Count of complaints raised',
    quality_issues_count INT NOT NULL DEFAULT 0 COMMENT 'Other quality-related issues',
    
    -- Rating and Scoring
    performance_rating DECIMAL(3,1) COMMENT 'Internal performance score (1.0-5.0)',
    scorecard_grade ENUM('A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D', 'E') COMMENT 'Letter grade classification',
    risk_score DECIMAL(5,2) COMMENT 'Risk assessment score (0-100, lower is better)',
    
    -- Additional Metrics
    average_transit_time_hours DECIMAL(6,2) COMMENT 'Average time from pickup to delivery',
    fuel_efficiency_score DECIMAL(5,2) COMMENT 'Fuel consumption efficiency rating',
    driver_behavior_score DECIMAL(5,2) COMMENT 'Driver conduct and professionalism rating',
    
    -- Status and Flags
    is_blacklisted BOOLEAN DEFAULT FALSE COMMENT 'Whether carrier is blacklisted in this period',
    is_preferred_carrier BOOLEAN DEFAULT FALSE COMMENT 'Whether carrier was preferred in this period',
    compliance_status ENUM('Compliant', 'Non-Compliant', 'Under Review') DEFAULT 'Compliant' COMMENT 'Compliance status for the period',
    
    -- Metadata
    remarks TEXT COMMENT 'Qualitative notes (e.g., repeated no-shows, exceptional service)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    created_by VARCHAR(100) COMMENT 'User who created the metrics record',
    updated_by VARCHAR(100) COMMENT 'User who last updated the metrics record',
    
    -- Foreign Key Constraints
    FOREIGN KEY (carrier_id) REFERENCES carrier_master(carrier_id) ON DELETE CASCADE,
    
    -- Composite Unique Constraint
    UNIQUE KEY unique_carrier_period_lane (
        carrier_id, 
        period_type, 
        period_start_date, 
        COALESCE(lane_id, 'ALL_LANES')
    ),
    
    -- Indexes for Performance
    INDEX idx_carrier_id (carrier_id),
    INDEX idx_period_dates (period_start_date, period_end_date),
    INDEX idx_period_type (period_type),
    INDEX idx_lane_id (lane_id),
    INDEX idx_equipment_type (equipment_type),
    INDEX idx_acceptance_rate (acceptance_rate),
    INDEX idx_otp_pickup (on_time_pickup_rate),
    INDEX idx_otp_delivery (on_time_delivery_rate),
    INDEX idx_overall_otp (overall_on_time_performance),
    INDEX idx_billing_accuracy (billing_accuracy_rate),
    INDEX idx_performance_rating (performance_rating),
    INDEX idx_scorecard_grade (scorecard_grade),
    INDEX idx_risk_score (risk_score),
    INDEX idx_compliance_status (compliance_status),
    INDEX idx_is_blacklisted (is_blacklisted),
    INDEX idx_is_preferred_carrier (is_preferred_carrier)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='Carrier Historical Metrics for TL transportation procurement - captures performance data over time for each carrier';

-- Create useful views for analysis

-- Active carriers with recent performance (last 3 months)
CREATE OR REPLACE VIEW active_carriers_recent_performance AS
SELECT 
    chm.carrier_id,
    chm.carrier_name,
    chm.period_label,
    chm.total_loads_assigned,
    chm.loads_accepted,
    chm.acceptance_rate,
    chm.overall_on_time_performance,
    chm.billing_accuracy_rate,
    chm.performance_rating,
    chm.scorecard_grade,
    chm.risk_score,
    chm.compliance_status
FROM carrier_historical_metrics chm
WHERE chm.period_start_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
ORDER BY chm.carrier_id, chm.period_start_date DESC;

-- Carrier performance summary (last 6 months)
CREATE OR REPLACE VIEW carrier_performance_summary AS
SELECT 
    chm.carrier_id,
    chm.carrier_name,
    COUNT(DISTINCT chm.period_label) as periods_tracked,
    AVG(chm.acceptance_rate) as avg_acceptance_rate,
    AVG(chm.overall_on_time_performance) as avg_otp,
    AVG(chm.billing_accuracy_rate) as avg_billing_accuracy,
    AVG(chm.performance_rating) as avg_performance_rating,
    AVG(chm.risk_score) as avg_risk_score,
    SUM(chm.total_loads_assigned) as total_loads_assigned,
    SUM(chm.loads_accepted) as total_loads_accepted,
    SUM(chm.loads_completed) as total_loads_completed,
    MAX(chm.scorecard_grade) as best_grade,
    MIN(chm.scorecard_grade) as worst_grade
FROM carrier_historical_metrics chm
WHERE chm.period_start_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY chm.carrier_id, chm.carrier_name
ORDER BY avg_performance_rating DESC;

-- Lane performance analysis
CREATE OR REPLACE VIEW lane_performance_analysis AS
SELECT 
    chm.lane_id,
    chm.origin_location,
    chm.destination_location,
    chm.equipment_type,
    COUNT(DISTINCT chm.carrier_id) as carriers_used,
    AVG(chm.acceptance_rate) as avg_acceptance_rate,
    AVG(chm.overall_on_time_performance) as avg_otp,
    AVG(chm.billing_accuracy_rate) as avg_billing_accuracy,
    AVG(chm.performance_rating) as avg_performance_rating,
    SUM(chm.total_loads_assigned) as total_loads_assigned,
    SUM(chm.loads_completed) as total_loads_completed
FROM carrier_historical_metrics chm
WHERE chm.lane_id IS NOT NULL
GROUP BY chm.lane_id, chm.origin_location, chm.destination_location, chm.equipment_type
ORDER BY total_loads_assigned DESC;

-- Risk assessment view
CREATE OR REPLACE VIEW carrier_risk_assessment AS
SELECT 
    chm.carrier_id,
    chm.carrier_name,
    chm.period_label,
    chm.risk_score,
    chm.compliance_status,
    chm.is_blacklisted,
    chm.claim_percentage,
    chm.customer_complaints_count,
    chm.billing_disputes_count,
    CASE 
        WHEN chm.risk_score <= 20 THEN 'Low Risk'
        WHEN chm.risk_score <= 40 THEN 'Medium-Low Risk'
        WHEN chm.risk_score <= 60 THEN 'Medium Risk'
        WHEN chm.risk_score <= 80 THEN 'High Risk'
        ELSE 'Very High Risk'
    END as risk_category
FROM carrier_historical_metrics chm
WHERE chm.period_start_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
ORDER BY chm.risk_score DESC, chm.period_start_date DESC;

-- Procurement decision support view
CREATE OR REPLACE VIEW procurement_decision_support AS
SELECT 
    chm.carrier_id,
    chm.carrier_name,
    chm.equipment_type,
    chm.origin_location,
    chm.destination_location,
    chm.acceptance_rate,
    chm.overall_on_time_performance,
    chm.billing_accuracy_rate,
    chm.performance_rating,
    chm.scorecard_grade,
    chm.risk_score,
    chm.compliance_status,
    CASE 
        WHEN chm.acceptance_rate >= 90 AND chm.overall_on_time_performance >= 95 
             AND chm.billing_accuracy_rate >= 95 AND chm.performance_rating >= 4.0
        THEN 'Preferred - High Priority'
        WHEN chm.acceptance_rate >= 80 AND chm.overall_on_time_performance >= 90 
             AND chm.billing_accuracy_rate >= 90 AND chm.performance_rating >= 3.5
        THEN 'Preferred - Standard Priority'
        WHEN chm.acceptance_rate >= 70 AND chm.overall_on_time_performance >= 85 
             AND chm.billing_accuracy_rate >= 85 AND chm.performance_rating >= 3.0
        THEN 'Acceptable - Monitor'
        WHEN chm.acceptance_rate < 70 OR chm.overall_on_time_performance < 85 
             OR chm.billing_accuracy_rate < 85 OR chm.performance_rating < 3.0
        THEN 'Review Required - Low Priority'
        ELSE 'Evaluate Further'
    END as procurement_recommendation
FROM carrier_historical_metrics chm
WHERE chm.period_start_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
ORDER BY chm.performance_rating DESC, chm.risk_score ASC;

-- Show table structure
DESCRIBE carrier_historical_metrics;

-- Show created views
SHOW TABLES LIKE '%view%'; 