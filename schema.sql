-- ============================================================================
-- PROJECT: ONLINE STORE DATABASE SCHEMA
-- DBMS: Microsoft SQL Server
-- Author: GitHub Portfolio Project
-- Description: Complete database structure with tables, views, and procedures.
-- ============================================================================

-- 1. DROP EXISTING OBJECTS (For easy re-runs)
IF OBJECT_ID('dbo.GetCustomerOrders', 'P') IS NOT NULL DROP PROCEDURE dbo.GetCustomerOrders;
IF OBJECT_ID('dbo.OrderSummary', 'V') IS NOT NULL DROP VIEW dbo.OrderSummary;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
GO

-- ============================================================================
-- 2. TABLE CREATION
-- ============================================================================

-- Customers Table
CREATE TABLE dbo.Customers (
    CustomerID INT IDENTITY(1,1) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    CreatedAt DATETIME2(7) NOT NULL CONSTRAINT DF_Customers_CreatedAt DEFAULT GETUTCDATE(),
    CONSTRAINT PK_Customers PRIMARY KEY CLUSTERED (CustomerID),
    CONSTRAINT UQ_Customers_Email UNIQUE (Email)
);
GO

-- Orders Table
CREATE TABLE dbo.Orders (
    OrderID INT IDENTITY(1,1) NOT NULL,
    CustomerID INT NOT NULL,
    OrderDate DATETIME2(7) NOT NULL CONSTRAINT DF_Orders_OrderDate DEFAULT GETUTCDATE(),
    TotalAmount DECIMAL(18, 2) NOT NULL,
    CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED (OrderID),
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES dbo.Customers (CustomerID)
        ON DELETE CASCADE
);
GO

-- ============================================================================
-- 3. VIEWS CREATION
-- ============================================================================

-- Business Intelligence View: Customer Sales Summary
CREATE VIEW dbo.OrderSummary 
WITH SCHEMABINDING 
AS
SELECT 
    c.CustomerID,
    c.FirstName + N' ' + c.LastName AS CustomerName,
    COUNT_BIG(o.OrderID) AS TotalOrders,
    ISNULL(SUM(o.TotalAmount), 0) AS TotalSpent
FROM dbo.Customers c
LEFT JOIN dbo.Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName;
GO

-- ============================================================================
-- 4. STORED PROCEDURES CREATION
-- ============================================================================

-- Get Order History for a Specific Customer
CREATE PROCEDURE dbo.GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Customers WHERE CustomerID = @CustomerID)
    BEGIN
        RAISERROR('Customer with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    SELECT 
        OrderID, 
        OrderDate, 
        TotalAmount
    FROM dbo.Orders
    WHERE CustomerID = @CustomerID
    ORDER BY OrderDate DESC;
END;
GO

-- ============================================================================
-- 5. SEED DATA (Sample dataset for testing)
-- ============================================================================

INSERT INTO dbo.Customers (FirstName, LastName, Email) VALUES
(N'John', N'Doe', N'john.doe@example.com'),
(N'Jane', N'Smith', N'jane.smith@example.com'),
(N'Alice', N'Jones', N'alice.jones@example.com');

INSERT INTO dbo.Orders (CustomerID, TotalAmount) VALUES
(1, 150.50),
(1, 45.00),
(2, 99.99);
GO
