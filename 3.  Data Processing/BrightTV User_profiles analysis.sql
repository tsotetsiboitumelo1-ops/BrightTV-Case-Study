-- Databricks notebook source
--This is to check what my data looks like
select
  *
from
  `casestudy`.`brighttv_database`.`bright_tv_userprofiles`
limit 5;
---------------------------------------------------
---Checking for duplicatesformal way
----------------------------------------------------
SELECT COUNT(*),
UserID
from casestudy.brighttv_database.bright_tv_userprofiles
Group by UserID
Having Count (*) > 1; ---this means that there is no duplicates
----------------------------------------------------
---Checking for duplicates informal way
select count(distinct UserID) as subs
from casestudy.brighttv_database.bright_tv_userprofiles;
---------------------------------------------------
---gender checks
---------------------------------------------------
---inspecting our gender column
select distinct
  gender ---- to check what is contained in this categorical column
from
  `casestudy`.`brighttv_database`.`bright_tv_userprofiles`;

---Cleaning the gender column using case statement
select distinct 
  case
    when gender = 'None' then 'unknown' --replaces the value None with unknown
    when gender = ' ' then 'unknown' --replaces the empty space with unknown
    when gender is null then 'unknown' --replaces the null with unknown
    else gender --if gender is male or female return it as it is
  end as sex ---new column name
from
  `casestudy`.`brighttv_database`.`bright_tv_userprofiles`;

-----------------------------------------------------
--race checks
------------------------------------------------------
select distinct
  race
from
  `casestudy`.`brighttv_database`.`bright_tv_userprofiles`;

select
  count(distinct userid) as subs,
  case
    when race = 'other' then 'unknown' ---replace other with unknown
    when race = 'None' then 'unknown' ---replace None with unknwon
    when race = ' ' then 'unknown' ---replace empty with unknwon
    when race is null then 'unknown' ---replace null with unknwon
    else race --keep it as it
  end as ethnicity --- new column
from
  `casestudy`.`brighttv_database`.`bright_tv_userprofiles`
group by
  ethnicity;

-------------------------------------------------
--Province check
--------------------------------------------------
select distinct
  Province
from
  `casestudy`.`brighttv_database`.`bright_tv_userprofiles`;

Select distinct
  case
    when Province = 'None' then 'unknown'
    when Province = ' ' then 'unknown'
    when Province is null then 'unknown'
    else Province
  end as Region
from
  `casestudy`.`brighttv_database`.`bright_tv_userprofiles`;

-------------------------------------------------
--Age check
--------------------------------------------------
Select
  min(age) as min_age, --check the youngest person
  max(age) as max_age, --find the oldest person
  avg(age) as mean_age
from
  `casestudy`.`brighttv_database`.`bright_tv_userprofiles`;

Select Count (distinct UserID) as subs,
  case
    when Age = 0 then 'Infant'
    when Age between 1 and 12 then 'Kids'
    when Age between 13 and 17 then 'Youth'
    when Age between 18 and 25 then 'Young Adults'
    when Age between 26 and 50 then 'Adults'
    when
      Age > 50
      and Age <= 60
    then
      'Elder'
    when Age > 60 then 'Pensioner'
  end as Age_group
from
  `casestudy`.`brighttv_database`.`bright_tv_userprofiles`
  Group by Age_group;

-----------------------------------------------
---TEMP TABLE
-----
create or replace temporary table processed_userprofiles as (
select
  b.userid,
  case
    when (b.`Email` is not null)  or (b.`Email` <> ' ') or (b.`Email` not in ('None', 'other')) then 1
    else 0
  end as email_flag,
  case
    when (b.`Social Media Handle` is not null)  or (b.`Social Media Handle` <> ' ') or (b.`Social Media Handle` not in ('None', 'other')) then 1
    else 0
  end as socialmedia_flag,
  case
    when b.gender = 'None' then 'unknown'
    when b.gender = ' ' then 'unknown'
    when b.gender is null then 'unknown'
    else b.gender
  end as sex,
  case
    when b.race = 'other' then 'unknown' ---replace other with unknown
    when b.race = 'None' then 'unknown' ---replace None with unknwon
    when b.race = ' ' then 'unknown' ---replace empty with unknwon
    when b.race is null then 'unknown' ---replace null with unknwon
    else b.race --keep it as it
  end as ethnicity, --- new column
  case
    when b.Province = 'None' then 'unknown'
    when b.Province = ' ' then 'unknown'
    when b.Province is null then 'unknown'
    else b.Province
  end as Region,
  age,

  case
    when Age = 0 then '01.Infant: 0'
    when Age between 1 and 12 then '02.Kids: 1-12'
    when Age between 13 and 17 then '03.Youth :13-17'
    when Age between 18 and 25 then '04.Young Adults: 18-25'
    when Age between 26 and 50 then '05.Adults: 36-50'
    when Age > 50 and b.Age <= 60 then '06.Elder: 51-60'
    when Age > 60 then '07.Pensioner: >60'
  end as Age_group,
  Channel2
from
  casestudy.brighttv_database.brighttv_viewrship AS A
LEFT JOIN casestudy.brighttv_database.bright_tv_userprofiles AS B
ON A.USERID0 = b.USERID
WHERE Age = 0
ORDER BY Age_group ASC);

select *
from casestudy.brighttv_database.brighttv_viewrship;

----checking for duplicates
  select count(*) as cnt,
        userid
  from processed_userprofiles
  group by userid
  having count(*)>1;
