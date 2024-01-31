-- Epoch to Natural Date time
	use p264crowdfunding;
		select * from projects; 

 set sql_safe_updates=1;

-- created_at
	alter table projects
		add column created_at_dateformat date;

	UPDATE projects
		SET created_at_dateformat = FROM_UNIXTIME(created_at);

-- alter table projects
-- drop column created_at_dateformat;

-- deadline
	alter table projects
		add column deadline_dateformat date;

	UPDATE projects
		SET deadline_dateformat = FROM_UNIXTIME(deadline);

-- updated_at

	alter table projects
		add column updated_at_dateformat date;

	UPDATE projects
		SET updated_at_dateformat = FROM_UNIXTIME(updated_at);

-- state_changed_at

	alter table projects
		add column state_changed_at_dateformat date;

	UPDATE projects
		SET state_changed_at_dateformat = FROM_UNIXTIME(state_changed_at);

-- successful_at

	alter table projects
		add column successful_at_dateformat date;

	UPDATE projects
		SET successful_at_dateformat = FROM_UNIXTIME(successful_at) where successful_at <> 0;

-- launched_at

	alter table projects
		add column launched_at_dateformat date;

	UPDATE projects
		SET launched_at_dateformat = FROM_UNIXTIME(launched_at);



-- Calendar Table


select * from calendar_table;

set sql_safe_updates = 1;
-- Create a new calendar table
CREATE TABLE calendar_table AS
WITH calendar_dates AS (
    SELECT MIN(created_at_dateformat) AS min_date, MAX(created_at_dateformat) AS max_date FROM crowdfunding_projects_1
    UNION ALL
    SELECT DATE_ADD(min_date, INTERVAL 1 DAY), max_date FROM calendar_dates WHERE DATE_ADD(min_date, INTERVAL 1 DAY) <= max_date
)
SELECT
    created_at_dateformat,
    YEAR(created_at_dateformat) AS Year,
    MONTH(created_at_dateformat) AS Monthno,
    DATE_FORMAT(created_at_dateformat, '%M') AS Monthfullname,
    CASE
        WHEN MONTH(created_at_dateformat) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN MONTH(created_at_dateformat) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN MONTH(created_at_dateformat) BETWEEN 7 AND 9 THEN 'Q3'
        ELSE 'Q4'
    END AS Quarter,
    CONCAT(YEAR(created_at_dateformat), '-', DATE_FORMAT(created_at_dateformat, '%b')) AS YearMonth,
    DAYOFWEEK(created_at_dateformat) AS Weekdayno,
    DATE_FORMAT(created_at_dateformat, '%W') AS Weekdayname,
    CASE
        WHEN MONTH(created_at_dateformat) BETWEEN 4 AND 6 THEN 'FM1'
        WHEN MONTH(created_at_dateformat) BETWEEN 7 AND 9 THEN 'FM2'
        WHEN MONTH(created_at_dateformat) BETWEEN 10 AND 12 THEN 'FM3'
        ELSE 'FM12'
    END AS FinancialMOnth,
    CASE
        WHEN MONTH(created_at_dateformat) BETWEEN 4 AND 6 THEN 'FQ-1'
        WHEN MONTH(created_at_dateformat) BETWEEN 7 AND 9 THEN 'FQ-2'
        WHEN MONTH(created_at_dateformat) BETWEEN 10 AND 12 THEN 'FQ-3'
        ELSE 'FQ-4'
    END AS FinancialQuarter
FROM projects;


-- Data Model


SELECT
    p.ProjectID,
    l.id,
    c.id,
    cat.id
FROM
    projects AS p
JOIN
    crowdfunding_location AS l ON p.location_id = l.id
JOIN
    crowdfunding_creator AS c ON p.creator_id = c.id
JOIN
    crowdfunding_category AS cat ON p.category_id = cat.id;

-- goal into USD


	alter table projects
		add column Goal_in_USD bigint;

-- alter table projects
-- drop column Goal_in_USD;


	UPDATE projects
		SET Goal_in_USD = goal * static_usd_rate;


	select * from projects; 


-- Total Number of Projects based on outcome 

select	distinct state, 
		case 
			when state <> 'purged' then concat(round(count(ProjectID) / 1000), 'k') 
		else count(projectID)
				end as Based_on_outcome
		from projects
				group by state;


