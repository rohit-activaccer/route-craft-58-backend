#!/usr/bin/env python3
"""
Fuel Surcharge Master Table Creation Script
Creates the fuel_surcharge_master table for dynamic fuel surcharge calculations
"""

import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv
from datetime import date, datetime

def create_fuel_surcharge_table():
    """Create the fuel_surcharge_master table and related views"""

    # Load environment variables
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
        
        if connection.is_connected():
            cursor = connection.cursor()
            
            print("✅ Successfully connected to MySQL database")
            
            # Create fuel_surcharge_master table
            create_table_query = """
            CREATE TABLE IF NOT EXISTS fuel_surcharge_master (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                effective_date DATE NOT NULL COMMENT 'When the surcharge table comes into effect',
                fuel_price_min DECIMAL(8,2) NOT NULL COMMENT 'Lower bound of diesel price slab (e.g., ₹85)',
                fuel_price_max DECIMAL(8,2) NOT NULL COMMENT 'Upper bound of the slab (e.g., ₹90)',
                fuel_surcharge_percentage DECIMAL(5,2) NOT NULL COMMENT 'Percentage surcharge on base freight',
                base_fuel_price DECIMAL(8,2) NOT NULL COMMENT 'Reference fuel price at which no surcharge is applied',
                change_per_rupee DECIMAL(5,2) NULL COMMENT 'Optional fixed % change per ₹1 increase above base price',
                currency ENUM('INR', 'USD', 'EUR', 'GBP') DEFAULT 'INR' COMMENT 'Currency for the surcharge',
                applicable_region VARCHAR(100) NULL COMMENT 'Optional field if table is region-specific',
                is_active ENUM('Yes', 'No') DEFAULT 'Yes' COMMENT 'Whether this surcharge slab is currently active',
                surcharge_type ENUM('Fixed', 'Variable', 'Hybrid') DEFAULT 'Fixed' COMMENT 'Type of surcharge calculation',
                min_surcharge_amount DECIMAL(10,2) NULL COMMENT 'Minimum surcharge amount in currency',
                max_surcharge_amount DECIMAL(10,2) NULL COMMENT 'Maximum surcharge amount in currency',
                surcharge_calculation_method ENUM('Percentage', 'Fixed Amount', 'Per KM', 'Per MT') DEFAULT 'Percentage',
                notes TEXT NULL COMMENT 'Any remarks (e.g., "Subject to IOC diesel rates")',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                created_by VARCHAR(100) DEFAULT 'System',
                updated_by VARCHAR(100) DEFAULT 'System',
                
                INDEX idx_effective_date (effective_date),
                INDEX idx_fuel_price_range (fuel_price_min, fuel_price_max),
                INDEX idx_base_fuel_price (base_fuel_price),
                INDEX idx_currency (currency),
                INDEX idx_region (applicable_region),
                INDEX idx_active (is_active),
                INDEX idx_surcharge_type (surcharge_type),
                
                UNIQUE KEY unique_price_range (effective_date, fuel_price_min, fuel_price_max, currency, applicable_region)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            COMMENT='Master table for fuel surcharge calculations based on diesel price ranges';
            """
            
            cursor.execute(create_table_query)
            print("✅ Fuel surcharge master table created successfully")
            
            # Create fuel price tracking table
            create_tracking_table_query = """
            CREATE TABLE IF NOT EXISTS fuel_price_tracking (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                tracking_date DATE NOT NULL COMMENT 'Date of fuel price tracking',
                fuel_price DECIMAL(8,2) NOT NULL COMMENT 'Current diesel price on tracking date',
                source VARCHAR(100) NOT NULL COMMENT 'Source of fuel price (IOC, HP, BP, etc.)',
                region VARCHAR(100) NULL COMMENT 'Region for which price is tracked',
                currency ENUM('INR', 'USD', 'EUR', 'GBP') DEFAULT 'INR',
                is_official BOOLEAN DEFAULT FALSE COMMENT 'Whether this is an official published rate',
                notes TEXT NULL COMMENT 'Additional notes about the price',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                
                INDEX idx_tracking_date (tracking_date),
                INDEX idx_fuel_price (fuel_price),
                INDEX idx_source (source),
                INDEX idx_region (region),
                INDEX idx_currency (currency),
                
                UNIQUE KEY unique_tracking (tracking_date, source, region, currency)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            COMMENT='Historical tracking of fuel prices for surcharge calculations';
            """
            
            cursor.execute(create_tracking_table_query)
            print("✅ Fuel price tracking table created successfully")
            
            # Create fuel surcharge calculation history table
            create_history_table_query = """
            CREATE TABLE IF NOT EXISTS fuel_surcharge_calculation_history (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                calculation_date DATE NOT NULL COMMENT 'Date when surcharge was calculated',
                lane_id VARCHAR(100) NULL COMMENT 'Lane identifier if applicable',
                base_freight_amount DECIMAL(12,2) NOT NULL COMMENT 'Base freight amount before surcharge',
                current_fuel_price DECIMAL(8,2) NOT NULL COMMENT 'Fuel price used for calculation',
                applicable_surcharge_percentage DECIMAL(5,2) NOT NULL COMMENT 'Surcharge percentage applied',
                surcharge_amount DECIMAL(12,2) NOT NULL COMMENT 'Calculated surcharge amount',
                total_amount DECIMAL(12,2) NOT NULL COMMENT 'Total amount including surcharge',
                surcharge_slab_id BIGINT NULL COMMENT 'Reference to fuel_surcharge_master',
                calculation_method VARCHAR(100) NULL COMMENT 'Method used for calculation',
                notes TEXT NULL COMMENT 'Calculation notes or exceptions',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                
                INDEX idx_calculation_date (calculation_date),
                INDEX idx_lane_id (lane_id),
                INDEX idx_fuel_price (current_fuel_price),
                INDEX idx_surcharge_slab (surcharge_slab_id),
                
                FOREIGN KEY (surcharge_slab_id) REFERENCES fuel_surcharge_master(id) ON DELETE SET NULL
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            COMMENT='History of fuel surcharge calculations for audit and analysis';
            """
            
            cursor.execute(create_history_table_query)
            print("✅ Fuel surcharge calculation history table created successfully")
            
            # Insert sample fuel surcharge data (India Example)
            sample_data = [
                # Format: (effective_date, price_min, price_max, surcharge_percentage, base_price, change_per_rupee, currency, region, surcharge_type, notes)
                (date(2025, 6, 1), 80.00, 84.99, 0.00, 80.00, 0.50, 'INR', 'All India', 'Fixed', 'No surcharge if ≤ ₹84.99'),
                (date(2025, 6, 1), 85.00, 89.99, 2.00, 80.00, None, 'INR', 'All India', 'Fixed', 'Standard surcharge for moderate price increase'),
                (date(2025, 6, 1), 90.00, 94.99, 4.00, 80.00, None, 'INR', 'All India', 'Fixed', 'Increased surcharge for higher fuel costs'),
                (date(2025, 6, 1), 95.00, 99.99, 6.00, 80.00, None, 'INR', 'All India', 'Fixed', 'Most lanes see this slab - significant fuel cost impact'),
                (date(2025, 6, 1), 100.00, 104.99, 8.00, 80.00, None, 'INR', 'All India', 'Fixed', 'High surcharge for expensive fuel'),
                (date(2025, 6, 1), 105.00, 110.00, 10.00, 80.00, None, 'INR', 'All India', 'Fixed', 'Maximum surcharge cap - extreme fuel prices'),
                
                # Regional variations
                (date(2025, 6, 1), 80.00, 84.99, 0.00, 80.00, 0.60, 'INR', 'Metro Cities', 'Variable', 'Higher sensitivity in metro areas'),
                (date(2025, 6, 1), 85.00, 89.99, 2.50, 80.00, None, 'INR', 'Metro Cities', 'Fixed', 'Metro-specific surcharge rates'),
                (date(2025, 6, 1), 90.00, 94.99, 4.50, 80.00, None, 'INR', 'Metro Cities', 'Fixed', 'Metro-specific surcharge rates'),
                (date(2025, 6, 1), 95.00, 99.99, 6.50, 80.00, None, 'INR', 'Metro Cities', 'Fixed', 'Metro-specific surcharge rates'),
                (date(2025, 6, 1), 100.00, 104.99, 8.50, 80.00, None, 'INR', 'Metro Cities', 'Fixed', 'Metro-specific surcharge rates'),
                (date(2025, 6, 1), 105.00, 110.00, 10.50, 80.00, None, 'INR', 'Metro Cities', 'Fixed', 'Metro-specific surcharge rates'),
                
                # Future effective dates for testing
                (date(2025, 7, 1), 80.00, 84.99, 0.00, 80.00, 0.55, 'INR', 'All India', 'Fixed', 'Updated rates effective July 2025'),
                (date(2025, 7, 1), 85.00, 89.99, 2.25, 80.00, None, 'INR', 'All India', 'Fixed', 'Updated rates effective July 2025'),
                (date(2025, 7, 1), 90.00, 94.99, 4.25, 80.00, None, 'INR', 'All India', 'Fixed', 'Updated rates effective July 2025'),
                (date(2025, 7, 1), 95.00, 99.99, 6.25, 80.00, None, 'INR', 'All India', 'Fixed', 'Updated rates effective July 2025'),
                (date(2025, 7, 1), 100.00, 104.99, 8.25, 80.00, None, 'INR', 'All India', 'Fixed', 'Updated rates effective July 2025'),
                (date(2025, 7, 1), 105.00, 110.00, 10.25, 80.00, None, 'INR', 'All India', 'Fixed', 'Updated rates effective July 2025'),
            ]
            
            insert_query = """
            INSERT INTO fuel_surcharge_master (
                effective_date, fuel_price_min, fuel_price_max, fuel_surcharge_percentage,
                base_fuel_price, change_per_rupee, currency, applicable_region,
                surcharge_type, notes, is_active
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            
            for data in sample_data:
                cursor.execute(insert_query, data + ('Yes',))
            
            print(f"✅ Inserted {len(sample_data)} fuel surcharge records")
            
            # Insert sample fuel price tracking data
            fuel_tracking_data = [
                (date(2025, 6, 1), 96.50, 'IOC', 'All India', 'INR', True, 'Official IOC diesel rate'),
                (date(2025, 6, 2), 96.75, 'IOC', 'All India', 'INR', True, 'Official IOC diesel rate'),
                (date(2025, 6, 3), 97.00, 'IOC', 'All India', 'INR', True, 'Official IOC diesel rate'),
                (date(2025, 6, 4), 97.25, 'IOC', 'All India', 'INR', True, 'Official IOC diesel rate'),
                (date(2025, 6, 5), 97.50, 'IOC', 'All India', 'INR', True, 'Official IOC diesel rate'),
                (date(2025, 6, 6), 97.75, 'IOC', 'All India', 'INR', True, 'Official IOC diesel rate'),
                (date(2025, 6, 7), 98.00, 'IOC', 'All India', 'INR', True, 'Official IOC diesel rate'),
                (date(2025, 6, 8), 98.25, 'IOC', 'All India', 'INR', True, 'Official IOC diesel rate'),
                (date(2025, 6, 9), 98.50, 'IOC', 'All India', 'INR', True, 'Official IOC diesel rate'),
                (date(2025, 6, 10), 98.75, 'IOC', 'All India', 'INR', True, 'Official IOC diesel rate'),
            ]
            
            tracking_insert_query = """
            INSERT INTO fuel_price_tracking (
                tracking_date, fuel_price, source, region, currency, is_official, notes
            ) VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            
            for data in fuel_tracking_data:
                cursor.execute(tracking_insert_query, data)
            
            print(f"✅ Inserted {len(fuel_tracking_data)} fuel price tracking records")
            
            # Create useful views
            views = [
                # Active fuel surcharge slabs
                """
                CREATE OR REPLACE VIEW active_fuel_surcharges AS
                SELECT 
                    effective_date,
                    fuel_price_min,
                    fuel_price_max,
                    fuel_surcharge_percentage,
                    base_fuel_price,
                    change_per_rupee,
                    currency,
                    applicable_region,
                    surcharge_type,
                    notes
                FROM fuel_surcharge_master 
                WHERE is_active = 'Yes'
                ORDER BY effective_date DESC, fuel_price_min ASC
                """,
                
                # Current fuel surcharge calculation helper
                """
                CREATE OR REPLACE VIEW current_fuel_surcharge_calculator AS
                SELECT 
                    fs.effective_date,
                    fs.fuel_price_min,
                    fs.fuel_price_max,
                    fs.fuel_surcharge_percentage,
                    fs.base_fuel_price,
                    fs.change_per_rupee,
                    fs.currency,
                    fs.applicable_region,
                    fs.surcharge_type,
                    fs.notes,
                    CASE 
                        WHEN fs.change_per_rupee IS NOT NULL THEN 
                            CONCAT('Variable: ', fs.change_per_rupee, '% per ₹1 above ₹', fs.base_fuel_price)
                        ELSE 
                            CONCAT('Fixed: ', fs.fuel_surcharge_percentage, '% for ₹', fs.fuel_price_min, ' - ₹', fs.fuel_price_max)
                    END as calculation_method
                FROM fuel_surcharge_master fs
                WHERE fs.is_active = 'Yes'
                ORDER BY fs.effective_date DESC, fs.fuel_price_min ASC
                """,
                
                # Fuel price trend analysis
                """
                CREATE OR REPLACE VIEW fuel_price_trend_analysis AS
                SELECT 
                    tracking_date,
                    fuel_price,
                    source,
                    region,
                    currency,
                    LAG(fuel_price) OVER (ORDER BY tracking_date) as previous_price,
                    fuel_price - LAG(fuel_price) OVER (ORDER BY tracking_date) as price_change,
                    ROUND(((fuel_price - LAG(fuel_price) OVER (ORDER BY tracking_date)) / LAG(fuel_price) OVER (ORDER BY tracking_date)) * 100, 2) as price_change_percentage
                FROM fuel_price_tracking
                WHERE is_official = TRUE
                ORDER BY tracking_date DESC
                """,
                
                # Surcharge impact analysis
                """
                CREATE OR REPLACE VIEW surcharge_impact_analysis AS
                SELECT 
                    fs.applicable_region,
                    fs.currency,
                    COUNT(*) as total_slabs,
                    MIN(fs.fuel_surcharge_percentage) as min_surcharge,
                    MAX(fs.fuel_surcharge_percentage) as max_surcharge,
                    AVG(fs.fuel_surcharge_percentage) as avg_surcharge,
                    SUM(CASE WHEN fs.fuel_surcharge_percentage = 0 THEN 1 ELSE 0 END) as no_surcharge_slabs,
                    SUM(CASE WHEN fs.fuel_surcharge_percentage > 0 THEN 1 ELSE 0 END) as surcharge_slabs
                FROM fuel_surcharge_master fs
                WHERE fs.is_active = 'Yes'
                GROUP BY fs.applicable_region, fs.currency
                ORDER BY fs.applicable_region, fs.currency
                """,
                
                # Latest fuel prices by region
                """
                CREATE OR REPLACE VIEW latest_fuel_prices AS
                SELECT 
                    region,
                    currency,
                    fuel_price,
                    source,
                    tracking_date,
                    is_official
                FROM fuel_price_tracking fpt1
                WHERE tracking_date = (
                    SELECT MAX(tracking_date) 
                    FROM fuel_price_tracking fpt2 
                    WHERE fpt2.region = fpt1.region 
                    AND fpt2.currency = fpt1.currency
                )
                ORDER BY region, currency
                """
            ]
            
            for i, view_query in enumerate(views, 1):
                try:
                    cursor.execute(view_query)
                    print(f"✅ Created view {i}/5")
                except Error as e:
                    print(f"⚠️  View {i} creation warning: {e}")
            
            # Create stored procedure for fuel surcharge calculation
            procedure_query = """
            DELIMITER //
            CREATE PROCEDURE CalculateFuelSurcharge(
                IN p_fuel_price DECIMAL(8,2),
                IN p_base_freight DECIMAL(12,2),
                IN p_region VARCHAR(100),
                IN p_currency ENUM('INR', 'USD', 'EUR', 'GBP'),
                IN p_calculation_date DATE,
                OUT p_surcharge_percentage DECIMAL(5,2),
                OUT p_surcharge_amount DECIMAL(12,2),
                OUT p_total_amount DECIMAL(12,2)
            )
            BEGIN
                DECLARE v_surcharge_percentage DECIMAL(5,2) DEFAULT 0;
                DECLARE v_base_fuel_price DECIMAL(8,2);
                DECLARE v_change_per_rupee DECIMAL(5,2);
                
                -- Find applicable surcharge slab
                SELECT 
                    fuel_surcharge_percentage,
                    base_fuel_price,
                    change_per_rupee
                INTO 
                    v_surcharge_percentage,
                    v_base_fuel_price,
                    v_change_per_rupee
                FROM fuel_surcharge_master 
                WHERE p_fuel_price BETWEEN fuel_price_min AND fuel_price_max
                AND applicable_region = COALESCE(p_region, 'All India')
                AND currency = p_currency
                AND is_active = 'Yes'
                AND effective_date <= p_calculation_date
                ORDER BY effective_date DESC
                LIMIT 1;
                
                -- If no fixed slab found, calculate variable surcharge
                IF v_surcharge_percentage IS NULL AND v_change_per_rupee IS NOT NULL THEN
                    SET v_surcharge_percentage = (p_fuel_price - v_base_fuel_price) * v_change_per_rupee;
                END IF;
                
                -- Set output parameters
                SET p_surcharge_percentage = COALESCE(v_surcharge_percentage, 0);
                SET p_surcharge_amount = (p_base_freight * p_surcharge_percentage) / 100;
                SET p_total_amount = p_base_freight + p_surcharge_amount;
                
                -- Log calculation in history
                INSERT INTO fuel_surcharge_calculation_history (
                    calculation_date, base_freight_amount, current_fuel_price,
                    applicable_surcharge_percentage, surcharge_amount, total_amount,
                    calculation_method, notes
                ) VALUES (
                    p_calculation_date, p_base_freight, p_fuel_price,
                    p_surcharge_percentage, p_surcharge_amount, p_total_amount,
                    'Stored Procedure', CONCAT('Region: ', COALESCE(p_region, 'All India'), ', Currency: ', p_currency)
                );
                
            END //
            DELIMITER ;
            """
            
            try:
                cursor.execute(procedure_query)
                print("✅ Created fuel surcharge calculation stored procedure")
            except Error as e:
                print(f"⚠️  Stored procedure creation warning: {e}")
            
            # Commit all changes
            connection.commit()
            print("✅ All changes committed successfully")
            
            # Display table summary
            cursor.execute("SELECT COUNT(*) FROM fuel_surcharge_master WHERE is_active = 'Yes'")
            active_count = cursor.fetchone()[0]
            
            cursor.execute("SELECT COUNT(*) FROM fuel_price_tracking")
            tracking_count = cursor.fetchone()[0]
            
            print(f"\n📊 Table Summary:")
            print(f"   • Active fuel surcharge slabs: {active_count}")
            print(f"   • Fuel price tracking records: {tracking_count}")
            print(f"   • Views created: 5")
            print(f"   • Stored procedure: 1")
            
            cursor.close()
            connection.close()
            print("\n✅ Database connection closed successfully")
            
    except Error as e:
        print(f"❌ Error: {e}")
        if connection.is_connected():
            connection.rollback()
            connection.close()

if __name__ == "__main__":
    create_fuel_surcharge_table() 