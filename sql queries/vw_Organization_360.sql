
USE Ejay_SaaS_Product_Intelligence;
GO

CREATE OR ALTER VIEW semantic.vw_Organization_360
AS

WITH UserMetrics AS
(
    SELECT
        OrganizationKey,
        COUNT(*) AS TotalUsers,

        SUM(CASE
            WHEN deactivated_on IS NULL THEN 1
            ELSE 0
        END) AS ActiveUsers,

        SUM(CASE
            WHEN deactivated_on IS NOT NULL THEN 1
            ELSE 0
        END) AS DeactivatedUsers

    FROM dw.DimUser
    WHERE UserKey <> 0
    GROUP BY OrganizationKey
),

SubscriptionMetrics AS
(
    SELECT
        OrganizationKey,

        COUNT(*) AS TotalSubscriptions,

        SUM(CASE
            WHEN EndDateKey = 0 THEN 1
            ELSE 0
        END) AS ActiveSubscriptions,

        SUM(CASE
            WHEN EndDateKey <> 0 THEN 1
            ELSE 0
        END) AS EndedSubscriptions,

        SUM(CASE
            WHEN cancel_reason IS NOT NULL THEN 1
            ELSE 0
        END) AS CancelledSubscriptions,

        SUM(CASE
            WHEN EndDateKey = 0 THEN seats
            ELSE 0
        END) AS ActiveSeats,

        SUM(seats) AS TotalSubscriptionSeats

    FROM dw.FactSubscription
    GROUP BY OrganizationKey
),

InvoiceMetrics AS
(
    SELECT
        OrganizationKey,

        COUNT(*) AS TotalInvoices,

        SUM(amount) AS TotalInvoicedAmount,

        SUM(CASE
            WHEN status = 'paid' THEN amount
            ELSE 0
        END) AS TotalPaidAmount,

        SUM(CASE
            WHEN status = 'refunded' THEN amount
            ELSE 0
        END) AS TotalRefundedAmount,

        SUM(CASE
            WHEN status = 'failed' THEN 1
            ELSE 0
        END) AS FailedInvoices,

        SUM(CASE
            WHEN status = 'open' THEN 1
            ELSE 0
        END) AS OpenInvoices,

        SUM(CASE
            WHEN status = 'paid' THEN 1
            ELSE 0
        END) AS PaidInvoices,

        SUM(CASE
            WHEN status = 'refunded' THEN 1
            ELSE 0
        END) AS RefundedInvoices

    FROM dw.FactInvoice
    GROUP BY OrganizationKey
),

UsageMetrics AS
(
    SELECT
        OrganizationKey,

        COUNT(*) AS TotalUsageEvents,

        SUM(quantity) AS TotalUsageQuantity,

        COUNT(DISTINCT CASE
            WHEN UserKey <> 0 THEN UserKey
        END) AS UniqueUsersWithUsage,

        COUNT(DISTINCT event_type) AS UniqueEventTypes,

        MAX(occurred_at) AS LastActivityAt

    FROM dw.FactUsageEvent
    GROUP BY OrganizationKey
)

SELECT
    -- =============================================
    -- ORGANIZATION PROFILE
    -- =============================================

    O.OrganizationKey,
    O.organization_id,
    O.org_name,
    O.industry,
    O.country,
    O.employee_band,
    O.signed_up_on,
    O.acquisition_channel,

    -- =============================================
    -- USER METRICS
    -- =============================================

    ISNULL(U.TotalUsers, 0) AS TotalUsers,
    ISNULL(U.ActiveUsers, 0) AS ActiveUsers,
    ISNULL(U.DeactivatedUsers, 0) AS DeactivatedUsers,

    -- =============================================
    -- SUBSCRIPTION METRICS
    -- =============================================

    ISNULL(S.TotalSubscriptions, 0) AS TotalSubscriptions,
    ISNULL(S.ActiveSubscriptions, 0) AS ActiveSubscriptions,
    ISNULL(S.EndedSubscriptions, 0) AS EndedSubscriptions,
    ISNULL(S.CancelledSubscriptions, 0) AS CancelledSubscriptions,
    ISNULL(S.ActiveSeats, 0) AS ActiveSeats,
    ISNULL(S.TotalSubscriptionSeats, 0) AS TotalSubscriptionSeats,

    -- =============================================
    -- INVOICE / REVENUE METRICS
    -- =============================================

    ISNULL(I.TotalInvoices, 0) AS TotalInvoices,

    ISNULL(I.TotalInvoicedAmount, 0)
        AS TotalInvoicedAmount,

    ISNULL(I.TotalPaidAmount, 0)
        AS TotalPaidAmount,

    ISNULL(I.TotalRefundedAmount, 0)
        AS TotalRefundedAmount,

    ISNULL(I.PaidInvoices, 0) AS PaidInvoices,
    ISNULL(I.FailedInvoices, 0) AS FailedInvoices,
    ISNULL(I.OpenInvoices, 0) AS OpenInvoices,
    ISNULL(I.RefundedInvoices, 0) AS RefundedInvoices,

    -- =============================================
    -- PRODUCT ENGAGEMENT
    -- =============================================

    ISNULL(E.TotalUsageEvents, 0) AS TotalUsageEvents,
    ISNULL(E.TotalUsageQuantity, 0) AS TotalUsageQuantity,
    ISNULL(E.UniqueUsersWithUsage, 0) AS UniqueUsersWithUsage,
    ISNULL(E.UniqueEventTypes, 0) AS UniqueEventTypes,
    E.LastActivityAt

FROM dw.DimOrganization O

LEFT JOIN UserMetrics U
    ON O.OrganizationKey = U.OrganizationKey

LEFT JOIN SubscriptionMetrics S
    ON O.OrganizationKey = S.OrganizationKey

LEFT JOIN InvoiceMetrics I
    ON O.OrganizationKey = I.OrganizationKey

LEFT JOIN UsageMetrics E
    ON O.OrganizationKey = E.OrganizationKey

WHERE O.OrganizationKey <> 0;
GO
