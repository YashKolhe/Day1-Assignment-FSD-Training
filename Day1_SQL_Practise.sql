
/*  Practise
*/



select * from production.products

create procedure displayMessage
as
begin
print 'Welcome to FSD Training'
end
 exec displayMessage
 drop procedure displayMessage

 create procedure uspProductList
 as
 begin 
 select product_name,list_price from production.products
 order by product_name
 end 
 exec uspProductList

 alter procedure uspProductList
 as 
 begin
 select product_name,list_price from production.products
 order by product_name desc
 end

 create procedure uspFindProducts(@modelyear as int)
 as
 begin
 select * from production.products where model_year = @modelyear
 end
 exec uspFindProducts 2017

 create procedure uspFindProductsByRange(@minPrice decimal, @maxprice decimal)
 alter procedure uspFindProductsByRange(@minPrice decimal, @maxprice decimal)
 as 
 begin
 select * from production.products
 where list_price>=@minPrice and list_price<=@maxprice
 order by product_name desc
 end
 uspFindProductsByRange 1000,2000

 create procedure uspFindProductsByName(@minPrice decimal = 1000, @maxprice decimal,@name as varchar(max))
 as 
 begin
 select * from production.products
 where list_price>=@minPrice and list_price<=@maxprice and product_name like '%' + @name + '%'
 order by product_name desc
 end
 uspFindProductsByName  @maxprice=2000,@name = 'Trek'


 -- using out parameter

 create procedure uspFindProductCountByModelYear(@modelyear int , @productcount int output )
 as
 begin
 select product_name,list_price from production.products
 where model_year = @modelyear

 select @productcount = @@ROWCOUNT
 end
 declare @count int
 exec uspFindProductCountByModelYear @modelyear = 2016,@productcount = @count out

 select @count as 'Number of Products Found'



 create procedure getAllCustomers
 as
 begin
 select * from sales.customers
 end

 exec getAllCustomers


 create procedure getAllOrders(@customerId int)
 as
 begin
 select * from sales.orders where customer_id = @customerId
 end

 exec getAllOrders 1


 create proc uspGetAllCustOrders
 alter proc uspGetAllCustOrders (@customerId int)
 as 
 begin
 exec getAllCustomers
 exec getAllOrders @customerId
 end

 exec uspGetAllCustOrders 1


 --           DAY 1 ASSIGNMENT  


 /* Create a stored procedure,it should return a list of all customers who have purchased the specified product, 
including customer details like CustomerID, CustomerName, and PurchaseDate.
The procedure should take a ProductID as an input parameter.
*/
select * from sales.orders
select * from sales.order_items
select * from sales.customers
select * from production.products

create procedure getCustByProduct(@productId int)
alter procedure getCustByProduct(@productId int)

as
begin
select c.customer_id,c.first_name,c.last_name,o.order_date,p.product_name
from sales.customers as c
inner join sales.orders as o on c.customer_id = o.customer_id
inner join sales.order_items as oi on o.order_id = oi.order_id
inner join production.products as p on oi.product_id = p.product_id
group by c.customer_id,c.first_name,c.last_name,o.order_date,p.product_id,p.product_name
having p.product_id = @productId
end

exec getCustByProduct 3


/*CREATE TABLE Department with the below columns
  ID,Name
populate with test data
 
 
CREATE TABLE Employee with the below columns
  ID,Name,Gender,DOB,DeptId
populate with test data
 
a) Create a procedure to update the Employee details in the Employee table based on the Employee id.
b) Create a Procedure to get employee information bypassing the employee gender and department id from Employee table
c) Create a Procedure to get the Count of Employee based on Gender(input)
*/

create table Department
( Dept_ID int IDENTITY (1, 1) PRIMARY KEY,
Dept_Name varchar(30))

insert into Department
values
('Testing'),('FrontEnd'),('BackEnd'),('Production')
select * from Department

create table Employee
( Emp_ID int IDENTITY (1, 1) PRIMARY KEY,
Emp_name varchar(30),
Gender varchar(20),
DOB Datetime,
Dept_ID int Foreign key references Department(Dept_ID))
insert into Employee
values
('Sam','M','2000-11-20',2),
('David','M','2001-11-20',1),
('Lily','F','2000-11-20',3),
('Steve','M','2002-11-20',3),
('Sonia','F','2000-11-20',2),
('Chris','M','2003-11-20',1),
('Rahul','M','2002-11-20',2),
('Sofia','F','2001-11-20',1)

--a) Create a procedure to update the Employee details in the Employee table based on the Employee id.

