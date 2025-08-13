#!/usr/bin/env python3
"""
Seasons Master Table Creation Script
This script creates the seasons_master table and populates it with sample data for Indian logistics seasons.
"""

import mysql.connector
import os
from mysql.connector import Error

def create_database_connection():
    """Create and return a database connection."""
    try:
        connection = mysql.connector.connect(
            host=os.getenv('MYSQL_HOST', 'localhost'),
            user=os.getenv('MYSQL_USER', 'routecraft_user'),
            password=os.getenv('MYSQL_PASSWORD', 'routecraft_password'),
            database=os.getenv('MYSQL_DATABASE', 'routecraft'),
            charset='utf8mb4'
        )
        if connection.is_connected():
            print("✅ Successfully connected to MySQL database")
            return connection
    except Error as e:
        print(f"❌ Error connecting to MySQL: {e}")
        return None

def execute_sql_file(connection, sql_file_path):
    """Execute SQL commands from a file."""
    try:
        cursor = connection.cursor()
        
        # Read the SQL file
        with open(sql_file_path, 'r', encoding='utf-8') as file:
            sql_content = file.read()
        
        # Split by semicolon and execute each statement
        statements = sql_content.split(';')
        
        for statement in statements:
            statement = statement.strip()
            if statement and not statement.startswith('--'):
                try:
                    cursor.execute(statement)
                    print(f"✅ Executed: {statement[:50]}...")
                except Error as e:
                    print(f"⚠️  Warning executing statement: {e}")
                    print(f"Statement: {statement[:100]}...")
        
        connection.commit()
        print("✅ SQL file execution completed")
        return True
        
    except Error as e:
        print(f"❌ Error executing SQL file: {e}")
        return False
    finally:
        if cursor:
            cursor.close()

def verify_table_creation(connection):
    """Verify that the table was created successfully."""
    try:
        cursor = connection.cursor()
        
        # Check if table exists
        cursor.execute("SHOW TABLES LIKE 'seasons_master'")
        table_exists = cursor.fetchone()
        
        if table_exists:
            print("✅ seasons_master table found")
            
            # Get table structure
            cursor.execute("DESCRIBE seasons_master")
            columns = cursor.fetchall()
            print(f"✅ Table has {len(columns)} columns")
            
            # Get row count
            cursor.execute("SELECT COUNT(*) FROM seasons_master")
            row_count = cursor.fetchone()[0]
            print(f"✅ Table contains {row_count} rows")
            
            return True
        else:
            print("❌ seasons_master table not found")
            return False
            
    except Error as e:
        print(f"❌ Error verifying table: {e}")
        return False
    finally:
        if cursor:
            cursor.close()

def verify_views_creation(connection):
    """Verify that the views were created successfully."""
    try:
        cursor = connection.cursor()
        
        views_to_check = [
            'active_seasons_overview',
            'high_impact_seasons',
            'seasonal_cost_analysis',
            'regional_season_impact',
            'equipment_specific_seasons'
        ]
        
        created_views = []
        for view in views_to_check:
            cursor.execute(f"SHOW TABLES LIKE '{view}'")
            if cursor.fetchone():
                created_views.append(view)
                print(f"✅ View '{view}' created successfully")
            else:
                print(f"❌ View '{view}' not found")
        
        print(f"✅ {len(created_views)} out of {len(views_to_check)} views created")
        return len(created_views) == len(views_to_check)
        
    except Error as e:
        print(f"❌ Error verifying views: {e}")
        return False
    finally:
        if cursor:
            cursor.close()

