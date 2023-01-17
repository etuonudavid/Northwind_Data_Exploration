-- Which shipers do we have?
Select *
From shippers;

-- Category Fields
Select CategoryName, Description
From categories;

--  Sales Representative and Hire date 
Select FirstName, LastName, HireDate
From employees
Where Title = 'Sales Representative';

-- Sales Rep From USA hire date
Select FirstName, LastName, HireDate
From employees
Where Country = 'USA' AND Title = 'Sales Representative';

-- Quick look at the orders of Employee wit ID of 5
Select OrderID, OrderDate
From orders
Where EmployeeID = 5;

-- All Supppliers that are not Marketing Managers
Select SupplierID, ContactName, ContactTitle
From Suppliers
Where ContactTitle <> 'Marketing Manager';

-- Selecting Products having queso in the name
 Select ProductID, ProductName
 From products
 Where ProductName LIKE '%queso%';
 
-- Select orders with ship countries from France and Belgium
Select OrderID, CustomerID, ShipCountry
From orders 
Where ShipCountry IN ('France', 'Belgium');

-- Select orders with ship countries from Brazil, Mexico, Argentina and Venezuela
Select OrderID, CustomerID, ShipCountry
From orders 
Where ShipCountry IN ('Brazil', 'Mexico', 'Argentina', 'Venezuela');


-- Employees and their birthdate
Select FirstName, LastName, Title, BirthDate
From employees 
Order by BirthDate;

-- Showing only the Date with a DateTime field
Select FirstName, LastName, Title, cast(BirthDate as date) as Birthdate, convert(Birthdate, date) as 'Alternative Birthdate'
From employees 
Order by BirthDate;

-- Employees full name
Select FirstName, LastName, concat(FirstName, ' ', LastName) as FullName
From employees;

-- OrderDetails amount per line item
Select OrderID, ProductID, UnitPrice, Quantity, UnitPrice * Quantity as Total
From northwind.`order details`
Order by OrderID, ProductID;

-- How many customers?
Select count(CustomerID)
From customers;

-- When was the first order?
Select MIN(cast(OrderDate as date))
From orders;

-- Countries where there are customers
Select distinct Country as Country
From customers
Order by Country;

-- count of Contact titles for customers
Select ContactTitle, count(ContactTitle)
From customers
Group By ContactTitle;

-- Products with associated suppliernames
Select p.ProductID, p.ProductName, s.CompanyName
From products as p
Join suppliers as s
On s.SupplierID = p.SupplierID;

-- Orders and the Shipper that was used
Select o.OrderID, cast(o.OrderDate as date), s.CompanyName
From orders as o
Join shippers as s
On o.ShipVia = s.ShipperID
where o.OrderID < 10300
Order by o.OrderID;

 -- Categories, and the total products in each category
 Select c.CategoryName, count(p.ProductName) as count
 From products as p
 Join categories as c
 On p.CategoryID = c.CategoryID
 Group By c.CategoryName
 Order by count Desc;
 
 -- Total customers per country/city
Select Country, City, count(*) as count
From customers
Group By Country, City
Order by count desc;

-- Products that need reordering
Select ProductName, UnitsInStock, ReorderLevel
From products
Where UnitsInStock < ReorderLevel;


-- Products that need reordering using Reorderlevel and Discontinued
Select ProductName, UnitsInStock, UnitsOnOrder,ReorderLevel, Discontinued
From products
Where (UnitsInStock + UnitsOnOrder) <= ReorderLevel
and Discontinued = 0;

-- Customer list by region
Select CustomerID, CompanyName, Region, 
Case when Region IS NULL then 1
When Region is not null then 0 end as region_sort
From customers
Order by region_sort asc, Region ASC, CompanyName;

-- top 3 Shiping countries with High freight charges
Select ShipCountry, avg(Freight) as freight
From orders
Group By ShipCountry
Order by freight DESC
Limit 3;

-- High freight charges for the year 1995
Select ShipCountry, avg(Freight) as freight
From orders
where extract(year from OrderDate) = '1995'
Group By ShipCountry
Order by freight DESC
Limit 3;


-- High freight charges for the last year of the dataset
Select ShipCountry, OrderDate
From orders
Where OrderDate >= date_sub(max(OrderDate), INTERVAL 1 YEAR)
group by ShipCountry;

-- Inventory list
Select e.EmployeeID, e.LastName, p.ProductName,	o.OrderID, `order details`.Quantity 
From products as p
Join `order details` 
on p.ProductID = `order details`.ProductID
Join orders as o
on o.OrderID = `order details`.OrderID
Join employees as e
on e.EmployeeID = o.EmployeeID
Order by o.OrderID;


-- Customers with no orders
Select customerID
From customers
Where CustomerID NOT IN
(Select customerID
From orders);

-- Customers with no orders alternative method
Select c.CustomerID, o.OrderID
From customers as c
LEFT JOIN orders as o
ON c.CustomerID = o.CustomerID
Where o.OrderID is NULL;

