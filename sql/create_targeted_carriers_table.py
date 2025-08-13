#!/usr/bin/env python3
"""
Create Targeted Carriers Table

This script creates the "targeted_carriers" table in MySQL for storing information about
external 3rd-party carriers sourced from platforms like TruckStop, LoadBoard, DAT, or FreightTiger.
The table supports dynamic sourcing during strategic sourcing, spot bid events, lane expansion, and backhaul optimization.
"""

import mysql.connector
from dotenv import load_dotenv
import os
from datetime import datetime, timedelta
import random

def create_targeted_carriers_table():
    """Create the targeted_carriers table and populate with sample data"""
    
    # Load environment variables
    load_dotenv()
    
    # Database configuration
    config = {
        'host': os.getenv('MYSQL_HOST', 'localhost'),
        'user': os.getenv('MYSQL_USER', 'routecraft_user'),
        'password': os.getenv('MYSQL_PASSWORD', 'routecraft_password'),
        'database': os.getenv('MYSQL_DATABASE', 'routecraft'),
        'port': int(os.getenv('MYSQL_PORT', 3306))
    }
    
    try:
        # Connect to database
        connection = mysql.connector.connect(**config)
        cursor = connection.cursor()
        
        print("🔌 Connected to MySQL database successfully!")
        
        # Create targeted_carriers table
        create_table_sql = """
        CREATE TABLE IF NOT EXISTS targeted_carriers (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            carrier_id_3p VARCHAR(50) NOT NULL COMMENT 'Unique ID from TruckStop/DAT/etc',
            carrier_name VARCHAR(255) NOT NULL COMMENT 'Legal entity or display name',
            dot_mc_number VARCHAR(50) COMMENT 'US-based registration number (or Indian equivalent like RC/GSTIN)',
            region_of_operation ENUM('North India', 'South India', 'East India', 'West India', 'Central India', 'PAN India', 'East Coast', 'West Coast', 'Central US', 'Northeast US', 'Southeast US', 'Northwest US', 'Southwest US') NOT NULL,
            origin_preference JSON COMMENT 'Preferred origin regions as JSON array',
            destination_preference JSON COMMENT 'Preferred delivery zones as JSON array',
            fleet_size INT COMMENT 'Total number of trucks they own/operate',
            equipment_types JSON COMMENT 'Equipment types as JSON array (e.g., Reefer, Flatbed, 32ft, Container)',
            mode ENUM('TL', 'LTL', 'Multimodal') NOT NULL DEFAULT 'TL',
            compliance_validated BOOLEAN DEFAULT FALSE COMMENT 'Has the 3rd-party verified documents (RC, insurance)',
            performance_score_external DECIMAL(3,1) COMMENT 'Score from 3rd-party platform (1-5 or A-D converted to numeric)',
            preferred_commodity_types JSON COMMENT 'Preferred commodity types as JSON array (e.g., pharma, FMCG)',
            technology_enabled BOOLEAN DEFAULT FALSE COMMENT 'GPS, ePOD, integrations supported',
            rating_threshold_met BOOLEAN DEFAULT FALSE COMMENT 'Filter result from system rule (e.g., only >80% rating carriers)',
            last_active DATE COMMENT 'Date of last seen load or activity',
            invited_to_bid BOOLEAN DEFAULT FALSE COMMENT 'Whether included in current RFP invite',
            remarks TEXT COMMENT 'Additional metadata, e.g., blacklist, preferred, rejected',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            
            -- Indexes for performance
            INDEX idx_carrier_id_3p (carrier_id_3p),
            INDEX idx_region (region_of_operation),
            INDEX idx_compliance (compliance_validated),
            INDEX idx_performance (performance_score_external),
            INDEX idx_rating_threshold (rating_threshold_met),
            INDEX idx_last_active (last_active),
            INDEX idx_invited (invited_to_bid),
            
            -- Unique constraint on external carrier ID
            UNIQUE KEY uk_carrier_id_3p (carrier_id_3p)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        COMMENT='External 3rd-party carriers for dynamic sourcing during procurement events';
        """
        
        cursor.execute(create_table_sql)
        print("✅ Targeted Carriers table created successfully!")
        
        # Insert sample data
        insert_sample_data(cursor)
        
        # Create analytical views
        create_views(cursor)
        
        # Show table information
        show_table_info(cursor)
        
        # Commit changes
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
    """Insert sample data into targeted_carriers table"""
    
    # Sample data for targeted carriers
    sample_carriers = [
        # North India carriers
        {
            'carrier_id_3p': 'TS001',
            'carrier_name': 'Delhi Express Logistics',
            'dot_mc_number': 'DL01AB1234',
            'region_of_operation': 'North India',
            'origin_preference': '["Delhi NCR", "Haryana", "Punjab", "Uttar Pradesh"]',
            'destination_preference': '["Mumbai", "Bangalore", "Chennai", "Kolkata"]',
            'fleet_size': 45,
            'equipment_types': '["32ft SXL", "Reefer", "Flatbed"]',
            'mode': 'TL',
            'compliance_validated': True,
            'performance_score_external': 4.2,
            'preferred_commodity_types': '["FMCG", "Electronics", "Textiles"]',
            'technology_enabled': True,
            'rating_threshold_met': True,
            'last_active': datetime.now().date() - timedelta(days=2),
            'invited_to_bid': True,
            'remarks': 'Preferred carrier for Delhi-Mumbai route'
        },
        {
            'carrier_id_3p': 'TS002',
            'carrier_name': 'Punjab Roadways Ltd',
            'dot_mc_number': 'PB02CD5678',
            'region_of_operation': 'North India',
            'origin_preference': '["Punjab", "Himachal Pradesh", "Jammu & Kashmir"]',
            'destination_preference': '["Delhi NCR", "Gujarat", "Maharashtra"]',
            'fleet_size': 32,
            'equipment_types': '["20ft Container", "32ft SXL", "Reefer"]',
            'mode': 'TL',
            'compliance_validated': True,
            'performance_score_external': 3.8,
            'preferred_commodity_types': '["Agriculture", "FMCG", "Pharma"]',
            'technology_enabled': False,
            'rating_threshold_met': True,
            'last_active': datetime.now().date() - timedelta(days=5),
            'invited_to_bid': False,
            'remarks': 'Good for agricultural commodities'
        },
        
        # South India carriers
        {
            'carrier_id_3p': 'TS003',
            'carrier_name': 'Chennai Cargo Solutions',
            'dot_mc_number': 'TN03EF9012',
            'region_of_operation': 'South India',
            'origin_preference': '["Tamil Nadu", "Karnataka", "Kerala"]',
            'destination_preference': '["Mumbai", "Delhi NCR", "Gujarat"]',
            'fleet_size': 28,
            'equipment_types': '["Reefer", "32ft SXL", "Flatbed"]',
            'mode': 'TL',
            'compliance_validated': True,
            'performance_score_external': 4.5,
            'preferred_commodity_types': '["Pharma", "FMCG", "Electronics"]',
            'technology_enabled': True,
            'rating_threshold_met': True,
            'last_active': datetime.now().date() - timedelta(days=1),
            'invited_to_bid': True,
            'remarks': 'Premium pharma carrier'
        },
        
        # West India carriers
        {
            'carrier_id_3p': 'TS004',
            'carrier_name': 'Mumbai Freight Services',
            'dot_mc_number': 'MH04GH3456',
            'region_of_operation': 'West India',
            'origin_preference': '["Maharashtra", "Gujarat", "Madhya Pradesh"]',
            'destination_preference': '["Delhi NCR", "Karnataka", "Tamil Nadu"]',
            'fleet_size': 67,
            'equipment_types': '["32ft SXL", "20ft Container", "Reefer", "Flatbed"]',
            'mode': 'Multimodal',
            'compliance_validated': True,
            'performance_score_external': 4.8,
            'preferred_commodity_types': '["FMCG", "Electronics", "Textiles", "Pharma"]',
            'technology_enabled': True,
            'rating_threshold_met': True,
            'last_active': datetime.now().date(),
            'invited_to_bid': True,
            'remarks': 'Top performer, preferred for all routes'
        },
        
        # East India carriers
        {
            'carrier_id_3p': 'TS005',
            'carrier_name': 'Kolkata Transport Co',
            'dot_mc_number': 'WB05IJ7890',
            'region_of_operation': 'East India',
            'origin_preference': '["West Bengal", "Bihar", "Odisha"]',
            'destination_preference': '["Delhi NCR", "Mumbai", "Bangalore"]',
            'fleet_size': 23,
            'equipment_types': '["32ft SXL", "Reefer"]',
            'mode': 'TL',
            'compliance_validated': False,
            'performance_score_external': 3.2,
            'preferred_commodity_types': '["Textiles", "Agriculture"]',
            'technology_enabled': False,
            'rating_threshold_met': False,
            'last_active': datetime.now().date() - timedelta(days=8),
            'invited_to_bid': False,
            'remarks': 'Compliance issues, needs verification'
        },
        
        # Central India carriers
        {
            'carrier_id_3p': 'TS006',
            'carrier_name': 'Bhopal Logistics',
            'dot_mc_number': 'MP06KL1234',
            'region_of_operation': 'Central India',
            'origin_preference': '["Madhya Pradesh", "Chhattisgarh", "Rajasthan"]',
            'destination_preference': '["Mumbai", "Delhi NCR", "Gujarat"]',
            'fleet_size': 18,
            'equipment_types': '["32ft SXL", "Flatbed"]',
            'mode': 'TL',
            'compliance_validated': True,
            'performance_score_external': 3.9,
            'preferred_commodity_types': '["Agriculture", "Mining", "FMCG"]',
            'technology_enabled': False,
            'rating_threshold_met': True,
            'last_active': datetime.now().date() - timedelta(days=3),
            'invited_to_bid': True,
            'remarks': 'Reliable for central India routes'
        },
        
        # US East Coast carriers
        {
            'carrier_id_3p': 'DAT001',
            'carrier_name': 'Atlantic Freight Solutions',
            'dot_mc_number': 'MC123456',
            'region_of_operation': 'East Coast',
            'origin_preference': '["New York", "New Jersey", "Pennsylvania", "Maryland"]',
            'destination_preference': '["Florida", "Georgia", "South Carolina", "North Carolina"]',
            'fleet_size': 89,
            'equipment_types': '["53ft Dry Van", "Reefer", "Flatbed", "Power Only"]',
            'mode': 'TL',
            'compliance_validated': True,
            'performance_score_external': 4.6,
            'preferred_commodity_types': '["Electronics", "FMCG", "Pharma", "Automotive"]',
            'technology_enabled': True,
            'rating_threshold_met': True,
            'last_active': datetime.now().date() - timedelta(days=1),
            'invited_to_bid': True,
            'remarks': 'Premium US East Coast carrier'
        },
        
        # US West Coast carriers
        {
            'carrier_id_3p': 'DAT002',
            'carrier_name': 'Pacific Coast Transport',
            'dot_mc_number': 'MC789012',
            'region_of_operation': 'West Coast',
            'origin_preference': '["California", "Oregon", "Washington"]',
            'destination_preference': '["Nevada", "Arizona", "Utah", "Colorado"]',
            'fleet_size': 156,
            'equipment_types': '["53ft Dry Van", "Reefer", "Flatbed", "Step Deck", "Power Only"]',
            'mode': 'Multimodal',
            'compliance_validated': True,
            'performance_score_external': 4.9,
            'preferred_commodity_types': '["Technology", "Agriculture", "FMCG", "Automotive"]',
            'technology_enabled': True,
            'rating_threshold_met': True,
            'last_active': datetime.now().date(),
            'invited_to_bid': True,
            'remarks': 'Top US West Coast performer'
        }
    ]
    
    # Insert sample data
    insert_sql = """
    INSERT INTO targeted_carriers (
        carrier_id_3p, carrier_name, dot_mc_number, region_of_operation,
        origin_preference, destination_preference, fleet_size, equipment_types,
        mode, compliance_validated, performance_score_external, preferred_commodity_types,
        technology_enabled, rating_threshold_met, last_active, invited_to_bid, remarks
    ) VALUES (
        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
    )
    """
    
    for carrier in sample_carriers:
        cursor.execute(insert_sql, (
            carrier['carrier_id_3p'],
            carrier['carrier_name'],
            carrier['dot_mc_number'],
            carrier['region_of_operation'],
            carrier['origin_preference'],
            carrier['destination_preference'],
            carrier['fleet_size'],
            carrier['equipment_types'],
            carrier['mode'],
            carrier['compliance_validated'],
            carrier['performance_score_external'],
            carrier['preferred_commodity_types'],
            carrier['technology_enabled'],
            carrier['rating_threshold_met'],
            carrier['last_active'],
            carrier['invited_to_bid'],
            carrier['remarks']
        ))
    
    print(f"✅ Inserted {len(sample_carriers)} sample targeted carriers")

