CREATE DATABASE LincolnGardenCentre;

USE LincolnGardenCentre;

SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE Supplier (
Supplier_ID int NOT NULL AUTO_INCREMENT, 
Supplier_Name varchar(255) NOT NULL, 
Tel_Number int UNIQUE NOT NULL, 
Address_Line1 varchar(255) NOT NULL, 
Address_Line2 varchar(255), 
City varchar(255), 
Postcode varchar(255) NOT NULL, 
Email varchar(255) UNIQUE NOT NULL,

CONSTRAINT Unique_Supplier UNIQUE (Email, Tel_Number),

CONSTRAINT
PK_Supplier PRIMARY KEY
(Supplier_ID)
);

CREATE TABLE Employee (
Employee_ID int NOT NULL AUTO_INCREMENT, 
Email varchar(255) UNIQUE NOT NULL,
F_Name varchar(255),
L_Name varchar(255) NOT NULL,
Department varchar(255) NOT NULL, 
Contract_Hours INT NOT NULL,
National_Insurance_Number varchar(9) UNIQUE NOT NULL, 
Job_Title varchar(255) NOT NULL, 
Date_Joined DATE,

CONSTRAINT Unique_Employee UNIQUE (Email, National_Insurance_Number),

CONSTRAINT
PK_Employee PRIMARY KEY
(Employee_ID)
);

CREATE TABLE Training (
Employee_ID int NOT NULL,
Training varchar(255),

CONSTRAINT
PK_Training PRIMARY KEY
(Training),

CONSTRAINT
FK_Training_Employee FOREIGN KEY
(Employee_ID)
REFERENCES
Employee(Employee_ID) 
ON DELETE CASCADE
ON UPDATE CASCADE
); 

CREATE TABLE Customer (
Customer_ID int NOT NULL AUTO_INCREMENT, 
Email varchar(255) UNIQUE NOT NULL,
F_Name varchar(255),
L_Name varchar(255) NOT NULL,
Address_Line1 varchar(255) NOT NULL, 
Address_Line2 varchar(255), 
City varchar(255), 
Postcode varchar(255) NOT NULL, 
Customer_Type varchar(255) NOT NULL,
Tel_Number varchar(20) UNIQUE NOT NULL,

CONSTRAINT Unique_Customer UNIQUE (Email, Tel_Number),

CONSTRAINT
PK_Product PRIMARY KEY
(Customer_ID)
);

CREATE TABLE Product (
Product_ID int NOT NULL AUTO_INCREMENT, 
Supplier_ID int, 
Item_Name varchar(255) NOT NULL, 
Scientific_Name varchar(255), 
Description varchar(255), 
Price double NOT NULL, 
Stock_Quantity int NOT NULL, 
Item_Category varchar(255) NOT NULL, 
Soil_Type varchar(255),
Season_Of_Growth varchar(255), 
Aftercare varchar(255),
Sunlight varchar(255),

CONSTRAINT
PK_Product PRIMARY KEY
(Product_ID),

CONSTRAINT
FK_Product_Supplier FOREIGN KEY
(Supplier_ID)
REFERENCES
Supplier(Supplier_ID) 
ON DELETE SET NULL
ON UPDATE CASCADE
);

CREATE TABLE Customer_Order (
Customer_Order_ID int NOT NULL AUTO_INCREMENT, 
Customer_ID int, 
Employee_ID int, 
Product_ID int, 
Quantity int NOT NULL,
Discount int DEFAULT 0,
Order_Date DATE NOT NULL,
Dispatch_Date DATE,
Invoice_Sent_Date DATE,
Payment_Date DATE,
Order_Status varchar(255) NOT NULL DEFAULT 'Pending',
Total_Price double NOT NULL,

CONSTRAINT
PK_Customer_Order PRIMARY KEY
(Customer_Order_ID),

CONSTRAINT
FK_Customer_Order_Customer FOREIGN KEY
(Customer_ID)
REFERENCES
Customer(Customer_ID) 
ON DELETE SET NULL
ON UPDATE CASCADE,

CONSTRAINT
FK_Customer_Order_Employee FOREIGN KEY
(Employee_ID)
REFERENCES
Employee(Employee_ID) 
ON DELETE SET NULL
ON UPDATE CASCADE,

CONSTRAINT
FK_Customer_Order_Product FOREIGN KEY
(Product_ID)
REFERENCES
Product(Product_ID) 
ON DELETE SET NULL
ON UPDATE CASCADE
);

