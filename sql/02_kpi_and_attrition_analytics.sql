-- ============================================================================
-- SCRIPT 02: Executive KPIs & Core Attrition Drivers
-- Project: HR Attrition & Workforce Performance Analytics
-- Purpose: Extract summary KPIs and breakdown analytics for Excel Dashboards
-- Base Source: v_hr_staging
-- ============================================================================
select * from v_hr_staging limit 20;
-- ----------------------------------------------------------------------------
-- SECTION 1: EXECUTIVE OVERVIEW KPIS
-- Top Summary KPI Cards
-- ----------------------------------------------------------------------------

select 
	count(employee_number) as total_employees,
	sum(case when is_attrition = 0 then 1 else 0 end) as active_employees,
	sum(is_attrition) as terminated_employees,
	round(avg(is_attrition) * 100 , 2) overall_attrition_rate_pct,
	round(avg(monthly_income) * 100 , 2) as avg_monthly_income,
	round(avg(age), 1  ) as avg_employee_age
from v_hr_staging 
	
-- ----------------------------------------------------------------------------
-- SECTION 2: ATTRITION BY DEPARTMENT & JOB ROLE
-- Target Dashboard: Department Breakdown Bar Chart & Role Risk Table
-- ----------------------------------------------------------------------------
-- 2.1 By Department

select 
	department,
	count(employee_number) as total_employees,
	SUM(is_attrition) as attrition_count,
	sum(case when is_attrition = 0 then 1 else 0 end) as active_employees,
	round(avg(is_attrition) * 100 , 2) overall_attrition_rate_pct
from v_hr_staging 
group by department 
order by overall_attrition_rate_pct desc;

-- 2.2 By Job Role (Nested under Department)
select 
	department,
	job_role,
	count(employee_number) as total_employees,
	sum(is_attrition) as attrition_count,
	sum(case when is_attrition = 0 then 1 else 0 end) as active_employees,
	round(avg(is_attrition) * 100 , 2) overall_attrition_rate_pct,
	round(avg(monthly_income) * 100 , 2) as avg_monthly_income
from v_hr_staging 
group by department, job_role
order by department, overall_attrition_rate_pct desc;

-- ----------------------------------------------------------------------------
-- SECTION 3: ATTRITION BY COMPENSATION QUARTILES 
-- Target Dashboard: Income vs. Churn Distribution Chart
-- ----------------------------------------------------------------------------

with income_quartiles as (
	select
		employee_number,
		monthly_income,
		is_attrition,
		ntile(4) over (order by monthly_income asc) as income_quartile
	from v_hr_staging 
)

select  
	income_quartile,
	case
		when income_quartile = 1 then 'Q1 (Lowest Pay)'
		when income_quartile = 2 then 'Q2 (Mid-Low Pay)'
		when income_quartile = 3 then 'Q3 (Mid-High Pay)'
		when income_quartile = 4 then 'Q4 (Highest Pay)'
	end as quartile_label,
	min(monthly_income) as min_income,
	max(monthly_income) as max_income,
	count(employee_number) as total_employees,
	sum(is_attrition) as terminated_employees,
	round(avg(is_attrition) * 100 , 2) overall_attrition_rate_pct
from income_quartiles
group by income_quartile
order by income_quartile;

-- ----------------------------------------------------------------------------
-- SECTION 4: ATTRITION BY OVERTIME & WORK-LIFE BALANCE
-- Target Dashboard: Workload vs. Retention Comparison Grid
-- ----------------------------------------------------------------------------

-- 4.1 Impact of Overtime alone
select 
	over_time,
	count(employee_number) as total_employees,
	sum(is_attrition) as attrition_count,
	round(avg(is_attrition) * 100 , 2) as overall_attrition_rate_pct
from v_hr_staging 
group by over_time 
order by overall_attrition_rate_pct desc;

-- 4.2 Cross-Tab: Overtime vs. Work-Life Balance Rating (1 = Low, 4 = Best)
select 
	over_time,
	work_life_balance,
	case 
		when work_life_balance = 1 then '1 - Bad'
		when work_life_balance = 2 then '2 - Good'
		when work_life_balance = 3 then '3 - Better'
		when work_life_balance = 4 then '4 - Best'
	end as work_life_balance_label,
	count(employee_number) as total_employees,
	sum(is_attrition) as attrition_count,
	round(avg(is_attrition) * 100 , 2) as overall_attrition_rate_pct