def display_sample_data(connection):
    """Display sample data from the table."""
    try:
        cursor = connection.cursor()
        
        print("\n📊 Sample Seasons Data:")
        print("-" * 100)
        
        cursor.execute("""
            SELECT 
                season_id, 
                season_name, 
                start_date, 
                end_date,
                impact_type,
                capacity_risk_level,
                rate_multiplier_percent,
                sla_adjustment_days
            FROM seasons_master 
            ORDER BY start_date
            LIMIT 10
        """)
        
        rows = cursor.fetchall()
        for row in rows:
            print(f"ID: {row[0]:<20} | Name: {row[1]:<25} | Period: {row[2]} to {row[3]} | Impact: {row[4]:<15} | Risk: {row[5]:<8} | Rate: {row[6]:<6}% | SLA: +{row[7]} days")
        
        print("-" * 100)
        
    except Error as e:
        print(f"❌ Error displaying sample data: {e}")
    finally:
        if cursor:
            cursor.close()

def test_views(connection):
    """Test the created views to ensure they work correctly."""
    try:
        cursor = connection.cursor()
        
        print("\n🔍 Testing Views:")
        print("-" * 50)
        
        # Test active seasons overview
        cursor.execute("SELECT COUNT(*) FROM active_seasons_overview")
        active_count = cursor.fetchone()[0]
        print(f"✅ active_seasons_overview: {active_count} active seasons")
        
        # Test high impact seasons
        cursor.execute("SELECT COUNT(*) FROM high_impact_seasons")
        high_impact_count = cursor.fetchone()[0]
        print(f"✅ high_impact_seasons: {high_impact_count} high impact seasons")
        
        # Test seasonal cost analysis
        cursor.execute("SELECT COUNT(*) FROM seasonal_cost_analysis")
        cost_analysis_count = cursor.fetchone()[0]
        print(f"✅ seasonal_cost_analysis: {cost_analysis_count} seasons with cost impact")
        
        # Test regional impact
        cursor.execute("SELECT COUNT(*) FROM regional_season_impact")
        regional_count = cursor.fetchone()[0]
        print(f"✅ regional_season_impact: {regional_count} affected regions")
        
        # Test equipment specific seasons
        cursor.execute("SELECT COUNT(*) FROM equipment_specific_seasons")
        equipment_count = cursor.fetchone()[0]
        print(f"✅ equipment_specific_seasons: {equipment_count} equipment-specific seasons")
        
        print("-" * 50)
        
    except Error as e:
        print(f"❌ Error testing views: {e}")
    finally:
        if cursor:
            cursor.close()

def main():
    """Main function to create the seasons master table."""
    print("🌦️  Creating Seasons Master Table")
    print("=" * 50)
    
    # Create database connection
    connection = create_database_connection()
    if not connection:
        return
    
    try:
        # Execute SQL schema file
        sql_file = "seasons_master_schema.sql"
        if os.path.exists(sql_file):
            print(f"📁 Executing SQL schema from: {sql_file}")
            success = execute_sql_file(connection, sql_file)
            
            if success:
                # Verify table creation
                print("\n🔍 Verifying table creation...")
                if verify_table_creation(connection):
                    print("✅ Table verification successful")
                    
                    # Verify views creation
                    print("\n🔍 Verifying views creation...")
                    if verify_views_creation(connection):
                        print("✅ Views verification successful")
                        
                        # Display sample data
                        display_sample_data(connection)
                        
                        # Test views
                        test_views(connection)
                        
                        print("\n🎉 Seasons Master table created successfully!")
                        print("\n📋 Summary:")
                        print("   • Table: seasons_master")
                        print("   • Views: 5 analytical views")
                        print("   • Sample Data: 15 seasonal periods")
                        print("   • Features: Comprehensive seasonal impact management")
                        print("   • Coverage: Indian logistics seasons (Monsoon, Festive, Harvest, etc.)")
                    else:
                        print("❌ Views verification failed")
                else:
                    print("❌ Table verification failed")
            else:
                print("❌ SQL file execution failed")
        else:
            print(f"❌ SQL file not found: {sql_file}")
    
    except Error as e:
        print(f"❌ Database operation error: {e}")
    
    finally:
        if connection and connection.is_connected():
            connection.close()
            print("🔌 Database connection closed")

if __name__ == "__main__":
    main() 