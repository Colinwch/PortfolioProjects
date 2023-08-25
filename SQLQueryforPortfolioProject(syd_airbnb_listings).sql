--Looking at the raw data
SELECT *
FROM dbo.listings$

--Cleaning Data

--1. Standardise date format
SELECT last_review, CONVERT(Date,last_review)
FROM dbo.listings$


ALTER TABLE dbo.listings$
ADD last_review_date DATE

UPDATE dbo.listings$
SET last_review_date = CONVERT(Date,last_review)


--2. Breaking out bedroom numbers, bathroom types and bathroom numbers into individual columns (from name column)

--Create new separate table where keywords like bedroom or studio are in the name column (keep raw data table untouched)
SELECT *
INTO dbo.listings_studio_bedroom$
FROM dbo.listings$
WHERE name LIKE '%bedroom%' OR name  LIKE '%studio%'


--Breaking out data from name column
SELECT
	name,
	CASE
		WHEN name LIKE '%bedroom%' THEN SUBSTRING(name,CHARINDEX('bedroom',name) -2,1)
		ELSE '1'
	END AS number_of_bedrooms,
	CASE
		WHEN name LIKE '%bed%' THEN SUBSTRING(name,CHARINDEX('bed',name) -2,1)
		ELSE '1'
	END AS number_of_beds,
	CASE
		WHEN name LIKE '%private bath%'  OR name NOT LIKE '%shared bath%' THEN 'Y'
		ELSE 'N'
	END AS private_bathroom
FROM dbo.listings_studio_bedroom$


--Creating new columns to store data
ALTER TABLE dbo.listings_studio_bedroom$
ADD number_of_bedrooms INT, number_of_beds INT, private_bathroom VARCHAR(3)

UPDATE dbo.listings_studio_bedroom$
SET number_of_bedrooms = 
	CASE 
		WHEN name LIKE '%bedroom%' THEN SUBSTRING(name,CHARINDEX('bedroom',name) -2,1) 
		ELSE '1'
	END

UPDATE dbo.listings_studio_bedroom$
SET number_of_beds = 
	CASE
		WHEN name LIKE '%bed%' THEN SUBSTRING(name,CHARINDEX('bed',name) -2,1)
		ELSE '1'
	END

UPDATE dbo.listings_studio_bedroom$
SET private_bathroom =
	CASE
		WHEN name LIKE '%private bath%'  OR name NOT LIKE '%shared bath%' THEN 'Yes'
		ELSE 'No'
	END


--3. Replacing Null values with 0 

UPDATE dbo.listings_studio_bedroom$
SET reviews_per_month = 0
WHERE reviews_per_month IS NULL

--4. Remove duplicates

WITH Row_num_CTE AS(

SELECT *,
	ROW_NUMBER()OVER(
	PARTITION BY id,
				host_id,
				last_review_date
				ORDER BY
					ID) row_num

FROM dbo.listings_studio_bedroom$
)
DELETE
FROM Row_num_CTE
WHERE row_num > 1


--5. Delete unused columns

ALTER TABLE dbo.listings_studio_bedroom$
DROP COLUMN name, host_name, neighbourhood_group, last_review, license

SELECT *
FROM dbo.listings_studio_bedroom$