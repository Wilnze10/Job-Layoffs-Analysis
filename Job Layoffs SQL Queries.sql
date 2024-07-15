drop table layoffs;

create table layoffs(
	company varchar(50),
	location varchar(50),
	industry varchar(50),
	total_laid_off varchar(50),
	percentage_laid_off varchar(50),
	date varchar(50),
	stage varchar(50),
	country varchar(50),
	funds_raised_millions varchar(50));

--remove duplicates

with duplicate_cte AS (
    select ctid
    from (
        select ctid,
               row_number() over (partition by company, location, industry, total_laid_off,
                                  percentage_laid_off, date, stage, country, funds_raised_millions 
                                  order by company) AS rn
        from layoffs
    ) duplicates
    where rn > 1
)
delete from layoffs
where ctid in (select ctid from duplicate_cte);
	
--data standardization
select distinct industry from layoffs
order by 1;

update layoffs
set industry = 'Crypto'
where industry like 'Crypto%';	

select distinct country from layoffs
order by 1;

update layoffs
set country = 'United States'
where country like 'United States%';	

SELECT date, 
       TO_DATE(date, 'MM/DD/YYYY') as Date
FROM layoffs;

delete from layoffs
where date like 'NU%'


delete from layoffs
where total_laid_off = 'NULL'
and percentage_laid_off = 'NULL'

update layoffs
set total_laid_off = 0
where total_laid_off = 'NULL'

update layoffs
set percentage_laid_off = 0
where percentage_laid_off = 'NULL'

update layoffs
set funds_raised_millions = 0
where funds_raised_millions = 'NULL'

SELECT total_laid_off
FROM layoffs
WHERE NOT total_laid_off ~ '^\d+$';

ALTER TABLE layoffs
ALTER COLUMN total_laid_off TYPE integer USING total_laid_off::integer;

ALTER TABLE layoffs
ALTER COLUMN percentage_laid_off TYPE decimal USING percentage_laid_off::decimal;

ALTER TABLE layoffs
ALTER COLUMN funds_raised_millions TYPE decimal USING funds_raised_millions ::decimal;

ALTER TABLE layoffs
ALTER COLUMN date TYPE date USING to_date(date, 'YYYY-MM-DD');

ALTER TABLE layoffs
ALTER COLUMN date TYPE date USING to_date(date, 'MM-DD-YYYY');


select distinct country from layoffs
order by 1

select * from layoffs
where industry is Null

--Filling up null values in the Industry column

select t1.industry, t2.industry
from layoffs t1
join layoffs t2
on t1.company = t2.company
where t1.industry is null
and t2.industry is not null;


UPDATE layoffs t1
SET industry = t2.industry
FROM layoffs t2
WHERE t1.company = t2.company
AND t1.industry IS NULL
AND t2.industry IS NOT NULL;

--DATA ANALYSIS
--Total number of layoffs by company
select company, sum(total_laid_off) as total_company_layoff
from layoffs
group by company
order by total_company_layoff desc

--Total layoffs
select sum(total_laid_off) as total_layoffs
from layoffs

-- Number of companies
select count(company) as number_of_companies
from layoffs
where total_laid_off > 0;

-- Average layoffs per company
select (sum(total_laid_off)/count(company)) as average_layoffs_by_company
from layoffs
where total_laid_off > 0;

--Total number of layoffs by industry
select industry, sum(total_laid_off) as total_industry_layoff
from layoffs
group by industry
order by total_industry_layoff desc

--Average percentage of layoffs by industry
select industry, round(avg(percentage_laid_off), 2) as avg_percentage_laid_off
from layoffs
group by industry
order by avg_percentage_laid_off desc

__Total number of layoffs by country
select country, sum(total_laid_off) as total_country_layoff
from layoffs
group by country
order by total_country_layoff desc

__Total funds raised by companies that had layoffs
select company, sum(funds_raised_millions) as total_funds_raised_in_dollars
from layoffs
group by company
order by total_funds_raised_in_dollars desc

__Total funds raised by companies that had the biggest layoffs
select company, sum(total_laid_off) as total_company_layoff,
	sum(funds_raised_millions) as total_funds_raised
from layoffs
group by company
order by total_company_layoff desc
LIMIT 15;


--Correlation between funds raised and layoffs
select company, funds_raised_millions, total_laid_off
from layoffs
where funds_raised_millions != 0 and total_laid_off != 0
order by funds_raised_millions desc, total_laid_off

--Layoffs trend
select EXTRACT(YEAR FROM date) AS Year, sum(total_laid_off) as total_layoff
from layoffs
group by EXTRACT(YEAR FROM date)
order by Year

--Top 20 companies by percentage laid off
select company, percentage_laid_off as company_percentage_laid_off
from layoffs
order by company_percentage_laid_off desc
limit 20


--Distribution of layoffs by company stage
select stage, sum(total_laid_off) as total_laid_off
from layoffs
group by stage
order by total_laid_off desc

--Top 5 locations by total layoffs
select location, sum(total_laid_off) as total_laid_off
from layoffs
group by location
order by total_laid_off desc
limit 5


--Most affected industries by country
select country, industry, sum(total_laid_off) as total_laid_off
from layoffs
group by country, industry
order by country, total_laid_off desc

-- 10 Most affected industries by USA
select industry, sum(total_laid_off) as total_layoff
from layoffs
where country = 'United States'
group by industry
order by total_layoff desc
LIMIT 10


--Percentage of layoffs at various stages
select stage,round(avg(percentage_laid_off), 2) as avg_percentage_laid_off
from layoffs
group by stage
order by avg_percentage_laid_off desc;

--Layoffs between countries in the Crypto Industry
select country, sum(total_laid_off) as crypto_total_laid_off
from layoffs
where industry = 'Crypto'
group by country
order by crypto_total_laid_off desc;