create proc updEmpDet
@Emp_ID as int,
@Emp_name as varchar(30),
@Gender as varchar(20),
@DOB as Datetime,
@Dept_ID as int

as
begin
UPDATE Employee
        SET 
            Emp_name = @Emp_ID,
			Gender = @Gender,
			DOB = @DOB,
			Dept_ID = @Dept_ID
        WHERE 
            Emp_ID = @Emp_ID
end

exec updEmpDet 
@Emp_ID = 2,
@Emp_name = 'Raman',
@Gender = 'M',
@DOB = '2002-11-21',
@Dept_ID = 3

--b) Create a Procedure to get employee information bypassing employee gender and department id from Employee table
 create proc getEmpDet(@Gender as varchar(20),@Dept_ID as int)
 as
 begin
 select * from Employee
 where Gender = @Gender and Dept_ID = @Dept_ID
 end

 exec getEmpDet 'F',3

 --c) Create a Procedure to get the Count of Employee based on Gender(input)

 create proc getCountEmpByGender(@Gender as varchar(20))
 alter proc getCountEmpByGender(@Gender as varchar(20))
 as
 begin
 select count(Emp_ID) as Total_Count from Employee 
 where Gender = @Gender
 end

 exec getCountEmpByGender 'F';



 create function MSTVF_GetEmployee()
 returns @TempTable Table(ID int,name varchar(30),DOB Datetime)
 as
 begin
 insert into @TempTable
 select ID,name,cast(DOB as Datetime) from Employee
 return
 end

 select * from Employee



 --3 ) Create a user Defined function to calculate the TotalPrice based on productid and Quantity Products Table

 create function getTotalPrice
 (@ProductID int, @Quantity int)

 returns Decimal(12,2)
 as 
 begin
 Declare @TotalPrice Decimal(12,2)
 set @TotalPrice = 0
 select @TotalPrice = list_price * @Quantity
 from production.products
 where product_id = @ProductID
 return @TotalPrice
 end
 go
 Declare @ProductID int = 3;
 Declare @Quantity int = 8;
SELECT * from dbo.getTotalPrice(@ProductID,@Quantity) AS TotalPrice;

--4) create a function that returns all orders for a specific customer, including details such as 
--    OrderID, OrderDate, and the total amount of each order.
select * from sales.orders
select * from sales.order_items;

CREATE FUNCTION getOrderByCust(@CustomerID int)

returns table
as
return(
SELECT o.order_id,o.order_date, sum(oi.list_price*oi.quantity) as Total_price
FROM sales.orders as o
inner join sales.order_items as oi on o.order_id = oi.order_id
where o.order_id = @CustomerID
group by o.order_id,o.order_date
)
go

Declare @CustomerID int = 10
SELECT * from dbo.getOrderByCust(@CustomerID) as Orders






--5)create a Multistatement table valued function that calculates the total sales for each product,
--  considering quantity and price.

CREATE FUNCTION GetTotalSalesPerProd()
RETURNS @ProductSales TABLE
(
    ProductID INT,
    ProductName VARCHAR(100),
    TotalSales DECIMAL(10, 2)
)
AS
BEGIN
    -- Insert total sales per product into the table variable
    INSERT INTO @ProductSales (ProductID, ProductName, TotalSales)
    SELECT 
        P.product_id,
        P.product_name,
        SUM(OI.quantity * P.list_price) AS TotalSales
    FROM 
        production.products P
        INNER JOIN sales.order_items OI ON P.product_id = OI.product_id
    GROUP BY 
        P.product_id, P.product_name;

    RETURN;
END;

SELECT * FROM dbo.GetTotalSalesPerProd();

--6)create a  multi-statement table-valued function that lists all customers along with the total amount
 --  they have spent on orders.

CREATE FUNCTION GetTotalSpentByCust()
RETURNS @CustomerSpending TABLE
(
    CustomerID INT,
    CustomerName VARCHAR(100),
    TotalSpent DECIMAL(10, 2)
)
AS
BEGIN
    -- Insert customer spending details into the table variable
    INSERT INTO @CustomerSpending (CustomerID, CustomerName, TotalSpent)
    SELECT 
        C.customer_id,
        C.first_name,
        SUM(OI.quantity * P.list_price) AS TotalSpent
    FROM 
        sales.customers C
        INNER JOIN sales.orders O ON C.customer_id = O.customer_id
        INNER JOIN sales.order_items OI ON O.order_id = OI.order_id
        INNER JOIN production.products P ON OI.product_id = P.product_id
    GROUP BY 
        C.customer_id, C.first_name;

    RETURN;
END;
go
-- Get the total amount spent by all customers
SELECT * FROM dbo.GetTotalSpentByCust();
go
