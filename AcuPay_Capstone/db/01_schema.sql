
-- Select your database
USE [AcuPay];
GO

-- 1. USERS
CREATE TABLE Users
(
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) NOT NULL
);
GO

-- 2. VENDORS
CREATE TABLE Vendors
(
    VendorId INT IDENTITY(1,1) PRIMARY KEY,
    VendorCode NVARCHAR(20) NOT NULL UNIQUE,
    VendorName NVARCHAR(100) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1
);
GO

-- 3. PURCHASE ORDERS
CREATE TABLE PurchaseOrders
(
    PoId INT IDENTITY(1,1) PRIMARY KEY,
    PoNumber NVARCHAR(30) NOT NULL UNIQUE,
    VendorId INT NOT NULL,
    PoAmount DECIMAL(18,2) NOT NULL,
    PoDate DATE NOT NULL,
    Status NVARCHAR(20) NOT NULL,

    CONSTRAINT FK_PurchaseOrders_Vendors
    FOREIGN KEY(VendorId) REFERENCES Vendors(VendorId)
);
GO

-- 4. INVOICES
CREATE TABLE Invoices
(
    InvoiceId INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceNumber NVARCHAR(30) NOT NULL,
    VendorId INT NOT NULL,
    PoId INT NULL,
    InvoiceAmount DECIMAL(18,2) NOT NULL,
    InvoiceDate DATE NOT NULL,
    Status NVARCHAR(20) NOT NULL,
    MatchNote NVARCHAR(50) NULL,
    CreatedBy NVARCHAR(50) NOT NULL,
    CreatedAtUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    DecidedBy NVARCHAR(50) NULL,
    DecidedAtUtc DATETIME2 NULL,
    DecisionReason NVARCHAR(500) NULL,

    CONSTRAINT FK_Invoices_Vendors
    FOREIGN KEY(VendorId) REFERENCES Vendors(VendorId),

    CONSTRAINT FK_Invoices_PurchaseOrders
    FOREIGN KEY(PoId) REFERENCES PurchaseOrders(PoId),

    CONSTRAINT UQ_Invoices_Vendor_InvoiceNumber
    UNIQUE(VendorId, InvoiceNumber),

    CONSTRAINT CK_Invoices_Amount
    CHECK(InvoiceAmount > 0),

    CONSTRAINT CK_Invoices_Status
    CHECK(Status IN('Pending', 'Matched', 'Exception', 'Approved', 'Rejected'))
);
GO

-- 5. AUDIT LOG
CREATE TABLE AuditLog
(
    AuditId INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceId INT NOT NULL,
    Action NVARCHAR(50) NOT NULL,
    PerformedBy NVARCHAR(50) NOT NULL,
    PerformedAtUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Details NVARCHAR(500) NULL,

    CONSTRAINT FK_AuditLog_Invoices
    FOREIGN KEY(InvoiceId) REFERENCES Invoices(InvoiceId)
);
GO

-- 6. NON-CLUSTERED INDEX
CREATE NONCLUSTERED INDEX IX_Invoices_Status_InvoiceDate
ON Invoices(Status, InvoiceDate);
GO
