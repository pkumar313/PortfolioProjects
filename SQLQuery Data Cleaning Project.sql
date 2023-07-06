/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM DataCleaningPortfolio..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

-- CONVERT changed the type of SaleDate from text to date
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM DataCleaningPortfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------
 -- Populate Property Address data

SELECT *
FROM DataCleaningPortfolio..NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningPortfolio..NashvilleHousing a
JOIN NashvilleHousing b
	ON  a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET  PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM DataCleaningPortfolio..NashvilleHousing a
JOIN NashvilleHousing b
	ON  a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

--------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress, StreetAddress, CityAddress
FROM DataCleaningPortfolio..NashvilleHousing

-- Substring Manipulations to separate PropertyAddress
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as StreetAddress, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM DataCleaningPortfolio..NashvilleHousing


-- Altering the Dataset to include separated Date
ALTER TABLE NashvilleHousing
ADD StreetAddress nvarchar(255);

UPDATE NashvilleHousing
SET StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD CityAddress nvarchar(255);

UPDATE NashvilleHousing
SET CityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


-- Separating OwnerAddress
SELECT *
FROM DataCleaningPortfolio..NashvilleHousing

SELECT OwnerAddress
FROM DataCleaningPortfolio..NashvilleHousing

-- Using PARSENAME instead of Substrings
-- PARSENAME looks for '.' delimiters instead of ','
-- REPLACE switches every ',' with '.'
-- PARSENAME looks for first instance of a '.' from the end of the text
SELECT OwnerAddress, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM DataCleaningPortfolio..NashvilleHousing


-- Altering the Dataset
ALTER TABLE NashvilleHousing
ADD OwnerStreetAddress nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerCityAddress nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerStateAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT OwnerAddress, OwnerStreetAddress, OwnerCityAddress, OwnerStateAddress
FROM DataCleaningPortfolio..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

-- Visualize how much Y, N, Yes and No are in the dataset currently
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaningPortfolio..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


-- Creating a Case statement to replace all 'Y' and 'N' with 'Yes' and 'No'
SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM DataCleaningPortfolio..NashvilleHousing

-- Dataset Updated
UPDATE NashvilleHousing
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						 WHEN SoldAsVacant = 'N' THEN 'No'
						 ELSE SoldAsVacant
						 END

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

-- This Query was created using the ROW_NUMBER function to count rows that that have duplicated information in several columns
-- The Partition By statement selects which columns to look at for duplicate data
-- ROW_NUMBER() counts the rows that have duplicate data specified by the Partition and assigns it to row_num
-- A CTE was used so that row_num could be used in another querry to remove the duplicated rows
WITH RowNUMCTE AS (
SELECT *, ROW_NUMBER() OVER (
		  PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
		  ORDER BY UniqueID
		  ) row_num
FROM DataCleaningPortfolio..NashvilleHousing
)
DELETE 
FROM RowNUMCTE
WHERE RowNUMCTE.row_num > 1

---------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

SELECT *
FROM DataCleaningPortfolio..NashvilleHousing

ALTER TABLE  DataCleaningPortfolio..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate, TaxDistrict

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------