CREATE TABLE Purchase_Order (
Purchase_Order_ID int NOT NULL AUTO_INCREMENT, 
Supplier_ID int, 
Employee_ID int, 
Product_ID int, 
Quantity int NOT NULL,
Order_Date DATE NOT NULL,
Order_Recieved_Date DATE,
Payment_Date DATE,
Order_Status varchar(255) NOT NULL DEFAULT 'Pending',
Total_Price double NOT NULL,

CONSTRAINT
PK_Purchase_Order PRIMARY KEY
(Purchase_Order_ID),

CONSTRAINT
FK_Purchase_Order_Supplier FOREIGN KEY
(Supplier_ID)
REFERENCES
Supplier(Supplier_ID) 
ON DELETE SET NULL
ON UPDATE CASCADE,

CONSTRAINT
FK_Purchase_Order_Employee FOREIGN KEY
(Employee_ID)
REFERENCES
Employee(Employee_ID)
ON UPDATE CASCADE,

CONSTRAINT
FK_Purchase_Order_Product FOREIGN KEY
(Product_ID)
REFERENCES
Product(Product_ID) 
ON DELETE SET NULL
ON UPDATE CASCADE
);

SET FOREIGN_KEY_CHECKS = 1;

ALTER TABLE Customer
ADD Discount int;

ALTER TABLE Customer
ALTER Discount SET DEFAULT 0;

ALTER TABLE Product
DROP COLUMN Sunlight;

ALTER TABLE Customer_Order
DROP COLUMN Discount;

ALTER TABLE Supplier
ADD County varchar(255);

ALTER TABLE Customer
ADD County varchar(255);

ALTER TABLE Supplier
MODIFY COLUMN Tel_Number varchar(20);

ALTER TABLE Training
DROP PRIMARY KEY;

ALTER TABLE Training
ADD CONSTRAINT PK_Training PRIMARY KEY (Employee_ID, Training);

--procedure that inserts two given values into the training table, and checks for duplicates
DELIMITER $$
CREATE PROCEDURE Insert_Training(IN Employee_ID int, IN Training varchar(255))
BEGIN
 DECLARE EXIT HANDLER FOR 1062 SELECT 'duplicate keys were encountered';
 
 INSERT INTO Training(Employee_ID, Training)
 VALUES(Employee_ID, Training);
 
 SELECT COUNT(*) FROM Training;
END $$
DELIMITER ;

INSERT INTO Supplier (Supplier_Name, Tel_Number, Address_Line1, Address_Line2, City, County, Postcode, Email)
VALUES ('Lincoln Flower Supplier', '07654321234', '6 Silver Street', NULL, 'Lincoln', 'Lincolnshire', 'LN2 5AQ', 'lincolnflowersuppliers@lfs.co.uk'),
('Garden Gifts', '07987654321', '25 Monks Road', NULL, 'Boston', 'Lincolnshire', 'PE21 0OP', 'GardenGifts@GardenG.co.uk'),
('Plants and pleasantries', '07766554433', '12 Nettleham Road', NULL, 'Grantham', 'Lincolnshire', 'NG31 6BG', 'plantsandpleasantries@pap.co.uk'),
('Sapling Supplier', '07112233445', '2 Long Lays Road', NULL, 'Nottingham', 'Nottinghamshire', 'NG1 1NG', 'saplingsupplier@ssupplier.co.uk'),
('Newark Flora', '07135798642', '8 Washingborough Road', NULL, 'Newark-on-Trent', 'Nottinghamshire', 'NG24 1DU', 'lincolnflora@lincolnf.co.uk'),
('The Outdoor Supplies co', '07603445566', '5 old Street', NULL, 'Doncaster', 'South Yorkshire', 'DN5 7PQ', 'Outdoorsupplies@outdoor.co.uk');


