-- ============================================================================
-- SCRIPT 01: Schema Setup, Data Staging & Data Sanity Checks
-- Project: HR Attrition & Workforce Performance Analytics
-- Dataset: IBM HR Analytics Employee Attrition & Performance
-- Target Database: PostgreSQL
-- ============================================================================

-- ----------------------------------------------------------------------------
-- STEP 1: DROPPING TABLE & CREATING SCHEMA
-- ----------------------------------------------------------------------------
drop table if exists hr_data

--We import our csv file using Dbeaver application
--Creating our hr_analytics_db database 
--Schemas --> Tables, right clicking on Tables and using Import Data tool
--Checking for data
select * from hr_data 

--Changing  datatypes for each columns
alter table hr_data 
alter column age type int,
alter column attrition type varchar(10),
alter column businesstravel type varchar(50),
alter column dailyrate type int,
alter column department type varchar(50),
alter column distancefromhome type int,
alter column education type int,
alter column educationfield type varchar(50),
alter column employeecount type int,
alter column employeenumber type int,
alter column environmentsatisfaction type int,
alter column gender type varchar(10),
alter column hourlyrate type int,
alter column jobinvolvement type int,
alter column joblevel type int,
alter column jobrole type varchar(50),
alter column jobsatisfaction type int,
alter column maritalstatus type varchar(20),
alter column monthlyincome type int,
alter column monthlyrate type int,
alter column numcompaniesworked type int,
alter column over18 type varchar(5),
alter column overtime type varchar(5),
alter column percentsalaryhike type int,
alter column performancerating type int,
alter column relationshipsatisfaction type int,
alter column standardhours type int,
alter column stockoptionlevel type int,
alter column totalworkingyears type int,
alter column trainingtimeslastyear type int,
alter column worklifebalance type int,
alter column yearsatcompany type int,
alter column yearsincurrentrole type int,
alter column yearssincelastpromotion type int,
alter column yearswithcurrmanager type int;

--Adding primary key to employeenumber, they should be unique and not null
alter table hr_data 
add primary key (employeenumber);

-- ----------------------------------------------------------------------------
-- STEP 2: DATA SANITY & INTEGRITY CHECKS
-- ----------------------------------------------------------------------------
--Confirming that nulls are completely cleared in key analytical columns
select 
count(*) as total_rows,
count(attrition) as valid_attrition,
count(employeenumber) as valid_employee_ids,
count(monthlyincome) as valid_incomes,
count(department) as valid_departments,
count(jobrole) as valid_jobrole
from hr_data 

--Inspecting Unique Categorical Values for Data Consistency
select distinct department from hr_data order by department;
select distinct jobrole from hr_data order by jobrole;
select distinct attrition from hr_data;
select distinct businesstravel from hr_data;
select distinct educationfield  from hr_data order by educationfield;

--Identifing & Confirming Redundant / Zero-Variance Columns
-- Columns where DISTINCT count = 1 provide zero predictive value and will be excluded in downstream modeling.
select 
    count(distinct over18) as unique_over_18,          -- Always 'Y'
    count(distinct standardhours) as unique_std_hours, -- Always 80
    count(distinct employeecount) as unique_emp_count  -- Always 1
from hr_data;

-- ----------------------------------------------------------------------------
-- STEP 3: CREATING STAGING VIEW (CLEANED BASE TABLE)
-- Drops zero-variance columns and standardizes attrition flag to numeric binary (1/0)
/* 
 The raw dataset contains zero-variance columns (over18, standardhours, employeecount) that hold the exact same value
 across all 1,470 rows. Dropping them in our view keeps our dataset lean, uncluttered, and easier to navigate when 
 querying or exporting to Excel.
 */
-- ----------------------------------------------------------------------------

create or replace view v_hr_staging as
select
	employeenumber as employee_number,
    age,
    attrition,
    case when lower(attrition) = 'yes' then 1 else 0 end as is_attrition,
    department,
    jobrole as job_role,
    joblevel as job_level,
    education,
    educationfield as education_field,
    gender,
    maritalstatus as marital_status,
    businesstravel as business_travel,
    distancefromhome as distance_from_home,
    monthlyincome as monthly_income,
    percentsalaryhike as percent_salary_hike,
    numcompaniesworked as num_companies_worked,
    overtime as over_time,
    case when lower(overtime) = 'yes' then 1 else 0 end as is_overtime,
    performancerating as performance_rating,
    environmentsatisfaction as environment_satisfaction,
    jobinvolvement as job_involvement,
    jobsatisfaction as job_satisfaction,
    relationshipsatisfaction as relationship_satisfaction,
    worklifebalance as work_life_balance,
    stockoptionlevel as stock_option_level,
    totalworkingyears as total_working_years,
    trainingtimeslastyear as training_times_last_year,
    yearsatcompany as years_at_company,
    yearsincurrentrole as years_in_current_role,
    yearssincelastpromotion as years_since_last_promotion,
    yearswithcurrmanager as years_with_curr_manager
from hr_data;
--Looking the view
select * from v_hr_staging;
