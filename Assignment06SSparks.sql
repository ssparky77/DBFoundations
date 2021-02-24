--*************************************************************************--
-- Title: Assignment06
-- Author: Steven Sparks
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-02-21,SSparks,Created File
-- 2021-02-22,SSparks,Continued Exercises
-- 2021-02-24,SSparks,Finalized for Submission
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_StevenSparks')
	 Begin 
	  Alter Database [Assignment06DB_StevenSparks] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_StevenSparks;
	 End
	Create Database Assignment06DB_StevenSparks;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_StevenSparks;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, Employees and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
/*NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------*/

-- Question 1 (5 pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		    3) Use SchemaBinding to protect the views from being orphaned!
--Select * From Categories; 
--Go

Create or Alter View vCategories  --Used Alter so I could run the block of code over and over when testing
With SCHEMABINDING
As
 Select 
  [Category ID] = CategoryID
  ,[Category Name] = CategoryName
  From dbo.Categories;
Go

--Select * From [dbo].[vCategories];
--Go

--Select * From Products;
--Go

Create or Alter View vProducts
With SCHEMABINDING
As
 Select 
  [Product ID] = ProductID
  ,[Product Name] = ProductName
  ,[Category ID] = CategoryID
  ,[Unit Price] = UnitPrice
  From dbo.Products;
Go

--Select * From [dbo].[vProducts];
--Go

--Select * From Inventories;
--Go

Create or Alter View vInventories
With SCHEMABINDING
As
 Select 
  [Inventory ID] = InventoryID
  ,[Inventory Date] = InventoryDate
  ,[Employee ID] = EmployeeID
  ,[Product ID] = ProductID
  ,Count
  From dbo.Inventories;
Go

--Select * From [dbo].[vInventories];
--Go

--Select * From Employees;
--Go

Create or Alter View vEmployees
With SCHEMABINDING
As
 Select 
  [Employee ID] = e.EmployeeID
  ,[First Name] = e.EmployeeFirstName
  ,[Last Name] = e.EmployeeLastName
  ,[Employee Name] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
  ,[Manager ID] = e.ManagerID
  ,[Manager] = m.EmployeeFirstName + ' ' + m.EmployeeLastName
  --From dbo.Employees
   From dbo.Employees as M 
  Inner Join dbo.Employees as E
   On E.[ManagerID] = M.[EmployeeID];
Go

--Select * From [dbo].[vEmployees];
--Go

-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Use Assignment06DB_StevenSparks;
Deny Select On Categories To Public;
Grant Select On vCategories To Public;
Deny Select On Products To Public;
Grant Select On vProducts To Public;
Deny Select On Employees To Public;
Grant Select On vEmployees To Public;
Deny Select On Inventories To Public;
Grant Select On vInventories To Public;
Go

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create or Alter View vProductsByCategories
With SCHEMABINDING
As 
Select Top 1000000000
  [Category Name] --= CategoryName
  ,[Product Name] --= ProductName
  ,[Unit Price] --= UnitPrice
  From dbo.vCategories as c
    Inner Join dbo.vProducts as p
      On c.[Category ID] = p.[Category ID]
      Order By [Category Name], [Product Name];
Go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create or Alter View vInventoriesByProductsByDates
With SCHEMABINDING
As
Select
  [Product Name] --= ProductName
  ,[Inventory Date] --= InventoryDate
  ,[Count] --= Count
  From dbo.vInventories as i
    Inner Join dbo.vProducts as p
     On i.[Product ID] = p.[Product ID];
Go

--Select * From [dbo].[vInventoriesByProductsByDates] Order By 1,2,3;
--Go

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83


-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

Create or Alter View vInventoriesByEmployeesByDates
With SCHEMABINDING
As
Select Top 1000000000
  [Date] = Max(InventoryDate)
  ,[Employee Name] --= EmployeeFirstName + ' ' + EmployeeLastName
  From dbo.Inventories as i
   Inner Join dbo.vEmployees as e
    On i.[EmployeeID] = e.[Employee ID]
  Group By [Employee Name]--EmployeeFirstName + ' ' + EmployeeLastName
  Order By [Date];
