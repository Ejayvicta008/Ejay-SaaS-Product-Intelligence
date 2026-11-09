CREATE OR ALTER VIEW semantic.vw_Customer_Retention
AS

WITH SubscriptionMetrics AS
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
            WHEN Cancel_Reason IS NOT NULL THEN 1
            ELSE 0
        END) AS CancelledSubscriptions,

        MIN(StartDateKey) AS FirstSubscriptionDateKey,

        MAX(EndDateKey) AS LastSubscriptionEndDateKey

    FROM dw.FactSubscription
    WHERE OrganizationKey <> 0
    GROUP BY OrganizationKey
),

CustomerActivity AS
(
    SELECT
        OrganizationKey,
        MAX(LastActivityAt) AS LastActivityAt,
        SUM(TotalUsageEvents) AS TotalUsageEvents
     FROM semantic.vw_Organization_360
    GROUP BY OrganizationKey
)

SELECT
    O.OrganizationKey,
    O.organization_id,
    O.org_name,
    O.Industry,
    O.Country,
    O.employee_band,
    O.acquisition_channel,
    O.signed_up_on,

    -- Subscription metrics
    ISNULL(S.TotalSubscriptions, 0) AS TotalSubscriptions,
    ISNULL(S.ActiveSubscriptions, 0) AS ActiveSubscriptions,
    ISNULL(S.EndedSubscriptions, 0) AS EndedSubscriptions,
    ISNULL(S.CancelledSubscriptions, 0) AS CancelledSubscriptions,

    -- Customer retention status
    CASE
        WHEN ISNULL(S.ActiveSubscriptions, 0) > 0
            THEN 'Retained'
        WHEN ISNULL(S.TotalSubscriptions, 0) > 0
            THEN 'Churned'
        ELSE 'Never Subscribed'
    END AS CustomerRetentionStatus,

    CASE
        WHEN ISNULL(S.ActiveSubscriptions, 0) > 0 THEN 0
        WHEN ISNULL(S.TotalSubscriptions, 0) > 0 THEN 1
        ELSE 0
    END AS IsChurned,

    -- Customer tenure
    DATEDIFF(
        DAY,
        O.signed_up_on,
        CAST(GETDATE() AS DATE)
    ) AS CustomerTenureDays,

    -- Subscription timeline
    S.FirstSubscriptionDateKey,
    S.LastSubscriptionEndDateKey,

    DATEDIFF(
        DAY,
        O.signed_up_on,
        FirstSubDate.FullDate
    ) AS DaysToFirstSubscription,

    -- Product activity
    A.LastActivityAt,
    ISNULL(A.TotalUsageEvents, 0) AS TotalUsageEvents,

    CASE
        WHEN A.LastActivityAt IS NULL THEN 'No Activity'
        WHEN A.LastActivityAt >= DATEADD(DAY, -30, GETDATE())
            THEN 'Active - Last 30 Days'
        ELSE 'Inactive - Over 30 Days'
    END AS ProductActivityStatus

FROM dw.DimOrganization O

LEFT JOIN SubscriptionMetrics S
    ON O.OrganizationKey = S.OrganizationKey

LEFT JOIN CustomerActivity A
    ON O.OrganizationKey = A.OrganizationKey

LEFT JOIN dw.DimDate FirstSubDate
    ON S.FirstSubscriptionDateKey = FirstSubDate.DateKey

WHERE O.OrganizationKey <> 0;
GO