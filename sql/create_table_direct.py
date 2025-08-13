#!/usr/bin/env python3
"""
Direct table creation script for transport_contracts
"""

import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv

def create_contract_table():
    """Create the transport_contracts table directly"""
    
    # Load environment variables
    load_dotenv()
    
    config = {
        'host': os.getenv('MYSQL_HOST', 'localhost'),
        'user': os.getenv('MYSQL_USER', 'routecraft_user'),
        'password': os.getenv('MYSQL_PASSWORD', 'routecraft_password'),
        'database': os.getenv('MYSQL_DATABASE', 'routecraft'),
        'port': int(os.getenv('MYSQL_PORT', 3306))
    }
    
    print("🚛 Creating Transport Contracts Table")
    print("=" * 50)
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
            CREATE TABLE IF NOT EXISTS transport_contracts (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                contract_id VARCHAR(100) UNIQUE NOT NULL COMMENT 'Unique identifier for the contract',
                contract_status ENUM('Active', 'Expired', 'In Review', 'Draft', 'Terminated') DEFAULT 'Draft' NOT NULL,
                carrier_name VARCHAR(255) NOT NULL COMMENT 'Name of the transportation provider',
                carrier_code VARCHAR(50) COMMENT 'Internal or industry carrier code',
                origin_location VARCHAR(255) NOT NULL COMMENT 'Start of the lane (city/state/pincode)',
                origin_facility_id VARCHAR(100) COMMENT 'Internal plant/warehouse code',
                origin_pincode VARCHAR(10) COMMENT 'Origin pincode for precise location',
                origin_state VARCHAR(100) COMMENT 'Origin state',
                destination_location VARCHAR(255) NOT NULL COMMENT 'End of the lane',
                destination_facility_id VARCHAR(100) COMMENT 'Internal code',
                destination_pincode VARCHAR(10) COMMENT 'Destination pincode for precise location',
                destination_state VARCHAR(100) COMMENT 'Destination state',
                lane_id VARCHAR(100) COMMENT 'System-generated or defined lane code',
                mode ENUM('FTL', 'LTL', 'Partial', 'Intermodal') DEFAULT 'FTL' NOT NULL,
                equipment_type VARCHAR(100) COMMENT 'Vehicle type: 32ft, 20ft, reefer, etc.',
                service_level ENUM('Express', 'Standard', 'Guaranteed', 'Premium', 'Economy') DEFAULT 'Standard' NOT NULL,
                transit_time_hours INT COMMENT 'Agreed delivery time in hours',
                transit_time_days INT COMMENT 'Agreed delivery time in days',
                rate_type ENUM('Per Trip', 'Per KM', 'Slab-based', 'Per Ton', 'Per Pallet', 'Fixed') NOT NULL,
                base_rate DECIMAL(15,2) NOT NULL COMMENT 'Fixed or variable rate per unit',
                rate_currency ENUM('INR', 'USD', 'EUR') DEFAULT 'INR' NOT NULL,
                minimum_charges DECIMAL(15,2) DEFAULT 0.00 COMMENT 'Minimum freight applicable',
                fuel_surcharge_type ENUM('Percentage', 'Indexed', 'Fixed', 'None') DEFAULT 'None',
                fuel_surcharge_value DECIMAL(8,4) COMMENT 'Percentage or fixed value',
                fuel_surcharge_index VARCHAR(100) COMMENT 'Reference to fuel index if applicable',
                accessorial_charges JSON COMMENT 'Extra fees (waiting, loading, etc.) as JSON',
                waiting_charges_per_hour DECIMAL(10,2) DEFAULT 0.00,
                loading_charges DECIMAL(10,2) DEFAULT 0.00,
                unloading_charges DECIMAL(10,2) DEFAULT 0.00,
                effective_from DATE NOT NULL COMMENT 'Contract start date',
                effective_to DATE NOT NULL COMMENT 'Contract expiry date',
                payment_terms VARCHAR(100) COMMENT 'e.g., 30 days, advance, COD',
                tender_type ENUM('Spot', 'Annual', 'Quarterly', 'Monthly', 'Project-based') DEFAULT 'Annual',
                load_volume_commitment INT COMMENT 'Volume guarantee or minimums in trips/tonnes',
                carrier_performance_clause TEXT COMMENT 'Linked to performance KPIs',
                penalty_clause TEXT COMMENT 'Conditions for delay/failure',
                penalty_amount DECIMAL(15,2) COMMENT 'Penalty amount if applicable',
                billing_method ENUM('POD-based', 'Digital', 'Milestone-based', 'Advance') DEFAULT 'POD-based',
                tariff_slab_attachment VARCHAR(500) COMMENT 'Path to tariff slab file if applicable',
                attachment_link VARCHAR(500) COMMENT 'Path or link to scanned PDF/MSA',
                remarks TEXT COMMENT 'Any special terms or conditions',
                special_instructions TEXT COMMENT 'Special handling or delivery instructions',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
                created_by VARCHAR(100) COMMENT 'User who created the contract',
                updated_by VARCHAR(100) COMMENT 'User who last updated the contract',
                INDEX idx_contract_id (contract_id),
                INDEX idx_carrier_name (carrier_name),
                INDEX idx_origin_location (origin_location),
                INDEX idx_destination_location (destination_location),
                INDEX idx_contract_status (contract_status),
                INDEX idx_effective_dates (effective_from, effective_to),
                INDEX idx_lane (origin_location, destination_location),
                INDEX idx_carrier_code (carrier_code)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Transportation contracts with lanes, rates, and service levels'
            """
            
            print("🏗️ Creating transport_contracts table...")
            cursor.execute(create_table_sql)
            print("✅ Table created successfully!")
            
            # Insert sample data
            insert_sample_data(cursor)
            
            # Create views
            create_views(cursor)
            
            connection.commit()
            print("✅ All operations completed successfully!")
            
            # Show table structure
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
    """Insert sample contract data"""
    print("📝 Inserting sample data...")
    
    sample_data = [
        ('CON-2024-001', 'ABC Transport Ltd', 'ABC001', 'Mumbai, Maharashtra', 'Delhi, Delhi',
         'FTL', '32ft Trailer', 'Standard', 'Per Trip', 25000.00, 'INR',
         '2024-01-01', '2024-12-31', 'Active', '30 days'),
        
        ('CON-2024-002', 'XYZ Logistics', 'XYZ002', 'Bangalore, Karnataka', 'Chennai, Tamil Nadu',
         'FTL', '20ft Container', 'Express', 'Per KM', 15.50, 'INR',
         '2024-02-01', '2025-01-31', 'Active', '15 days'),
        
        ('CON-2024-003', 'Fast Freight Co', 'FFC003', 'Pune, Maharashtra', 'Hyderabad, Telangana',
         'FTL', 'Reefer Trailer', 'Guaranteed', 'Per Trip', 18000.00, 'INR',
         '2024-03-01', '2024-08-31', 'Active', '45 days')
    ]
    
    insert_sql = """
    INSERT INTO transport_contracts (
        contract_id, carrier_name, carrier_code, origin_location, destination_location,
        mode, equipment_type, service_level, rate_type, base_rate, rate_currency,
        effective_from, effective_to, contract_status, payment_terms
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    
    for data in sample_data:
        try:
            cursor.execute(insert_sql, data)
            print(f"  ✓ Inserted: {data[0]} - {data[1]}")
        except Error as e:
            if "duplicate entry" in str(e).lower():
                print(f"  ⚠ Skipped (duplicate): {data[0]}")
            else:
                print(f"  ✗ Error inserting {data[0]}: {e}")

def create_views(cursor):
    """Create useful views"""
    print("👁️ Creating views...")
    
    # Active contracts view
    active_view_sql = """
    CREATE OR REPLACE VIEW active_contracts AS
    SELECT 
        contract_id, carrier_name, carrier_code, origin_location, destination_location,
        mode, equipment_type, service_level, rate_type, base_rate, rate_currency,
        effective_from, effective_to, contract_status
    FROM transport_contracts 
    WHERE contract_status = 'Active' 
    AND CURDATE() BETWEEN effective_from AND effective_to
    """
    
    try:
        cursor.execute(active_view_sql)
        print("  ✓ Created active_contracts view")
    except Error as e:
        print(f"  ⚠ View creation: {e}")
    
    # Contract summary view
    summary_view_sql = """
    CREATE OR REPLACE VIEW contract_summary AS
    SELECT 
        contract_status,
        COUNT(*) as contract_count,
        AVG(base_rate) as avg_base_rate,
        MIN(effective_from) as earliest_start,
        MAX(effective_to) as latest_end
    FROM transport_contracts 
    GROUP BY contract_status
    """
    
    try:
        cursor.execute(summary_view_sql)
        print("  ✓ Created contract_summary view")
    except Error as e:
        print(f"  ⚠ View creation: {e}")

def show_table_info(cursor):
    """Show table information"""
    print("\n📋 Table Information:")
    print("-" * 50)
    
    # Show table structure
    cursor.execute("DESCRIBE transport_contracts")
    columns = cursor.fetchall()
    
    print(f"{'Field':<25} {'Type':<20} {'Null':<8} {'Key':<8} {'Default':<15} {'Extra':<10}")
    print("-" * 90)
    for col in columns:
        print(f"{col[0]:<25} {col[1]:<20} {col[2]:<8} {col[3]:<8} {str(col[4]):<15} {col[5]:<10}")
    
    # Show data count
    cursor.execute("SELECT COUNT(*) FROM transport_contracts")
    count = cursor.fetchone()[0]
    print(f"\n📊 Total contracts: {count}")
    
    if count > 0:
        print("\n🔍 Sample contracts:")
        cursor.execute("SELECT contract_id, carrier_name, origin_location, destination_location, base_rate FROM transport_contracts LIMIT 3")
        samples = cursor.fetchall()
        for sample in samples:
            print(f"  - {sample[0]}: {sample[1]} ({sample[2]} → {sample[3]}) - ₹{sample[4]}")

if __name__ == "__main__":
    create_contract_table() 