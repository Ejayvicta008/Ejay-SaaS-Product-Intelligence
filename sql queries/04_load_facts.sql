
USE Ejay_SaaS_Product_Intelligence;
GO

SET XACT_ABORT ON;

BEGIN TRY

    BEGIN TRANSACTION;

    -- =============================================
    -- 1. FACT SUBSCRIPTION
    -- Grain: One row per subscription
    -- =============================================

    INSERT INTO dw.FactSubscription
    (
        subscription_id,
        OrganizationKey,
        PlanKey,
        StartDateKey,
        EndDateKey,
        seats,
        cancel_reason
    )
    SELECT
        S.subscription_id,
        ISNULL(O.OrganizationKey, 0),
        ISNULL(P.PlanKey, 0),
        ISNULL(DS.DateKey, 0),
        ISNULL(DE.DateKey, 0),
        S.seats,
        S.cancel_reason
    FROM stg.Subscriptions S

    LEFT JOIN dw.DimOrganization O
        ON S.organization_id = O.organization_id

    LEFT JOIN dw.DimPlan P
        ON S.plan_id = P.plan_id

    LEFT JOIN dw.DimDate DS
        ON DS.DateKey = CONVERT(
            INT, CONVERT(CHAR(8), S.started_on, 112)
        )

    LEFT JOIN dw.DimDate DE
        ON DE.DateKey = CONVERT(
            INT, CONVERT(CHAR(8), S.ended_on, 112)
        )

    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dw.FactSubscription F
        WHERE F.subscription_id = S.subscription_id
    );

    PRINT 'FactSubscription loaded';


    -- =============================================
    -- 2. FACT INVOICE
    -- Grain: One row per invoice
    -- =============================================

    INSERT INTO dw.FactInvoice
    (
        invoice_id,
        subscription_id,
        OrganizationKey,
        PlanKey,
        InvoiceDateKey,
        PeriodStartDateKey,
        PeriodEndDateKey,
        PaidDateKey,
        amount,
        status
    )
    SELECT
        I.invoice_id,
        I.subscription_id,
        ISNULL(O.OrganizationKey, 0),
        ISNULL(P.PlanKey, 0),

        ISNULL(DI.DateKey, 0),
        ISNULL(DPS.DateKey, 0),
        ISNULL(DPE.DateKey, 0),
        ISNULL(DP.DateKey, 0),

        I.amount,
        I.status

    FROM stg.Invoices I

    INNER JOIN stg.Subscriptions S
        ON I.subscription_id = S.subscription_id

    LEFT JOIN dw.DimOrganization O
        ON S.organization_id = O.organization_id

    LEFT JOIN dw.DimPlan P
        ON S.plan_id = P.plan_id

    LEFT JOIN dw.DimDate DI
        ON DI.DateKey = CONVERT(
            INT, CONVERT(CHAR(8), I.issued_on, 112)
        )

    LEFT JOIN dw.DimDate DPS
        ON DPS.DateKey = CONVERT(
            INT, CONVERT(CHAR(8), I.period_start, 112)
        )

    LEFT JOIN dw.DimDate DPE
        ON DPE.DateKey = CONVERT(
            INT, CONVERT(CHAR(8), I.period_end, 112)
        )

    LEFT JOIN dw.DimDate DP
        ON DP.DateKey = CONVERT(
            INT, CONVERT(CHAR(8), I.paid_on, 112)
        )

    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dw.FactInvoice F
        WHERE F.invoice_id = I.invoice_id
    );

    PRINT 'FactInvoice loaded';


    -- =============================================
    -- 3. FACT USAGE EVENT
    -- Grain: One row per usage event
    -- =============================================

    INSERT INTO dw.FactUsageEvent
    (
        event_id,
        OrganizationKey,
        UserKey,
        EventDateKey,
        occurred_at,
        event_type,
        quantity
    )
    SELECT
        U.event_id,
        ISNULL(O.OrganizationKey, 0),
        ISNULL(DU.UserKey, 0),

        ISNULL(D.DateKey, 0),

        U.occurred_at,
        U.event_type,
        U.quantity

    FROM stg.Usage_Events U

    LEFT JOIN dw.DimOrganization O
        ON U.organization_id = O.organization_id

    LEFT JOIN dw.DimUser DU
        ON U.user_id = DU.user_id

    LEFT JOIN dw.DimDate D
        ON D.DateKey = CONVERT(
            INT, CONVERT(CHAR(8), U.occurred_at, 112)
        )

    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dw.FactUsageEvent F
        WHERE F.event_id = U.event_id
    );

    PRINT 'FactUsageEvent loaded';


    COMMIT TRANSACTION;

    PRINT 'All fact tables loaded successfully.';

END TRY

BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO
