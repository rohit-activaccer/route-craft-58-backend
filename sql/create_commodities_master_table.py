#!/usr/bin/env python3
"""Create Commodities Master Table for TL Transportation"""

import mysql.connector
from dotenv import load_dotenv
import os
from datetime import datetime

def create_commodities_master_table():
    """Create the commodities_master table and populate with sample data"""
    
    load_dotenv()
    config = {
        'host': os.getenv('MYSQL_HOST', 'localhost'),
        'user': os.getenv('MYSQL_USER', 'routecraft_user'),
        'password': os.getenv('MYSQL_PASSWORD', 'routecraft_password'),
        'database': os.getenv('MYSQL_DATABASE', 'routecraft'),
        'port': int(os.getenv('MYSQL_PORT', 3306))
    }
    
    try:
        connection = mysql.connector.connect(**config)
        cursor = connection.cursor()
        
        print("🔌 Connected to MySQL database successfully!")
        
        # Create commodities_master table
        create_table_sql = """
        CREATE TABLE IF NOT EXISTS commodities_master (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            commodity_id VARCHAR(50) NOT NULL COMMENT 'Unique system-assigned code',
            commodity_name VARCHAR(255) NOT NULL COMMENT 'Name of the commodity',
            commodity_category ENUM('Perishable', 'Industrial', 'FMCG', 'Hazardous', 'Electronics', 'Textiles', 'Automotive', 'Pharmaceuticals', 'Construction', 'Agriculture') NOT NULL,
            hsn_code VARCHAR(20) COMMENT 'Harmonized System Nomenclature',
            typical_packaging_type ENUM('Palletized', 'Drums', 'Loose Cartons', 'Bags', 'Bulk', 'Crates', 'Barrels', 'Rolls', 'Bundles', 'Individual Units') NOT NULL,
            handling_instructions TEXT COMMENT 'Special handling requirements',
            temperature_controlled BOOLEAN DEFAULT FALSE COMMENT 'Needs reefer or climate control',
            hazmat BOOLEAN DEFAULT FALSE COMMENT 'Hazardous material',
            value_category ENUM('Low', 'Medium', 'High', 'Very High') NOT NULL DEFAULT 'Medium',
            avg_weight_per_load DECIMAL(8,2) COMMENT 'Average weight per load in MT',
            avg_volume_per_load DECIMAL(8,2) COMMENT 'Average volume per load in CFT',
            insurance_required BOOLEAN DEFAULT FALSE COMMENT 'Special insurance needed',
            sensitive_cargo BOOLEAN DEFAULT FALSE COMMENT 'Triggers geofencing/tamper alerts',
            loading_unloading_sla INT COMMENT 'Load/unload time in minutes',
            min_insurance_amount DECIMAL(12,2) COMMENT 'Minimum insurance amount in INR',
            preferred_carrier_types JSON COMMENT 'Preferred carrier types',
            restricted_carrier_types JSON COMMENT 'Restricted carrier types',
            seasonal_peak_start DATE COMMENT 'Seasonal peak start date',
            seasonal_peak_end DATE COMMENT 'Seasonal peak end date',
            commodity_status ENUM('Active', 'Inactive', 'Seasonal', 'Discontinued') NOT NULL DEFAULT 'Active',
            remarks TEXT COMMENT 'Additional notes',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            created_by VARCHAR(100),
            updated_by VARCHAR(100),
            
            INDEX idx_commodity_id (commodity_id),
            INDEX idx_commodity_category (commodity_category),
            INDEX idx_temperature_controlled (temperature_controlled),
            INDEX idx_hazmat (hazmat),
            INDEX idx_value_category (value_category),
            INDEX idx_commodity_status (commodity_status),
            
            UNIQUE KEY uk_commodity_id (commodity_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        COMMENT='Master reference dataset for commodity types in TL transportation';
        """
        
        cursor.execute(create_table_sql)
        print("✅ Commodities Master table created successfully!")
        
        # Insert sample data
        insert_sample_data(cursor)
        
        # Create views
        create_views(cursor)
        
        # Show table info
        show_table_info(cursor)
        
        connection.commit()
        print("✅ All operations completed successfully!")
        
    except mysql.connector.Error as err:
        print(f"❌ MySQL Error: {err}")
    except Exception as e:
        print(f"❌ Error: {e}")
    finally:
        if 'connection' in locals() and connection.is_connected():
            cursor.close()
            connection.close()
            print("🔌 Database connection closed")

