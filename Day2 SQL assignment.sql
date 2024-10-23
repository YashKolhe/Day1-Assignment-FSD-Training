--          ASSIGNMENT DAY 2

/*7) Create a trigger to updates the Stock (quantity) table whenever new order placed in orders tables*/

CREATE TRIGGER UpdateStockAfterOrder
ON sales.order_items
AFTER INSERT
AS
BEGIN
DECLARE @ProductID INT, @Quantity INT

-- Get the inserted values
SELECT @ProductID = product_id, @Quantity = quantity
FROM inserted;

-- Update the stock in the production.stocks table
UPDATE production.stocks
SET quantity = quantity - @Quantity
WHERE product_id = @ProductID;
END;

SELECT * FROM production.stocks
SELECT * FROM sales.order_items

INSERT INTO sales.orders(customer_id, order_status, order_date, required_date, shipped_date, store_id, staff_id)
VALUES(23,4,'2024-10-23','2024-10-30','2024-10-25',1,5)


--8) Create a trigger to that prevents deletion of a customer if they have existing orders.
CREATE VIEW vWCustomerDetails
AS
SELECT 
    customer_id,
    first_name,
    last_name,
    phone,
    email,
    street,
    city,
    state,
    zip_code
FROM sales.customers


CREATE TRIGGER PreventCustomerDeletion
ON sales.customers
INSTEAD OF DELETE
AS
BEGIN
DECLARE @CustomerID INT;

-- Get the CustomerID from the deleted row
SELECT @CustomerID = customer_id
FROM deleted;

-- If no orders exist, proceed with deletion
DELETE FROM sales.customers WHERE customer_id = @CustomerID;
END


select * from vWCustomerDetails
select * from sales.orders
delete from vWCustomerDetails
where customer_id = 20

exec sp_tables 'dbo.Employee'

--9) Create Employee,Employee_Audit insert some test data   
--b) Create a Trigger that logs changes to the Employee Table into an Employee_Audit Table

CREATE TABLE Employee1 (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY, 
    FirstName NVARCHAR(50) NOT NULL,          
    HireDate DATE NOT NULL                   
);

CREATE TABLE Employee1Audit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,     
    EmployeeID INT NOT NULL,                 
    AuditDate DATETIME DEFAULT GETDATE()      
	)

	create trigger tgr_logchangesinEmployeeAudit
	on Employee1
	after insert,update,delete
	as begin
	insert into Employee1Audit(EmployeeID)
	select EmployeeID from inserted;

	insert into Employee1Audit(EmployeeID)
	select EmployeeID from deleted;

	end

	insert into Employee1 values ('YASH','2024-11-21'),('KOLHE','2024-12-21')
	select * from Employee1
	select * from Employee1Audit

	/*10) create Room Table with below columns
RoomID,RoomType,Availability
create Bookins Table with below columns
BookingID,RoomID,CustomerName,CheckInDate,CheckInDate
 
Insert some test data with both  the tables
Ensure both the tables are having Entity relationship
Write a transaction that books a room for a customer, ensuring the room is marked as unavailable.
*/

CREATE TABLE Room (
    RoomID INT IDENTITY(1,1) PRIMARY KEY,
    RoomType NVARCHAR(50) NOT NULL,
    Availability BIT NOT NULL DEFAULT 1 
);

CREATE TABLE Bookings (
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    RoomID INT NOT NULL,
    CustomerName NVARCHAR(100) NOT NULL,
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE NOT NULL,
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID)  
);

INSERT INTO Room (RoomType, Availability) VALUES ('Single', 1);
INSERT INTO Room (RoomType, Availability) VALUES ('Double', 0);
INSERT INTO Room (RoomType, Availability) VALUES ('Suite', 1);

BEGIN TRANSACTION;


IF EXISTS (SELECT 1 FROM Room WHERE RoomID = 1 AND Availability = 1)
BEGIN
  
INSERT INTO Bookings (RoomID, CustomerName, CheckInDate, CheckOutDate)
VALUES (1, 'Yash', '2024-10-21', '2024-10-31');

 
UPDATE Room
SET Availability = 0
WHERE RoomID = 1;

   
COMMIT TRANSACTION;
PRINT 'Room booked successfully and marked as unavailable';
END
ELSE
BEGIN
  
ROLLBACK TRANSACTION;
PRINT 'Room is already unavailable';
END;

select * from Room