def create_views(cursor):
    """Create analytical views for targeted carriers"""
    
    # View 1: Eligible carriers for bidding
    view1_sql = """
    CREATE OR REPLACE VIEW eligible_carriers_for_bidding AS
    SELECT 
        carrier_id_3p,
        carrier_name,
        region_of_operation,
        fleet_size,
        equipment_types,
        performance_score_external,
        compliance_validated,
        rating_threshold_met,
        last_active,
        invited_to_bid
    FROM targeted_carriers
    WHERE compliance_validated = TRUE 
        AND rating_threshold_met = TRUE
        AND last_active >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    ORDER BY performance_score_external DESC, fleet_size DESC;
    """
    
    # View 2: Regional carrier distribution
    view2_sql = """
    CREATE OR REPLACE VIEW regional_carrier_distribution AS
    SELECT 
        region_of_operation,
        COUNT(*) as total_carriers,
        COUNT(CASE WHEN compliance_validated = TRUE THEN 1 END) as compliant_carriers,
        COUNT(CASE WHEN rating_threshold_met = TRUE THEN 1 END) as eligible_carriers,
        COUNT(CASE WHEN invited_to_bid = TRUE THEN 1 END) as invited_carriers,
        AVG(performance_score_external) as avg_performance_score,
        SUM(fleet_size) as total_fleet_capacity
    FROM targeted_carriers
    GROUP BY region_of_operation
    ORDER BY total_carriers DESC;
    """
    
    # View 3: Equipment type analysis
    view3_sql = """
    CREATE OR REPLACE VIEW equipment_type_analysis AS
    SELECT 
        JSON_UNQUOTE(JSON_EXTRACT(equipment_types, '$[0]')) as primary_equipment,
        COUNT(*) as carrier_count,
        AVG(performance_score_external) as avg_performance,
        COUNT(CASE WHEN compliance_validated = TRUE THEN 1 END) as compliant_count,
        SUM(fleet_size) as total_capacity
    FROM targeted_carriers
    WHERE equipment_types IS NOT NULL
    GROUP BY JSON_UNQUOTE(JSON_EXTRACT(equipment_types, '$[0]'))
    ORDER BY carrier_count DESC;
    """
    
    # View 4: Performance tier analysis
    view4_sql = """
    CREATE OR REPLACE VIEW performance_tier_analysis AS
    SELECT 
        CASE 
            WHEN performance_score_external >= 4.5 THEN 'Premium (4.5+)'
            WHEN performance_score_external >= 4.0 THEN 'High (4.0-4.4)'
            WHEN performance_score_external >= 3.5 THEN 'Good (3.5-3.9)'
            WHEN performance_score_external >= 3.0 THEN 'Average (3.0-3.4)'
            ELSE 'Below Average (<3.0)'
        END as performance_tier,
        COUNT(*) as carrier_count,
        AVG(fleet_size) as avg_fleet_size,
        COUNT(CASE WHEN compliance_validated = TRUE THEN 1 END) as compliant_count,
        COUNT(CASE WHEN invited_to_bid = TRUE THEN 1 END) as invited_count
    FROM targeted_carriers
    WHERE performance_score_external IS NOT NULL
    GROUP BY performance_tier
    ORDER BY 
        CASE performance_tier
            WHEN 'Premium (4.5+)' THEN 1
            WHEN 'High (4.0-4.4)' THEN 2
            WHEN 'Good (3.5-3.9)' THEN 3
            WHEN 'Average (3.0-3.4)' THEN 4
            ELSE 5
        END;
    """
    
    # View 5: Sourcing recommendations
    view5_sql = """
    CREATE OR REPLACE VIEW sourcing_recommendations AS
    SELECT 
        carrier_id_3p,
        carrier_name,
        region_of_operation,
        equipment_types,
        performance_score_external,
        fleet_size,
        CASE 
            WHEN performance_score_external >= 4.5 AND compliance_validated = TRUE AND fleet_size >= 50 THEN 'Priority 1 - Premium'
            WHEN performance_score_external >= 4.0 AND compliance_validated = TRUE AND fleet_size >= 30 THEN 'Priority 2 - High'
            WHEN performance_score_external >= 3.5 AND compliance_validated = TRUE AND fleet_size >= 20 THEN 'Priority 3 - Good'
            WHEN compliance_validated = TRUE AND fleet_size >= 15 THEN 'Priority 4 - Standard'
            ELSE 'Priority 5 - Review Required'
        END as sourcing_priority,
        CASE 
            WHEN invited_to_bid = TRUE THEN 'Already Invited'
            WHEN last_active >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) THEN 'Recently Active'
            WHEN last_active >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) THEN 'Active'
            ELSE 'Inactive'
        END as activity_status
    FROM targeted_carriers
    ORDER BY 
        CASE sourcing_priority
            WHEN 'Priority 1 - Premium' THEN 1
            WHEN 'Priority 2 - High' THEN 2
            WHEN 'Priority 3 - Good' THEN 3
            WHEN 'Priority 4 - Standard' THEN 4
            ELSE 5
        END,
        performance_score_external DESC;
    """
    
    # Execute view creation
    views = [
        ("eligible_carriers_for_bidding", view1_sql),
        ("regional_carrier_distribution", view2_sql),
        ("equipment_type_analysis", view3_sql),
        ("performance_tier_analysis", view4_sql),
        ("sourcing_recommendations", view5_sql)
    ]
    
    for view_name, view_sql in views:
        try:
            cursor.execute(view_sql)
            print(f"✅ Created view: {view_name}")
        except mysql.connector.Error as err:
            print(f"⚠️ Warning creating view {view_name}: {err}")

def show_table_info(cursor):
    """Display table structure and sample data"""
    
    print("\n📊 Targeted Carriers Table Information:")
    print("=" * 50)
    
    # Show table structure
    cursor.execute("DESCRIBE targeted_carriers")
    columns = cursor.fetchall()
    print("\n🏗️ Table Structure:")
    for col in columns:
        print(f"  - {col[0]}: {col[1]} {col[2]} {col[3]} {col[4]} {col[5]}")
    
    # Show record count
    cursor.execute("SELECT COUNT(*) FROM targeted_carriers")
    count = cursor.fetchone()[0]
    print(f"\n📈 Total targeted carriers: {count}")
    
    # Show sample data
    cursor.execute("""
        SELECT carrier_id_3p, carrier_name, region_of_operation, 
               performance_score_external, fleet_size, invited_to_bid
        FROM targeted_carriers 
        ORDER BY performance_score_external DESC 
        LIMIT 10
    """)
    sample_data = cursor.fetchall()
    
    print("\n🔍 Sample targeted carriers:")
    for row in sample_data:
        print(f"  - {row[0]}: {row[1]} | {row[2]} | Score: {row[3]} | Fleet: {row[4]} | Invited: {row[5]}")
    
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
    create_targeted_carriers_table() 