def insert_sample_data(cursor):
    """Insert sample commodities data"""
    
    sample_commodities = [
        ('CMD-001', 'FMCG Cartons', 'FMCG', '4819', 'Loose Cartons', 'Stack max 5 layers, Keep dry', False, False, 'Medium', 8.5, 1200.0, True, False, 120, 500000.00, '["32ft SXL", "Closed Body"]', '["Open Body"]', None, None, 'Active', 'Standard FMCG items'),
        ('CMD-002', 'Electronics & Gadgets', 'Electronics', '8517', 'Individual Units', 'Fragile - Handle with care', False, False, 'High', 3.2, 800.0, True, True, 180, 2000000.00, '["32ft SXL", "Air Suspension"]', '["Open Body"]', None, None, 'Active', 'High-value electronics'),
        ('CMD-003', 'Pharmaceutical Products', 'Pharmaceuticals', '3004', 'Palletized', 'Temperature sensitive, 15-25°C', True, False, 'Very High', 5.8, 950.0, True, True, 150, 5000000.00, '["Reefer", "Temperature Controlled"]', '["Open Body"]', None, None, 'Active', 'Critical temperature control'),
        ('CMD-004', 'Steel Coils', 'Industrial', '7208', 'Rolls', 'Heavy loads, Use cranes', False, False, 'Medium', 25.0, 600.0, False, False, 240, 100000.00, '["Flatbed", "Heavy Duty"]', '["Closed Body"]', None, None, 'Active', 'Heavy industrial material'),
        ('CMD-005', 'Industrial Chemicals', 'Hazardous', '2811', 'Drums', 'HAZMAT - Special handling', False, True, 'High', 12.5, 750.0, True, True, 300, 3000000.00, '["HAZMAT Certified", "Closed Body"]', '["Open Body", "Food Carriers"]', None, None, 'Active', 'Dangerous goods')
    ]
    
    insert_sql = """
    INSERT INTO commodities_master (
        commodity_id, commodity_name, commodity_category, hsn_code, typical_packaging_type,
        handling_instructions, temperature_controlled, hazmat, value_category, avg_weight_per_load,
        avg_volume_per_load, insurance_required, sensitive_cargo, loading_unloading_sla,
        min_insurance_amount, preferred_carrier_types, restricted_carrier_types, remarks
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    
    for commodity in sample_commodities:
        cursor.execute(insert_sql, commodity)
    
    print(f"✅ Inserted {len(sample_commodities)} sample commodities")

def create_views(cursor):
    """Create analytical views"""
    
    views = [
        ("active_commodities_by_category", """
        CREATE OR REPLACE VIEW active_commodities_by_category AS
        SELECT commodity_category, COUNT(*) as count, 
               AVG(avg_weight_per_load) as avg_weight,
               COUNT(CASE WHEN temperature_controlled = TRUE THEN 1 END) as temp_controlled_count
        FROM commodities_master WHERE commodity_status = 'Active'
        GROUP BY commodity_category ORDER BY count DESC;
        """),
        
        ("high_value_commodities", """
        CREATE OR REPLACE VIEW high_value_commodities AS
        SELECT commodity_id, commodity_name, commodity_category, value_category,
               min_insurance_amount, temperature_controlled, hazmat
        FROM commodities_master 
        WHERE value_category IN ('High', 'Very High') AND commodity_status = 'Active'
        ORDER BY min_insurance_amount DESC;
        """),
        
        ("equipment_requirements", """
        CREATE OR REPLACE VIEW equipment_requirements AS
        SELECT commodity_id, commodity_name, commodity_category,
               CASE WHEN temperature_controlled = TRUE THEN 'Reefer Required'
                    WHEN hazmat = TRUE THEN 'HAZMAT Certified'
                    ELSE 'Standard Equipment' END as equipment_requirement,
               preferred_carrier_types, restricted_carrier_types
        FROM commodities_master WHERE commodity_status = 'Active';
        """)
    ]
    
    for view_name, view_sql in views:
        try:
            cursor.execute(view_sql)
            print(f"✅ Created view: {view_name}")
        except mysql.connector.Error as err:
            print(f"⚠️ Warning creating view {view_name}: {err}")

def show_table_info(cursor):
    """Display table information"""
    
    print("\n📊 Commodities Master Table Information:")
    print("=" * 50)
    
    cursor.execute("DESCRIBE commodities_master")
    columns = cursor.fetchall()
    print("\n🏗️ Table Structure:")
    for col in columns:
        print(f"  - {col[0]}: {col[1]} {col[2]} {col[3]} {col[4]} {col[5]}")
    
    cursor.execute("SELECT COUNT(*) FROM commodities_master")
    count = cursor.fetchone()[0]
    print(f"\n📈 Total commodities: {count}")
    
    cursor.execute("""
        SELECT commodity_id, commodity_name, commodity_category, value_category, 
               temperature_controlled, hazmat
        FROM commodities_master ORDER BY commodity_category LIMIT 5
    """)
    sample_data = cursor.fetchall()
    
    print("\n🔍 Sample commodities:")
    for row in sample_data:
        temp_control = "🌡️" if row[4] else "❄️"
        hazmat_flag = "⚠️" if row[5] else "✅"
        print(f"  - {row[0]}: {row[1]} | {row[2]} | {row[3]} | {temp_control} {hazmat_flag}")

if __name__ == "__main__":
    create_commodities_master_table() 