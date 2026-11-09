
INSERT INTO ref.MetricCatalog
(
    MetricName,
    MetricCategory,
    BusinessDefinition,
    CalculationLogic,
    SourceView,
    DataGrain,
    Caveats
)
SELECT *
FROM
(
    VALUES
    ('Total Customers', 'Customer', 'Total number of organizations in the dataset.', 'COUNT of organizations.', 'semantic.vw_Organization_360', 'Organization', 'Includes organizations that have never subscribed.'),
    ('Active Customers', 'Customer', 'Organizations with at least one active subscription.', 'Count organizations where ActiveSubscriptions > 0.', 'semantic.vw_Customer_Retention', 'Organization', 'Active subscription means no end date.'),
    ('Churned Customers', 'Customer', 'Organizations with subscriptions but no remaining active subscription.', 'Count organizations where ActiveSubscriptions = 0 and TotalSubscriptions > 0.', 'semantic.vw_Customer_Retention', 'Organization', 'An ended subscription does not automatically mean customer churn.'),
    ('Customer Retention Status', 'Customer', 'Lifecycle classification of an organization.', 'Retained, Churned, or Never Subscribed.', 'semantic.vw_Customer_Retention', 'Organization', 'Based on subscription status, not recent product activity.'),
    ('Customer Tenure', 'Customer', 'Number of days since the organization signed up.', 'DATEDIFF(DAY, SignedUpOn, current date).', 'semantic.vw_Customer_Retention', 'Organization', 'Changes as the current date advances.'),
    ('Total Subscriptions', 'Subscription', 'Total number of subscriptions.', 'COUNT of subscription records.', 'semantic.vw_Subscription_Overview', 'Subscription', NULL),
    ('Active Subscriptions', 'Subscription', 'Subscriptions without an end date.', 'COUNT where EndDateKey = 0.', 'semantic.vw_Subscription_Overview', 'Subscription', 'Active status is based on the source end date.'),
    ('Ended Subscriptions', 'Subscription', 'Subscriptions with an end date.', 'COUNT where EndDateKey <> 0.', 'semantic.vw_Subscription_Overview', 'Subscription', 'Not all ended subscriptions necessarily have a cancellation reason.'),
    ('Cancelled Subscriptions', 'Subscription', 'Subscriptions with a recorded cancellation reason.', 'COUNT where CancelReason IS NOT NULL.', 'semantic.vw_Subscription_Overview', 'Subscription', 'Cancellation is based on the presence of a cancellation reason.'),
    ('Estimated MRR', 'Revenue', 'Estimated monthly recurring subscription run-rate for active subscriptions.', 'Monthly price + (seat price * seats), for active subscriptions.', 'semantic.vw_Revenue_Analytics', 'Subscription', 'Estimated run-rate, not recognized accounting revenue.'),
    ('Estimated ARR', 'Revenue', 'Estimated annual recurring subscription run-rate for active subscriptions.', 'Estimated MRR * 12.', 'semantic.vw_Revenue_Analytics', 'Subscription', 'Derived from estimated MRR, not recognized accounting revenue.'),
    ('Total Paid Amount', 'Revenue', 'Total amount associated with paid invoices.', 'SUM of invoice amounts where invoice status is paid.', 'semantic.vw_Revenue_Analytics', 'Subscription', 'Not equivalent to MRR. Refunds are reported separately.'),
    ('Total Usage Events', 'Engagement', 'Total recorded product usage events.', 'COUNT of usage event records.', 'semantic.vw_Product_Engagement', 'Organization', 'Includes identified and anonymous events.'),
    ('Users With Usage', 'Engagement', 'Distinct identified users with at least one recorded usage event.', 'COUNT DISTINCT UserKey, excluding unknown UserKey = 0.', 'semantic.vw_Product_Engagement', 'Organization', 'Does not include anonymous usage events.'),
    ('User Adoption Rate', 'Engagement', 'Percentage of organization users with at least one attributed usage event.', 'Users With Usage / Total Users * 100.', 'semantic.vw_Product_Engagement', 'Organization', 'Historical adoption, not rolling-period adoption.'),
    ('Total User Events', 'User Analytics', 'Total attributed usage events per identified user.', 'COUNT of usage events grouped by user.', 'semantic.vw_User_Analytics', 'User', 'Excludes anonymous usage events.'),
    ('Activated Users', 'User Analytics', 'Identified users with at least one attributed usage event.', 'Users with at least one usage event.', 'semantic.vw_User_Analytics', 'User', 'Activation is defined by any recorded usage event.'),
    ('Days To First Activity', 'User Analytics', 'Number of days between user registration and first recorded activity.', 'DATEDIFF(DAY, JoinedOn, FirstActivityDate).', 'semantic.vw_User_Analytics', 'User', 'May be negative for source chronology anomalies.')
) AS M
(
    MetricName,
    MetricCategory,
    BusinessDefinition,
    CalculationLogic,
    SourceView,
    DataGrain,
    Caveats
)
WHERE NOT EXISTS
(
    SELECT 1
    FROM ref.MetricCatalog C
    WHERE C.MetricName = M.MetricName
);
GO