INSERT INTO Employee (Email, F_Name, L_Name, Department, Contract_Hours, National_Insurance_Number, Job_Title, Date_Joined)
VALUES ('D.Killingham@lgc.co.uk', 'Dave', 'Killingham', 'Advertising', 30, 'HH112233K', 'Advertising Manager', '2014-10-04' ),
('K.Smith@lgc.co.uk', 'Kyle', 'Smith', 'IT', 36, 'PP445566B', 'Website Maintenance', '2016-08-14' ),
('H.Prescott@lgc.co.uk', 'Hannah', 'Prescott', 'Retail', 38, 'LL778899F', 'Sales Associate', '2015-03-30' ),
('M.Crawford@lgc.co.uk', 'Maisy', 'Crawford', 'Retail', 36, 'CC123456L', 'Sales Associate', '2017-07-22' ),
('L.Brody@lgc.co.uk', 'Lindsay', 'Brody', 'Retail', 40, 'KK987654Q', 'Store Manager', '2013-06-06' ),
('B.Tanner@lgc.co.uk', 'Betty', 'Tanner', 'Stock Management', 40, 'LL135792Y', 'Buyer', '2014-10-4' ),
('J.Cox@lgc.co.uk', 'James', 'Cox', 'Security', 42, 'AA246801J', 'Security Guard', '2015-10-4' ),
('T.Bradley@lgc.co.uk', 'Thomas', 'Bradley', 'Stock Management', 26, 'BB192837G', 'Warehouse Operative', '2016-01-24' ),
('J.Day@lgc.co.uk', 'Jack', 'Day', 'Retail', 38, 'MM918273K', 'Part Time Sales Associate', '2017-11-09' );


INSERT INTO customer (Email, F_Name, L_Name, Address_Line1, Address_Line2, City, County, Postcode, Customer_Type, Discount, Tel_Number)
VALUES ('JennyWest86@outlook.com', 'Jennifer', 'West', '13 Monks Road', NULL, 'Lincoln', 'Lincolnshire', 'LN2 6PB', 'Pay as you go', 0, '07543281122'),
('GreenMan@hotmail.com', 'Joe', 'Green', '12 Carholme Road', NULL, 'Lincoln', 'Lincolnshire', 'LN4 8KL', 'Pay as you go', 0, '07098976786'),
('Alex.Shaw@gmail.com', 'Alex', 'Shaw', '3 South Park Avenue', NULL, 'Lincoln', 'Lincolnshire', 'LN5 6KB', 'Pay as you go', 0, '07145476897'),
('OJT.Work@outlook.com', 'Oliver', 'Tanner', '27 Alexandra Terrace', NULL, 'Lincoln', 'Lincolnshire', 'LN3 5OL', 'Pay as you go', 0, '07035539506'),
('Blart199286@gmail.com', 'Paul', 'Blart', '3 Box Avenue', NULL, 'Newark-on-Trent', 'Nottinghamshire', 'NG24 1FX', 'Contract', 5, '07867564533'),
('HarryBlackadder@outlook.com', 'Alexander', 'Blackadder', '3 Campus Way', 'Apartment 3', 'Lincoln', 'Lincolnshire', 'LN6 7FX', 'Pay as you go', 0, '07869485080'),
('TheOfficialMaxWest@hotmail.com', 'Max', 'West', '25 New Lane', NULL, 'Gainsbrough', 'Lincolnshire', 'DN21 1HA', 'Pay as you go', 0, '07345678745'),
('BarryBB@Gmail.com', 'Barry', 'Benson', '13 Bridge Way', 'Apartment 7', 'Lincoln', 'Lincolnshire', 'LN2 0PG', 'Pay as you go', 0, '07777888877'),
('JT.Work@outlook.com', 'Jayne', 'Tanner', '27 Alexandra Terrace', NULL, 'Lincoln', 'Lincolnshire', 'LN3 5OL', 'Contract', 10, '07123323232'),
('CameronTailor@btinternet.com', 'Cameron', 'Tailor', '32 Peters Walk', NULL, 'Saxilby', 'Lincolnshire', 'LN1 2HP', 'Contract', 5, '07009900990');


