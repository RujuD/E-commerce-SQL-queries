create database ecommerce;
use ecommerce;

-- Create tables

CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(255) NOT NULL
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(255) NOT NULL
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    category_id INT,
    supplier_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(255) NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    product_id INT,
    quantity INT,
    order_date DATE,
    order_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(255) NOT NULL
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_name VARCHAR(255) NOT NULL,
    department_id INT,
    salary DECIMAL(10, 2),
    manager_id INT,
    birth_date DATE,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id) ON DELETE SET NULL
);

CREATE TABLE employee_projects (
    employee_id INT,
    project_id INT,
    PRIMARY KEY (employee_id, project_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Insert sample data

-- Suppliers
INSERT INTO suppliers (supplier_name) VALUES 
('Supplier A'),
('Supplier B'),
('Supplier C');

-- Categories
INSERT INTO categories (category_name) VALUES 
('Category 1'),
('Category 2'),
('Category 3');

-- Products
INSERT INTO products (product_name, category_id, supplier_id) VALUES 
('Product 1', 1, 1),
('Product 2', 1, 2),
('Product 3', 2, 1),
('Product 4', 3, 3),
('Product 5', 2, 2),
('Product 6', 3, 1);

-- Customers
INSERT INTO customers (customer_name) VALUES 
('Customer A'),
('Customer B'),
('Customer C');

-- Orders
INSERT INTO orders (customer_id, product_id, quantity, order_date, order_amount) VALUES 
(1, 1, 10, '2023-01-10', 100.00),
(1, 2, 5, '2023-02-15', 50.00),
(2, 3, 20, '2023-03-20', 200.00),
(2, 4, 15, '2023-04-25', 150.00),
(3, 5, 10, '2023-05-30', 100.00),
(3, 6, 25, '2023-06-05', 250.00),
(1, 3, 5, '2023-07-10', 50.00),
(2, 2, 15, '2023-08-15', 150.00),
(3, 1, 20, '2023-09-20', 200.00),
(1,	5,	10,'2023-08-12',400.00);

-- Departments
INSERT INTO departments (department_name) VALUES 
('HR'),
('Engineering'),
('Marketing');

-- Employees
INSERT INTO employees (employee_name, department_id, salary, manager_id, birth_date) VALUES 
('Employee A', 1, 60000.00, NULL, '1980-01-01'),
('Employee B', 1, 65000.00, 1, '1985-02-02'),
('Employee C', 2, 70000.00, 1, '1990-03-03'),
('Employee D', 3, 75000.00, 2, '1985-04-04'),
('Employee E', 2, 80000.00, 2, '1970-05-05'),
('Employee F', 3, 85000.00, 3, '1995-06-06');

-- Employee Projects
INSERT INTO employee_projects (employee_id, project_id) VALUES 
(1, 1),
(1, 2),
(2, 2),
(2, 3),
(3, 3),
(4, 1),
(4, 4),
(5, 4),
(6, 5);


## SOLVING

# 1. Write a query to find the customer name who have placed orders amount more than 500
select customer_name from customers c join orders o on c.customer_id=o.customer_id where order_amount > 500;

# 2. Find the most recently ordered product by each customer?
select customer_name, max(order_date) as RecentOrder from customers c join orders o using(customer_id) group by customer_name;

# 3. Find the most frequently ordered product by each customer? Note: most frequently ordered means the highest volume ordered
with temp as( select customer_id, product_id, sum(quantity) as total_quantity from orders group by customer_id,product_id), RankedProducts as
(select customer_id, product_id, total_quantity, rank() over(partition by customer_id order by total_quantity desc) as Ranks from temp) 
select customer_id, product_id as most_frequent_product, total_quantity as highest_quantity from RankedProducts where Ranks = 1;

# 4. List the names of suppliers who supply products in 'Category 2’. (try using join and subquery separately)
# by join
select supplier_name,category_name,product_name from suppliers s join products p using(supplier_id) join categories c using(category_id) where category_name='Category 2';
# by subquery
select supplier_name from suppliers where supplier_id in(select supplier_id from products where category_id in(select category_id from categories
where category_name='Category 2'));

# 5. List the employees who are working on more than one project.    # since its more than one use count
select employee_id,employee_name from employees e where employee_id in(select employee_id from employee_projects group by employee_id having count(project_id)>1);

# 6. Display the customer name along with number of orders and total amount paid   # number fo orders means take count
select customer_name, count(order_id) as NumberofOrders, sum(order_amount) as TotalAmtPaid from customers c join orders o on c.customer_id=o.customer_id
group by customer_name;

# 7. List the top 3 products that have generated the highest revenue.
select product_name,sum(order_amount * quantity) as HighestRevenue from products p join orders o on p.product_id=o.product_id group by product_name
order by HighestRevenue limit 3;

# 8. List customers who have ordered every product supplied by 'Supplier B'.
select customer_name,o.product_id,product_name,supplier_name from customers c join orders o on c.customer_id=o.customer_id join products p on p.product_id=o.product_id
join suppliers s on s.supplier_id=p.supplier_id where supplier_name='Supplier B';

# 9. Find the products ordered by at least two different customers.
select p.product_name,o.product_id,c.customer_name,c.customer_id from products p join orders o on p.product_id=o.product_id 
join customers c on o.customer_id=c.customer_id group by o.product_id,c.customer_id
having count(c.customer_id)>=2;

# 10. List the departments where all employees earn above the company's average salary
with temp as(select avg(salary) as AvgSal from employees) select department_id,salary from employees group by department_id,salary
having min(salary) > (select AvgSal from temp); 
