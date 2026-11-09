INSERT INTO ref.BusinessGlossary
(
    TermName,
    Category,
    Definition,
    RelatedMetric,
    Notes
)
SELECT *
FROM
(
    VALUES
    ('Organization', 'Customer', 'A company or business entity registered in the SaaS platform.', 'Total Customers', 'Represents the customer-level reporting entity.'),
    ('Customer', 'Customer', 'An organization using or registered in the SaaS platform.', 'Total Customers', 'One organization represents one customer in this dataset.'),
    ('Customer Retention', 'Customer', 'The continued relationship between a customer organization and the SaaS platform.', 'Active Customers', 'Measured using subscription status.'),
    ('Customer Churn', 'Customer', 'An organization that has ended all its subscriptions and has no active subscription remaining.', 'Churned Customers', 'An organization with at least one active subscription is not considered churned.'),
    ('Customer Tenure', 'Customer', 'The elapsed number of days since an organization registered.', 'Customer Tenure', 'Calculated using the current date.'),
    ('Subscription', 'Subscription', 'A contractual service relationship between an organization and a SaaS plan.', 'Total Subscriptions', 'One organization may have multiple subscriptions.'),
    ('Active Subscription', 'Subscription', 'A subscription record without an end date.', 'Active Subscriptions', 'Based on the source subscription end date.'),
    ('Ended Subscription', 'Subscription', 'A subscription record with an end date.', 'Ended Subscriptions', 'An ended subscription does not necessarily mean customer churn.'),
    ('Cancelled Subscription', 'Subscription', 'A subscription with a recorded cancellation reason.', 'Cancelled Subscriptions', 'Cancellation is identified using cancel_reason.'),
    ('MRR', 'Revenue', 'Estimated monthly recurring subscription run-rate.', 'Estimated MRR', 'Uses monthly plan price plus seat price multiplied by seats. Not recognized accounting revenue.'),
    ('ARR', 'Revenue', 'Estimated annual recurring subscription run-rate.', 'Estimated ARR', 'Calculated as estimated MRR multiplied by 12.'),
    ('Invoice', 'Revenue', 'A billing record associated with a subscription.', 'Total Paid Amount', 'Invoice statuses include paid, failed, refunded, and open.'),
    ('Product Engagement', 'Engagement', 'The recorded interaction of users and organizations with SaaS product features.', 'Total Usage Events', 'Based on historical usage event records.'),
    ('Usage Event', 'Engagement', 'A recorded interaction or activity within the SaaS platform.', 'Total Usage Events', 'Examples include report runs, dashboard views, exports, and API calls.'),
    ('User Adoption', 'Engagement', 'The proportion of identified organization users with at least one attributed usage event.', 'User Adoption Rate', 'Historical adoption, not rolling-period adoption.'),
    ('Activation', 'User Analytics', 'A user who has recorded at least one attributed usage event.', 'Activated Users', 'This project uses a simplified activation definition.'),
    ('Anonymous Usage', 'Engagement', 'A usage event without an associated identified user.', 'Total Usage Events', 'Excluded from identified user-level analytics.'),
    ('Customer Lifecycle', 'Customer', 'The progression of an organization from registration through subscription and retention or churn.', 'Customer Retention Status', 'Lifecycle status is based on subscription records.'),
    ('Data Grain', 'Data Governance', 'The level of detail represented by one row in a dataset or view.', NULL, 'Each semantic view documents its intended grain.'),
    ('Semantic Layer', 'Data Governance', 'A governed collection of business-oriented views and metric definitions.', NULL, 'Provides consistent business logic for reporting and analytics.')
) AS G
(
    TermName,
    Category,
    Definition,
    RelatedMetric,
    Notes
)
WHERE NOT EXISTS
(
    SELECT 1
    FROM ref.BusinessGlossary B
    WHERE B.TermName = G.TermName
);
GO