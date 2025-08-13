-- Setup MySQL Database for RouteCraft
-- Run this as root user

-- Create database
CREATE DATABASE IF NOT EXISTS routecraft;
USE routecraft;

-- Create user and grant privileges
CREATE USER IF NOT EXISTS 'routecraft_user'@'localhost' IDENTIFIED BY 'routecraft_password';
GRANT ALL PRIVILEGES ON routecraft.* TO 'routecraft_user'@'localhost';
FLUSH PRIVILEGES;

-- Create tables
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    company_name VARCHAR(255),
    phone VARCHAR(20),
    role ENUM('admin', 'user', 'carrier') DEFAULT 'user',
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS carriers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    company_name VARCHAR(255) NOT NULL,
    dot_number VARCHAR(20),
    mc_number VARCHAR(20),
    status ENUM('active', 'inactive', 'pending') DEFAULT 'pending',
    insurance_expiry DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS lanes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    origin_city VARCHAR(100) NOT NULL,
    origin_state VARCHAR(2) NOT NULL,
    destination_city VARCHAR(100) NOT NULL,
    destination_state VARCHAR(2) NOT NULL,
    distance_miles INT,
    estimated_transit_days INT,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bids (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    lane_id INT,
    estimated_cost DECIMAL(10,2),
    status ENUM('open', 'awarded', 'closed', 'cancelled') DEFAULT 'open',
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (lane_id) REFERENCES lanes(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS bid_responses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bid_id INT NOT NULL,
    carrier_id INT NOT NULL,
    proposed_cost DECIMAL(10,2) NOT NULL,
    proposed_transit_days INT,
    status ENUM('pending', 'accepted', 'rejected') DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (bid_id) REFERENCES bids(id) ON DELETE CASCADE,
    FOREIGN KEY (carrier_id) REFERENCES carriers(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS insurance_claims (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bid_response_id INT,
    claim_type ENUM('damage', 'delay', 'loss', 'other') NOT NULL,
    description TEXT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'approved', 'rejected', 'resolved') DEFAULT 'pending',
    filed_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (bid_response_id) REFERENCES bid_responses(id) ON DELETE SET NULL,
    FOREIGN KEY (filed_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS bid_lanes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bid_id INT NOT NULL,
    lane_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bid_id) REFERENCES bids(id) ON DELETE CASCADE,
    FOREIGN KEY (lane_id) REFERENCES lanes(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS bid_carriers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bid_id INT NOT NULL,
    carrier_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bid_id) REFERENCES bids(id) ON DELETE CASCADE,
    FOREIGN KEY (carrier_id) REFERENCES carriers(id) ON DELETE CASCADE
);

-- Insert sample data
INSERT INTO users (email, password_hash, first_name, last_name, company_name, role) VALUES
('admin@routecraft.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8Q8jK8i', 'Admin', 'User', 'RouteCraft Admin', 'admin'),
('user@routecraft.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8Q8jK8i', 'Test', 'User', 'Test Company', 'user'),
('carrier@routecraft.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8Q8jK8i', 'Test', 'Carrier', 'Test Carrier', 'carrier');

INSERT INTO carriers (user_id, company_name, dot_number, mc_number, status) VALUES
(3, 'Test Carrier Company', 'DOT123456', 'MC789012', 'active');

INSERT INTO lanes (origin_city, origin_state, destination_city, destination_state, distance_miles, estimated_transit_days) VALUES
('New York', 'NY', 'Los Angeles', 'CA', 2789, 5),
('Chicago', 'IL', 'Houston', 'TX', 940, 2),
('Miami', 'FL', 'Seattle', 'WA', 3300, 7);

INSERT INTO bids (title, description, lane_id, estimated_cost, created_by) VALUES
('NYC to LA Express', 'Fast delivery from New York to Los Angeles', 1, 2500.00, 2),
('Chicago to Houston', 'Reliable shipping from Chicago to Houston', 2, 1200.00, 2);

INSERT INTO bid_responses (bid_id, carrier_id, proposed_cost, proposed_transit_days) VALUES
(1, 1, 2400.00, 5),
(2, 1, 1150.00, 2);

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_carriers_user_id ON carriers(user_id);
CREATE INDEX idx_bids_lane_id ON bids(lane_id);
CREATE INDEX idx_bids_status ON bids(status);
CREATE INDEX idx_bid_responses_bid_id ON bid_responses(bid_id);
CREATE INDEX idx_bid_responses_carrier_id ON bid_responses(carrier_id); 