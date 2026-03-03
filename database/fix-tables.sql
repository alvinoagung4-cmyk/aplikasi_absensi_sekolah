-- Drop existing tables
DROP TABLE IF EXISTS attendance CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Create users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  nama_lengkap VARCHAR(100) NOT NULL,
  no_hp VARCHAR(20) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  email_verified BOOLEAN DEFAULT FALSE,
  verification_token VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_email ON users(email);

-- Create attendance table
CREATE TABLE attendance (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  check_in_time TIMESTAMP,
  check_out_time TIMESTAMP,
  location VARCHAR(100),
  status VARCHAR(50),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_date ON attendance(user_id, check_in_time);

-- Insert sample data
INSERT INTO users (nama_lengkap, no_hp, email, password, email_verified) VALUES
('Admin User', '082123456789', 'admin@test.com', '$2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k', TRUE),
('John Doe', '081234567890', 'john@test.com', '$2a$10$XQnF0WXh0JHNYYj7QQk4Z.DTQQ8RHmJ5c3h5S5H5k5H5k5H5k5H5k', TRUE);
