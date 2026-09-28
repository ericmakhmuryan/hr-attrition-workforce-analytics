#  Executive HR Attrition & Workforce Flight Risk Analytics

[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL%2015+-336791?style=for-the-badge&logo=postgresql&logoColor=white)](#)
[![Excel](https://img.shields.io/badge/Analytics-Microsoft%20Excel-217346?style=for-the-badge&logo=microsoftexcel&logoColor=white)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](#)

[View Live Insights](#-executive-summary--core-findings) • [Architecture](#-architecture--technical-data-pipeline) • [Database Setup](#-8-local-replication--setup-guide)

An end-to-end enterprise workforce analytics solution engineered to diagnose organizational attrition drivers, assess pay equity gaps, and model active flight risk across enterprise talent cohorts. Built using a decoupled architecture with a **PostgreSQL** relational database backend and an interactive **Microsoft Excel** Executive Dashboard.

---

##  Executive Dashboard Preview

![HR Executive Dashboard](visualization/dashboard_preview.png)

---

##  Table of Contents
1. [Project Overview & Business Problem](#-project-overview--business-problem)
2. [Executive Summary & Core Findings](#-executive-summary--core-findings)
3. [Architecture & Technical Data Pipeline](#-architecture--technical-data-pipeline)
4. [Database Schema & SQL Engineering](#-database-schema--sql-engineering)
5. [Excel Data Engine & Dashboard Design](#-excel-data-engine--dashboard-design)
6. [Repository Structure](#-repository-structure)
7. [Strategic HR Recommendations](#-strategic-hr-recommendations)


---

##  Project Overview & Business Problem

Unplanned employee attrition poses significant financial and operational challenges, including recruiting costs, lost productivity, and diminished team morale. This project analyzes **1,470 employee records** to answer three critical executive questions:


1. **What are the primary operational drivers of voluntary turnover?**
2. **Which active employees represent the highest immediate flight risk?**
3. **How do compensation variance and overtime demands compound attrition rates?**

By integrating relational SQL modeling with interactive Excel dashboarding, this solution transitions raw HR administrative data into predictive, actionable talent retention strategies.

---

##  Executive Summary & Core Findings

### Key Performance Indicators (KPIs)
* **Total Headcount Analyzed:** 1,470 Records
* **Active Workforce:** 1,233 Employees
* **Total Historical Terminations:** 237 Exits
* **Baseline Organizational Attrition Rate:** 16.12%
* **Average Monthly Income:** $6,503 / month

### Key Analytical Insights

1. **Overtime Workload as the Primary Attrition Driver:**
   * Staff assigned to regular overtime experience a **30.5% attrition rate**—nearly **3x higher** than non-overtime staff (**10.4%**).
   * **45.5% Peak Turnover:** Attrition reaches its global maximum when mandatory overtime coincides with a Level 1 ("Bad") Work-Life Balance rating.
   * **Mitigation Buffer:** Improving work-life balance satisfaction from Level 1 to Level 3 reduces overtime turnover down to **28.7%**.

2. **Active High Flight Risk Cohort:**
   * The multi-factor predictive risk model identifies **33 active employees** with a critical flight risk score ($\ge 6$).
   * Risk is heavily concentrated in **Research & Development (26 staff)** and **Sales (6 staff)**.
   * Primary risk vectors: Low annual salary hikes ($<12\%$), low job satisfaction ($\le 2$), and promotion stagnation ($\ge 4$ years in current role).

3. **Compensation & Equity Dynamics:**
   * Turnover is significantly higher among staff earning below their role's benchmark average.
   * Mid-level roles experiencing stagnant pay hikes ($<12\%$) exhibit a 22% higher probability of voluntary departure within 12 months.

---

##  Architecture & Technical Data Pipeline

This solution uses a decoupled architecture to optimize computational performance and maintain analytical flexibility:
![Data Pipeline Architecture](visualization/pipeline_architecture.png)


##  4. Database Schema & SQL Engineering

The backend architecture uses modular PostgreSQL scripts to transform raw HR data into clean analytical staging views, operational KPIs, and risk models.

### 4.1 Schema Setup & Staging (`sql/01_schema_and_staging.sql`)
* Creates the primary database table schema (`hr_data`) and imports raw employee records.
* Establishes the core staging view (`v_hr_staging`) to handle data type casting, string normalization, and data sanitization.
* Generates binary analytics flags (`is_attrition`, `is_overtime`) to simplify downstream aggregations and filters.

### 4.2 Attrition Analytics & KPIs (`sql/02_kpi_and_attrition_analytics.sql`)
* Calculates baseline organizational turnover metrics, including total headcount, active workforce, total historical terminations, and overall attrition rate.
* Aggregates attrition percentages cross-tabulated by department, job role, and marital status.
* Evaluates the operational impact of mandatory overtime and work-life balance satisfaction levels on employee turnover.

### 4.3 Flight Risk & Compensation Modeling (`sql/03_flight_risk_and_compensation_modeling.sql`)
* **Multi-Factor Flight Risk Engine (`v_flight_risk_analytics`):** Applies a weighted scoring algorithm (evaluating overtime demands, promotion stagnation $\ge 4$ years, low salary hikes $<12\%$, and low job satisfaction) to categorize active employees into **High**, **Medium**, and **Low** flight risk tiers.
* **Pay Equity & Salary Variance Analytics (`v_pay_equity_analytics`):** Leverages PostgreSQL window functions (`AVG() OVER`) to benchmark individual monthly incomes against departmental and role averages, highlighting compensation compression points.

##  5. Excel Data Engine & Dashboard Design

The presentation layer is organized into three distinct workbook functional zones:

### 5.1 Data Ingestion & Formatting Layer
* **`hr_staging_master` (`tbl_HR_Staging`):** Contains 1,470 employee records imported via Power Query. Numeric fields are configured with standard integer, percentage, and currency formats.
* **`flight_risk_export` (`tbl_Flight_Risk`):** Stores risk scoring calculations and active flight risk tiers exported from the SQL model.
* **`pay_equity_export` (`tbl_Pay_Parity`):** Tracks salary distribution benchmarks and compensation variance across job titles.

### 5.2 Pivot Aggregation Engine (`Pivot_Engine` Tab)
Houses four structured Pivot Tables driving all visual dashboard components:
* **Pivot Table 1 (KPI Metrics - Range `A3:D4`):** Aggregates Total Headcount (`1,470`), Active Workforce (`1,233`), Terminations (`237`), Attrition Rate (`16.12%`), and Average Monthly Income (`$6,503`).
* **Pivot Table 2 (Department Attrition - Range `E3:G6`):** Groups headcount and turnover rate across Human Resources, Research & Development, and Sales.
* **Pivot Table 3 (Overtime vs. Work-Life Matrix - Range `I3:M5`):** Calculates attrition percentages across Overtime (`Yes`/`No`) cross-tabulated with Work-Life Balance levels (`1 - Bad` to `4 - Best`).
* **Pivot Table 4 (Flight Risk Grid - Range `N3:Q6`):** Summarizes active workforce distribution across `High Flight Risk`, `Medium Flight Risk`, and `Low Flight Risk` categories by department.

### 5.3 Presentation UI (`Dashboard` Tab)
* **Executive Banner:** Dark Slate (`#1E293B`) top container across range `A1:N2`.
* **Summary KPI Cards:** 5 card containers spanning `C4:L5` displaying dynamic references to the `Pivot_Engine` tab.
* **Visualizations:**
  * **Attrition Rate by Department:** Horizontal Bar Chart (`C8:H18`).
  * **Workforce Flight Risk Heatmap:** Dynamic grid (`I8:L12`) utilizing Conditional Formatting 3-Color Scales (Red-Yellow-Green).
  * **Overtime vs. Work-Life Balance Attrition Chart:** 2D Clustered Column Chart (`C20:L32`).
* **Interactive Control Panel:** Left sidebar (`Columns A–B`) containing 3 connected Slicers (`department`, `job_role`, `gender`) synchronized via Report Connections across all four Pivot Tables.

##  6. Repository Structure

```text
hr-attrition-workforce-analytics/
│
├── data/
│   └── hr_data.csv                       # Raw source dataset (1,470 records)
│
├── sql/
│   ├── 01_schema_and_staging.sql          # Table DDL & staging view creation
│   ├── 02_kpi_and_attrition_analytics.sql# Core turnover KPIs & departmental metrics
│   └── 03_flight_risk_and_compensation_modeling.sql # Predictive scoring & pay equity
│
├── excel/
│   ├── flight_risk_export.csv            # Engineered CSV export for flight risk
│   ├── hr_staging_master.csv             # Cleaned staging CSV export
│   └── pay_equity_export.csv             # Compensation analytics CSV export
│
├── visualization/
│   ├── hr_workforce_analytics_dashboard.xlsx # Primary Excel Engine & Dashboard
│   └── dashboard_preview.png             # Executive Dashboard screenshot
│
├── LICENSE                               # MIT Open-Source License
└── README.md                             # Project documentation
```

## 7. Strategic HR Recommendations

Based on empirical modeling, organizational leadership should execute three immediate interventions:

1. **Implement Overtime Guardrails in High-Volume Roles:**
   Mandate strict weekly overtime caps in Research & Development and Sales. Establish workload re-balancing protocols for any employee reporting a Level 1 ("Bad") or Level 2 ("Good") Work-Life Balance score to mitigate burnout-driven turnover.
2. **Deploy Targeted Retention Budgets to High Flight Risk Cohort:**
   Direct immediate off-cycle compensation reviews and retention agreements toward the **33 High Flight Risk personnel**, prioritizing employees facing promotion stagnation ($\ge 4$ years in role) and low salary hikes ($<12\%$).
3. **Establish Structured Horizontal Mobility Tracks:**
   Create internal lateral career pathways for mid-level staff nearing compensation ceilings, allowing skill development and internal progression without requiring management openings.

---
