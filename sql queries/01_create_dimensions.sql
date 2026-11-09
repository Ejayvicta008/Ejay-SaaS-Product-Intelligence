
USE Ejay_SaaS_Product_Intelligence;
GO

-- =============================================
-- 1. DIM ORGANIZATION
-- =============================================

IF OBJECT_ID('dw.DimOrganization', 'U') IS NULL
BEGIN
    CREATE TABLE dw.DimOrganization
    (
        OrganizationKey INT IDENTITY(1,1) NOT NULL,
        organization_id INT NULL,
        org_name VARCHAR(50) NULL,
        industry VARCHAR(30) NULL,
        country CHAR(2) NULL,
        employee_band VARCHAR(20) NULL,
        signed_up_on DATE NULL,
        acquisition_channel VARCHAR(30) NULL,

        CONSTRAINT PK_DimOrganization
            PRIMARY KEY (OrganizationKey)
    );

    CREATE UNIQUE INDEX UX_DimOrganization_SourceID
        ON dw.DimOrganization(organization_id)
        WHERE organization_id IS NOT NULL;
END;
GO

-- =============================================
-- 2. DIM PLAN
-- =============================================

IF OBJECT_ID('dw.DimPlan', 'U') IS NULL
BEGIN
    CREATE TABLE dw.DimPlan
    (
        PlanKey INT IDENTITY(1,1) NOT NULL,
        plan_id INT NULL,
        plan_name VARCHAR(30) NULL,
        tier VARCHAR(20) NULL,
        monthly_price DECIMAL(12,2) NULL,
        seat_price DECIMAL(12,2) NULL,
        billing_interval VARCHAR(20) NULL,
        is_active BIT NULL,

        CONSTRAINT PK_DimPlan
            PRIMARY KEY (PlanKey)
    );

    CREATE UNIQUE INDEX UX_DimPlan_SourceID
        ON dw.DimPlan(plan_id)
        WHERE plan_id IS NOT NULL;
END;
GO

-- =============================================
-- 3. DIM USER
-- =============================================

IF OBJECT_ID('dw.DimUser', 'U') IS NULL
BEGIN
    CREATE TABLE dw.DimUser
    (
        UserKey INT IDENTITY(1,1) NOT NULL,
        user_id INT NULL,
        OrganizationKey INT NOT NULL,
        email VARCHAR(100) NULL,
        role VARCHAR(20) NULL,
        joined_on DATE NULL,
        deactivated_on DATE NULL,

        CONSTRAINT PK_DimUser
            PRIMARY KEY (UserKey),

        CONSTRAINT FK_DimUser_Organization
            FOREIGN KEY (OrganizationKey)
            REFERENCES dw.DimOrganization(OrganizationKey)
    );

    CREATE UNIQUE INDEX UX_DimUser_SourceID
        ON dw.DimUser(user_id)
        WHERE user_id IS NOT NULL;
END;
GO

-- =============================================
-- 4. DIM DATE
-- =============================================

IF OBJECT_ID('dw.DimDate', 'U') IS NULL
BEGIN
    CREATE TABLE dw.DimDate
    (
        DateKey INT NOT NULL,
        FullDate DATE NULL,
        CalendarYear SMALLINT NULL,
        CalendarQuarter TINYINT NULL,
        CalendarMonth TINYINT NULL,
        MonthName VARCHAR(15) NULL,
        MonthYear VARCHAR(10) NULL,
        DayOfMonth TINYINT NULL,
        DayOfWeekNumber TINYINT NULL,
        DayName VARCHAR(15) NULL,
        IsWeekend BIT NULL,

        CONSTRAINT PK_DimDate
            PRIMARY KEY (DateKey)
    );
END;
GO

-- =============================================
-- 5. UNKNOWN MEMBERS
-- =============================================

-- Unknown Organization
IF NOT EXISTS (
    SELECT 1 FROM dw.DimOrganization
    WHERE OrganizationKey = 0
)
BEGIN
    SET IDENTITY_INSERT dw.DimOrganization ON;

    INSERT INTO dw.DimOrganization
    (
        OrganizationKey,
        organization_id,
        org_name
    )
    VALUES
    (
        0,
        NULL,
        'Unknown Organization'
    );

    SET IDENTITY_INSERT dw.DimOrganization OFF;
END;
GO

-- Unknown Plan
IF NOT EXISTS (
    SELECT 1 FROM dw.DimPlan
    WHERE PlanKey = 0
)
BEGIN
    SET IDENTITY_INSERT dw.DimPlan ON;

    INSERT INTO dw.DimPlan
    (
        PlanKey,
        plan_id,
        plan_name
    )
    VALUES
    (
        0,
        NULL,
        'Unknown Plan'
    );

    SET IDENTITY_INSERT dw.DimPlan OFF;
END;
GO

-- Unknown User
IF NOT EXISTS (
    SELECT 1 FROM dw.DimUser
    WHERE UserKey = 0
)
BEGIN
    SET IDENTITY_INSERT dw.DimUser ON;

    INSERT INTO dw.DimUser
    (
        UserKey,
        user_id,
        OrganizationKey,
        email,
        role
    )
    VALUES
    (
        0,
        NULL,
        0,
        'unknown',
        'unknown'
    );

    SET IDENTITY_INSERT dw.DimUser OFF;
END;
GO

-- Unknown Date
IF NOT EXISTS (
    SELECT 1 FROM dw.DimDate
    WHERE DateKey = 0
)
BEGIN
    INSERT INTO dw.DimDate
    (
        DateKey,
        FullDate,
        MonthName,
        MonthYear,
        DayName
    )
    VALUES
    (
        0,
        NULL,
        'Unknown',
        'Unknown',
        'Unknown'
    );
END;
GO