from v_hr_staging 
group by over_time,  work_life_balance
order by over_time desc, work_life_balance asc;
	
-- ----------------------------------------------------------------------------
-- SECTION 5: ATTRITION BY TENURE & MANAGER RELATIONSHIP
-- Target Dashboard: Retention Bottlenecks / Cohort Analysis
-- ----------------------------------------------------------------------------
-- 5.1 Tenure Buckets at Company

select 
	case
		when years_at_company < 2 then '0-1 Years (New Hires)'
        when years_at_company between 2 and 5 then '2-5 Years (Mid-Tenure)'
        when years_at_company between 6 and 10 then '6-10 Years (Established)'
        else '10+ Years (Veterans)'
    end as tenure_bucket,
	count(employee_number) as total_employees,
	sum(is_attrition) as attrition_count,
	round(avg(is_attrition) * 100 , 2) as overall_attrition_rate_pct
from v_hr_staging 
group by 1
order by min(years_at_company);
		
-- 5.2 Tenure under Current Manager
select 
	case
		when years_with_curr_manager < 1 then '< 1 Year with Manager'
        when years_with_curr_manager between 1 and 3 then '1-3 Years with Manager'
        when years_with_curr_manager between 4 and 7 then '4-7 Years with Manager'
        else '7+ Years with Manager'
    end as manager_tenure_bucket,
	count(employee_number) as total_employees,
	sum(is_attrition) as attrition_count,
	round(avg(is_attrition) * 100 , 2) as overall_attrition_rate_pct
from v_hr_staging 
group by 1
order by min(years_with_curr_manager);
		

-- ----------------------------------------------------------------------------
-- SECTION 6: DEMOGRAPHICS & PERSONAL PROFILE (Age, Gender, Marital Status)
-- ----------------------------------------------------------------------------
-- 6.1 Age Group Segmentation

select 
	case 
		when age < 30 then 'Under 30'
		when age between 30 and 39 then '30-39'
		when age between 40 and 49 then '40-49'
		else '50+'
	end as age_label,
	count(employee_number) as total_employees,
	sum(is_attrition) as attrition_count,
	round(avg(is_attrition) * 100 , 2) as overall_attrition_rate_pct,
	round(avg(monthly_income) * 100 , 2) as avg_monthly_income
from v_hr_staging 
group by 1
order by min(age);

-- 6.2 Gender & Marital Status Cross-Tabulation
select 
	gender,
	marital_status,
	count(employee_number) as total_employees,
	sum(is_attrition) as attrition_count,
	round(avg(is_attrition) * 100 , 2) as overall_attrition_rate_pct,
	round(avg(monthly_income) * 100 , 2) as avg_monthly_income
from v_hr_staging 
group by gender, marital_status
order by gender, overall_attrition_rate_pct desc;

-- ----------------------------------------------------------------------------
-- SECTION 7: COMMUTE & TRAVEL (BusinessTravel, DistanceFromHome)
-- ----------------------------------------------------------------------------
-- 7.1 Travel Frequency Impact
select 
	business_travel,
	count(employee_number) as total_employees,
	sum(is_attrition) as attrition_count,
	round(avg(is_attrition) * 100 , 2) as overall_attrition_rate_pct
from v_hr_staging 
group by business_travel
order by overall_attrition_rate_pct desc;

-- 7.2 Distance From Home Buckets
select 
	case 
		when distance_from_home  <=5 then '1. Near (0-5 miles)'
		when distance_from_home between 6 and 15 then '2. Moderate (6-15 miles)'
		when distance_from_home between 16 and 25 then'3. Far (16-25 miles)'
		else '4. Extreme (25+ miles)'
	end as commute_distance_bucket,
	count(employee_number) as total_employees,
	sum(is_attrition) as attrition_count,
	round(avg(is_attrition) * 100 , 2) as overall_attrition_rate_pct,
	round(avg(monthly_income) * 100 , 2) as avg_monthly_income
from v_hr_staging 
group by 1
order by overall_attrition_rate_pct desc;
 
