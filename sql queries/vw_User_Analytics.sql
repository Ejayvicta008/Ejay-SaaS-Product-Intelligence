
USE Ejay_SaaS_Product_Intelligence;
GO

CREATE OR ALTER VIEW semantic.vw_User_Analytics
AS

WITH UserUsage AS
(
    SELECT
        UserKey,

        -- Usage volume
        COUNT(*) AS TotalUsageEvents,
        SUM(quantity) AS TotalUsageQuantity,

        -- Event type adoption
        COUNT(DISTINCT event_type) AS UniqueEventTypes,

        -- Feature usage
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
        MAX(occurred_at) AS LastActivityAt,

        -- Distinct calendar days with activity
        COUNT(DISTINCT EventDateKey) AS ActiveDays

    FROM dw.FactUsageEvent
    WHERE UserKey <> 0
    GROUP BY UserKey
)

SELECT

    -- =============================================
    -- USER PROFILE
    -- =============================================

    U.UserKey,
    U.user_id,
    U.email,
    U.role,

    -- =============================================
    -- ORGANIZATION PROFILE
    -- =============================================

    O.OrganizationKey,
    O.organization_id,
    O.org_name,
    O.industry,
    O.country,
    O.employee_band,

    -- =============================================
    -- USER LIFECYCLE
    -- =============================================

    U.joined_on,
    U.deactivated_on,

    CASE
        WHEN U.deactivated_on IS NULL THEN 'Active'
        ELSE 'Deactivated'
    END AS user_status,

    -- =============================================
    -- USAGE METRICS
    -- =============================================

    ISNULL(E.TotalUsageEvents, 0) AS TotalUsageEvents,
    ISNULL(E.TotalUsageQuantity, 0) AS TotalUsageQuantity,
    ISNULL(E.UniqueEventTypes, 0) AS UniqueEventTypes,
    ISNULL(E.ActiveDays, 0) AS ActiveDays,

    -- =============================================
    -- FEATURE USAGE
    -- =============================================

    ISNULL(E.ReportRuns, 0) AS ReportRuns,
    ISNULL(E.DashboardViews, 0) AS DashboardViews,
    ISNULL(E.Exports, 0) AS Exports,
    ISNULL(E.APICalls, 0) AS APICalls,
    ISNULL(E.InvitesSent, 0) AS InvitesSent,
    ISNULL(E.IntegrationSyncs, 0) AS IntegrationSyncs,
    ISNULL(E.AlertsFired, 0) AS AlertsFired,

    -- =============================================
    -- ACTIVITY TIMELINE
    -- =============================================

    E.FirstActivityAt,
    E.LastActivityAt,

    -- =============================================
    -- ACTIVATION
    -- =============================================

    CASE
        WHEN E.TotalUsageEvents IS NOT NULL
            THEN 'Activated'
        ELSE 'Not Activated'
    END AS ActivationStatus,

    CASE
        WHEN E.FirstActivityAt IS NOT NULL
        THEN DATEDIFF(
            DAY,
            U.joined_on,
            CAST(E.FirstActivityAt AS DATE)
        )
        ELSE NULL
    END AS DaysToFirstActivity,

    CASE
        WHEN E.FirstActivityAt IS NOT NULL
             AND CAST(E.FirstActivityAt AS DATE) < U.joined_on
            THEN 'Activity Before Join Date'

        WHEN E.FirstActivityAt IS NOT NULL
            THEN 'Valid Activity Sequence'

        ELSE 'No Activity'
    END AS ActivationDateValidation

FROM dw.DimUser U

LEFT JOIN dw.DimOrganization O
    ON U.OrganizationKey = O.OrganizationKey

LEFT JOIN UserUsage E
    ON U.UserKey = E.UserKey

WHERE U.UserKey <> 0;
GO
