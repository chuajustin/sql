-- List all products
SELECT *
FROM products;

-- Show the names and city of all customers
SELECT ContactName, City
FROM customers;

-- Display all employees' first & last name
SELECT FirstName, LastName
FROM employees;

-- Show all orders placed in 1997
SELECT *
FROM orders
WHERE OrderDate BETWEEN '1997-01-01' and '1997-12-31';

SELECT *
FROM orders
WHERE OrderDate >= '1997-01-01';

-- List all customers from germany
SELECT *
FROM customers
WHERE country = 'Germany';

-- Show products that cost more than $50
SELECT *
FROM products
WHERE UnitPrice > 50;

-- Get all employees who were hired after 1994
SELECT *
FROM employees
WHERE HireDate >= '1994-01-01';

-- List products sorted by price, highest first
SELECT *
FROM products
ORDER BY UnitPrice desc;

-- Display customers from Mexico ordered alphabetically
SELECT *
FROM customers
WHERE country = 'Mexico'
ORDER BY ContactName ASC;

-- Show the 10 top most exp products
SELECT *
FROM products
ORDER BY UnitPrice DESC
limit 10;

-- Get the top 5 most recent orders
SELECT *
FROM orders
ORDER BY OrderDate DESC
limit 5;

-- get orders with customer names and employee names
SELECT o.OrderID, c.ContactName, CONCAT(e.FirstName, ' ', e.LastName) AS Fullname
FROM orders o
JOIN customers c
ON o.CustomerID = c.CustomerID
JOIN employees e
ON o.EmployeeID = e.EmployeeID;

-- Show each OrderID with productname and quantity
SELECT o.orderID, p.ProductName, od.Quantity
FROM orders o
JOIN orderdetails od 
ON o.OrderID = od.OrderID
JOIN products p
ON od.ProductID = p.ProductID
ORDER BY o.ORDERID asc;

-- Grouping OrderID with productname in one ROW
SELECT 
    o.OrderID,
    GROUP_CONCAT(p.ProductName, ' , Q: ', od.Quantity ORDER BY p.ProductName SEPARATOR ' | ') AS ProductList
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY o.OrderID;

-- Orders By Customers
SELECT CustomerID, Count(*) AS TotalOrders
FROM Orders
Group by CustomerID;

-- Find the avg unit price of products in each category
SELECT CategoryID, avg(UnitPrice) AS avg_unit_price
FROM products
GROUP BY CategoryID;

-- Show total sales by employee name
select e.employeeid as EmployeeID, CONCAT(e.FirstName,' ', e.LastName) AS EmployeeName, SUM(od.UnitPrice * od.Quantity) AS TotalSales, count(o.orderid) AS No_of_orders
from orderdetails od
join orders o
on od.OrderID = o.OrderID
join employees e
on e.employeeID = o.employeeID
GROUP BY e.employeeID, e.FirstName, e.Lastname;


-- Total Sales Per Order, Group By Employee
SELECT 
    e.EmployeeID, 
    e.FirstName, 
    e.LastName, 
    o.OrderID,
    SUM(od.UnitPrice * od.Quantity) AS OrderTotal
FROM OrderDetails od
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Employees e ON o.EmployeeID = e.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName, o.OrderID;

-- Number of orders place each month in 1996
SELECT MONTH(OrderDate) AS 1996_Month, COUNT(*) AS NumberofOrders
FROM orders
WHERE YEAR(OrderDate) = 1996
GROUP BY Month(OrderDate)
ORDER BY 1996_Month;

-- List all the orders shipped in december
SELECT *
From orders
WHERE MONTH(ShippedDate) = 12;

-- List products that cost more than avg product price
SELECT ProductName, UnitPrice, 
(select avg(UnitPrice)
from products) as avg_unitprice
from products
HAVING unitprice > avg_unitprice;

select ProductName, UnitPrice
from Products
WHERE UnitPrice > (Select avg(unitprice) from products);


