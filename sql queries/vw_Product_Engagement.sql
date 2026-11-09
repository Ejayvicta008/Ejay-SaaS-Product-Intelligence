
USE Ejay_SaaS_Product_Intelligence;
GO

CREATE OR ALTER VIEW semantic.vw_Product_Engagement
AS

WITH UsageMetrics AS
(
    SELECT
        OrganizationKey,

        -- Usage volume
        COUNT(*) AS TotalUsageEvents,
        SUM(quantity) AS TotalUsageQuantity,

        -- Identified vs anonymous events
        SUM(CASE
            WHEN UserKey <> 0 THEN 1
            ELSE 0
        END) AS IdentifiedUsageEvents,

        SUM(CASE
            WHEN UserKey = 0 THEN 1
            ELSE 0
        END) AS AnonymousUsageEvents,

        -- User engagement
        COUNT(DISTINCT CASE
            WHEN UserKey <> 0 THEN UserKey
        END) AS UsersWithUsage,

        -- Event type adoption
        COUNT(DISTINCT event_type) AS UniqueEventTypes,

        -- Event breakdown
        SUM(CASE WHEN event_type = 'report_run'
            THEN 1 ELSE 0 END) AS ReportRuns,

        SUM(CASE WHEN event_type = 'dashboard_view'
            THEN 1 ELSE 0 END) AS DashboardViews,

        SUM(CASE WHEN event_type = 'export'
            THEN 1 ELSE 0 END) AS Exports,

        SUM(CASE WHEN event_type = 'api_call'
            THEN 1 ELSE 0 END) AS APICalls,

        SUM(CASE WHEN event_type = 'invite_sent'
            THEN 1 ELSE 0 END) AS InvitesSent,

        SUM(CASE WHEN event_type = 'integration_sync'
            THEN 1 ELSE 0 END) AS IntegrationSyncs,

        SUM(CASE WHEN event_type = 'alert_fired'
            THEN 1 ELSE 0 END) AS AlertsFired,

        -- Activity dates
        MIN(occurred_at) AS FirstActivityAt,
        MAX(occurred_at) AS LastActivityAt

    FROM dw.FactUsageEvent
    GROUP BY OrganizationKey
),

UserMetrics AS
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
    O.acquisition_channel,
    O.signed_up_on,

    -- =============================================
    -- USER METRICS
    -- =============================================

    ISNULL(U.TotalUsers, 0) AS TotalUsers,
    ISNULL(U.ActiveUsers, 0) AS ActiveUsers,
    ISNULL(U.DeactivatedUsers, 0) AS DeactivatedUsers,

    ISNULL(E.UsersWithUsage, 0) AS UsersWithUsage,

    -- Registered user adoption rate
    CAST(
        ISNULL(E.UsersWithUsage, 0) * 100.0
        / NULLIF(U.TotalUsers, 0)
        AS DECIMAL(10,2)
    ) AS UserAdoptionRatePct,

    -- =============================================
    -- USAGE VOLUME
    -- =============================================

    ISNULL(E.TotalUsageEvents, 0) AS TotalUsageEvents,
    ISNULL(E.TotalUsageQuantity, 0) AS TotalUsageQuantity,

    ISNULL(E.IdentifiedUsageEvents, 0)
        AS IdentifiedUsageEvents,

    ISNULL(E.AnonymousUsageEvents, 0)
        AS AnonymousUsageEvents,

    -- =============================================
    -- EVENT TYPE ADOPTION
    -- =============================================

    ISNULL(E.UniqueEventTypes, 0) AS UniqueEventTypes,

    ISNULL(E.ReportRuns, 0) AS ReportRuns,
    ISNULL(E.DashboardViews, 0) AS DashboardViews,
    ISNULL(E.Exports, 0) AS Exports,
    ISNULL(E.APICalls, 0) AS APICalls,
    ISNULL(E.InvitesSent, 0) AS InvitesSent,
    ISNULL(E.IntegrationSyncs, 0) AS IntegrationSyncs,
    ISNULL(E.AlertsFired, 0) AS AlertsFired,

    -- =============================================
    -- ACTIVITY RECENCY
    -- =============================================

    E.FirstActivityAt,
    E.LastActivityAt,

    CASE
        WHEN E.TotalUsageEvents IS NULL THEN 'No Activity'
        ELSE 'Has Activity'
    END AS ActivityStatus

FROM dw.DimOrganization O

LEFT JOIN UserMetrics U
    ON O.OrganizationKey = U.OrganizationKey

LEFT JOIN UsageMetrics E
    ON O.OrganizationKey = E.OrganizationKey

WHERE O.OrganizationKey <> 0;
GO
