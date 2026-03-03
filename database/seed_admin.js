// Seed admin user into PostgreSQL using bcrypt for password hashing
// Usage: node database/seed_admin.js
// Requires env var: DATABASE_URL or configure connection below

const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/presensi_raliway',
  ssl: process.env.DATABASE_URL ? { rejectUnauthorized: false } : false,
});

async function seedAdmin() {
  const client = await pool.connect();
  try {
    const name = 'Admin User';
    const email = 'admin@example.com';
    const no_hp = '081234567890';
    const plainPassword = '123456'; // change this password after first login

    const salt = await bcrypt.genSalt(10);
    const hashed = await bcrypt.hash(plainPassword, salt);

    // Ensure users table exists (simple check)
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        nama_lengkap VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        no_hp VARCHAR(20),
        password VARCHAR(255) NOT NULL,
        departemen VARCHAR(100),
        posisi VARCHAR(100),
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Insert admin if not exists
    const res = await client.query('SELECT id FROM users WHERE email = $1', [email]);
    if (res.rows.length > 0) {
      console.log('Admin user already exists with email:', email);
    } else {
      await client.query(
        'INSERT INTO users (nama_lengkap, email, no_hp, password, departemen, posisi) VALUES ($1, $2, $3, $4, $5, $6)',
        [name, email, no_hp, hashed, 'IT', 'Administrator']
      );
      console.log('Admin user created. Email:', email, 'Password:', plainPassword);
    }
  } catch (err) {
    console.error('Error seeding admin:', err.message || err);
  } finally {
    client.release();
    pool.end();
  }
}

seedAdmin();
