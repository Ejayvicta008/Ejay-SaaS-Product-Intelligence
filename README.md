# SaaS Product Intelligence Platform

An end-to-end Business Intelligence and Product Analytics project built using Python, SQL Server, Tableau, and Power BI.

The project transforms SaaS subscription, customer, invoice, and product usage data into a structured analytics platform. It demonstrates how raw operational data can be transformed into reliable business metrics and interactive dashboards.

## Project Overview

The objective is to build a centralized analytics platform that helps answer key SaaS business questions:

- How many customers are actively using the platform?
- How much recurring revenue is being generated?
- Which customers and users are adopting the product?
- Which product features are receiving the most engagement?
- How many customers are churning?
- How long does it take for a new customer to subscribe?
- What patterns can help explain customer retention and churn?

The project follows an end-to-end data workflow, from source data profiling to warehouse development and BI reporting.

## Technology Stack

| Area | Technology |
|---|---|
| Data Source | SQLShed SaaS Practice Dataset |
| Programming | Python |
| Data Processing | Pandas, NumPy, PyArrow |
| Database | Microsoft SQL Server |
| Database Connectivity | SQLAlchemy, pyodbc |
| Data Modeling | Dimensional Modeling / Star Schema |
| Analytics Layer | SQL Server Views |
| Data Visualization | Tableau Desktop, Power BI |
| Version Control | Git / GitHub |

## Data Source

The primary dataset comes from the SQLShed SaaS Subscription and Usage dataset.

It contains six Parquet files:

| Dataset | Records | Description |
|---|---:|---|
| Plans | 8 | SaaS subscription plans and pricing |
| Organizations | 3,000 | Customer organization information |
| Users | 26,000 | Organization users and account roles |
| Subscriptions | 4,200 | Subscription history and cancellation details |
| Invoices | 46,000 | Customer billing and invoice records |
| Usage Events | 180,000 | Product activity and usage events |
| **Total** | **259,208** | |

**License:** CC0 1.0 Universal.

The original source files are retained separately from processed data.

Additional synthetic datasets may be introduced for CRM reconciliation, product telemetry, and Voice of Customer analysis. Any generated data will be clearly identified as synthetic.

## Data Architecture

The project follows a layered architecture:


Source Data (Parquet)
        |
        v
Python Data Processing
        |
        v
SQL Server Staging
        |
        v
Data Warehouse
        |
        +-- Dimensions
        |     +-- DimOrganization
        |     +-- DimUser
        |     +-- DimPlan
        |     +-- DimDate
        |
        +-- Fact Tables
        |     +-- FactSubscription
        |     +-- FactInvoice
        |     +-- FactUsageEvent
        |
        v
Semantic Layer
        |
        +-- Organization 360
        +-- Subscription Overview
        +-- Revenue Analytics
        +-- Product Engagement
        +-- User Analytics
        +-- Customer Retention
        |
        v
BI Reporting
        |
        +-- Tableau
        +-- Power BI


## Key Analytics Areas

### 1. Customer Overview
- Total customers
- Active customers
- Churned customers
- Total users
- Customer distribution by industry and country
- Customer acquisition channels

### 2. Revenue Analytics
- Estimated Monthly Recurring Revenue (MRR)
- Estimated Annual Recurring Revenue (ARR)
- Total paid invoice amount
- Refunded amounts
- Revenue by subscription plan and tier
- Invoice status analysis

### 3. Product Engagement
- Total product usage events
- Identified versus anonymous events
- User adoption rate
- Product activity by event type
- Most engaged customers
- User activation analysis

### 4. Customer Retention
- Retained customers
- Churned customers
- Customer retention rate
- Customer churn rate
- Subscription lifecycle
- Cancellation reasons
- Customer tenure

## Metric Governance

Business metrics are defined centrally through SQL Server reference tables.

- `ref.MetricCatalog` – metric definitions, calculation logic, source views, and business caveats.
- `ref.BusinessGlossary` – standardized business terminology and definitions.

The objective is to maintain consistent metric definitions across Tableau and Power BI.

## Data Quality and Validation

Data profiling and validation were performed before and after warehouse loading.

Key validation results:

| Validation | Result |
|---|---:|
| Source records profiled | 259,208 |
| Primary key violations | 0 |
| Foreign key orphan records | 0 |
| Invalid subscription date sequences identified | 23 |
| Invalid user date sequences identified | 2 |
| Staging-to-warehouse fact count differences | 0 |
| Warehouse constraint validation | Passed |

Data anomalies were investigated and documented rather than silently removed or modified.

An audit framework was also implemented to record execution details and data quality results.

## Project Structure


Ejay-SaaS-Product-Intelligence/
│
├── data/
│   ├── raw/
│   ├── processed/
│   └── reference/
│
├── python/
│
├── sql/
│   ├── 01_database/
│   ├── 02_staging/
│   ├── 03_warehouse/
│   ├── 04_semantic/
│   └── 05_quality_checks/
│
├── dashboards/
│   ├── tableau/
│   └── powerbi/
│
├── documentation/
│
├── tests/
│   ├── data_quality/
│   ├── reconciliation/
│   └── metric_validation/
│
└── README.md


## Current Project Status

The core data warehouse and semantic layer have been implemented and validated.

| Component | Status |
|---|---|
| Source data acquisition | Completed |
| Data profiling | Completed |
| Python staging loader | Implemented |
| SQL Server staging | Completed |
| Dimensional warehouse | Completed |
| Fact tables | Completed |
| Semantic views | Completed |
| Metric catalog and business glossary | Implemented |
| Data quality validation | Implemented; automation ongoing |
| Tableau dashboards | In Progress |
| Power BI dashboards | In Progress |
| GitHub version control | In Progress |
| Automated ETL orchestration | Planned |
| CRM and VoC supplements | Planned |
| AI-assisted metric validation | Planned |

## Important Metric Definitions and Limitations

- **Active Customer:** An organization with at least one subscription without an end date.
- **Churned Customer:** An organization with subscriptions but no active subscription.
- **Estimated MRR:** Estimated monthly subscription run-rate based on plan pricing and seats for active subscriptions.
- **Estimated ARR:** Estimated MRR multiplied by 12.
- **User Adoption Rate:** Identified users with usage divided by total users.
- **Activated User:** A user with at least one attributed product usage event.

These metrics are based on the available dataset and documented business rules.

The revenue measures represent estimated subscription run-rate, not recognized accounting revenue. Historical usage data is not automatically equivalent to rolling 7-day or 30-day active-user metrics.

## Project Objectives

This project is intended to demonstrate practical skills in:

- SQL development and advanced querying
- Python-based data ingestion and processing
- Data warehouse design and dimensional modeling
- Data quality and source-to-target reconciliation
- Semantic layer development and metric governance
- Product analytics and customer lifecycle analysis
- Tableau and Power BI dashboard development
- Technical documentation and version control

## Disclaimer

This is an independent portfolio project using a publicly available practice dataset.

The project does not represent actual customer data, production systems, or integrations with commercial SaaS platforms. Any future supplemental datasets generated for demonstration purposes will be explicitly labeled synthetic.


**Author:** Ejay  
**Project:** SaaS Product Intelligence Platform
