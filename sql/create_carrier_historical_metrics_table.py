#!/usr/bin/env python3
"""
Carrier Historical Metrics Table Creation Script
Creates the carrier_historical_metrics table for TL transportation procurement
Captures performance data over time for each carrier to evaluate:
- Operational reliability
- Financial discipline  
- Carrier selection during procurement
- Bid weighting and disqualification
"""

import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv
from datetime import datetime, timedelta
import random

def create_carrier_historical_metrics_table():
    """Create the carrier_historical_metrics table and related views"""

    # Load environment variables
    load_dotenv()

    config = {
        'host': os.getenv('MYSQL_HOST', 'localhost'),
        'user': os.getenv('MYSQL_USER', 'routecraft_user'),
        'password': os.getenv('MYSQL_PASSWORD', 'routecraft_password'),
        'database': os.getenv('MYSQL_DATABASE', 'routecraft'),
        'port': int(os.getenv('MYSQL_PORT', 3306))
    }

    print("📊 Creating Carrier Historical Metrics Table for TL Transportation")
    print("=" * 70)
    print(f"📡 Connecting to MySQL at {config['host']}:{config['port']}")
    print(f"🗄️ Database: {config['database']}")

    try:
        # Create connection
        connection = mysql.connector.connect(**config)

        if connection.is_connected():
            print("✅ Connected to MySQL database successfully!")

            cursor = connection.cursor()

            # Create table SQL
            create_table_sql = """
            CREATE TABLE IF NOT EXISTS carrier_historical_metrics (
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
                    lane_id
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
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Carrier Historical Metrics for TL transportation procurement - captures performance data over time for each carrier'
            """

            print("🏗️ Creating carrier_historical_metrics table...")
            cursor.execute(create_table_sql)
            print("✅ Table created successfully!")

            # Insert sample data
            insert_sample_data(cursor)

            # Create views
            create_views(cursor)

            # Show table information
            show_table_info(cursor)

            # Commit changes
            connection.commit()
            print("✅ All operations completed successfully!")

        else:
            print("❌ Failed to connect to MySQL database")

    except Error as e:
        print(f"❌ Error: {e}")

    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()
            print("🔌 Database connection closed")

def insert_sample_data(cursor):
    """Insert sample carrier historical metrics data"""
    print("📝 Inserting sample carrier historical metrics data...")
    
    # Sample carrier IDs (should match existing carriers in carrier_master table)
    carrier_ids = ['CAR-001', 'CAR-002', 'CAR-003', 'CAR-004', 'CAR-005']
    carrier_names = ['ABC Transport Ltd', 'Gati Ltd', 'South Express', 'Cold Chain Express', 'East West Cargo']
    
    # Sample equipment types
    equipment_types = ['32ft SXL', '32ft Trailer', '20ft Container', 'Reefer Trailer', 'Flatbed Trailer']
    
    # Sample lanes
    lanes = [
        ('Gurgaon, Haryana', 'Bangalore, Karnataka'),
        ('Mumbai, Maharashtra', 'Delhi, Delhi'),
        ('Chennai, Tamil Nadu', 'Hyderabad, Telangana'),
        ('Pune, Maharashtra', 'Ahmedabad, Gujarat'),
        ('Kolkata, West Bengal', 'Pune, Maharashtra')
    ]
    
    # Generate data for the last 12 months
    current_date = datetime.now()
    
    for month_offset in range(12, 0, -1):
        period_start = current_date.replace(day=1) - timedelta(days=month_offset * 30)
        period_end = (period_start.replace(day=1) + timedelta(days=32)).replace(day=1) - timedelta(days=1)
        period_label = period_start.strftime('%B %Y')
        
        for i, carrier_id in enumerate(carrier_ids):
            # Generate realistic performance metrics
            total_loads = random.randint(15, 50)
            accepted_loads = random.randint(int(total_loads * 0.7), total_loads)
            completed_loads = random.randint(int(accepted_loads * 0.85), accepted_loads)
            
            acceptance_rate = round((accepted_loads / total_loads) * 100, 2)
            completion_rate = round((completed_loads / accepted_loads) * 100, 2)
            otp_pickup = round(random.uniform(75, 98), 2)
            otp_delivery = round(random.uniform(80, 95), 2)
            overall_otp = round((otp_pickup + otp_delivery) / 2, 2)
            
            billing_accuracy = round(random.uniform(85, 99), 2)
            performance_rating = round(random.uniform(2.5, 4.8), 1)
            
            # Determine scorecard grade based on performance
            if performance_rating >= 4.5:
                scorecard_grade = random.choice(['A+', 'A', 'A-'])
            elif performance_rating >= 3.5:
                scorecard_grade = random.choice(['B+', 'B', 'B-'])
            elif performance_rating >= 2.5:
                scorecard_grade = random.choice(['C+', 'C', 'C-'])
            else:
                scorecard_grade = random.choice(['D', 'E'])
            
            # Risk score (lower is better)
            risk_score = round(100 - (performance_rating * 20) + random.uniform(-10, 10), 2)
            risk_score = max(0, min(100, risk_score))
            
            # Randomly select lane and equipment
            lane_idx = random.randint(0, len(lanes) - 1)
            equipment_idx = random.randint(0, len(equipment_types) - 1)
            
            # Insert monthly metrics
            insert_sql = """
            INSERT INTO carrier_historical_metrics (
                carrier_id, carrier_name, period_type, period_start_date, period_end_date, period_label,
                lane_id, origin_location, destination_location, equipment_type,
                total_loads_assigned, loads_accepted, loads_rejected, loads_cancelled_by_carrier, loads_completed,
                acceptance_rate, completion_rate, on_time_pickup_rate, on_time_delivery_rate, overall_on_time_performance,
                late_pickup_count, late_delivery_count, early_pickup_count, early_delivery_count,
                billing_accuracy_rate, billing_disputes_count, average_detention_time_hours, detention_charges_applied,
                claim_incidents_count, claim_percentage, customer_complaints_count, quality_issues_count,
                performance_rating, scorecard_grade, risk_score,
                average_transit_time_hours, fuel_efficiency_score, driver_behavior_score,
                is_blacklisted, is_preferred_carrier, compliance_status, remarks
            ) VALUES (
                %s, %s, 'Monthly', %s, %s, %s,
                %s, %s, %s, %s,
                %s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s,
                %s, %s, %s, %s,
                %s, %s, %s, %s,
                %s, %s, %s, %s,
                %s, %s, %s,
                %s, %s, %s,
                %s, %s, %s, %s
            )
            """
            
            lane_id = f"LANE-{month_offset:02d}-{i+1:02d}"
            origin, destination = lanes[lane_idx]
            
            values = (
                carrier_id, carrier_names[i], period_start.date(), period_end.date(), period_label,
                lane_id, origin, destination, equipment_types[equipment_idx],
                total_loads, accepted_loads, total_loads - accepted_loads, 
                random.randint(0, int(accepted_loads * 0.1)), completed_loads,
                acceptance_rate, completion_rate, otp_pickup, otp_delivery, overall_otp,
                random.randint(0, int(accepted_loads * 0.3)), random.randint(0, int(completed_loads * 0.25)),
                random.randint(0, int(accepted_loads * 0.2)), random.randint(0, int(completed_loads * 0.15)),
                billing_accuracy, random.randint(0, 3), round(random.uniform(2, 8), 2), 
                round(random.uniform(0, 5000), 2),
                random.randint(0, 2), round((random.randint(0, 2) / max(completed_loads, 1)) * 100, 2),
                random.randint(0, 2), random.randint(0, 1),
                performance_rating, scorecard_grade, risk_score,
                round(random.uniform(24, 72), 2), round(random.uniform(70, 95), 2), round(random.uniform(75, 98), 2),
                False, random.choice([True, False]), 'Compliant',
                f"Monthly performance metrics for {period_label}"
            )
            
            try:
                cursor.execute(insert_sql, values)
                print(f"  ✓ Inserted metrics for {carrier_names[i]} - {period_label}")
            except Error as e:
                print(f"  ✗ Error inserting {carrier_names[i]} - {period_label}: {e}")

