-- Exploratory Data Analysis
-- some idea of u are looking for, sometime need to re-clean

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC; 

-- Sum of total laid off
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Industry (total laid off)
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Country (total laid off)
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Base on year (total laid off)
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Rolling sum of total laid offs (keep on adding)
SELECT SUBSTRING(`date`,1,7) AS yearmonth, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY yearmonth
ORDER BY 1 ASC;

-- CTE Rolling Total (sum up every month)
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS yearmonth, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY yearmonth
ORDER BY 1 ASC
)
SELECT yearmonth, total_off
, SUM(total_off) OVER (ORDER BY yearmonth) AS rolling_total
FROM Rolling_Total;

-- Layoffs by year + ranking based on sum total using CTEs
-- you can change it to industry // by year, by months
SELECT company, YEAR(`date`) AS year, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company, year
ORDER BY 3 DESC;

WITH Company_Year AS
(
SELECT company, YEAR(`date`) AS year, SUM(total_laid_off) as total_layoffs
FROM layoffs_staging2
GROUP BY company, year
), Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY year ORDER BY total_layoffs DESC) AS ranking
FROM Company_year
WHERE year IS NOT NULL
)
SELECT
*
FROM Company_year_Rank
WHERE ranking <= 5;