-- ecommerce_schema.sql
-- E-commerce database schema with keys, constraints and relationships
-- Run on MySQL (InnoDB)

CREATE DATABASE IF NOT EXISTS ecommerce_db
  CHARACTER SET = 'utf8mb4'
  COLLATE = 'utf8mb4_unicode_ci';
USE ecommerce_db;

-- ----------------------------------------------------
-- USERS (customers / accounts)
-- One-to-Many: users -> orders, users -> addresses, users -> reviews
-- One-to-One: users -> user_profiles
-- ----------------------------------------------------
CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  is_active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

-- ----------------------------------------------------
-- USER PROFILES (One-to-One with users)
-- user_profiles.user_id references users.id and is UNIQUE to ensure 1-to-1
-- ----------------------------------------------------
CREATE TABLE user_profiles (
  user_id BIGINT UNSIGNED PRIMARY KEY,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  phone VARCHAR(30),
  date_of_birth DATE,
  bio TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------
-- ADDRESSES (One-to-Many: user can have multiple addresses)
-- ----------------------------------------------------
CREATE TABLE addresses (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  label VARCHAR(50), -- e.g., "home", "work"
  street VARCHAR(255) NOT NULL,
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100),
  postal_code VARCHAR(20),
  country VARCHAR(100) NOT NULL,
  is_default TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------
-- CATEGORIES (products may belong to many categories via product_categories)
-- ----------------------------------------------------
CREATE TABLE categories (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ----------------------------------------------------
-- PRODUCTS
-- ----------------------------------------------------
CREATE TABLE products (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  sku VARCHAR(64) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ----------------------------------------------------
-- PRODUCT_CATEGORIES (Many-to-Many: products <-> categories)
-- ----------------------------------------------------
CREATE TABLE product_categories (
  product_id BIGINT UNSIGNED NOT NULL,
  category_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (product_id, category_id),
  FOREIGN KEY (product_id) REFERENCES products(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------
-- PRODUCT_IMAGES (One-to-Many: product -> images)
-- ----------------------------------------------------
CREATE TABLE product_images (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id BIGINT UNSIGNED NOT NULL,
  url VARCHAR(1024) NOT NULL,
  alt_text VARCHAR(255),
  display_order INT UNSIGNED DEFAULT 0,
  FOREIGN KEY (product_id) REFERENCES products(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------
-- INVENTORY (tracks stock; One-to-One-ish per product+location if using warehouse)
-- Keep simple: quantity per product
-- ----------------------------------------------------
CREATE TABLE inventory (
  product_id BIGINT UNSIGNED PRIMARY KEY,
  quantity INT NOT NULL DEFAULT 0 CHECK (quantity >= 0),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------
-- ORDERS (One-to-Many: user -> orders)
-- ----------------------------------------------------
CREATE TABLE orders (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  order_number VARCHAR(64) NOT NULL UNIQUE,
  order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status ENUM('pending','processing','shipped','delivered','cancelled','refunded') NOT NULL DEFAULT 'pending',
  total_amount DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0),
  shipping_address_id B
