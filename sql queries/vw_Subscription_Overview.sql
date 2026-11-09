
USE Ejay_SaaS_Product_Intelligence;
GO

CREATE OR ALTER VIEW semantic.vw_Subscription_Overview
AS

SELECT
    -- =============================================
    -- SUBSCRIPTION IDENTIFICATION
    -- =============================================

    F.subscription_id,

    -- =============================================
    -- ORGANIZATION
    -- =============================================

    O.OrganizationKey,
    O.organization_id,
    O.org_name,
    O.industry,
    O.country,
    O.employee_band,
    O.acquisition_channel,

    -- =============================================
    -- PLAN DETAILS
    -- =============================================

    P.PlanKey,
    P.plan_id,
    P.plan_name,
    P.tier,
    P.billing_interval,
    P.monthly_price,
    P.seat_price,

    -- =============================================
    -- SUBSCRIPTION DETAILS
    -- =============================================

    F.seats,
    DS.FullDate AS started_on,
    DE.FullDate AS ended_on,

    -- =============================================
    -- SUBSCRIPTION STATUS
    -- =============================================

    CASE
        WHEN F.EndDateKey = 0 THEN 'Active'
        ELSE 'Ended'
    END AS subscription_status,

    CASE
        WHEN F.cancel_reason IS NOT NULL THEN 1
        ELSE 0
    END AS is_cancelled,

    F.cancel_reason,

    -- =============================================
    -- SUBSCRIPTION DURATION
    -- =============================================

    CASE
        WHEN F.EndDateKey <> 0
        THEN DATEDIFF(DAY, DS.FullDate, DE.FullDate)
        ELSE NULL
    END AS subscription_duration_days

FROM dw.FactSubscription F

LEFT JOIN dw.DimOrganization O
    ON F.OrganizationKey = O.OrganizationKey

LEFT JOIN dw.DimPlan P
    ON F.PlanKey = P.PlanKey

LEFT JOIN dw.DimDate DS
    ON F.StartDateKey = DS.DateKey

LEFT JOIN dw.DimDate DE
    ON F.EndDateKey = DE.DateKey;
GO