-- Total Number of Projects based on Locations

	select distinct country, format(count(ProjectID),0) as Based_on_location
		from projects
			group by country;

-- Total Number of Projects based on  Category

	select distinct Category_name, format(count(ProjectID),0) as Based_on_Category
		from projects
	left join crowdfunding_category on
		projects.category_id = crowdfunding_category.id
	group by Category_name;

-- Total Number of Projects created by Year , Quarter , Month

-- Year

SELECT
     distinct ct.year,
   format(COUNT(ProjectID),0) AS total_projects_by_year
FROM
    calendar_table ct
left outer JOIN
   projects on projects.created_at_dateformat = ct.created_at_dateformat
GROUP BY
    ct.year;

-- Quarter

SELECT
     distinct ct.Quarter,
   format(COUNT(ProjectID),0) AS total_projects_by_quarter
FROM
    calendar_table ct
left outer JOIN
   projects on projects.created_at_dateformat = ct.created_at_dateformat
GROUP BY
    ct.Quarter;
    
-- Month

SELECT
     distinct ct.monthfullname,
	format(COUNT(ProjectID),0) AS total_projects_by_month
FROM
    calendar_table ct
left outer JOIN
   projects on projects.created_at_dateformat = ct.created_at_dateformat
GROUP BY
    ct.monthfullname;

-- Successful Projects

-- Amount Raised 

	select concat(format(sum(Goal_in_USD) / 1000000000, 2), 'B') as amount_raised
		from projects
	where state = 'Successful';

-- Number of Backers

	select concat(round(count(backers_count)/1000), 'k') as Number_of_backers
		from projects
	where state = 'Successful';

-- Avg Number of Days for successful projects

	select format(abs(avg(datediff(created_at_dateformat, successful_at_dateformat))),0) As Avg_Number_of_days
		from projects;

-- Top Successful Projects :

-- Based on Number of Backers

	select p.name as project_name, concat(format(sum(backers_count)/1000,0),'k') as Number_of_backers
		from projects p
	where state = 'Successful'
		group by project_name
	order by sum(backers_count) desc;

-- Based on Amount Raised.

	select p.name as project_name, concat(format(sum(Goal_in_USD)/10000,0), 'M') as Amount_Raised
		from projects p
	where state = 'Successful'
		group by project_name
	order by sum(Goal_in_USD) desc;

-- Percentage of Successful Projects overall

SELECT 
  concat(format((COUNT(CASE WHEN state = 'successful' THEN 1 END) / COUNT(ProjectID)) * 100,2), '%') AS Percentage_of_Successful_Project_overall
FROM projects;


--  Percentage of Successful Projects  by Category

SELECT 
	Category_name,
concat(format((sum(CASE WHEN state = 'successful' THEN 1 END) / count(*)) * 100.0, 2), '%') AS percentage_of_Successful_Project_by_Category
	FROM projects
		left join crowdfunding_category on
	projects.category_id = crowdfunding_category.id
		group by Category_name;


-- Percentage of Successful Projects by Year

SELECT 
		ct.year,
			concat(format((COUNT(CASE WHEN state = 'successful' THEN 1 END) / COUNT(ct.year)) * 100,2), '%') AS Percentage_of_Successful_Project_by_year
		FROM calendar_table ct
			left join projects
		on projects.created_at_dateformat=ct.created_at_dateformat
			group by ct.year;


-- Percentage of Successful projects by Goal Range ( decide the range as per your need )

SELECT
    GoalRange,
    SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) AS SuccessfulProjects,
    COUNT(*) AS TotalProjects,
concat(format((SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) / COUNT(*)) * 100,2), '%') AS Percentage
FROM (
    SELECT
        CASE
            WHEN Goal_in_USD < 1000 THEN 'Less than 1000'
            WHEN Goal_in_USD >= 1000 AND Goal_in_USD < 5000 THEN '1000 - 4999'
            WHEN Goal_in_USD >= 5000 AND Goal_in_USD < 10000 THEN '5000 - 9999'
            ELSE '10,000 and above'
        END AS GoalRange,
        state
    FROM projects
) AS GoalCategorized
GROUP BY GoalRange;