CALL  insert_Training(1, 'Advertising');
CALL  insert_Training(1, 'Office');
CALL  insert_Training(1, 'Photoshop');
CALL  insert_Training(2, 'IT');
CALL  insert_Training(2, 'Office');
CALL  insert_Training(3, 'Till');
CALL  insert_Training(3, 'Shop floor');
CALL  insert_Training(3, 'product Inspection');
CALL  insert_Training(4, 'Till');
CALL  insert_Training(4, 'Shop floor');
CALL  insert_Training(5, 'Till');
CALL  insert_Training(5, 'Shop floor');
CALL  insert_Training(5, 'product Inspection');
CALL  insert_Training(5, 'Store Management');
CALL  insert_Training(5, 'Stock Management');
CALL  insert_Training(6, 'Stock Management');
CALL  insert_Training(6, 'negotiation');
CALL  insert_Training(7, 'Self Defense');
CALL  insert_Training(7, 'Pearson BTEC');
CALL  insert_Training(8, 'Warehouse training');
CALL  insert_Training(8, 'RTITB Forklift Training Course');
CALL  insert_Training(9, 'Till');


INSERT INTO Product (Supplier_ID, Item_Name, Scientific_Name, Description, Price, Stock_Quantity, Item_Category, Soil_Type, Season_Of_Growth, Aftercare)
VALUES (1, 'Rose', 'Rosa', 'Woody perennial flowering plant', 2.99, 75, 'flower', 'Chalk/ Loam/ Sand/ Clay', 'autumn - summer', 'Mulch with organic matter then feed every fortnight' ),
(4, 'Magnolia Black Tulip', 'Magnoliaceae', 'vigorous, upright, open-branched, deciduous tree', 29.99, 14, 'tree', 'loam/ clay/ sand', 'autumn - summer', 'Low Maintenance Wall-side Borders and pruning should be carried out in midsummer' ),
(1, 'Cow Parsley', 'Apiaceae', 'common British wild plant', 1.99, 30, 'flower', 'Chalk/ Loam/ Sand/ Clay', 'spring - summer', 'Deadhead to prevent prolific self-seeding' ),
(1, 'chrysanthemum', 'Asteraceae', 'cultivar that reaches 90cm in height', 4.99, 45, 'flower', 'Loam', 'autumn - summer', 'water regularly and feed until flower buds colour up' ),
(6, 'yellow berried rowan', 'Rosaceae', 'medium-sized deciduous tree', 34.99, 5, 'tree', 'loam/ clay/ sand', 'autumn - summer', 'Grow in moderately fertile and humus-rich soil' ),
(3, 'monkey puzzle', 'Araucariaceae', 'evergreen tree with sharply pointed leaves', 39.99, 10, 'tree', 'loam/ chalk/ sand', 'autumn - winter', 'Grow in moderately fertile well drained soil with shelter from cold' ),
(2, 'dwarf Russian almond', 'Rosaceae', 'small deciduous shrub with narrow, glossy dark green leaves', 10.99, 23, 'shrub', 'Chalk/ Loam/ Sand/ Clay', 'autumn - summer', 'grow in any moist but well-drained moderately fertile soil' ),
(5, 'rosemary', 'Lamiaceae', 'evergreen shrubs with narrow aromatic leaves', 8.99, 29, 'shrub', 'Chalk/ Loam/ Sand/ Clay', 'autumn - winter', 'Prefers poor, well-drained soil' ),
(5, 'clematis', 'Ranunculaceae', 'vigorous deciduous climber with finely-cut leaves', 14.99, 1, 'climber', 'Chalk/ Loam/ Sand/ Clay', 'autumn - summer', 'Plant in a moisture-retentive well-drained soil next to a wall' ),
(3, 'daffodil', 'Amaryllidaceae', 'large-cupped daffodil with shapely pure white flowers', 2.49, 30, 'flower', 'Chalk/ Loam/ Sand/ Clay', 'spring', 'Will tolerate most soils but prefers moderately fertile well-drained soil' );