-- Customers with no orders for EmployeeID 4
Select customerID
From orders
Where EmployeeID <> 4;

-- High-value customers - customers who have purchased up to $10,000 without discounts in 1996
Select o.CustomerID, count(*) as Orders, sum(`order details`.Discount) as Discounts, sum(`order details`.UnitPrice * `order details`.Quantity) as Price 
From (
	Select *
    From orders
    Where OrderDate >= '1996-01-01' and OrderDate <= '1996-12-31'
) as o
Join `order details`
on o.OrderID = `order details`.OrderID
group by o.CustomerID
Having Discounts = 0 and Price >= 10000;

-- High-value customers - customers who have purchased up to $15,000 without discounts in 1996
Select o.CustomerID, count(*) as Orders, sum(`order details`.Discount) as Discounts, sum(`order details`.UnitPrice * `order details`.Quantity) as Price 
From (
	Select *
    From orders
    Where OrderDate >= '1996-01-01' and OrderDate <= '1996-12-31'
) as o
Join `order details`
on o.OrderID = `order details`.OrderID
group by o.CustomerID
Having Discounts = 0 and Price >= 15000;

-- High-value customers - customers who have purchased up to $15,000 with discounts in 1996
Select o.CustomerID, count(*) as Orders, sum(`order details`.Discount) as Discounts, sum(`order details`.UnitPrice * `order details`.Quantity * (1-`order details`.Discount)) as Price 
From (
	Select *
    From orders
    Where OrderDate >= '1996-01-01' and OrderDate <= '1996-12-31'
) as o
Join `order details`
on o.OrderID = `order details`.OrderID
group by o.CustomerID
Having Price >= 15000;

-- Month-end orders
Select EmployeeID, OrderID, Last_day(OrderDate)
From orders;

-- Orders with many line items
Select o.OrderID, count(*) as count
From `order details`
Join orders as o
on `order details`.OrderID = o.OrderID
group by o.OrderID
Order by count Desc
Limit 10;

-- Orders - randomize the ordering
Select OrderID
From orders
order by RAND()
Limit 20;

-- accidental double-entry: a single item entered twice with different ID numbers and same quantity of 60
Select OrderID, Quantity
From `order details`
where Quantity >= 60 and OrderID in (
	Select OrderID
	From (Select *
		  From `order details`
          Where Quantity >=60  
        ) as tab1
group by OrderID
Having count(*) > 1 
)
Order by OrderID;

-- details of the double entry
 Select OrderID, Quantity, Discount, ProductID, UnitPrice
From `order details`
where Quantity >= 60 and OrderID in (
	Select OrderID
	From (Select *
		  From `order details`
          Where Quantity >=60  
        ) as tab1
group by OrderID
Having count(*) > 1 
)
Order by OrderID;
 
 -- Which orders are late?
 Select OrderID, OrderDate, cast(RequiredDate as date) as Required, cast(ShippedDate as date) as Shipped
 From orders
Where cast(RequiredDate as date) < cast(ShippedDate as date);

-- which empployee has regular late orders
 Select tab.EmployeeID, e.LastName ,count(*) as Total_Late_Orders
 From (
	 Select *
	 From orders
	 Where cast(RequiredDate as date) < cast(ShippedDate as date)
 ) as tab
 Join employees as e
 on tab.EmployeeID = e.EmployeeID
 group by tab.EmployeeID
 Order by Total_Late_Orders Desc;
 
 -- How many orders has the employees made vs the late orders they made also
 with late as (
  Select tab.EmployeeID, e.LastName ,count(*) as Total_Late_Orders
 From (
	 Select *
	 From orders
	 Where cast(RequiredDate as date) < cast(ShippedDate as date)
 ) as tab
 Join employees as e
 on tab.EmployeeID = e.EmployeeID
 group by tab.EmployeeID
 Order by Total_Late_Orders Desc 
 ),
 total_orders as (
 Select o.EmployeeID, e.LastName, Count(*) as Total_Orders
 From orders as o
 Join employees as e
 on o.EmployeeID = e.EmployeeID
 group by o.EmployeeID
 )
 
 Select l.EmployeeID, l.LastName, l.Total_Late_Orders, t.Total_Orders
 From late as l
 Left join total_orders as t
 on l.EmployeeID = t.EmployeeID AND l.LastName = t.LastName;

-- removing null from the previous question
 Select l.EmployeeID, l.LastName, l.Total_Late_Orders, coalesce(t.Total_Orders, 0) 
 From late as l
 Left join total_orders as t
 on l.EmployeeID = t.EmployeeID AND l.LastName = t.LastName;
 
 -- Late orders vs. total orders - percentage
  Select l.EmployeeID, l.LastName, l.Total_Late_Orders, coalesce(t.Total_Orders, 0) as Total_Orders, (l.Total_Late_Orders / coalesce(t.Total_Orders, 0))*100 as Percentage
 From late as l
 Left join total_orders as t
 on l.EmployeeID = t.EmployeeID AND l.LastName = t.LastName;
 
 -- Late orders vs. total orders just as float %