def create_views(cursor):
    """Create useful views for carrier historical metrics analysis"""
    print("👁️ Creating carrier historical metrics views...")
    
    views = [
        # Active carriers with recent performance
        ("active_carriers_recent_performance", """
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
        ORDER BY chm.carrier_id, chm.period_start_date DESC
        """),
        
        # Carrier performance summary (last 6 months)
        ("carrier_performance_summary", """
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
        ORDER BY avg_performance_rating DESC
        """),
        
        # Lane performance analysis
        ("lane_performance_analysis", """
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
        ORDER BY total_loads_assigned DESC
        """),
        
        # Risk assessment view
        ("carrier_risk_assessment", """
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
        ORDER BY chm.risk_score DESC, chm.period_start_date DESC
        """),
        
        # Procurement decision support view
        ("procurement_decision_support", """
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
        ORDER BY chm.performance_rating DESC, chm.risk_score ASC
        """)
    ]
    
    for view_name, view_sql in views:
        try:
            cursor.execute(view_sql)
            print(f"  ✓ Created {view_name} view")
        except Error as e:
            print(f"  ✗ Error creating {view_name} view: {e}")

def show_table_info(cursor):
    """Display information about the created table and views"""
    print("\n📋 Carrier Historical Metrics Table Information:")
    print("-" * 60)
    
    # Show table structure
    cursor.execute("DESCRIBE carrier_historical_metrics")
    columns = cursor.fetchall()
    
    print(f"{'Field':<35} {'Type':<25} {'Null':<8} {'Key':<8} {'Default':<15} {'Extra':<10}")
    print("-" * 100)
    
    for column in columns:
        field, type_name, null, key, default, extra = column
        print(f"{field:<35} {type_name:<25} {null:<8} {key:<8} {str(default):<15} {str(extra):<10}")
    
    # Show record count
    cursor.execute("SELECT COUNT(*) FROM carrier_historical_metrics")
    total_records = cursor.fetchone()[0]
    print(f"\n📊 Total historical metrics records: {total_records}")
    
    # Show sample data
    cursor.execute("""
        SELECT carrier_id, carrier_name, period_label, acceptance_rate, overall_on_time_performance, 
               performance_rating, scorecard_grade, risk_score
        FROM carrier_historical_metrics 
        ORDER BY period_start_date DESC, carrier_id 
        LIMIT 10
        """)
    sample_records = cursor.fetchall()
    
    print(f"\n🔍 Sample historical metrics records:")
    for record in sample_records:
        carrier_id, carrier_name, period, acceptance, otp, rating, grade, risk = record
        print(f"  - {carrier_id}: {carrier_name} - {period} | Acceptance: {acceptance}% | OTP: {otp}% | Rating: {rating} | Grade: {grade} | Risk: {risk}")
    
    # Show available views
    cursor.execute("SHOW TABLES LIKE '%view%'")
    views = cursor.fetchall()
    
    print(f"\n👁️ Available Views:")
    for view in views:
        view_name = view[0]
        cursor.execute(f"SELECT COUNT(*) FROM {view_name}")
        count = cursor.fetchone()[0]
        print(f"  - {view_name}: {count} records")

if __name__ == "__main__":
    create_carrier_historical_metrics_table()