INSERT INTO Customer_Order (Customer_ID, Employee_ID, Product_ID, Quantity, Order_Date, Dispatch_Date, Invoice_Sent_Date, Payment_Date, Order_Status, Total_Price)
VALUES (1, 3, 1, 2, '2016-12-20', '2016-12-22', '2016-12-22', '2016-12-20', 'Completed', 5.98),
(9, 5, 8, 4, '2017-08-02', '2017-08-05', '2017-08-05', '2017-08-02', 'Completed', 32.36),
(3, 3, 5, 1, '2017-02-27', '2017-03-02', '2017-02-02', '2017-03-27', 'Completed', 34.99),
(6, 9, 3, 10, '2018-01-02', NULL, NULL, '2018-01-02', 'Paid', 19.90),
(7, 9, 7, 2, '2018-01-02', NULL, NULL, NULL, 'Pending', 21.98),
(2, 9, 1, 8, '2017-11-10', '2017-11-14', '2017-11-14', '2017-11-10', 'Completed', 23.92),
(10, 4, 2, 2, '2017-10-13', '2017-10-17', '2017-10-18', '2017-10-13', 'Completed', 56.98),
(5, 5, 9, 1, '2017-12-30', "2018-01-03", NULL, '2017-12-30', 'dispatched', 14.24),
(4, 4, 6, 1, '2018-01-03', NULL, NULL, '2018-01-03', 'Paid', 39.99),
(8, 5, 4, 3, '2016-12-21', '2016-12-28', '2016-12-28', '2016-12-21', 'Completed', 14.97),
(2, 3, 10, 2, '2017-04-01', '2017-04-05', '2017-04-06', '2017-04-01', 'Completed', 4.98);


INSERT INTO Purchase_Order (Supplier_ID, Employee_ID, Product_ID, Quantity, Order_Date, Order_Recieved_Date, Payment_Date, Order_Status, Total_Price)
VALUES (1, 6, 1, 25, '2017-01-25', '2017-02-04', '2017-02-04', 'Completed', 25),
(5, 6, 9, 15, '2018-01-05', NULL, '2018-01-05', 'Paid', 30),
(3, 6, 6, 5, '2016-10-25', '2016-10-30', '2016-10-30', 'Completed', 75),
(3, 6, 10, 20, '2017-06-06', '2017-06-13', '2017-06-06', 'Completed', 5),
(4, 6, 2, 10, '2018-01-04', NULL, NULL, 'Dispatched', 100),
(2, 5, 7, 5, '2017-03-05', '2017-03-06', '2017-03-05', 'Completed', 25),
(6, 6, 5, 5, '2016-12-10', '2017-12-12', '2017-12-12', 'Completed', 50),
(5, 6, 8, 25, '2016-09-21', '2016-09-25', '2016-09-21', 'Completed', 50),
(1, 6, 1, 25, '2017-11-05', '2017-11-14', '2017-11-10', 'Completed', 25),
(1, 6, 4, 15, '2018-01-06', NULL, NULL, 'Pending', 30);

-- updates the address of a customer
UPDATE customer
SET City = 'Doncaster', Address_Line1 = '25 New Lane', County = 'South Yorkshire', Postcode = 'DN5 7RR'
WHERE Email = 'Alex.Shaw@gmail.com';

-- updated the date and status of an order now that it is completed
UPDATE Purchase_Order
SET Order_Recieved_Date = '2018-01-07', Order_Status = 'Completed'
WHERE Purchase_Order_ID = 2;

--changes the price of a product
UPDATE Product
SET Price = 29.99
WHERE Item_Name = 'yellow berried rowan';

--changes the street number for current residents of '27 Alexandra Terrace'
UPDATE customer
SET Address_Line1 = '24 Alexandra Terrace'
WHERE Address_Line1 = '27 Alexandra Terrace';

--Delete the records of a employee
DELETE FROM Employee
WHERE (F_Name = 'Jack' AND L_Name = 'Day');

-- inner join that returns all orders with the corresponding customer that placed it
SELECT Customer_Order.Customer_Order_ID, Customer.F_Name, Customer.L_Name
FROM Customer_Order
INNER JOIN Customer ON Customer_Order.Customer_ID = Customer.Customer_ID;

--left join that returns all purchase orders and what suppliers they came from
SELECT Supplier.Supplier_Name, Purchase_Order.Purchase_Order_ID
FROM Supplier
LEFT JOIN Purchase_Order ON supplier.Supplier_ID = Purchase_Order.Supplier_ID
ORDER BY Purchase_Order.Purchase_Order_ID;

