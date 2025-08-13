#!/usr/bin/env python3
"""
Routing Guide Table Creation Script
Creates the routing_guides table for TL transportation procurement
"""

import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv

def create_routing_guide_table():
    """Create the routing_guides table and related views"""

    # Load environment variables
    load_dotenv()

    config = {
        'host': os.getenv('MYSQL_HOST', 'localhost'),
        'user': os.getenv('MYSQL_USER', 'routecraft_user'),
        'password': os.getenv('MYSQL_PASSWORD', 'routecraft_password'),
        'database': os.getenv('MYSQL_DATABASE', 'routecraft'),
        'port': int(os.getenv('MYSQL_PORT', 3306))
    }

    print("🚛 Creating Routing Guide Table for TL Transportation")
    print("=" * 60)
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
            CREATE TABLE IF NOT EXISTS routing_guides (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                routing_guide_id VARCHAR(100) UNIQUE NOT NULL COMMENT 'Unique reference for the routing guide',
                origin_location VARCHAR(255) NOT NULL COMMENT 'City, state, pin code, or facility ID',
                destination_location VARCHAR(255) NOT NULL COMMENT 'Same format as origin',
                lane_id VARCHAR(100) COMMENT 'Optional if standardized lane identification',
                equipment_type VARCHAR(100) NOT NULL COMMENT 'E.g., 32ft SXL, reefer, flatbed, 20ft container',
                service_level ENUM('Standard', 'Express', 'Next-day', 'Same-day', 'Economy', 'Premium') DEFAULT 'Standard' NOT NULL,
                mode ENUM('TL', 'LTL', 'Rail', 'Intermodal', 'Partial') DEFAULT 'TL' NOT NULL,
                primary_carrier_id BIGINT COMMENT 'Reference to carriers table - default/preferred carrier',
                primary_carrier_name VARCHAR(255) COMMENT 'Name of primary carrier for quick reference',
                primary_carrier_rate DECIMAL(15,2) NOT NULL COMMENT 'Rate applicable for primary carrier',
                primary_carrier_rate_type ENUM('Per KM', 'Per Load', 'Slab-based', 'Per Ton', 'Fixed') NOT NULL,
                backup_carrier_1_id BIGINT COMMENT 'Reference to carriers table - secondary carrier',
                backup_carrier_1_name VARCHAR(255) COMMENT 'Name of backup carrier 1',
                backup_carrier_1_rate DECIMAL(15,2) COMMENT 'Rate for backup carrier 1',
                backup_carrier_1_rate_type ENUM('Per KM', 'Per Load', 'Slab-based', 'Per Ton', 'Fixed'),
                backup_carrier_2_id BIGINT COMMENT 'Reference to carriers table - tertiary carrier',
                backup_carrier_2_name VARCHAR(255) COMMENT 'Name of backup carrier 2',
                backup_carrier_2_rate DECIMAL(15,2) COMMENT 'Rate for backup carrier 2',
                backup_carrier_2_rate_type ENUM('Per KM', 'Per Load', 'Slab-based', 'Per Ton', 'Fixed'),
                tender_sequence VARCHAR(50) NOT NULL COMMENT 'Order in which carriers should be tendered (e.g., 1-2-3)',
                tender_lead_time_hours INT NOT NULL COMMENT 'How early carrier must be informed (in hours)',
                transit_sla_days INT COMMENT 'Agreed time to deliver (in days)',
                transit_sla_hours INT COMMENT 'Agreed time to deliver (in hours)',
                fuel_surcharge_percentage DECIMAL(8,4) DEFAULT 0.0000 COMMENT 'Dynamic or fixed fuel surcharge value',
                fuel_surcharge_type ENUM('Percentage', 'Fixed', 'Indexed', 'None') DEFAULT 'None',
                accessorials_included ENUM('Yes', 'No', 'Partial') DEFAULT 'No' COMMENT 'For loading/unloading/etc.',
                accessorial_charges JSON COMMENT 'Detailed breakdown of accessorial charges as JSON',
                load_commitment_type ENUM('Fixed', 'Variable', 'Spot', 'Guaranteed', 'Best-effort') DEFAULT 'Variable',
                load_volume_commitment INT COMMENT 'Volume guarantee or minimums in trips/tonnes',
                valid_from DATE NOT NULL COMMENT 'Start of routing guide validity',
                valid_to DATE NOT NULL COMMENT 'End date of routing guide validity',
                tender_via_api BOOLEAN DEFAULT FALSE COMMENT 'Whether to tender via TMS API',
                load_type ENUM('Regular', 'High-value', 'Fragile', 'Hazardous', 'Temperature-controlled', 'Oversized') DEFAULT 'Regular',
                auto_tender_rule TEXT COMMENT 'e.g., tender to carrier X unless carrier Y offers <90% OTP',
                penalty_missed_tender_percentage DECIMAL(5,2) COMMENT 'Penalty if primary rejects more than X%',
                exceptions TEXT COMMENT 'Special notes (e.g., night ban, regional blackout, seasonal restrictions)',
                business_rules JSON COMMENT 'Additional business rules and constraints as JSON',
                remarks TEXT COMMENT 'Any other business rules or notes',
                routing_guide_status ENUM('Active', 'Inactive', 'Draft', 'Under Review', 'Expired') DEFAULT 'Active' NOT NULL,
                compliance_score DECIMAL(5,2) COMMENT 'Performance compliance score (0-100)',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
                created_by VARCHAR(100) COMMENT 'User who created the routing guide',
                updated_by VARCHAR(100) COMMENT 'User who last updated the routing guide',
                INDEX idx_routing_guide_id (routing_guide_id),
                INDEX idx_lane (origin_location, destination_location),
                INDEX idx_equipment_type (equipment_type),
                INDEX idx_service_level (service_level),
                INDEX idx_primary_carrier (primary_carrier_id),
                INDEX idx_routing_guide_status (routing_guide_status),
                INDEX idx_validity_period (valid_from, valid_to),
                INDEX idx_lane_equipment (origin_location, destination_location, equipment_type),
                INDEX idx_carrier_rates (primary_carrier_rate, backup_carrier_1_rate, backup_carrier_2_rate)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Routing guides for TL transportation procurement with carrier selection rules'
            """

            print("🏗️ Creating routing_guides table...")
            cursor.execute(create_table_sql)
            print("✅ Table created successfully!")

            # Insert sample data
            insert_sample_data(cursor)

            # Create views
            create_views(cursor)

            connection.commit()
            print("✅ All operations completed successfully!")

            # Show table structure and data
            show_table_info(cursor)

        else:
            print("✗ Failed to connect to MySQL database")

    except Error as e:
        print(f"✗ Error: {e}")
        if 'connection' in locals():
            connection.rollback()

    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'connection' in locals() and connection.is_connected():
            connection.close()
            print("🔌 Database connection closed")

def insert_sample_data(cursor):
    """Insert sample routing guide data"""
    print("📝 Inserting sample routing guide data...")

    sample_data = [
        ('RG-2024-001', 'Gurgaon, Haryana', 'Bangalore, Karnataka', 'LANE-GUR-BLR-001', '32ft SXL', 'Standard', 'TL',
         'Gati Ltd', 25000.00, 'Per Load',
         'Delhivery', 27000.00, 'Per Load',
         'Blue Dart', 30000.00, 'Per Load',
         '1-2-3', 24, 3, 12.50,
         'Partial', 'Variable', '2024-01-01', '2024-12-31', 'Active'),

        ('RG-2024-002', 'Mumbai, Maharashtra', 'Delhi, Delhi', 'LANE-MUM-DEL-001', '32ft Trailer', 'Express', 'TL',
         'ABC Transport Ltd', 35000.00, 'Per Load',
         'XYZ Logistics', 38000.00, 'Per Load',
         'Fast Freight Co', 42000.00, 'Per Load',
         '1-2-3', 12, 2, 15.00,
         'Yes', 'Fixed', '2024-02-01', '2025-01-31', 'Active'),

        ('RG-2024-003', 'Chennai, Tamil Nadu', 'Hyderabad, Telangana', 'LANE-CHE-HYD-001', '20ft Container', 'Standard', 'TL',
         'South Express', 18000.00, 'Per Load',
         'Regional Cargo', 20000.00, 'Per Load',
         'City Connect', 22000.00, 'Per Load',
         '1-2-3', 48, 1, 10.00,
         'No', 'Variable', '2024-03-01', '2024-08-31', 'Active'),

        ('RG-2024-004', 'Pune, Maharashtra', 'Ahmedabad, Gujarat', 'LANE-PUN-AHM-001', 'Reefer Trailer', 'Premium', 'TL',
         'Cold Chain Express', 45000.00, 'Per Load',
         'Frozen Logistics', 48000.00, 'Per Load',
         'Chill Transport', 52000.00, 'Per Load',
         '1-2-3', 36, 2, 18.00,
         'Yes', 'Guaranteed', '2024-04-01', '2025-03-31', 'Active'),

        ('RG-2024-005', 'Kolkata, West Bengal', 'Pune, Maharashtra', 'LANE-KOL-PUN-001', 'Flatbed Trailer', 'Economy', 'TL',
         'East West Cargo', 28000.00, 'Per Load',
         'Bharat Transport', 30000.00, 'Per Load',
         'National Logistics', 32000.00, 'Per Load',
         '1-2-3', 72, 4, 8.50,
         'Partial', 'Variable', '2024-05-01', '2024-10-31', 'Active')
    ]

    insert_sql = """
    INSERT INTO routing_guides (
        routing_guide_id, origin_location, destination_location, lane_id, equipment_type, service_level, mode,
        primary_carrier_name, primary_carrier_rate, primary_carrier_rate_type,
        backup_carrier_1_name, backup_carrier_1_rate, backup_carrier_1_rate_type,
        backup_carrier_2_name, backup_carrier_2_rate, backup_carrier_2_rate_type,
        tender_sequence, tender_lead_time_hours, transit_sla_days, fuel_surcharge_percentage,
        accessorials_included, load_commitment_type, valid_from, valid_to, routing_guide_status
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """

    for data in sample_data:
        try:
            cursor.execute(insert_sql, data)
            print(f"  ✓ Inserted: {data[0]} - {data[1]} → {data[2]} ({data[4]})")
        except Error as e:
            if "duplicate entry" in str(e).lower():
                print(f"  ⚠ Skipped (duplicate): {data[0]}")
            else:
                print(f"  ✗ Error inserting {data[0]}: {e}")

def create_views(cursor):
    """Create useful views for routing guides"""
    print("👁️ Creating routing guide views...")

    # Active routing guides view
    active_view_sql = """
    CREATE OR REPLACE VIEW active_routing_guides AS
    SELECT
        routing_guide_id,
        origin_location,
        destination_location,
        lane_id,
        equipment_type,
        service_level,
        mode,
        primary_carrier_name,
        primary_carrier_rate,
        primary_carrier_rate_type,
        backup_carrier_1_name,
        backup_carrier_2_name,
        tender_sequence,
        tender_lead_time_hours,
        transit_sla_days,
        routing_guide_status,
        valid_from,
        valid_to
    FROM routing_guides
    WHERE routing_guide_status = 'Active'
    AND CURDATE() BETWEEN valid_from AND valid_to
    """

    try:
        cursor.execute(active_view_sql)
        print("  ✓ Created active_routing_guides view")
    except Error as e:
        print(f"  ⚠ View creation: {e}")

    # Routing guide summary view
    summary_view_sql = """
    CREATE OR REPLACE VIEW routing_guide_summary AS
    SELECT
        routing_guide_status,
        COUNT(*) as guide_count,
        AVG(primary_carrier_rate) as avg_primary_rate,
        MIN(valid_from) as earliest_validity,
        MAX(valid_to) as latest_validity,
        COUNT(DISTINCT equipment_type) as unique_equipment_types,
        COUNT(DISTINCT primary_carrier_name) as unique_carriers
    FROM routing_guides
    GROUP BY routing_guide_status
    """

    try:
        cursor.execute(summary_view_sql)
        print("  ✓ Created routing_guide_summary view")
    except Error as e:
        print(f"  ⚠ View creation: {e}")

    # Lane coverage analysis view
    coverage_view_sql = """
    CREATE OR REPLACE VIEW lane_coverage_analysis AS
    SELECT
        CONCAT(origin_location, ' → ', destination_location) as lane,
        equipment_type,
        COUNT(*) as routing_guide_count,
        GROUP_CONCAT(DISTINCT primary_carrier_name ORDER BY primary_carrier_name SEPARATOR ', ') as carriers,
        AVG(primary_carrier_rate) as avg_rate,
        MIN(primary_carrier_rate) as min_rate,
        MAX(primary_carrier_rate) as max_rate
    FROM routing_guides
    WHERE routing_guide_status = 'Active'
    GROUP BY origin_location, destination_location, equipment_type
    ORDER BY routing_guide_count DESC
    """

    try:
        cursor.execute(coverage_view_sql)
        print("  ✓ Created lane_coverage_analysis view")
    except Error as e:
        print(f"  ⚠ View creation: {e}")

def show_table_info(cursor):
    """Show table information and sample data"""
    print("\n📋 Routing Guide Table Information:")
    print("-" * 60)

    # Show table structure
    cursor.execute("DESCRIBE routing_guides")
    columns = cursor.fetchall()

    print(f"{'Field':<30} {'Type':<25} {'Null':<8} {'Key':<8} {'Default':<15} {'Extra':<10}")
    print("-" * 100)
    for col in columns:
        print(f"{col[0]:<30} {col[1]:<25} {col[2]:<8} {col[3]:<8} {str(col[4]):<15} {col[5]:<10}")

    # Show data count
    cursor.execute("SELECT COUNT(*) FROM routing_guides")
    count = cursor.fetchone()[0]
    print(f"\n📊 Total routing guides: {count}")

    if count > 0:
        print("\n🔍 Sample routing guides:")
        cursor.execute("""
            SELECT routing_guide_id, origin_location, destination_location, 
                   equipment_type, primary_carrier_name, primary_carrier_rate, 
                   routing_guide_status 
            FROM routing_guides LIMIT 5
        """)
        samples = cursor.fetchall()
        for sample in samples:
            print(f"  - {sample[0]}: {sample[1]} → {sample[2]} ({sample[3]}) - {sample[4]} @ ₹{sample[5]} [{sample[6]}]")

        # Show view information
        print("\n👁️ Available Views:")
        views = ['active_routing_guides', 'routing_guide_summary', 'lane_coverage_analysis']
        for view in views:
            try:
                cursor.execute(f"SELECT COUNT(*) FROM {view}")
                view_count = cursor.fetchone()[0]
                print(f"  - {view}: {view_count} records")
            except Error as e:
                print(f"  - {view}: Error - {e}")

if __name__ == "__main__":
    create_routing_guide_table() 