Select l.EmployeeID, l.LastName, l.Total_Late_Orders, coalesce(t.Total_Orders, 0) as Total_Orders, round(cast(l.Total_Late_Orders / coalesce(t.Total_Orders, 0) as float), 2) as Percentage
 From late as l
 Left join total_orders as t
 on l.EmployeeID = t.EmployeeID AND l.LastName = t.LastName;
 
 -- Customer Groupings - very High value, high value, medium value and low value customers in 1995
 Select *, 
Case When Total_Order_Amount >= 0 AND Total_Order_Amount < 1000 THEN 'Low'
	  When Total_Order_Amount >= 1000 AND Total_Order_Amount < 5000 THEN 'Medium' 
      When Total_Order_Amount >= 5000 AND Total_Order_Amount < 10000 THEN 'High'
      When Total_Order_Amount > 10000 THEN 'Very High'
      end as CustomerGroup
From (
Select o.CustomerID, c.CompanyName,sum(`order details`.Quantity * `order details`.UnitPrice) as Total_Order_Amount, o.OrderDate as dates
From `order details`
join orders as o
on `order details`.OrderID = o.OrderID
Join customers as c
on c.CustomerID = o.CustomerID
group by o.CustomerID
Order by Total_Order_Amount) as tab1
Where extract(year from dates) = 1995;

-- fixing the null of the previous questions
 Select *, 
 Case When Total_Order_Amount >= 0 AND Total_Order_Amount < 1000 THEN 'Low'
	  When Total_Order_Amount >= 1000 AND Total_Order_Amount < 5000 THEN 'Medium' 
      When Total_Order_Amount >= 5000 AND Total_Order_Amount < 10000 THEN 'High'
      When Total_Order_Amount > 10000 THEN 'Very High'
      end as CustomerGroup
From (
Select o.CustomerID, c.CompanyName,sum(`order details`.Quantity * `order details`.UnitPrice) as Total_Order_Amount, o.OrderDate as dates
From `order details`
join orders as o
on `order details`.OrderID = o.OrderID
Join customers as c
on c.CustomerID = o.CustomerID
group by o.CustomerID
Order by Total_Order_Amount) as tab1
Where extract(year from dates) = 1995 and CustomerGroup IS NOT NULL;

-- Customer grouping with percentage
Select CustomerGroup, count(*)
From(
 Select *, 
 Case When Total_Order_Amount >= 0 AND Total_Order_Amount < 1000 THEN 'Low'
	  When Total_Order_Amount >= 1000 AND Total_Order_Amount < 5000 THEN 'Medium' 
      When Total_Order_Amount >= 5000 AND Total_Order_Amount < 10000 THEN 'High'
      When Total_Order_Amount > 10000 THEN 'Very High'
      end as CustomerGroup
From (
Select o.CustomerID, c.CompanyName,sum(`order details`.Quantity * `order details`.UnitPrice) as Total_Order_Amount, o.OrderDate as dates
From `order details`
join orders as o
on `order details`.OrderID = o.OrderID
Join customers as c
on c.CustomerID = o.CustomerID
group by o.CustomerID
Order by Total_Order_Amount) as tab1
Where extract(year from dates) = 1995) as tab2
group by CustomerGroup;


-- Countries with suppliers or customers
with countries as (Select Country
From customers
Union
Select ShipCountry as Country
From orders)

Select distinct Country
From countries
Order by Country;

-- Countries with suppliers or customers - version 2
with customerCountry as (
Select Country
From customers
), 
supplierCountry as (
	Select Country
    From suppliers
)

Select *
From customerCountry as c
Join supplierCountry as s
On c.Country = s.Country;

-- Countries with suppliers or customers -version 3
with customerCountry as (
Select Country, count(*) as Total_Customers
From customers
group by Country
), 
supplierCountry as (
	Select Country, count(*) as Total_Supplier
    From suppliers
    group by Country
    
)

Select c.Country, c.Total_Customers, s.Total_Supplier
From customerCountry as c
Join supplierCountry as s
On c.Country = s.Country
Order by c.Country;

-- First order in each country
with Orders as ( Select CustomerID, OrderID, ShipCountry, cast(OrderDate as date) as OrderDate, row_number() Over(partition by ShipCountry order by cast(OrderDate as date)) as row_num
From orders
Order by ShipCountry, cast(OrderDate as date))

Select *
From Orders
Where row_num = 1;

-- Customers with multiple orders in 5 day period,
with Orders as (Select CustomerID, cast(OrderDate as date) as orderdate, lead(cast(OrderDate as date), 1) over(partition by CustomerID Order by CustomerID) as NextOrder
From orders)

Select CustomerID, orderdate, NextOrder, datediff(NextOrder, orderdate)
From Orders
Where datediff(NextOrder, orderdate) <= 5