--Right join that returns all suppliers and the items that they supply
SELECT Product.Item_Name, Supplier.Supplier_ID
FROM Product
RIGHT JOIN Supplier ON Product.Supplier_ID = supplier.Supplier_ID
ORDER BY Product.Item_Name;

--UNION that selects the total price and order date for both cusomer orders and purchase orders for all orders in 2017
SELECT Total_Price, Order_Date FROM Customer_Order
WHERE (Order_Date >= '2017-01-01' AND Order_Date < '2018-01-01')
UNION ALL
SELECT Total_Price, Order_Date FROM Purchase_Order
WHERE (Order_Date >= '2017-01-01' AND Order_Date < '2018-01-01')
ORDER BY (Order_Date);

CREATE TABLE Copy_of_Supplier (
Supplier_ID int NOT NULL AUTO_INCREMENT, 
Supplier_Name varchar(255) NOT NULL, 
Tel_Number varchar(20) UNIQUE NOT NULL, 
Address_Line1 varchar(255) NOT NULL, 
Address_Line2 varchar(255), 
City varchar(255), 
Postcode varchar(255) NOT NULL, 
Email varchar(255) UNIQUE NOT NULL,
County varchar(255),

CONSTRAINT Unique_Copy_of_Supplier UNIQUE (Email, Tel_Number),

CONSTRAINT
PK_Copy_of_Supplier PRIMARY KEY
(Supplier_ID)
);

CREATE TABLE Copy_of_Employee (
Employee_ID int NOT NULL AUTO_INCREMENT, 
Email varchar(255) UNIQUE NOT NULL,
F_Name varchar(255),
L_Name varchar(255) NOT NULL,
Department varchar(255) NOT NULL, 
Contract_Hours INT NOT NULL,
National_Insurance_Number varchar(9) UNIQUE NOT NULL, 
Job_Title varchar(255) NOT NULL, 
Date_Joined DATE,

CONSTRAINT Unique_Copy_of_Employee UNIQUE (Email, National_Insurance_Number),

CONSTRAINT
PK_Copy_of_Employee PRIMARY KEY
(Employee_ID)
);

CREATE TABLE Copy_of_Training (
Employee_ID int NOT NULL,
Training varchar(255),

CONSTRAINT PK_Copy_of_Training PRIMARY KEY (Employee_ID, Training),

CONSTRAINT
FK_Copy_of_Training_Copy_of_Employee FOREIGN KEY
(Employee_ID)
REFERENCES
Copy_of_Employee(Employee_ID) 
ON DELETE CASCADE
ON UPDATE CASCADE
); 

CREATE TABLE Copy_of_Customer (
Customer_ID int NOT NULL AUTO_INCREMENT, 
Email varchar(255) UNIQUE NOT NULL,
F_Name varchar(255),
L_Name varchar(255) NOT NULL,
Address_Line1 varchar(255) NOT NULL, 
Address_Line2 varchar(255), 
City varchar(255), 
Postcode varchar(255) NOT NULL, 
Customer_Type varchar(255) NOT NULL,
Tel_Number varchar(20) UNIQUE NOT NULL,
Discount int DEFAULT 0,
County varchar(255),

CONSTRAINT Unique_Copy_of_Customer UNIQUE (Email, Tel_Number),

CONSTRAINT
PK_Copy_of_Product PRIMARY KEY
(Customer_ID)
);

CREATE TABLE Copy_of_Product (
Product_ID int NOT NULL AUTO_INCREMENT, 
Supplier_ID int, 
Item_Name varchar(255) NOT NULL, 
Scientific_Name varchar(255), 
Description varchar(255), 
Price double NOT NULL, 
Stock_Quantity int NOT NULL, 
Item_Category varchar(255) NOT NULL, 
Soil_Type varchar(255),
Season_Of_Growth varchar(255), 
Aftercare varchar(255),

CONSTRAINT
PK_Copy_of_Product PRIMARY KEY
(Product_ID),

CONSTRAINT
FK_Copy_of_Product_Supplier FOREIGN KEY
(Supplier_ID)
REFERENCES
Copy_of_Supplier(Supplier_ID) 
ON DELETE SET NULL
ON UPDATE CASCADE
);

