#!/usr/bin/env python3
"""
Carrier Master Table Creation Script
Creates the carrier_master table for TL transportation procurement
"""

import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv

def create_carrier_master_table():
    """Create the carrier_master table and related views"""

    # Load environment variables
    load_dotenv()

    config = {
        'host': os.getenv('MYSQL_HOST', 'localhost'),
        'user': os.getenv('MYSQL_USER', 'routecraft_user'),
        'password': os.getenv('MYSQL_PASSWORD', 'routecraft_password'),
        'database': os.getenv('MYSQL_DATABASE', 'routecraft'),
        'port': int(os.getenv('MYSQL_PORT', 3306))
    }

    print("🚛 Creating Carrier Master Table for TL Transportation")
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
            CREATE TABLE IF NOT EXISTS carrier_master (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                carrier_id VARCHAR(100) UNIQUE NOT NULL COMMENT 'Unique system-generated or assigned ID',
                carrier_name VARCHAR(255) NOT NULL COMMENT 'Registered legal entity name',
                carrier_code VARCHAR(50) UNIQUE NOT NULL COMMENT 'Short code used in TMS/ERP',
                pan_number VARCHAR(20) COMMENT 'Indian tax identification',
                gstin VARCHAR(20) COMMENT 'Indian tax registration number',
                registered_address TEXT COMMENT 'Carrier''s official address',
                contact_person_name VARCHAR(255) COMMENT 'Primary contact name',
                contact_number VARCHAR(20) COMMENT 'Phone number of POC',
                email VARCHAR(255) COMMENT 'Official communication address',
                region_coverage ENUM('North India', 'South India', 'East India', 'West India', 'Central India', 'PAN India', 'Specific States') COMMENT 'Geographic zones they operate in',
                fleet_size INT COMMENT 'Total number of vehicles owned',
                vehicle_types JSON COMMENT 'Supported equipment as JSON array',
                own_market ENUM('Own', 'Market', 'Mixed') DEFAULT 'Market' COMMENT 'Whether fleet is owned or brokered',
                avg_acceptance_rate DECIMAL(5,2) COMMENT 'Historic load acceptance rate (0-100)',
                avg_on_time_performance DECIMAL(5,2) COMMENT 'Pickup and delivery OTP (0-100)',
                billing_accuracy DECIMAL(5,2) COMMENT 'Disputes vs total bills (0-100)',
                compliance_valid_until DATE COMMENT 'Latest document (RC, Insurance, Fitness) validity',
                preferred_carrier ENUM('Yes', 'No') DEFAULT 'No' COMMENT 'Internal status flag',
                contracted ENUM('Yes', 'No') DEFAULT 'No' COMMENT 'Whether under active rate contract',
                rate_expiry_date DATE COMMENT 'If applicable',
                carrier_rating ENUM('1', '2', '3', '4', '5', 'A', 'B', 'C', 'D', 'E') COMMENT 'Internal performance score',
                payment_terms VARCHAR(255) COMMENT 'e.g., 30 days from invoice, COD, Advance',
                bank_name VARCHAR(255) COMMENT 'For payments',
                account_number VARCHAR(50) COMMENT 'Carrier''s bank account number',
                ifsc_code VARCHAR(20) COMMENT 'For electronic transfers',
                msme_registered ENUM('Yes', 'No') DEFAULT 'No' COMMENT 'MSME registration status in India',
                last_load_date DATE COMMENT 'When they last moved a shipment',
                blacklisted ENUM('Yes', 'No') DEFAULT 'No' COMMENT 'Status if carrier was blocked',
                remarks TEXT COMMENT 'Additional notes',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
                created_by VARCHAR(100) COMMENT 'User who created the carrier record',
                updated_by VARCHAR(100) COMMENT 'User who last updated the carrier record',
                
                -- Indexes for Performance
                INDEX idx_carrier_id (carrier_id),
                INDEX idx_carrier_code (carrier_code),
                INDEX idx_carrier_name (carrier_name),
                INDEX idx_region_coverage (region_coverage),
                INDEX idx_preferred_carrier (preferred_carrier),
                INDEX idx_contracted (contracted),
                INDEX idx_carrier_rating (carrier_rating),
                INDEX idx_blacklisted (blacklisted),
                INDEX idx_compliance_validity (compliance_valid_until),
                INDEX idx_last_load_date (last_load_date),
                INDEX idx_avg_otp (avg_on_time_performance),
                INDEX idx_avg_acceptance (avg_acceptance_rate),
                INDEX idx_billing_accuracy (billing_accuracy)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Carrier Master for TL transportation procurement with comprehensive carrier information'
            """

            print("🏗️ Creating carrier_master table...")
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
    """Insert sample carrier master data"""
    print("📝 Inserting sample carrier master data...")

    sample_data = [
        ('CAR-001', 'Gati Ltd', 'GATI', 'ABCDE1234F', '22AAAAA0000A1Z5', '123, Transport Nagar, Gurgaon, Haryana 122001', 'Rajesh Kumar', '+91-9876543210', 'rajesh.kumar@gati.com', 'PAN India', 500, '["32ft SXL", "20ft Container", "Reefer"]', 'Own', 95.50, 92.30, 98.20, '2025-12-31', 'Yes', 'Yes', '2025-06-30', 'A', '30 days from invoice', 'HDFC Bank', '1234567890', 'HDFC0001234', 'Yes', '2024-12-15', 'No', 'Premium carrier with excellent track record', 'admin', 'admin'),
        
        ('CAR-002', 'Delhivery', 'DELHI', 'BCDEF2345G', '33BBBBB0000B2Z6', '456, Logistics Park, Delhi, Delhi 110001', 'Priya Sharma', '+91-8765432109', 'priya.sharma@delhivery.com', 'PAN India', 800, '["32ft Trailer", "Flatbed", "20ft Container"]', 'Mixed', 88.75, 89.45, 95.80, '2025-10-31', 'Yes', 'Yes', '2025-08-31', 'B', '45 days from invoice', 'ICICI Bank', '0987654321', 'ICIC0000987', 'No', '2024-12-10', 'No', 'Large fleet with good coverage', 'admin', 'admin'),
        
        ('CAR-003', 'Blue Dart Express', 'BLUED', 'CDEFG3456H', '44CCCCC0000C3Z7', '789, Cargo Hub, Mumbai, Maharashtra 400001', 'Amit Patel', '+91-7654321098', 'amit.patel@bluedart.com', 'PAN India', 1200, '["32ft SXL", "Reefer", "20ft Container", "Flatbed"]', 'Own', 92.30, 94.20, 97.50, '2025-09-30', 'Yes', 'Yes', '2025-07-31', 'A', '30 days from invoice', 'SBI Bank', '1122334455', 'SBIN0001122', 'No', '2024-12-12', 'No', 'Express delivery specialist', 'admin', 'admin'),
        
        ('CAR-004', 'ABC Transport Ltd', 'ABCT', 'DEFGH4567I', '55DDDDD0000D4Z8', '321, Transport Colony, Chennai, Tamil Nadu 600001', 'Suresh Reddy', '+91-6543210987', 'suresh.reddy@abctransport.com', 'South India', 300, '["32ft Trailer", "20ft Container"]', 'Market', 85.60, 87.30, 93.40, '2025-11-30', 'No', 'Yes', '2025-05-31', 'C', '60 days from invoice', 'Canara Bank', '2233445566', 'CNRB0002233', 'Yes', '2024-12-08', 'No', 'Regional carrier with good rates', 'admin', 'admin'),
        
        ('CAR-005', 'XYZ Logistics', 'XYZL', 'EFGHI5678J', '66EEEEE0000E5Z9', '654, Cargo Terminal, Pune, Maharashtra 411001', 'Meera Desai', '+91-5432109876', 'meera.desai@xyzlogistics.com', 'West India', 450, '["32ft SXL", "Reefer", "Flatbed"]', 'Mixed', 90.20, 91.80, 96.70, '2025-08-31', 'No', 'Yes', '2025-04-30', 'B', '45 days from invoice', 'Axis Bank', '3344556677', 'UTIB0003344', 'No', '2024-12-05', 'No', 'Specialized in temperature-controlled transport', 'admin', 'admin'),
        
        ('CAR-006', 'Fast Freight Co', 'FAST', 'FGHIJ6789K', '77FFFFF0000F6Z0', '987, Freight Zone, Kolkata, West Bengal 700001', 'Vikram Singh', '+91-4321098765', 'vikram.singh@fastfreight.com', 'East India', 250, '["32ft Trailer", "20ft Container"]', 'Market', 82.40, 84.60, 91.30, '2025-07-31', 'No', 'No', None, 'D', 'Advance payment', 'Punjab National Bank', '4455667788', 'PUNB0004455', 'Yes', '2024-11-28', 'No', 'Economy carrier for basic transport needs', 'admin', 'admin'),
        
        ('CAR-007', 'South Express', 'SOUTH', 'GHIJK7890L', '88GGGGG0000G7Z1', '147, Express Way, Hyderabad, Telangana 500001', 'Lakshmi Devi', '+91-3210987654', 'lakshmi.devi@southexpress.com', 'South India', 180, '["20ft Container", "32ft SXL"]', 'Own', 88.90, 86.70, 94.20, '2025-06-30', 'No', 'Yes', '2025-03-31', 'C', '30 days from invoice', 'Karnataka Bank', '5566778899', 'KARB0005566', 'No', '2024-12-01', 'No', 'Small but reliable regional carrier', 'admin', 'admin'),
        
        ('CAR-008', 'Regional Cargo', 'REGIO', 'HIJKL8901M', '99HHHHH0000H8Z2', '258, Cargo Lane, Ahmedabad, Gujarat 380001', 'Rahul Mehta', '+91-2109876543', 'rahul.mehta@regionalcargo.com', 'West India', 120, '["32ft Trailer"]', 'Market', 79.30, 81.50, 89.80, '2025-05-31', 'No', 'No', None, 'E', 'COD only', 'Bank of Baroda', '6677889900', 'BARB0006677', 'Yes', '2024-11-25', 'No', 'Local carrier for short-haul routes', 'admin', 'admin'),
        
        ('CAR-009', 'City Connect', 'CITY', 'IJKLM9012N', '00IIIII0000I9Z3', '369, City Hub, Bangalore, Karnataka 560001', 'Anjali Rao', '+91-1098765432', 'anjali.rao@cityconnect.com', 'South India', 200, '["20ft Container", "32ft SXL", "Flatbed"]', 'Mixed', 86.70, 88.40, 92.90, '2025-04-30', 'No', 'Yes', '2025-02-28', 'C', '45 days from invoice', 'HDFC Bank', '7788990011', 'HDFC0007788', 'No', '2024-11-30', 'No', 'Urban logistics specialist', 'admin', 'admin'),
        
        ('CAR-010', 'Cold Chain Express', 'COLD', 'JKLMN0123O', '11JJJJJ0000J0Z4', '741, Cold Storage, Pune, Maharashtra 411002', 'Sanjay Verma', '+91-0987654321', 'sanjay.verma@coldchain.com', 'West India', 80, '["Reefer", "Temperature-controlled"]', 'Own', 94.20, 96.80, 98.90, '2025-03-31', 'Yes', 'Yes', '2025-01-31', 'A', '30 days from invoice', 'ICICI Bank', '8899001122', 'ICIC0008899', 'No', '2024-12-03', 'No', 'Premium cold chain logistics provider', 'admin', 'admin')
    ]

    insert_sql = """
    INSERT INTO carrier_master (
        carrier_id, carrier_name, carrier_code, pan_number, gstin, registered_address, 
        contact_person_name, contact_number, email, region_coverage, fleet_size, 
        vehicle_types, own_market, avg_acceptance_rate, avg_on_time_performance, 
        billing_accuracy, compliance_valid_until, preferred_carrier, contracted, 
        rate_expiry_date, carrier_rating, payment_terms, bank_name, account_number, 
        ifsc_code, msme_registered, last_load_date, blacklisted, remarks,
        created_by, updated_by
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """

    for data in sample_data:
        try:
            cursor.execute(insert_sql, data)
            print(f"  ✓ Inserted: {data[0]} - {data[1]} ({data[2]})")
        except Error as e:
            if "duplicate entry" in str(e).lower():
                print(f"  ⚠ Skipped (duplicate): {data[0]}")
            else:
                print(f"  ✗ Error inserting {data[0]}: {e}")

def create_views(cursor):
    """Create useful views for carrier master"""
    print("👁️ Creating carrier master views...")

    # Active carriers view
    active_carriers_view_sql = """
    CREATE OR REPLACE VIEW active_carriers AS
    SELECT
        carrier_id,
        carrier_name,
        carrier_code,
        region_coverage,
        fleet_size,
        vehicle_types,
        avg_on_time_performance,
        avg_acceptance_rate,
        billing_accuracy,
        carrier_rating,
        preferred_carrier,
        contracted,
        compliance_valid_until,
        last_load_date
    FROM carrier_master
    WHERE blacklisted = 'No'
    AND (compliance_valid_until IS NULL OR compliance_valid_until >= CURDATE())
    ORDER BY carrier_rating, avg_on_time_performance DESC
    """

    try:
        cursor.execute(active_carriers_view_sql)
        print("  ✓ Created active_carriers view")
    except Error as e:
        print(f"  ⚠ View creation: {e}")

    # Carrier performance summary view
    performance_summary_view_sql = """
    CREATE OR REPLACE VIEW carrier_performance_summary AS
    SELECT
        carrier_rating,
        COUNT(*) as carrier_count,
        AVG(avg_on_time_performance) as avg_otp,
        AVG(avg_acceptance_rate) as avg_acceptance,
        AVG(billing_accuracy) as avg_billing_accuracy,
        AVG(fleet_size) as avg_fleet_size,
        COUNT(CASE WHEN preferred_carrier = 'Yes' THEN 1 END) as preferred_count,
        COUNT(CASE WHEN contracted = 'Yes' THEN 1 END) as contracted_count
    FROM carrier_master
    WHERE blacklisted = 'No'
    GROUP BY carrier_rating
    ORDER BY carrier_rating
    """

    try:
        cursor.execute(performance_summary_view_sql)
        print("  ✓ Created carrier_performance_summary view")
    except Error as e:
        print(f"  ⚠ View creation: {e}")

    # Regional coverage analysis view
    regional_coverage_view_sql = """
    CREATE OR REPLACE VIEW regional_coverage_analysis AS
    SELECT
        region_coverage,
        COUNT(*) as carrier_count,
        AVG(avg_on_time_performance) as avg_otp,
        AVG(avg_acceptance_rate) as avg_acceptance,
        AVG(fleet_size) as avg_fleet_size,
        GROUP_CONCAT(DISTINCT carrier_rating ORDER BY carrier_rating SEPARATOR ', ') as available_ratings,
        COUNT(CASE WHEN preferred_carrier = 'Yes' THEN 1 END) as preferred_carriers,
        COUNT(CASE WHEN contracted = 'Yes' THEN 1 END) as contracted_carriers
    FROM carrier_master
    WHERE blacklisted = 'No'
    GROUP BY region_coverage
    ORDER BY carrier_count DESC
    """

    try:
        cursor.execute(regional_coverage_view_sql)
        print("  ✓ Created regional_coverage_analysis view")
    except Error as e:
        print(f"  ⚠ View creation: {e}")

    # Compliance monitoring view
    compliance_monitoring_view_sql = """
    CREATE OR REPLACE VIEW compliance_monitoring AS
    SELECT
        carrier_id,
        carrier_name,
        carrier_code,
        compliance_valid_until,
        DATEDIFF(compliance_valid_until, CURDATE()) as days_until_expiry,
        CASE 
            WHEN DATEDIFF(compliance_valid_until, CURDATE()) <= 30 THEN 'Expiring Soon'
            WHEN DATEDIFF(compliance_valid_until, CURDATE()) <= 90 THEN 'Warning'
            ELSE 'Valid'
        END as compliance_status,
        last_load_date,
        DATEDIFF(CURDATE(), last_load_date) as days_since_last_load
    FROM carrier_master
    WHERE compliance_valid_until IS NOT NULL
    ORDER BY compliance_valid_until ASC
    """

    try:
        cursor.execute(compliance_monitoring_view_sql)
        print("  ✓ Created compliance_monitoring view")
    except Error as e:
        print(f"  ⚠ View creation: {e}")

def show_table_info(cursor):
    """Show table information and sample data"""
    print("\n📋 Carrier Master Table Information:")
    print("-" * 60)

    # Show table structure
    cursor.execute("DESCRIBE carrier_master")
    columns = cursor.fetchall()

    print(f"{'Field':<30} {'Type':<25} {'Null':<8} {'Key':<8} {'Default':<15} {'Extra':<10}")
    print("-" * 100)
    for col in columns:
        print(f"{col[0]:<30} {col[1]:<25} {col[2]:<8} {col[3]:<8} {str(col[4]):<15} {col[5]:<10}")

    # Show data count
    cursor.execute("SELECT COUNT(*) FROM carrier_master")
    count = cursor.fetchone()[0]
    print(f"\n📊 Total carriers: {count}")

    if count > 0:
        print("\n🔍 Sample carriers:")
        cursor.execute("""
            SELECT carrier_id, carrier_name, carrier_code, region_coverage, 
                   fleet_size, carrier_rating, preferred_carrier, contracted 
            FROM carrier_master LIMIT 5
        """)
        samples = cursor.fetchall()
        for sample in samples:
            print(f"  - {sample[0]}: {sample[1]} ({sample[2]}) - {sample[3]} - Fleet: {sample[4]} - Rating: {sample[5]} - Preferred: {sample[6]} - Contracted: {sample[7]}")

        # Show view information
        print("\n👁️ Available Views:")
        views = ['active_carriers', 'carrier_performance_summary', 'regional_coverage_analysis', 'compliance_monitoring']
        for view in views:
            try:
                cursor.execute(f"SELECT COUNT(*) FROM {view}")
                view_count = cursor.fetchone()[0]
                print(f"  - {view}: {view_count} records")
            except Error as e:
                print(f"  - {view}: Error - {e}")

        # Show performance statistics
        print("\n📈 Performance Statistics:")
        cursor.execute("""
            SELECT 
                AVG(avg_on_time_performance) as avg_otp,
                AVG(avg_acceptance_rate) as avg_acceptance,
                AVG(billing_accuracy) as avg_billing,
                COUNT(CASE WHEN preferred_carrier = 'Yes' THEN 1 END) as preferred_count,
                COUNT(CASE WHEN contracted = 'Yes' THEN 1 END) as contracted_count,
                COUNT(CASE WHEN blacklisted = 'Yes' THEN 1 END) as blacklisted_count
            FROM carrier_master
        """)
        stats = cursor.fetchone()
        print(f"  - Average OTP: {stats[0]:.2f}%")
        print(f"  - Average Acceptance Rate: {stats[1]:.2f}%")
        print(f"  - Average Billing Accuracy: {stats[2]:.2f}%")
        print(f"  - Preferred Carriers: {stats[3]}")
        print(f"  - Contracted Carriers: {stats[4]}")
        print(f"  - Blacklisted Carriers: {stats[5]}")

if __name__ == "__main__":
    create_carrier_master_table() 