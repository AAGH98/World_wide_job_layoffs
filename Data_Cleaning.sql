-- Data Cleaning 



SELECT *
FROM layoffs
;


-- 1 Remove Duplicates
-- 2 Standerdise data
-- 3 Null values or blank values
-- 4 Remove any columns 


-- Create a new table and copy everything into the new one

CREATE TABLE layoffs_staging
LIKE layoffs;


SELECT *
FROM layoffs_staging
;

INSERT layoffs_staging
SELECT *
FROM layoffs
;

-- We want to add row numbers to create a distinctive row 

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging
;

WITH duplicate_cte AS
(
SELECT*,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1
;

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


SELECT *
FROM layoffs_staging2
WHERE row_num > 1
;


INSERT INTO layoffs_staging2
SELECT*,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
;


SELECT *
FROM layoffs_staging2
WHERE row_num > 1
;


-- STANDERDISING DATA 

SELECT DISTINCT company, (TRIM(company))
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET company = TRIM(company);


SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'crypto%';


UPDATE layoffs_staging2
SET industry = 'crypto'
WHERE industry LIKE 'crypto%'
;


-- ensuring that cryto has been updated correctly

SELECT DISTINCT industry
FROM layoffs_staging2
;


SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1
;

-- no problems seen in location


SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1
;

-- issue found with united states

SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'united states%'
ORDER BY 1
;

UPDATE layoffs_staging2
SET country = 'united states'
WHERE country LIKE 'united states%'
;


-- now we need to look at the date because it is set as text 

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%y')
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
;

-- checking that it has been updated

SELECT `date`
FROM layoffs_staging2;


-- now we can change it into a date column

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- looking for NULL values

select *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;


SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ''
;

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL
    ;
    
    
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL
    ;



UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = ''
;


UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL )
AND t2.industry IS NOT NULL
    ;



SELECT *
FROM layoffs_staging2
;



select *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

SELECT*
FROM layoffs_staging2
;


ALTER TABLE layoffs_staging2
DROP COLUMN row_num
;





















