#!/usr/bin/env python3
"""
Accessorial Definitions Master Table Creation Script
Creates the accessorial_definitions_master table for TL transportation accessorial charges
"""

import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv

def create_accessorial_definitions_master_table():
    """Create the accessorial_definitions_master table and related views"""

    # Load environment variables
    load_dotenv()

    config = {
        'host': os.getenv('MYSQL_HOST', 'localhost'),
        'user': os.getenv('MYSQL_USER', 'routecraft_user'),
        'password': os.getenv('MYSQL_PASSWORD', 'routecraft_password'),
        'database': os.getenv('MYSQL_DATABASE', 'routecraft'),
        'port': int(os.getenv('MYSQL_PORT', 3306))
    }

    print("💰 Creating Accessorial Definitions Master Table for TL Transportation")
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
            CREATE TABLE IF NOT EXISTS accessorial_definitions_master (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                accessorial_id VARCHAR(100) UNIQUE NOT NULL COMMENT 'Unique accessorial code (e.g., ACC-DET01)',
                accessorial_name VARCHAR(255) NOT NULL COMMENT 'Name of the charge (e.g., Detention, Driver Assist)',
                description TEXT COMMENT 'Short explanation of the condition under which it is applied',
                applies_to ENUM('Pickup', 'Delivery', 'In-Transit', 'General') NOT NULL COMMENT 'Pickup / Delivery / In-Transit / General',
                trigger_condition TEXT COMMENT 'E.g., More than 2 hours waiting, over 1 extra stop',
                rate_type ENUM('Flat Fee', 'Per Hour', 'Per KM', 'Per Attempt', 'Per Pallet', 'Per MT', 'Per Stop') NOT NULL COMMENT 'Rate calculation method',
                rate_value DECIMAL(10,2) NOT NULL COMMENT 'Numeric amount (e.g., ₹500/hour for detention)',
                unit ENUM('Hours', 'KM', 'Pallet', 'Stop', 'Attempt', 'MT', 'Trip') NOT NULL COMMENT 'Hours / KM / Pallet / Stop / Attempt',
                taxable ENUM('Yes', 'No') DEFAULT 'Yes' COMMENT 'Whether GST or other tax applies',
                included_in_base ENUM('Yes', 'No') DEFAULT 'No' COMMENT 'Whether it is bundled or billed separately',
                invoice_code VARCHAR(100) COMMENT 'For finance/invoice processing systems',
                gl_mapping VARCHAR(100) COMMENT 'General Ledger account mapping',
                applicable_equipment_types TEXT COMMENT 'E.g., Only for reefers, flatbeds, etc.',
                carrier_editable_in_bid ENUM('Yes', 'No') DEFAULT 'No' COMMENT 'Can carriers propose their own value in RFP?',
                remarks TEXT COMMENT 'Notes on usage, exceptions, or region-specific rules',
                is_active ENUM('Yes', 'No') DEFAULT 'Yes' COMMENT 'Whether this accessorial is currently active',
                effective_from DATE NOT NULL COMMENT 'Date from which this accessorial is effective',
                effective_to DATE COMMENT 'Date until which this accessorial is effective (NULL for indefinite)',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
                created_by VARCHAR(100) COMMENT 'User who created the accessorial',
                updated_by VARCHAR(100) COMMENT 'User who last updated the accessorial',
                
                -- Indexes for Performance
                INDEX idx_accessorial_id (accessorial_id),
                INDEX idx_accessorial_name (accessorial_name),
                INDEX idx_applies_to (applies_to),
                INDEX idx_rate_type (rate_type),
                INDEX idx_taxable (taxable),
                INDEX idx_included_in_base (included_in_base),
                INDEX idx_carrier_editable (carrier_editable_in_bid),
                INDEX idx_is_active (is_active),
                INDEX idx_effective_from (effective_from),
                INDEX idx_effective_to (effective_to),
                INDEX idx_rate_value (rate_value)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Accessorial Definitions Master for TL transportation with comprehensive charge definitions'
            """

            print("🏗️ Creating accessorial_definitions_master table...")
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
    """Insert sample accessorial data"""
    print("📝 Inserting sample accessorial data...")
    
    from datetime import date, timedelta
    
    # Get current date for effective_from
    current_date = date.today()
    
    sample_data = [
        # Detention Charges
        ('ACC-DET-2025', 'Detention – Delivery Site', 'Charged when truck waits beyond free time at delivery location', 'Delivery', 'After 2 hours of free time', 'Per Hour', 400.00, 'Hours', 'Yes', 'No', 'DET-DEL', 'GL-4001', 'All equipment types', 'No', 'Applicable to metro zones only', 'Yes', current_date, None, 'System', 'System'),
        
        ('ACC-DET-PICKUP', 'Detention – Pickup Site', 'Charged when truck waits beyond free time at pickup location', 'Pickup', 'After 1.5 hours of free time', 'Per Hour', 350.00, 'Hours', 'Yes', 'No', 'DET-PICK', 'GL-4002', 'All equipment types', 'No', 'Standard detention charge for pickup delays', 'Yes', current_date, None, 'System', 'System'),
        
        # Multi-stop Fees
        ('ACC-MULTI-01', 'Multi-stop Fee', 'Additional charge for deliveries at multiple drop-off points', 'Delivery', 'For each additional stop beyond first delivery', 'Per Stop', 500.00, 'Stop', 'Yes', 'No', 'MULTI-STOP', 'GL-4003', 'All equipment types', 'Yes', 'Negotiable based on distance and complexity', 'Yes', current_date, None, 'System', 'System'),
        
        # Loading/Unloading Charges
        ('ACC-LOAD-01', 'Loading Assistance', 'When driver or vehicle helps with loading operations', 'Pickup', 'Manual loading assistance required', 'Per MT', 150.00, 'MT', 'Yes', 'No', 'LOAD-ASSIST', 'GL-4004', 'All equipment types', 'Yes', 'Based on actual loading time and complexity', 'Yes', current_date, None, 'System', 'System'),
        
        ('ACC-UNLOAD-01', 'Unloading Assistance', 'When driver or vehicle helps with unloading operations', 'Delivery', 'Manual unloading assistance required', 'Per MT', 150.00, 'MT', 'Yes', 'No', 'UNLOAD-ASSIST', 'GL-4005', 'All equipment types', 'Yes', 'Based on actual unloading time and complexity', 'Yes', current_date, None, 'System', 'System'),
        
        # Toll Charges
        ('ACC-TOLL-01', 'Toll Charges', 'Highway and bridge toll fees for certain routes', 'In-Transit', 'Route includes toll roads or bridges', 'Flat Fee', 250.00, 'Trip', 'Yes', 'No', 'TOLL-FEE', 'GL-4006', 'All equipment types', 'No', 'Fixed toll charge for standard routes', 'Yes', current_date, None, 'System', 'System'),
        
        # Escort Fee
        ('ACC-ESCORT-01', 'Escort Fee', 'For high-value or over-dimensional cargo requiring escort', 'In-Transit', 'Cargo value exceeds ₹10 lakhs or dimensions exceed limits', 'Flat Fee', 2000.00, 'Trip', 'Yes', 'No', 'ESCORT-FEE', 'GL-4007', 'All equipment types', 'No', 'Required for high-value shipments and oversized cargo', 'Yes', current_date, None, 'System', 'System'),
        
        # Fuel Surcharge
        ('ACC-FUEL-01', 'Fuel Surcharge', 'Variable percentage based on diesel price index', 'General', 'Applied when diesel price exceeds base threshold', 'Per KM', 2.50, 'KM', 'Yes', 'Yes', 'FUEL-SUR', 'GL-4008', 'All equipment types', 'No', 'Percentage varies monthly based on fuel price index', 'Yes', current_date, None, 'System', 'System'),
        
        # Night Delivery Charges
        ('ACC-NIGHT-01', 'Night Delivery Charges', 'For delivery outside regular business hours', 'Delivery', 'Delivery between 8 PM and 6 AM', 'Flat Fee', 800.00, 'Trip', 'Yes', 'No', 'NIGHT-DEL', 'GL-4009', 'All equipment types', 'Yes', 'Additional charge for after-hours delivery', 'Yes', current_date, None, 'System', 'System'),
        
        # Reattempt Fee
        ('ACC-REATTEMPT-01', 'Reattempt Fee', 'When delivery is unsuccessful and retried', 'Delivery', 'Delivery attempt failed, retry required', 'Per Attempt', 300.00, 'Attempt', 'Yes', 'No', 'REATTEMPT', 'GL-4010', 'All equipment types', 'No', 'Charged for each additional delivery attempt', 'Yes', current_date, None, 'System', 'System'),
        
        # Weighbridge Fee
        ('ACC-WEIGH-01', 'Weighbridge Fee', 'Charged when weighing is mandatory at checkpoints', 'In-Transit', 'Mandatory weighing at checkpoints or borders', 'Flat Fee', 200.00, 'Trip', 'Yes', 'No', 'WEIGH-FEE', 'GL-4011', 'All equipment types', 'No', 'Standard weighbridge charge', 'Yes', current_date, None, 'System', 'System'),
        
        # Temperature Monitoring
        ('ACC-TEMP-01', 'Temperature Monitoring', 'Additional charge for temperature-controlled shipments', 'In-Transit', 'Temperature monitoring and recording required', 'Per Hour', 50.00, 'Hours', 'Yes', 'No', 'TEMP-MON', 'GL-4012', 'Reefer, insulated trailers only', 'No', 'For pharmaceuticals and temperature-sensitive cargo', 'Yes', current_date, None, 'System', 'System'),
        
        # Security Escort
        ('ACC-SEC-01', 'Security Escort', 'Armed or unarmed security personnel for high-value cargo', 'In-Transit', 'Cargo value exceeds ₹25 lakhs or security requirement', 'Flat Fee', 5000.00, 'Trip', 'Yes', 'No', 'SEC-ESCORT', 'GL-4013', 'All equipment types', 'No', 'Required for high-value electronics, jewelry, cash', 'Yes', current_date, None, 'System', 'System'),
        
        # Border Crossing
        ('ACC-BORDER-01', 'Border Crossing Fee', 'Additional charges for interstate or international border crossing', 'In-Transit', 'Crossing state or international borders', 'Flat Fee', 400.00, 'Trip', 'Yes', 'No', 'BORDER-FEE', 'GL-4014', 'All equipment types', 'No', 'Standard border crossing charge', 'Yes', current_date, None, 'System', 'System'),
        
        # Special Equipment
        ('ACC-EQUIP-01', 'Special Equipment Fee', 'Additional charge for specialized equipment requirements', 'General', 'Specialized equipment like hydraulic lift, crane, etc.', 'Flat Fee', 1500.00, 'Trip', 'Yes', 'No', 'SPEC-EQUIP', 'GL-4015', 'Specialized equipment only', 'Yes', 'Based on equipment type and availability', 'Yes', current_date, None, 'System', 'System'),
        
        # Documentation
        ('ACC-DOC-01', 'Documentation Fee', 'Additional paperwork and documentation processing', 'General', 'Complex documentation or special permits required', 'Flat Fee', 300.00, 'Trip', 'Yes', 'No', 'DOC-FEE', 'GL-4016', 'All equipment types', 'No', 'For shipments requiring special permits or documentation', 'Yes', current_date, None, 'System', 'System')
    ]

    insert_sql = """
    INSERT INTO accessorial_definitions_master (
        accessorial_id, accessorial_name, description, applies_to, trigger_condition,
        rate_type, rate_value, unit, taxable, included_in_base, invoice_code,
        gl_mapping, applicable_equipment_types, carrier_editable_in_bid, remarks,
        is_active, effective_from, effective_to, created_by, updated_by
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """

    success_count = 0
    for data in sample_data:
        try:
            cursor.execute(insert_sql, data)
            success_count += 1
            print(f"  ✓ Inserted {data[0]}: {data[1]}")
        except Error as e:
            print(f"  ✗ Error inserting {data[0]}: {e}")

    print(f"📊 Successfully inserted {success_count} out of {len(sample_data)} accessorial definitions")

def create_views(cursor):
    """Create useful views for accessorial analysis"""
    print("👁️ Creating accessorial views...")
    
    views = [
        # Active Accessorials View
        ("active_accessorials", """
        CREATE OR REPLACE VIEW active_accessorials AS
        SELECT 
            accessorial_id,
            accessorial_name,
            applies_to,
            rate_type,
            rate_value,
            unit,
            taxable,
            included_in_base,
            carrier_editable_in_bid
        FROM accessorial_definitions_master
        WHERE is_active = 'Yes' AND (effective_to IS NULL OR effective_to >= CURDATE())
        ORDER BY applies_to, accessorial_name
        """),
        
        # Accessorial Summary by Category View
        ("accessorial_summary_by_category", """
        CREATE OR REPLACE VIEW accessorial_summary_by_category AS
        SELECT 
            applies_to,
            COUNT(*) as total_accessorials,
            COUNT(CASE WHEN taxable = 'Yes' THEN 1 END) as taxable_count,
            COUNT(CASE WHEN included_in_base = 'Yes' THEN 1 END) as included_in_base_count,
            COUNT(CASE WHEN carrier_editable_in_bid = 'Yes' THEN 1 END) as carrier_editable_count,
            AVG(rate_value) as avg_rate_value
        FROM accessorial_definitions_master
        WHERE is_active = 'Yes'
        GROUP BY applies_to
        ORDER BY applies_to
        """),
        
        # Rate Type Analysis View
        ("rate_type_analysis", """
        CREATE OR REPLACE VIEW rate_type_analysis AS
        SELECT 
            rate_type,
            COUNT(*) as total_accessorials,
            COUNT(CASE WHEN taxable = 'Yes' THEN 1 END) as taxable_count,
            AVG(rate_value) as avg_rate_value,
            MIN(rate_value) as min_rate_value,
            MAX(rate_value) as max_rate_value
        FROM accessorial_definitions_master
        WHERE is_active = 'Yes'
        GROUP BY rate_type
        ORDER BY rate_type
        """),
        
        # Taxable vs Non-Taxable Accessorials View
        ("taxable_accessorials_analysis", """
        CREATE OR REPLACE VIEW taxable_accessorials_analysis AS
        SELECT 
            taxable,
            COUNT(*) as total_accessorials,
            AVG(rate_value) as avg_rate_value,
            SUM(CASE WHEN applies_to = 'Pickup' THEN 1 ELSE 0 END) as pickup_count,
            SUM(CASE WHEN applies_to = 'Delivery' THEN 1 ELSE 0 END) as delivery_count,
            SUM(CASE WHEN applies_to = 'In-Transit' THEN 1 ELSE 0 END) as in_transit_count,
            SUM(CASE WHEN applies_to = 'General' THEN 1 ELSE 0 END) as general_count
        FROM accessorial_definitions_master
        WHERE is_active = 'Yes'
        GROUP BY taxable
        ORDER BY taxable
        """),
        
        # Carrier Editable Accessorials View
        ("carrier_editable_accessorials", """
        CREATE OR REPLACE VIEW carrier_editable_accessorials AS
        SELECT 
            accessorial_id,
            accessorial_name,
            applies_to,
            rate_type,
            rate_value,
            unit,
            remarks
        FROM accessorial_definitions_master
        WHERE carrier_editable_in_bid = 'Yes' AND is_active = 'Yes'
        ORDER BY applies_to, accessorial_name
        """),
        
        # High-Value Accessorials View
        ("high_value_accessorials", """
        CREATE OR REPLACE VIEW high_value_accessorials AS
        SELECT 
            accessorial_id,
            accessorial_name,
            applies_to,
            rate_type,
            rate_value,
            unit,
            taxable,
            remarks
        FROM accessorial_definitions_master
        WHERE rate_value > 1000 AND is_active = 'Yes'
        ORDER BY rate_value DESC
        """),
        
        # Equipment-Specific Accessorials View
        ("equipment_specific_accessorials", """
        CREATE OR REPLACE VIEW equipment_specific_accessorials AS
        SELECT 
            accessorial_id,
            accessorial_name,
            applicable_equipment_types,
            applies_to,
            rate_type,
            rate_value,
            unit
        FROM accessorial_definitions_master
        WHERE applicable_equipment_types != 'All equipment types' AND is_active = 'Yes'
        ORDER BY applicable_equipment_types, accessorial_name
        """)
    ]

    for view_name, view_sql in views:
        try:
            cursor.execute(view_sql)
            print(f"  ✓ Created {view_name} view")
        except Error as e:
            print(f"  ✗ Error creating {view_name} view: {e}")

def show_table_info(cursor):
    """Display table information and sample data"""
    print("\n📋 Accessorial Definitions Master Table Information:")
    print("-" * 60)
    
    # Show table structure
    cursor.execute("DESCRIBE accessorial_definitions_master")
    columns = cursor.fetchall()
    
    print(f"{'Field':<35} {'Type':<25} {'Null':<8} {'Key':<8} {'Default':<15} {'Extra'}")
    print("-" * 100)
    
    for column in columns:
        field, type_name, null, key, default, extra = column
        print(f"{field:<35} {type_name:<25} {null:<8} {key:<8} {str(default):<15} {extra}")
    
    # Show record count
    cursor.execute("SELECT COUNT(*) FROM accessorial_definitions_master")
    total_records = cursor.fetchone()[0]
    print(f"\n📊 Total accessorial definitions: {total_records}")
    
    # Show sample data
    cursor.execute("""
        SELECT accessorial_id, accessorial_name, applies_to, 
               rate_type, rate_value, unit, taxable, included_in_base
        FROM accessorial_definitions_master 
        ORDER BY accessorial_id 
        LIMIT 5
    """)
    
    sample_records = cursor.fetchall()
    if sample_records:
        print("🔍 Sample accessorial definitions:")
        for record in sample_records:
            acc_id, name, applies_to, rate_type, rate_value, unit, taxable, included = record
            print(f"  - {acc_id}: {name} ({applies_to}) - ₹{rate_value}/{unit}, {rate_type}, Taxable: {taxable}, Base: {included}")
    
    # Show available views
    cursor.execute("SHOW TABLES LIKE '%view%'")
    views = cursor.fetchall()
    if views:
        print(f"\n👁️ Available Views:")
        for view in views:
            print(f"  - {view[0]}")
    else:
        print("\n👁️ No views found")

if __name__ == "__main__":
    create_accessorial_definitions_master_table() 