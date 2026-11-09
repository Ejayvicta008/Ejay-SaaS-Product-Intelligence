
USE Ejay_SaaS_Product_Intelligence;
GO

CREATE OR ALTER VIEW semantic.vw_Revenue_Analytics
AS

WITH InvoiceMetrics AS
(
    SELECT
        subscription_id,

        COUNT(*) AS TotalInvoices,

        SUM(amount) AS TotalInvoicedAmount,

        SUM(CASE
            WHEN status = 'paid' THEN amount
            ELSE 0
        END) AS PaidInvoiceAmount,

        SUM(CASE
            WHEN status = 'refunded' THEN amount
            ELSE 0
        END) AS RefundedInvoiceAmount,

        SUM(CASE
            WHEN status = 'open' THEN amount
            ELSE 0
        END) AS OpenInvoiceAmount,

        SUM(CASE
            WHEN status = 'failed' THEN amount
            ELSE 0
        END) AS FailedInvoiceAmount,

        SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END)
            AS PaidInvoiceCount,

        SUM(CASE WHEN status = 'refunded' THEN 1 ELSE 0 END)
            AS RefundedInvoiceCount,

        SUM(CASE WHEN status = 'open' THEN 1 ELSE 0 END)
            AS OpenInvoiceCount,

        SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END)
            AS FailedInvoiceCount,

        MAX(DI.FullDate) AS LatestInvoiceDate,

        MAX(DP.FullDate) AS LatestPaymentDate

    FROM dw.FactInvoice F

    LEFT JOIN dw.DimDate DI
        ON F.InvoiceDateKey = DI.DateKey

    LEFT JOIN dw.DimDate DP
        ON F.PaidDateKey = DP.DateKey

    GROUP BY subscription_id
)

SELECT

    -- =============================================
    -- SUBSCRIPTION IDENTIFICATION
    -- =============================================

    S.subscription_id,

    -- =============================================
    -- ORGANIZATION
    -- =============================================

    O.OrganizationKey,
    O.organization_id,
    O.org_name,
    O.industry,
    O.country,

    -- =============================================
    -- PLAN DETAILS
    -- =============================================

    P.PlanKey,
    P.plan_name,
    P.tier,
    P.billing_interval,

    P.monthly_price,
    P.seat_price,

    -- =============================================
    -- SUBSCRIPTION DETAILS
    -- =============================================

    S.seats,
    DS.FullDate AS started_on,
    DE.FullDate AS ended_on,

    CASE
        WHEN S.EndDateKey = 0 THEN 'Active'
        ELSE 'Ended'
    END AS subscription_status,

    -- =============================================
    -- RECURRING REVENUE
    -- =============================================

    CAST(
        P.monthly_price +
        (P.seat_price * S.seats)
        AS DECIMAL(18,2)
    ) AS EstimatedContractMRR,

    CAST(
        CASE
            WHEN S.EndDateKey = 0
            THEN P.monthly_price + (P.seat_price * S.seats)
            ELSE 0
        END
        AS DECIMAL(18,2)
    ) AS EstimatedMRR,

    CAST(
        CASE
            WHEN S.EndDateKey = 0
            THEN (P.monthly_price + (P.seat_price * S.seats)) * 12
            ELSE 0
        END
        AS DECIMAL(18,2)
    ) AS EstimatedARR,

    -- =============================================
    -- INVOICE METRICS
    -- =============================================

    ISNULL(I.TotalInvoices, 0) AS TotalInvoices,

    ISNULL(I.TotalInvoicedAmount, 0)
        AS TotalInvoicedAmount,

    ISNULL(I.PaidInvoiceAmount, 0)
        AS PaidInvoiceAmount,

    ISNULL(I.RefundedInvoiceAmount, 0)
        AS RefundedInvoiceAmount,

    ISNULL(I.OpenInvoiceAmount, 0)
        AS OpenInvoiceAmount,

    ISNULL(I.FailedInvoiceAmount, 0)
        AS FailedInvoiceAmount,

    ISNULL(I.PaidInvoiceCount, 0)
        AS PaidInvoiceCount,

    ISNULL(I.RefundedInvoiceCount, 0)
        AS RefundedInvoiceCount,

    ISNULL(I.OpenInvoiceCount, 0)
        AS OpenInvoiceCount,

    ISNULL(I.FailedInvoiceCount, 0)
        AS FailedInvoiceCount,

    I.LatestInvoiceDate,
    I.LatestPaymentDate

FROM dw.FactSubscription S

LEFT JOIN dw.DimOrganization O
    ON S.OrganizationKey = O.OrganizationKey

LEFT JOIN dw.DimPlan P
    ON S.PlanKey = P.PlanKey

LEFT JOIN dw.DimDate DS
    ON S.StartDateKey = DS.DateKey

LEFT JOIN dw.DimDate DE
    ON S.EndDateKey = DE.DateKey

LEFT JOIN InvoiceMetrics I
    ON S.subscription_id = I.subscription_id;
GO
