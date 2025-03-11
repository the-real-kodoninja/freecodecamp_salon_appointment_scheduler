-- Create the database
CREATE DATABASE salon;

-- Connect to the database
\c salon

-- Create the customers table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    phone VARCHAR UNIQUE NOT NULL,
    name VARCHAR NOT NULL
);

-- Create the services table
CREATE TABLE services (
    service_id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL
);

-- Create the appointments table
CREATE TABLE appointments (
    appointment_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id) ON DELETE CASCADE,
    service_id INT REFERENCES services(service_id) ON DELETE CASCADE,
    time VARCHAR NOT NULL
);

-- Insert initial data into the services table
INSERT INTO services (name) VALUES 
('cut'),
('color'),
('trim'), 
('perm'),
('shampoo'),
('braids');

-- Insert initial data into the customers table
INSERT INTO customers (phone, name) VALUES 
('555-555-5555', 'Fabio'),
('281-330-8004', 'Mike'),
('410-500-6753', 'Emmanuel');

-- Insert initial data into the appointments table
INSERT INTO appointments (customer_id, service_id, time) VALUES 
((SELECT customer_id FROM customers WHERE phone='555-555-5555'), 1, '10:30'),
((SELECT customer_id FROM customers WHERE phone='555-555-5555'), 2, '11:00'),
((SELECT customer_id FROM customers WHERE phone='281-330-8004'), 1, '02:30'),
((SELECT customer_id FROM customers WHERE phone='410-500-6753'), 4, '04:00'),
((SELECT customer_id FROM customers WHERE phone='410-500-6753'), 5, '05:00');