-- ----------------------------------------------------------------------------
-- SECTION 8: EDUCATION & BACKGROUND (Education Level, EducationField)
-- ----------------------------------------------------------------------------
select
	education_field,
	case 
		when education = 1  then 'Below College'
		when education = 2  then 'College'
		when education = 3  then 'Bachelor'
		when education = 4  then 'Master'
		when education = 5  then 'Doctor'
	end as education_level_bucket,
	count(employee_number) as total_employees,
	sum(is_attrition) as attrition_count,
	round(avg(is_attrition) * 100 , 2) as overall_attrition_rate_pct,
	round(avg(monthly_income) * 100 , 2) as avg_monthly_income
from v_hr_staging 
group by education_field, education
order by education_field, education ;

-- ----------------------------------------------------------------------------
-- SECTION 9: SATISFACTION & INVOLVEMENT MATRIX
-- (EnvironmentSatisfaction, JobInvolvement, JobSatisfaction, RelationshipSatisfaction)
-- ----------------------------------------------------------------------------
select 
	environment_satisfaction,
    job_involvement,
    job_satisfaction,
    relationship_satisfaction,
	count(employee_number) as total_employees,
	sum(is_attrition) as attrition_count,
	round(avg(is_attrition) * 100 , 2) as overall_attrition_rate_pct,
	round(avg(monthly_income) * 100 , 2) as avg_monthly_income
from v_hr_staging 
group by environment_satisfaction, job_involvement,job_satisfaction,relationship_satisfaction
having count(employee_number) >5 -- Filtering out rare single-employee combinations
order by overall_attrition_rate_pct desc;

-- ----------------------------------------------------------------------------
-- SECTION 10: CAREER GROWTH & PROMOTION VELOCITY
-- ----------------------------------------------------------------------------
-- 10.1 Promotion Lag & Stock Options
select 
    job_level,
    stock_option_level,
    case 
        when years_since_last_promotion = 0 then 'Promoted This Year'
        when years_since_last_promotion between 1 and 3 then '1-3 Years Ago'
        when years_since_last_promotion between 4 and 7 then '4-7 Years Ago'
        else '8+ Years (Stagnant)'
    end as promotion_lag_bucket,
    count(employee_number) as total_employees,
	sum(is_attrition) as attrition_count,
	round(avg(is_attrition) * 100 , 2) as overall_attrition_rate_pct
from v_hr_staging
group by job_level, stock_option_level, 3
order by job_level, stock_option_level;

-- ----------------------------------------------------------------------------
-- SECTION 11: Cumulative Attrition & Percentile Rank Within Department
-- ----------------------------------------------------------------------------
/*
 * Ranks employees by salary within their department and tracks the cumulative attrition rate as income increases to 
 * pinpoint the exact income percentile where turnover spikes.
 */
with ranked_employees as (
	select
		department,
    	employee_number,
    	monthly_income,
    	is_attrition,
    	percent_rank() over(
    		partition by department
    		order by monthly_income asc
    	) as income_percentile_in_dept
	from v_hr_staging
)

select 
	department,
	round(cast(income_percentile_in_dept as numeric), 2) as income_percentile,
	count(employee_number) as total_employees,
	sum(is_attrition) as attrition_count
from ranked_employees
group by department, round(cast(income_percentile_in_dept as numeric), 2)
order by department, income_percentile;	

-- ----------------------------------------------------------------------------
-- SECTION 12: Multi-Factor "Burnout & Stagnation" Cross-Cohort Matrix
-- ----------------------------------------------------------------------------
/*
 * Combines Overtime, Low Satisfaction (< 3), and Promotion Stagnation (>= 4$ years) into composite cohorts to 
 * isolate compound risk drivers.
*/
select 
	department,
	count(employee_number) as total_employees,
	-- Cohort 1: High Workload + Low Satisfaction
	count(employee_number) filter (where is_overtime = 1 and job_satisfaction <= 2) as burnout_risk_headcount,
	round(avg(is_attrition) filter (where is_overtime = 1 and job_satisfaction <= 2) * 100, 2) as burnout_attrition_rate,
	-- Cohort 2: Promotion Stagnation + Low Hike
	count(employee_number) filter (where years_since_last_promotion >= 4 and percent_salary_hike < 12) as stagnation_risk_headcount,
    round(avg(is_attrition) filter (where years_since_last_promotion >= 4 and percent_salary_hike < 12) * 100, 2) as stagnation_attrition_rate
from v_hr_staging
group by department
order by total_employees DESC;

 
 
