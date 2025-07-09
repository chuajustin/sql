-- Data Cleaning Project

-- Step 1: Remove Duplicates (if any)
-- Step 2: Standardize the Data (if any spellings changes etc)
-- Step 3: Null Values or Blank Values (see if we can populate the values)
-- Step 4: Remove columns or rows that is unecessary

-- To duplicate or create a table
CREATE TABLE layoffs_staging
LIKE layoffs;

-- insert data from the raw table data
INSERT layoffs_staging
SELECT *
FROM layoffs;

-- giving it a row number
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- in this situation, 2 would mean a duplicate as 1 are all unique values
WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Step 2: Standardize the Data (if any spellings changes etc)

-- 1: Trimming the white spaces
UPDATE layoffs_staging2
SET company = trim(company);

-- 2: Standardizing industry (Crypto% can work, but in this case, not work why it doesnt)
select *
from layoffs_staging2
where industry = 'Crypto Currency' OR industry = 'CryptoCurrency';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry = 'Crypto Currency' OR industry = 'CryptoCurrency';

select distinct industry
from layoffs_staging2;

-- 2. Standardlizing country
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country) -- triming from the back
WHERE country LIKE 'United States%';

-- 2. Changing date text to str
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') -- why capital Y, it captures 4 digits.
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2 -- only do it on the staging table
MODIFY COLUMN `date` DATE;


-- Step 3  - Null and blank values (updating or remove)
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = ''; -- setting all to null values so easer to update

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry is NULL)
AND t2.industry IS NOT NULL;

-- Step 4: Removing columns or rows (only confident than delete, if not populate it)
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

select *
from layoffs_staging2;



