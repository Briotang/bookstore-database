-- This SQL script creates a database schema for a bookstore system, including tables for books, authors, customers, orders, and more. It also includes user roles and permissions.

-- table publisher
CREATE TABLE publisher (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(100),
    website VARCHAR(100)
);
-- table book_language

CREATE TABLE book_language (
    language_id INT AUTO_INCREMENT PRIMARY KEY,
    language_name VARCHAR(255)
);
-- table book

CREATE TABLE book (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255),
    isbn VARCHAR(255),
    language_id INT,
    num_pages INT,
    price INT,
    publication_date DATE,
    stock INT,
    publisher_id INT,
    FOREIGN KEY (publisher_id)
        REFERENCES publisher (publisher_id),
    FOREIGN KEY (language_id)
        REFERENCES book_language (language_id)
);

-- table author
CREATE TABLE author (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    author_name VARCHAR(100)
);

-- table book_author
CREATE TABLE book_author (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id , author_id),
    FOREIGN KEY (book_id)
        REFERENCES book (book_id),
    FOREIGN KEY (author_id)
        REFERENCES author (author_id)
);

--table customer
CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone INT
);

-- table country
CREATE TABLE country (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100)
);

-- table address
CREATE TABLE address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    street_number VARCHAR(100),
    street_name VARCHAR(100),
    city VARCHAR(100),
    country_id INT,
    FOREIGN KEY (country_id)
        REFERENCES country (country_id)
);

-- table address_status
CREATE TABLE address_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    address_status VARCHAR(100)
);

-- table customer_address
CREATE TABLE customer_address (
    customer_id INT,
    address_id INT,
    status_id INT,
    PRIMARY KEY (customer_id , address_id),
    FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id),
    FOREIGN KEY (address_id)
        REFERENCES address (address_id),
    FOREIGN KEY (status_id)
        REFERENCES address_status (status_id)
);

-- table order_status
CREATE TABLE order_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(255)
);

-- table order_history
CREATE TABLE order_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    status_id INT,
    status_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id)
        REFERENCES cust_order (order_id),
    FOREIGN KEY (status_id)
        REFERENCES order_status (status_id)
);

-- table cust_order
CREATE TABLE cust_order (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    shipping_method_id INT,
    status_id INT,
    FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id),
    FOREIGN KEY (shipping_method_id)
        REFERENCES shipping_method (shipping_method_id),
    FOREIGN KEY (status_id)
        REFERENCES order_status (status_id)
);

-- table order_line
CREATE TABLE order_line (
    line_id INT,
    book_id INT,
    order_id INT,
    quantity INT,
    price_each INT,
    PRIMARY KEY (line_id , book_id),
    FOREIGN KEY (order_id)
        REFERENCES cust_order (order_id),
    FOREIGN KEY (book_id)
        REFERENCES book (book_id)
);

-- table shipping_method
CREATE TABLE shipping_method (
    shipping_method_id INT AUTO_INCREMENT PRIMARY KEY,
    method_name VARCHAR(100),
    cost INT
);

-- create roles and users
create role admins, readonly;
grant all on bookstore_db.* to admins;
grant select on bookstore_db.* to readonly;
create user 'admin_user'@'localhost' 
identified by "123456789";

create user 'readonly_user'@'localhost'
identified by "123456789";

grant admins to 'admin_user'@'localhost' ;
grant readonly to 'readonly_user'@'localhost' ;

-- example queries
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(ca.address_id) AS address_count
FROM
    customer c
        JOIN
    customer_address ca ON c.customer_id = ca.customer_id
GROUP BY c.customer_id
HAVING address_count > 1;

SELECT 
    oh.order_id, os.status_name, oh.status_date
FROM
    order_history oh
        JOIN
    order_status os ON oh.status_id = os.status_id
ORDER BY oh.order_id , oh.status_date;

SELECT 
    co.order_id,
    c.first_name,
    c.last_name,
    co.order_date,
    os.status_name AS order_status
FROM
    cust_order co
        JOIN
    customer c ON co.customer_id = c.customer_id
        JOIN
    order_status os ON co.status_id = os.status_id;