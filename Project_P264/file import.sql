use p264crowdfunding ;
drop table Crowdfunding_projects_1;
create table Crowdfunding_projects_1(
id int,
state varchar(200),
Pname varchar(200),
country varchar(200),
creator_id int,
location_id int,
category_id int,
created_at int,
deadline int,
updated_at int,
state_changed_at int,
successful_at int,
launched_at_goal int,
pledged int,
currency varchar(200),
currency_symbol varchar(200),
usd_pledged int,
static_usd_rate int,
backers_count int,
spotlight varchar(200),
staff_pick varchar(200),
blurb varchar(200) ,
currency_trailing_code varchar(200),
disable_communication varchar(200)
);

set sql_mode = "";
load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Crowdfunding_projects_1.csv' into table Crowdfunding_projects_1
fields terminated by ','
ignore 1 lines;

drop table Crowdfunding_Location;
create table Crowdfunding_Location (
id int,
displayable_name varchar(200),
typename varchar(200),
state varchar(200),
short_name varchar(200),
is_root int,
country varchar(200),
localized_name varchar(200)) ;

set sql_mode = "";
load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Crowdfunding_Location.csv' into table Crowdfunding_Location
fields terminated by ','
ignore 1 lines;

SELECT * FROM Crowdfunding_Location;

create table Crowdfunding_Creator(
id int,
Cname varchar(200),
chosen_currency varchar(200));

set sql_mode = "";
load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Crowdfunding_Creator.csv' into table Crowdfunding_Creator
fields terminated by ','
ignore 1 lines;

select * from Crowdfunding_Creator;

create table crowdfunding_Category(
id int,
Category_name varchar(200),
parent_id int,
position int);

set sql_mode = "";
load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\crowdfunding_Category.csv' into table crowdfunding_Category
fields terminated by ','
ignore 1 lines;

select * from crowdfunding_Category;





