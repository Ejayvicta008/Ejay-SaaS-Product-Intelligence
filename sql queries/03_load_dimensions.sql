
USE Ejay_SaaS_Product_Intelligence;
GO

-- =============================================
-- 1. LOAD DIM ORGANIZATION
-- =============================================

INSERT INTO dw.DimOrganization
(
    organization_id,
    org_name,
    industry,
    country,
    employee_band,
    signed_up_on,
    acquisition_channel
)
SELECT
    S.organization_id,
    S.org_name,
    S.industry,
    S.country,
    S.employee_band,
    S.signed_up_on,
    S.acquisition_channel
FROM stg.Organizations S
WHERE NOT EXISTS
(
    SELECT 1
    FROM dw.DimOrganization D
    WHERE D.organization_id = S.organization_id
);

PRINT 'DimOrganization loaded';


-- =============================================
-- 2. LOAD DIM PLAN
-- =============================================

INSERT INTO dw.DimPlan
(
    plan_id,
    plan_name,
    tier,
    monthly_price,
    seat_price,
    billing_interval,
    is_active
)
SELECT
    S.plan_id,
    S.plan_name,
    S.tier,
    S.monthly_price,
    S.seat_price,
    S.billing_interval,
    S.is_active
FROM stg.Plans S
WHERE NOT EXISTS
(
    SELECT 1
    FROM dw.DimPlan D
    WHERE D.plan_id = S.plan_id
);

PRINT 'DimPlan loaded';


-- =============================================
-- 3. LOAD DIM USER
-- =============================================

INSERT INTO dw.DimUser
(
    user_id,
    OrganizationKey,
    email,
    role,
    joined_on,
    deactivated_on
)
SELECT
    S.user_id,
    ISNULL(O.OrganizationKey, 0),
    S.email,
    S.role,
    S.joined_on,
    S.deactivated_on
FROM stg.Users S
LEFT JOIN dw.DimOrganization O
    ON S.organization_id = O.organization_id
WHERE NOT EXISTS
(
    SELECT 1
    FROM dw.DimUser D
    WHERE D.user_id = S.user_id
);

PRINT 'DimUser loaded';

GO
