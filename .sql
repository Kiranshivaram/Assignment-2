Schema Definition (SQL)
sql
Copy
-- Create Suppliers Table
CREATE TABLE suppliers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    contact_info VARCHAR(255),
    product_categories_offered VARCHAR(255) -- Stores categories the supplier offers
);

-- Create Products Table
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    brand VARCHAR(255),
    price DECIMAL(10, 2) NOT NULL,
    category VARCHAR(100),
    description TEXT,
    supplier_id INT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);
3. Populate the Database with Sample Data
sql
Copy
-- Insert Sample Data into Suppliers
INSERT INTO suppliers (name, contact_info, product_categories_offered)
VALUES
('Tech Corp', 'contact@techcorp.com, 555-0101', 'Electronics, Computers, Accessories'),
('Fashion World', 'support@fashionworld.com, 555-0202', 'Clothing, Accessories'),
('Green Foods', 'info@greenfoods.com, 555-0303', 'Groceries, Organic');

-- Insert Sample Data into Products
INSERT INTO products (name, brand, price, category, description, supplier_id)
VALUES
('Laptop X1000', 'TechBrand', 999.99, 'Electronics', 'High-performance laptop with 16GB RAM and 512GB SSD', 1),
('Smartphone Y200', 'TechBrand', 499.99, 'Electronics', 'Latest smartphone with 6GB RAM and 128GB storage', 1),
('Leather Jacket', 'FashionPro', 150.00, 'Clothing', 'Premium leather jacket for winter', 2),
('Organic Avocados', 'Green Foods', 2.99, 'Groceries', 'Fresh organic avocados', 3),
('Winter Coat', 'FashionPro', 200.00, 'Clothing', 'Warm winter coat with a waterproof outer shell', 2);
4. Queries to Fetch Relevant Information
Below are some sample queries to retrieve relevant information based on common chatbot requests:

Get all products from a specific supplier:
sql
Copy
SELECT p.name, p.brand, p.price, p.category, p.description
FROM products p
JOIN suppliers s ON p.supplier_id = s.id
WHERE s.name = 'Tech Corp';
Get products by category (e.g., Electronics):
sql
Copy
SELECT name, brand, price, description
FROM products
WHERE category = 'Electronics';
Get products within a specific price range:
sql
Copy
SELECT name, brand, price, description
FROM products
WHERE price BETWEEN 100 AND 500;
Get suppliers who offer products in a specific category (e.g., Clothing):
sql
Copy
SELECT DISTINCT s.name, s.contact_info
FROM suppliers s
JOIN products p ON FIND_IN_SET(p.category, s.product_categories_offered)
WHERE p.category = 'Clothing';
Get a list of all suppliers and the categories they offer:
sql
Copy
SELECT name, product_categories_offered
FROM suppliers;
Get the most expensive product from each supplier:
sql
Copy
SELECT s.name AS supplier_name, p.name AS product_name, MAX(p.price) AS max_price
FROM products p
JOIN suppliers s ON p.supplier_id = s.id
GROUP BY s.name;
Get products with a description containing a specific keyword (e.g., "organic"):
sql
Copy
SELECT name, brand, price, description
FROM products
WHERE description LIKE '%organic%';
5. Optimizations
Indexes: You might want to create indexes on frequently queried columns, such as category in the products table or product_categories_offered in the suppliers table, to improve performance.
sql
Copy
CREATE INDEX idx_category ON products (category);
CREATE INDEX idx_supplier_category ON suppliers (product_categories_offered);