-- Customers who never placed an order (NOT IN doesnt require a join, and its the same effect as leftjoin + using is null)
-- Both methods are valid. NOT IN is often faster and simpler when you're just checking for absence in a related table.
SELECT ContactName
FROM Customers
WHERE CustomerID NOT IN (SELECT DISTINCT CustomerID FROM Orders WHERE CustomerID IS NOT NULL);

SELECT c.ContactName, c.customerID
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;

-- For each employee, show how many orders they've handled and total revenue
select e.employeeid as EmployeeID, CONCAT(e.FirstName,' ', e.LastName) AS EmployeeName, SUM(od.UnitPrice * od.Quantity) AS TotalRevenue, count(distinct o.orderid) AS No_of_orders
from orderdetails od
join orders o
on od.OrderID = o.OrderID
join employees e
on e.employeeID = o.employeeID
GROUP BY e.employeeID, e.FirstName, e.Lastname
order by totalrevenue desc;


-- Show top 3 customer by total amount spend
select o.customerid, SUM(od.unitprice * od.quantity) as total_amount_spend
from orders o
join orderdetails od
on o.orderid = od.OrderID
group by o.CustomerID
order by total_amount_spend desc
limit 3;

-- OR
SELECT 
    c.CustomerID,
    c.ContactName,
    ROUND(SUM(od.UnitPrice * od.Quantity), 2) AS TotalSpent
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY c.CustomerID, c.ContactName
ORDER BY TotalSpent DESC
LIMIT 3;

-- Show each product's price along with the average price of its category
select ProductName, UnitPrice, CategoryID,
avg(UnitPrice) over(partition by CategoryID) as avg_price_category
from products;

-- Rank products by sales within each category
select p.ProductName, p.CategoryID, p.ProductID,
SUM(od.unitprice * od.quantity) as TotalSales,
dense_rank() over(partition by p.CategoryID ORDER BY SUM(od.unitprice * od.quantity) desc) as SalesRank
from products p
join orderdetails od
on p.ProductID = od.ProductID
group by p.ProductID,p.CategoryID, p.ProductName;

-- Rank sales by product (no need to partition + cause ranking overall + SQL cant recognize aggre in partition, so in this case use a sub query
select ProductName, TotalSales, ProductID,
dense_rank() OVER (ORDER BY TotalSales DESC) AS SalesRank
from (
SELECT 
p.ProductID,p.ProductName, 
SUM(od.unitprice * od.quantity) as TotalSales
FROM
products p
join orderdetails od
on p.ProductID = od.ProductID
group by p.ProductName,p.ProductID)
as sales_data;


-- Frequently ordered product (via ranking)
SELECT ProductID,
SUM(quantity) AS totalordered,
DENSE_RANK() OVER (ORDER BY SUM(quantity) DESC) as product_ranking
FROM orderdetails
GROUP BY productid;

-- Frequently ordered product (Name + ProductID)
SELECT od.productid, p.productname,
SUM(quantity) AS totalqty
FROM orderdetails od
JOIN products p
ON od.productid = p.productid
ORDER BY totalqty desc;

-- Determine which country generates the most revenue
SELECT o.ShipCountry, SUM(od.unitprice * od.quantity) AS totalrevenue,
DENSE_RANK() OVER(ORDER BY SUM(od.unitprice * od.quantity) DESC) AS ranking
FROM orders o
JOIN orderdetails od
ON o.OrderID = od.OrderID
GROUP BY o.ShipCountry;

-- Reorder rates of order
WITH ProductOrders AS (
SELECT 
ProductID,
COUNT(*) AS TotalOrders
FROM 
OrderDetails
GROUP BY 
ProductID
)
SELECT 
p.ProductID,
p.ProductName,
po.TotalOrders,
CASE 
WHEN po.TotalOrders > 1 THEN CAST((po.TotalOrders - 1) AS FLOAT) / po.TotalOrders
ELSE 0
END AS ReorderRate
FROM 
Products p
LEFT JOIN 
ProductOrders po ON p.ProductID = po.ProductID;
    


