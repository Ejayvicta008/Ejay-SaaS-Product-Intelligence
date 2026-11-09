
USE Ejay_SaaS_Product_Intelligence;
GO

-- =============================================
-- 1. FACT SUBSCRIPTION
-- Grain: One row per subscription
-- =============================================

IF OBJECT_ID('dw.FactSubscription', 'U') IS NULL
BEGIN
    CREATE TABLE dw.FactSubscription
    (
        subscription_id INT NOT NULL,
        OrganizationKey INT NOT NULL,
        PlanKey INT NOT NULL,
        StartDateKey INT NOT NULL,
        EndDateKey INT NOT NULL,
        seats INT NOT NULL,
        cancel_reason VARCHAR(30) NULL,

        CONSTRAINT PK_FactSubscription
            PRIMARY KEY (subscription_id),

        CONSTRAINT FK_FactSubscription_Organization
            FOREIGN KEY (OrganizationKey)
            REFERENCES dw.DimOrganization(OrganizationKey),

        CONSTRAINT FK_FactSubscription_Plan
            FOREIGN KEY (PlanKey)
            REFERENCES dw.DimPlan(PlanKey),

        CONSTRAINT FK_FactSubscription_StartDate
            FOREIGN KEY (StartDateKey)
            REFERENCES dw.DimDate(DateKey),

        CONSTRAINT FK_FactSubscription_EndDate
            FOREIGN KEY (EndDateKey)
            REFERENCES dw.DimDate(DateKey)
    );
END;
GO

-- =============================================
-- 2. FACT INVOICE
-- Grain: One row per invoice
-- =============================================

IF OBJECT_ID('dw.FactInvoice', 'U') IS NULL
BEGIN
    CREATE TABLE dw.FactInvoice
    (
        invoice_id INT NOT NULL,
        subscription_id INT NOT NULL,
        OrganizationKey INT NOT NULL,
        PlanKey INT NOT NULL,
        InvoiceDateKey INT NOT NULL,
        PeriodStartDateKey INT NOT NULL,
        PeriodEndDateKey INT NOT NULL,
        PaidDateKey INT NOT NULL,
        amount DECIMAL(12,2) NOT NULL,
        status VARCHAR(20) NOT NULL,

        CONSTRAINT PK_FactInvoice
            PRIMARY KEY (invoice_id),

        CONSTRAINT FK_FactInvoice_Organization
            FOREIGN KEY (OrganizationKey)
            REFERENCES dw.DimOrganization(OrganizationKey),

        CONSTRAINT FK_FactInvoice_Plan
            FOREIGN KEY (PlanKey)
            REFERENCES dw.DimPlan(PlanKey),

        CONSTRAINT FK_FactInvoice_InvoiceDate
            FOREIGN KEY (InvoiceDateKey)
            REFERENCES dw.DimDate(DateKey),

        CONSTRAINT FK_FactInvoice_PeriodStart
            FOREIGN KEY (PeriodStartDateKey)
            REFERENCES dw.DimDate(DateKey),

        CONSTRAINT FK_FactInvoice_PeriodEnd
            FOREIGN KEY (PeriodEndDateKey)
            REFERENCES dw.DimDate(DateKey),

        CONSTRAINT FK_FactInvoice_PaidDate
            FOREIGN KEY (PaidDateKey)
            REFERENCES dw.DimDate(DateKey)
    );
END;
GO

-- =============================================
-- 3. FACT USAGE EVENT
-- Grain: One row per usage event
-- =============================================

IF OBJECT_ID('dw.FactUsageEvent', 'U') IS NULL
BEGIN
    CREATE TABLE dw.FactUsageEvent
    (
        event_id INT NOT NULL,
        OrganizationKey INT NOT NULL,
        UserKey INT NOT NULL,
        EventDateKey INT NOT NULL,
        occurred_at DATETIME2(6) NOT NULL,
        event_type VARCHAR(30) NOT NULL,
        quantity INT NOT NULL,

        CONSTRAINT PK_FactUsageEvent
            PRIMARY KEY (event_id),

        CONSTRAINT FK_FactUsageEvent_Organization
            FOREIGN KEY (OrganizationKey)
            REFERENCES dw.DimOrganization(OrganizationKey),

        CONSTRAINT FK_FactUsageEvent_User
            FOREIGN KEY (UserKey)
            REFERENCES dw.DimUser(UserKey),

        CONSTRAINT FK_FactUsageEvent_Date
            FOREIGN KEY (EventDateKey)
            REFERENCES dw.DimDate(DateKey)
    );
END;
GO

-- =============================================
-- 4. INDEXES FOR QUERY PERFORMANCE
-- =============================================

CREATE INDEX IX_FactSubscription_Organization
ON dw.FactSubscription(OrganizationKey);

CREATE INDEX IX_FactSubscription_Plan
ON dw.FactSubscription(PlanKey);

CREATE INDEX IX_FactInvoice_Organization
ON dw.FactInvoice(OrganizationKey);

CREATE INDEX IX_FactInvoice_Plan
ON dw.FactInvoice(PlanKey);

CREATE INDEX IX_FactInvoice_InvoiceDate
ON dw.FactInvoice(InvoiceDateKey);

CREATE INDEX IX_FactInvoice_Subscription
ON dw.FactInvoice(subscription_id);

CREATE INDEX IX_FactUsageEvent_Organization
ON dw.FactUsageEvent(OrganizationKey);

CREATE INDEX IX_FactUsageEvent_User
ON dw.FactUsageEvent(UserKey);

CREATE INDEX IX_FactUsageEvent_EventDate
ON dw.FactUsageEvent(EventDateKey);
GO

PRINT 'Fact tables created successfully.';
GO
