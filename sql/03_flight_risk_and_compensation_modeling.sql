-- ============================================================================
-- SCRIPT 03: Flight Risk Scoring & Compensation Parity Modeling
-- Project: HR Attrition & Workforce Performance Analytics
-- Purpose: Advanced feature engineering for flight risk tags and pay equity views
-- Base Source: v_hr_staging
-- ============================================================================

-- ----------------------------------------------------------------------------
-- SECTION 1: FLIGHT RISK SCORING MODEL (Database View)
-- Targets active headcount to calculate a weighted composite risk index.
-- Risk Levers: Overtime (+2), Low Satisfaction (+2), Long Commute (+1), 
--              Low Hike (+1), Promotion Lag (+2), Bad Work-Life Balance (+2)
-- ----------------------------------------------------------------------------
create or replace view v_flight_risk_model as 
with risk_calculated as (
	select
		employee_number,
        age,
        department,
        job_role,
        job_level,
        monthly_income,
        over_time,
        job_satisfaction,
        distance_from_home,
        percent_salary_hike,
        years_since_last_promotion,
        work_life_balance,
        -- Weighted Risk Index Calculation
        (case when is_overtime = 1 then 2 else 0 end +
         case when job_satisfaction <= 2 then 2 else 0 end +
         case when percent_salary_hike < 12 then 1 else 0 end +
         case when years_since_last_promotion >= 4 then 2 else 0 end +        
         case when work_life_balance = 1 then 2 else 0 end) as risk_score        
	from v_hr_staging
	where is_attrition = 0 -- Excludes departed staff to focus on active retention
)

select 
	employee_number,
    age,
    department,
    job_role,
    job_level,
    monthly_income,
    over_time,
    job_satisfaction,
    distance_from_home,
    percent_salary_hike,
    years_since_last_promotion,
    work_life_balance,
    risk_score,	
    case
    	when risk_score >= 6 then 'High Flight Risk'
        when risk_score between 3 and 5 then 'Medium Flight Risk'
        else 'Low Flight Risk'
    end as risk_category
from risk_calculated;
--Exporting our data for Excel analysis
select * from v_flight_risk_model
    
    
-- ----------------------------------------------------------------------------
-- SECTION 2: GENDER PAY PARITY & ROLE BENCHMARKING (Database View)
-- Analyzes compensation gaps across Job Roles and Gender 
-- ----------------------------------------------------------------------------
create or replace view v_compensation_parity as 
select 
	job_role,
	gender,
	count(employee_number) as total_employees,
	round(avg(monthly_income) * 100 , 2) as avg_monthly_income,
	round(avg(percent_salary_hike), 2) as avg_hike_pct,
	round( 
		avg(monthly_income) - avg(avg(monthly_income)) over(partition by job_role),
		2		
	)as variance_from_role_avg

from v_hr_staging
group by job_role, gender
order by variance_from_role_avg desc;
    
select * from v_compensation_parity