CREATE TABLE Copy_of_Customer_Order (
Customer_Order_ID int NOT NULL AUTO_INCREMENT, 
Customer_ID int, 
Employee_ID int, 
Product_ID int, 
Quantity int NOT NULL,
Order_Date DATE NOT NULL,
Dispatch_Date DATE,
Invoice_Sent_Date DATE,
Payment_Date DATE,
Order_Status varchar(255) NOT NULL DEFAULT 'Pending',
Total_Price double NOT NULL,

CONSTRAINT
PK_Copy_of_Customer_Order PRIMARY KEY
(Customer_Order_ID),

CONSTRAINT
FK_Copy_of_Customer_Order_Copy_of_Customer FOREIGN KEY
(Customer_ID)
REFERENCES
Copy_of_Customer(Customer_ID) 
ON DELETE SET NULL
ON UPDATE CASCADE,

CONSTRAINT
FK_Copy_of_Customer_Order_Copy_of_Employee FOREIGN KEY
(Employee_ID)
REFERENCES
Copy_of_Employee(Employee_ID) 
ON DELETE SET NULL
ON UPDATE CASCADE,

CONSTRAINT
FK_Copy_of_Customer_Order_Copy_of_Product FOREIGN KEY
(Product_ID)
REFERENCES
Copy_of_Product(Product_ID) 
ON DELETE SET NULL
ON UPDATE CASCADE
);

CREATE TABLE Copy_of_Purchase_Order (
Purchase_Order_ID int NOT NULL AUTO_INCREMENT, 
Supplier_ID int, 
Employee_ID int, 
Product_ID int, 
Quantity int NOT NULL,
Order_Date DATE NOT NULL,
Order_Recieved_Date DATE,
Payment_Date DATE,
Order_Status varchar(255) NOT NULL DEFAULT 'Pending',
Total_Price double NOT NULL,

CONSTRAINT
PK_Copy_of_Purchase_Order PRIMARY KEY
(Purchase_Order_ID),

CONSTRAINT
FK_Copy_of_Purchase_Order_Copy_of_Supplier FOREIGN KEY
(Supplier_ID)
REFERENCES
Copy_of_Supplier(Supplier_ID) 
ON DELETE SET NULL
ON UPDATE CASCADE,

CONSTRAINT
FK_Copy_of_Purchase_Order_Copy_of_Employee FOREIGN KEY
(Employee_ID)
REFERENCES
Copy_of_Employee(Employee_ID)
ON UPDATE CASCADE,

CONSTRAINT
FK_Copy_of_Purchase_Order_Copy_of_Product FOREIGN KEY
(Product_ID)
REFERENCES
Copy_of_Product(Product_ID) 
ON DELETE SET NULL
ON UPDATE CASCADE
);

INSERT INTO Copy_of_Supplier
SELECT * FROM Supplier;

INSERT INTO Copy_of_Employee
SELECT * FROM Employee;

INSERT INTO Copy_of_Training
SELECT * FROM Training;

INSERT INTO Copy_of_Customer
SELECT * FROM Customer;

INSERT INTO Copy_of_Product 
SELECT * FROM Product;

INSERT INTO Copy_of_Customer_Order
SELECT * FROM Customer_Order;

INSERT INTO Copy_of_Purchase_Order  
SELECT * FROM Purchase_Order ;

CREATE USER 'user2'@'localhost' IDENTIFIED BY 'user2PSWD';
GRANT SELECT ON lincolngardencentre . * TO 'user2'@'localhost';

--procedure that calculates the tatal price of an order when given the Product_ID, Customer_ID and quantity bought
DELIMITER $$
CREATE PROCEDURE Total_Price_Calculator(IN ITEM_ID int, IN Quantity int, IN CUST_ID int)
BEGIN
  
  DECLARE Total double;
  
  SET Total = (SELECT Price FROM Product WHERE Product_ID = ITEM_ID) * Quantity - ((SELECT Discount FROM Customer WHERE Customer_ID = CUST_ID) / 100) * (SELECT Price FROM Product WHERE Product_ID = ITEM_ID) * Quantity;
 
 SET Total = ROUND(Total, 2);
 
  SELECT Total as Total;
 
END $$
DELIMITER ;

CALL Total_Price_Calculator (7,2,7);
CALL Total_Price_Calculator (8,4,9);
