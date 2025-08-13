#!/usr/bin/env python3
"""
Bids Master Table Creation Script
Creates the bids_master table for comprehensive bid management in TL transportation
"""

import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv
from datetime import datetime, timedelta

def create_bids_master_table():
    """Create the bids_master table with comprehensive bid management fields"""
    
    # Load environment variables
    load_dotenv()
    
    # Database connection configuration
    config = {
        'host': os.getenv('MYSQL_HOST', 'localhost'),
        'user': os.getenv('MYSQL_USER', 'root'),
        'password': os.getenv('MYSQL_PASSWORD', ''),
        'database': os.getenv('MYSQL_DATABASE', 'routecraft'),
        'port': int(os.getenv('MYSQL_PORT', 3306))
    }
    
    try:
        # Establish database connection
        connection = mysql.connector.connect(**config)
        
        if connection.is_connected():
            cursor = connection.cursor()
            print("✅ Successfully connected to MySQL database")
            
            # Create bids_master table
            create_table_query = """
            CREATE TABLE IF NOT EXISTS bids_master (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                bid_reference VARCHAR(100) UNIQUE NOT NULL COMMENT 'Unique bid reference number',
                bid_title VARCHAR(255) NOT NULL COMMENT 'Title/name of the bid',
                description TEXT COMMENT 'Detailed description of the bid requirements',
                bid_type ENUM('contract', 'spot', 'seasonal', 'regional', 'tender') NOT NULL COMMENT 'Type of bid',
                priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium' COMMENT 'Bid priority level',
                
                -- Date fields
                bid_start_date DATE NOT NULL COMMENT 'When the bid becomes active',
                bid_end_date DATE NOT NULL COMMENT 'When the bid expires',
                submission_deadline DATETIME NOT NULL COMMENT 'Deadline for carrier submissions',
                award_date DATE NULL COMMENT 'When the bid was awarded',
                contract_start_date DATE NULL COMMENT 'Contract start date if awarded',
                contract_end_date DATE NULL COMMENT 'Contract end date if awarded',
                
                -- Financial fields
                budget_amount DECIMAL(12,2) NULL COMMENT 'Budget allocated for this bid',
                currency VARCHAR(3) DEFAULT 'INR' COMMENT 'Currency for financial values',
                estimated_cost DECIMAL(12,2) NULL COMMENT 'Estimated cost for the bid',
                min_bid_amount DECIMAL(12,2) NULL COMMENT 'Minimum acceptable bid amount',
                max_bid_amount DECIMAL(12,2) NULL COMMENT 'Maximum acceptable bid amount',
                
                -- Status and workflow
                status ENUM('draft', 'published', 'open', 'evaluating', 'awarded', 'closed', 'cancelled') DEFAULT 'draft' COMMENT 'Current bid status',
                bid_category ENUM('freight', 'warehousing', 'last_mile', 'cross_border', 'specialized') DEFAULT 'freight' COMMENT 'Category of services',
                
                -- Requirements and specifications
                equipment_requirements TEXT COMMENT 'Required equipment types and specifications',
                service_level_requirements TEXT COMMENT 'Service level requirements (SLA)',
                insurance_requirements TEXT COMMENT 'Insurance and liability requirements',
                compliance_requirements TEXT COMMENT 'Regulatory and compliance requirements',
                
                -- Geographic scope
                origin_regions TEXT COMMENT 'Origin regions/cities covered',
                destination_regions TEXT COMMENT 'Destination regions/cities covered',
                applicable_lanes TEXT COMMENT 'Specific lanes or routes covered',
                
                -- Carrier management
                target_carrier_types ENUM('all', 'preferred', 'certified', 'regional') DEFAULT 'all' COMMENT 'Types of carriers eligible',
                max_carriers_per_lane INT DEFAULT 5 COMMENT 'Maximum carriers per lane',
                min_carrier_rating DECIMAL(3,2) DEFAULT 3.0 COMMENT 'Minimum carrier rating required',
                
                -- Evaluation criteria
                evaluation_criteria JSON COMMENT 'JSON object defining evaluation criteria and weights',
                scoring_matrix JSON COMMENT 'Scoring matrix for bid evaluation',
                
                -- Business rules
                is_template BOOLEAN DEFAULT FALSE COMMENT 'Whether this bid can be used as a template',
                allow_partial_awards BOOLEAN DEFAULT FALSE COMMENT 'Allow partial lane awards',
                auto_extend BOOLEAN DEFAULT FALSE COMMENT 'Auto-extend if no responses',
                extension_days INT DEFAULT 7 COMMENT 'Days to extend if auto-extend is enabled',
                
                -- Metadata
                created_by BIGINT NOT NULL COMMENT 'User ID who created the bid',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                published_by BIGINT NULL COMMENT 'User ID who published the bid',
                published_at TIMESTAMP NULL COMMENT 'When the bid was published',
                closed_by BIGINT NULL COMMENT 'User ID who closed the bid',
                closed_at TIMESTAMP NULL COMMENT 'When the bid was closed',
                awarded_by BIGINT NULL COMMENT 'User ID who awarded the bid',
                awarded_at TIMESTAMP NULL COMMENT 'When the bid was awarded',
                
                -- Additional fields
                external_reference VARCHAR(100) NULL COMMENT 'External system reference',
                notes TEXT COMMENT 'Additional notes and comments',
                attachments JSON COMMENT 'JSON array of attachment references',
                
                -- Indexes for performance
                INDEX idx_bid_reference (bid_reference),
                INDEX idx_status (status),
                INDEX idx_bid_type (bid_type),
                INDEX idx_priority (priority),
                INDEX idx_submission_deadline (submission_deadline),
                INDEX idx_bid_dates (bid_start_date, bid_end_date),
                INDEX idx_created_by (created_by),
                INDEX idx_budget_range (min_bid_amount, max_bid_amount),
                INDEX idx_category (bid_category),
                INDEX idx_created_at (created_at),
                
                -- Foreign key constraints
                FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
                FOREIGN KEY (published_by) REFERENCES users(id) ON DELETE SET NULL,
                FOREIGN KEY (closed_by) REFERENCES users(id) ON DELETE SET NULL,
                FOREIGN KEY (awarded_by) REFERENCES users(id) ON DELETE SET NULL
                
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            COMMENT='Master table for comprehensive bid management in TL transportation';
            """
            
            cursor.execute(create_table_query)
            print("✅ Successfully created bids_master table")
            
            # Create bid_lanes table for many-to-many relationship
            create_bid_lanes_query = """
            CREATE TABLE IF NOT EXISTS bid_lanes (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                bid_id BIGINT NOT NULL COMMENT 'Reference to bids_master',
                lane_id BIGINT NOT NULL COMMENT 'Reference to lanes table',
                lane_priority INT DEFAULT 1 COMMENT 'Priority of this lane in the bid',
                estimated_volume DECIMAL(10,2) NULL COMMENT 'Estimated volume for this lane',
                volume_unit ENUM('MT', 'KG', 'Pallets', 'Units', 'TEU') DEFAULT 'MT' COMMENT 'Unit for volume measurement',
                special_requirements TEXT COMMENT 'Lane-specific requirements',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                
                UNIQUE KEY unique_bid_lane (bid_id, lane_id),
                INDEX idx_bid_id (bid_id),
                INDEX idx_lane_id (lane_id),
                INDEX idx_lane_priority (lane_priority),
                
                FOREIGN KEY (bid_id) REFERENCES bids_master(id) ON DELETE CASCADE,
                FOREIGN KEY (lane_id) REFERENCES lanes(id) ON DELETE CASCADE
                
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            COMMENT='Many-to-many relationship between bids and lanes';
            """
            
            cursor.execute(create_bid_lanes_query)
            print("✅ Successfully created bid_lanes table")
            
            # Create bid_carriers table for many-to-many relationship
            create_bid_carriers_query = """
            CREATE TABLE IF NOT EXISTS bid_carriers (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                bid_id BIGINT NOT NULL COMMENT 'Reference to bids_master',
                carrier_id BIGINT NOT NULL COMMENT 'Reference to carriers table',
                invitation_status ENUM('invited', 'accepted', 'declined', 'auto_invited') DEFAULT 'invited' COMMENT 'Status of carrier invitation',
                invitation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When the invitation was sent',
                response_date TIMESTAMP NULL COMMENT 'When the carrier responded',
                notes TEXT COMMENT 'Notes about this carrier for this bid',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                
                UNIQUE KEY unique_bid_carrier (bid_id, carrier_id),
                INDEX idx_bid_id (bid_id),
                INDEX idx_carrier_id (carrier_id),
                INDEX idx_invitation_status (invitation_status),
                
                FOREIGN KEY (bid_id) REFERENCES bids_master(id) ON DELETE CASCADE,
                FOREIGN KEY (carrier_id) REFERENCES carriers(id) ON DELETE CASCADE
                
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            COMMENT='Many-to-many relationship between bids and invited carriers';
            """
            
            cursor.execute(create_bid_carriers_query)
            print("✅ Successfully created bid_carriers table")
            
            # Create bid_responses table for carrier responses
            create_bid_responses_query = """
            CREATE TABLE IF NOT EXISTS bid_responses (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                bid_id BIGINT NOT NULL COMMENT 'Reference to bids_master',
                carrier_id BIGINT NOT NULL COMMENT 'Reference to carriers table',
                response_reference VARCHAR(100) UNIQUE NOT NULL COMMENT 'Unique response reference',
                
                -- Financial proposal
                proposed_total_amount DECIMAL(12,2) NOT NULL COMMENT 'Total proposed amount',
                proposed_currency VARCHAR(3) DEFAULT 'INR' COMMENT 'Currency of the proposal',
                breakdown_available BOOLEAN DEFAULT FALSE COMMENT 'Whether detailed breakdown is provided',
                price_breakdown JSON NULL COMMENT 'JSON breakdown of pricing components',
                
                -- Service proposal
                proposed_transit_time_hours INT NULL COMMENT 'Proposed transit time in hours',
                proposed_equipment_types TEXT COMMENT 'Proposed equipment types',
                proposed_equipment_count INT DEFAULT 1 COMMENT 'Number of equipment units',
                proposed_crew_size INT DEFAULT 1 COMMENT 'Proposed crew size',
                
                -- Additional services
                additional_services JSON NULL COMMENT 'JSON array of additional services offered',
                value_added_services TEXT COMMENT 'Description of value-added services',
                
                -- Terms and conditions
                terms_conditions TEXT COMMENT 'Carrier-specific terms and conditions',
                exceptions TEXT COMMENT 'Any exceptions to standard terms',
                validity_period_days INT DEFAULT 30 COMMENT 'Validity period of the proposal',
                
                -- Status and evaluation
                status ENUM('draft', 'submitted', 'under_review', 'shortlisted', 'awarded', 'rejected', 'withdrawn') DEFAULT 'draft' COMMENT 'Response status',
                evaluation_score DECIMAL(5,2) NULL COMMENT 'Evaluation score (0-100)',
                evaluation_notes TEXT COMMENT 'Notes from evaluation process',
                ranking_position INT NULL COMMENT 'Position in ranking (1 = best)',
                
                -- Timestamps
                submitted_at TIMESTAMP NULL COMMENT 'When the response was submitted',
                evaluated_at TIMESTAMP NULL COMMENT 'When the response was evaluated',
                awarded_at TIMESTAMP NULL COMMENT 'When the response was awarded',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                
                -- Additional fields
                is_preferred_carrier BOOLEAN DEFAULT FALSE COMMENT 'Whether this is a preferred carrier',
                previous_performance_rating DECIMAL(3,2) NULL COMMENT 'Previous performance rating',
                risk_assessment_score DECIMAL(5,2) NULL COMMENT 'Risk assessment score',
                
                -- Indexes
                INDEX idx_bid_id (bid_id),
                INDEX idx_carrier_id (carrier_id),
                INDEX idx_status (status),
                INDEX idx_submitted_at (submitted_at),
                INDEX idx_evaluation_score (evaluation_score),
                INDEX idx_ranking_position (ranking_position),
                INDEX idx_response_reference (response_reference),
                
                -- Foreign keys
                FOREIGN KEY (bid_id) REFERENCES bids_master(id) ON DELETE CASCADE,
                FOREIGN KEY (carrier_id) REFERENCES carriers(id) ON DELETE CASCADE
                
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            COMMENT='Carrier responses to bids with comprehensive proposal details';
            """
            
            cursor.execute(create_bid_responses_query)
            print("✅ Successfully created bid_responses table")
            
            # Insert sample data
            print("📝 Inserting sample bid data...")
            
            # Sample bid data
            sample_bids = [
                {
                    'bid_reference': 'BID-2025-001',
                    'bid_title': 'Mumbai-Delhi Express Freight Service',
                    'description': 'High-priority freight service between Mumbai and Delhi with daily departures',
                    'bid_type': 'contract',
                    'priority': 'high',
                    'bid_start_date': '2025-01-01',
                    'bid_end_date': '2025-12-31',
                    'submission_deadline': '2024-12-15 18:00:00',
                    'budget_amount': 5000000.00,
                    'currency': 'INR',
                    'estimated_cost': 4500000.00,
                    'status': 'published',
                    'bid_category': 'freight',
                    'equipment_requirements': '20ft and 40ft containers, flatbed trailers',
                    'service_level_requirements': '24-hour delivery guarantee',
                    'origin_regions': 'Mumbai, Pune, Nashik',
                    'destination_regions': 'Delhi, Noida, Gurgaon',
                    'target_carrier_types': 'preferred',
                    'max_carriers_per_lane': 3,
                    'min_carrier_rating': 4.0,
                    'created_by': 1
                },
                {
                    'bid_reference': 'BID-2025-002',
                    'bid_title': 'Bangalore-Chennai Seasonal Transport',
                    'description': 'Seasonal transport service for agricultural products',
                    'bid_type': 'seasonal',
                    'priority': 'medium',
                    'bid_start_date': '2025-03-01',
                    'bid_end_date': '2025-08-31',
                    'submission_deadline': '2025-02-15 18:00:00',
                    'budget_amount': 2000000.00,
                    'currency': 'INR',
                    'estimated_cost': 1800000.00,
                    'status': 'open',
                    'bid_category': 'freight',
                    'equipment_requirements': 'Reefer trailers, temperature-controlled containers',
                    'service_level_requirements': 'Temperature monitoring and reporting',
                    'origin_regions': 'Bangalore, Mysore',
                    'destination_regions': 'Chennai, Coimbatore',
                    'target_carrier_types': 'certified',
                    'max_carriers_per_lane': 2,
                    'min_carrier_rating': 4.5,
                    'created_by': 1
                },
                {
                    'bid_reference': 'BID-2025-003',
                    'bid_title': 'Pan-India Spot Freight Services',
                    'description': 'On-demand spot freight services across major Indian cities',
                    'bid_type': 'spot',
                    'priority': 'urgent',
                    'bid_start_date': '2025-01-01',
                    'bid_end_date': '2025-12-31',
                    'submission_deadline': '2024-12-20 18:00:00',
                    'budget_amount': 10000000.00,
                    'currency': 'INR',
                    'estimated_cost': 9000000.00,
                    'status': 'draft',
                    'bid_category': 'freight',
                    'equipment_requirements': 'All equipment types accepted',
                    'service_level_requirements': 'Flexible delivery windows',
                    'origin_regions': 'All major cities',
                    'destination_regions': 'All major cities',
                    'target_carrier_types': 'all',
                    'max_carriers_per_lane': 10,
                    'min_carrier_rating': 3.0,
                    'created_by': 1
                }
            ]
            
            # Insert sample bids
            for bid in sample_bids:
                insert_query = """
                INSERT INTO bids_master (
                    bid_reference, bid_title, description, bid_type, priority,
                    bid_start_date, bid_end_date, submission_deadline, budget_amount,
                    currency, estimated_cost, status, bid_category, equipment_requirements,
                    service_level_requirements, origin_regions, destination_regions,
                    target_carrier_types, max_carriers_per_lane, min_carrier_rating, created_by
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """
                
                cursor.execute(insert_query, (
                    bid['bid_reference'], bid['bid_title'], bid['description'], bid['bid_type'],
                    bid['priority'], bid['bid_start_date'], bid['bid_end_date'], bid['submission_deadline'],
                    bid['budget_amount'], bid['currency'], bid['estimated_cost'], bid['status'],
                    bid['bid_category'], bid['equipment_requirements'], bid['service_level_requirements'],
                    bid['origin_regions'], bid['destination_regions'], bid['target_carrier_types'],
                    bid['max_carriers_per_lane'], bid['min_carrier_rating'], bid['created_by']
                ))
            
            print("✅ Successfully inserted sample bid data")
            
            # Create database views for common queries
            print("🔍 Creating database views...")
            
            # View for active bids
            create_active_bids_view = """
            CREATE OR REPLACE VIEW active_bids AS
            SELECT 
                bm.*,
                COUNT(DISTINCT bl.lane_id) as total_lanes,
                COUNT(DISTINCT bc.carrier_id) as total_invited_carriers,
                COUNT(DISTINCT br.carrier_id) as total_responses
            FROM bids_master bm
            LEFT JOIN bid_lanes bl ON bm.id = bl.bid_id
            LEFT JOIN bid_carriers bc ON bm.id = bc.bid_id
            LEFT JOIN bid_responses br ON bm.id = br.bid_id AND br.status IN ('submitted', 'under_review', 'shortlisted')
            WHERE bm.status IN ('published', 'open', 'evaluating')
            GROUP BY bm.id
            """
            
            cursor.execute(create_active_bids_view)
            print("✅ Created active_bids view")
            
            # View for bid summary statistics
            create_bid_stats_view = """
            CREATE OR REPLACE VIEW bid_statistics AS
            SELECT 
                bid_type,
                status,
                COUNT(*) as bid_count,
                AVG(budget_amount) as avg_budget,
                AVG(estimated_cost) as avg_estimated_cost,
                MIN(budget_amount) as min_budget,
                MAX(budget_amount) as max_budget
            FROM bids_master
            GROUP BY bid_type, status
            """
            
            cursor.execute(create_bid_stats_view)
            print("✅ Created bid_statistics view")
            
            # View for carrier response analysis
            create_response_analysis_view = """
            CREATE OR REPLACE VIEW carrier_response_analysis AS
            SELECT 
                bm.bid_reference,
                bm.bid_title,
                c.company_name as carrier_name,
                br.proposed_total_amount,
                br.proposed_transit_time_hours,
                br.evaluation_score,
                br.ranking_position,
                br.status as response_status,
                br.submitted_at
            FROM bid_responses br
            JOIN bids_master bm ON br.bid_id = bm.id
            JOIN carriers c ON br.carrier_id = c.id
            ORDER BY bm.bid_reference, br.ranking_position
            """
            
            cursor.execute(create_response_analysis_view)
            print("✅ Created carrier_response_analysis view")
            
            print("\n🎉 Successfully created comprehensive bids management system!")
            print("\n📊 Tables created:")
            print("   - bids_master (main bids table)")
            print("   - bid_lanes (bid-lane relationships)")
            print("   - bid_carriers (bid-carrier relationships)")
            print("   - bid_responses (carrier responses)")
            print("\n🔍 Views created:")
            print("   - active_bids (active bid summary)")
            print("   - bid_statistics (statistical analysis)")
            print("   - carrier_response_analysis (response analysis)")
            print("\n📝 Sample data inserted: 3 sample bids")
            
        else:
            print("❌ Failed to connect to MySQL database")
            
    except Error as e:
        print(f"❌ Error: {e}")
        
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()
            print("✅ Database connection closed")

if __name__ == "__main__":
    create_bids_master_table() 