Go

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth

-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create or Alter View vInventoriesByProductsByCategories
With SCHEMABINDING
As
Select Top 1000000000
 [Category Name] --= CategoryName
 ,[Product Name] --= ProductName
 ,[Inventory Date] --= InventoryDate
 ,[Count] --= Count
 From dbo.vCategories as c
  Inner Join dbo.vProducts as p
   On c.[Category ID] = p.[Category ID]
  Inner Join dbo.vInventories as i
   On p.[Product ID] = i.[Product ID]
   Order By [Category Name],[Product Name],[Inventory Date],[Count];
Go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54


-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create or Alter View vInventoriesByProductsByEmployees
With SCHEMABINDING
As
Select Top 1000000000
 [Category Name] --= CategoryName
 ,[Product Name] --= ProductName
 ,[Inventory Date] --= InventoryDate
 ,[Count] --= Count
 ,[Employee Name] --= EmployeeFirstName + ' ' + EmployeeLastName
 From dbo.vCategories as c
  Inner Join dbo.vProducts as p
   On c.[Category ID] = p.[Category ID]
  Inner Join dbo.vInventories as i
   On p.[Product ID] = i.[Product ID]
  Inner Join dbo.vEmployees as e
   On e.[Employee ID] = i.[Employee ID]
   Order By [Inventory Date], [Category Name], [Product Name], [Employee Name];
Go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create or Alter View vInventoriesForChaiAndChangByEmployees
With SCHEMABINDING
As
Select Top 1000000000
 [Category Name] --= CategoryName
 ,[Product Name] --= ProductName 
 ,[Inventory Date] --= InventoryDate
 ,[Count] --= Count
 ,[Employee Name] --= EmployeeFirstName + ' ' + EmployeeLastName
 From dbo.vCategories as c
  Inner Join dbo.vProducts as p
   On c.[Category ID] = p.[Category ID]
  Inner Join dbo.vInventories as i
   On p.[Product ID] = i.[Product ID]
  Inner Join dbo.vEmployees as e
   On e.[Employee ID] = i.[Employee ID]
  Where p.[Product Name] in (Select [Product Name] from dbo.vProducts where [Product ID] between 1 and 2) --ProductName = 'chai' or ProductName = 'chang')
 Order By [Inventory Date], [Category Name], [Product Name];
Go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King


-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Create or Alter View vEmployeesByManager
With SCHEMABINDING
As
Select Top 1000000000
 e.[Manager] --= M.EmployeeFirstName + ' ' + M.EmployeeLastName
 ,e.[Employee Name] --= E.EmployeeFirstName + ' ' + E.EmployeeLastName
 From dbo.vEmployees as M 
  Inner Join dbo.vEmployees as E
   On E.[Manager ID] = M.[Employee ID]
   Order By e.[Manager], e.[Employee Name];
Go

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan


-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

Create or Alter View vInventoriesByProductsByCategoriesByEmployees
With SCHEMABINDING
As
Select Top 1000000000
 c.[Category ID]
 ,[Category Name]
 ,p.[Product ID]
 ,[Product Name]
 ,[Unit Price]
 ,[Inventory ID]
 ,[Inventory Date]
 ,Count
 ,e.[Employee ID]
 ,e.[Employee Name] --= e.EmployeeFirstName + ' ' + e.EmployeeLastName
 ,m.[Manager] --= m.EmployeeFirstName + ' ' + m.EmployeeLastName
From 
 [dbo].[vCategories] as c
  Inner Join [dbo].[vProducts] as p
   On p.[Category ID] = c.[Category ID]
  Inner Join [dbo].[vInventories] as i
   On i.[Product ID] = p.[Product ID]
  Inner Join [dbo].[vEmployees] as e
   On e.[Employee ID] = i.[Employee ID]
  Inner Join [dbo].[vEmployees] as m
   on e.[Manager ID] = m.[Employee ID]
  Order By c.[Category ID], [Category Name], p.[Product ID], [Unit Price];
Go

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)

Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/