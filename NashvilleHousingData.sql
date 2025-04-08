-- Cleaning data in SQL Queries

SELECT *
FROM `my-project-furkan.NashvilleHousing.nashville_housing`;

-----------------------------------------------------------------------------------------------------------
-- Standardize date format

SELECT SaleDate , PARSE_DATE('%B/%e/%Y', SaleDate) AS SaleDate
FROM `my-project-furkan.NashvilleHousing.nashville_housing`;


-----------------------------------------------------------------------------------------------------------
-- Populate property address data

SELECT *
FROM `my-project-furkan.NashvilleHousing.nashville_housing`
--WHERE PropertyAddress IS NULL;
ORDER BY ParcelID;

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, IFNULL(A.PropertyAddress,B.PropertyAddress)
FROM `my-project-furkan.NashvilleHousing.nashville_housing` A
JOIN `my-project-furkan.NashvilleHousing.nashville_housing` B
  ON A.ParcelID = B.ParcelID
  AND A.`UniqueID ` <> B.`UniqueID ` --There is an extra space at the end of `UniqueID ` column title. that is why we wrote it btw ``.
WHERE A.PropertyAddress IS NULL;

/*     -------IF YOU USE BILLING VERSION OF BIG QUERY. YOU CAN USE DDL COMMAND.------------
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM `my-project-furkan.NashvilleHousing.nashville_housing` A
JOIN `my-project-furkan.NashvilleHousing.nashville_housing` B
  ON A.ParcelID = B.ParcelID
  AND A.`UniqueID ` <> B.`UniqueID `  --There is an extra space at the end of `UniqueID ` column title. that is why we wrote it btw ``.
WHERE A.PropertyAddress IS NULL;
*/

-----------------------------------------------------------------------------------------------------------
-- Breaking out Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM `my-project-furkan.NashvilleHousing.nashville_housing`;
--WHERE PropertyAddress IS NULL;
--ORDER BY ParcelID;

/*      //CHARINDEX function is used in SQL Server (T-SQL). NOT IN BIGQUERY//
SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(' ',PropertyAddress)) AS Address
FROM `my-project-furkan.NashvilleHousing.nashville_housing`;
*/

SELECT 
SUBSTRING(PropertyAddress, 1, STRPOS(PropertyAddress, ' ') - 1) AS Address1,
SUBSTRING(PropertyAddress, (STRPOS(PropertyAddress, ' ') + 1),LENGTH(PropertyAddress)) AS Address2
FROM `my-project-furkan.NashvilleHousing.nashville_housing`;


/*     -------IF YOU USE BILLING VERSION OF BIG QUERY. YOU CAN USE DDL COMMAND.------------

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, STRPOS(PropertyAddress, ' ') - 1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, (STRPOS(PropertyAddress, ' ') + 1),LENGTH(PropertyAddress));
*/


SELECT OwnerAddress
FROM `my-project-furkan.NashvilleHousing.nashville_housing`;

SELECT OwnerAddress,
SPLIT(OwnerAddress,' ')[OFFSET(0)] AS Street,
SPLIT(OwnerAddress,' ')[OFFSET(2)] AS City
FROM `my-project-furkan.NashvilleHousing.nashville_housing`;


SELECT OwnerAddress,
SPLIT(REPLACE(OwnerAddress,' ','.'),'.')
FROM `my-project-furkan.NashvilleHousing.nashville_housing`;


-----------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold As Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM `my-project-furkan.NashvilleHousing.nashville_housing`
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
FROM `my-project-furkan.NashvilleHousing.nashville_housing`;


/*    -------IF YOU USE BILLING VERSION OF BIG QUERY. YOU CAN USE DDL COMMAND.------------
UPDATE NashvilleHousing
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END

*/
-----------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- This query gives each unique group of records a sequence number using the ROW_NUMBER() function. 
-- This way you can find and clean up duplicate rows that contain the same information.

WITH RowNumCTE AS(
SELECT *,
  ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
                 PropertyAddress,
                 --SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY
                 `UniqueID `
                ) row_num

FROM `my-project-furkan.NashvilleHousing.nashville_housing`
)
SELECT * -- IF WE WRITE "DELETE" INSTEAD IF "SELECT *" -, ALL DUBLICATE ROWS WILL BE DELETED.
FROM RowNumCTE
WHERE row_num >1
--ORDER BY PropertyAddress; 

--CTE (Common Table Expression) is a construct used in SQL to create a temporary named result set. 
--It starts with a WITH statement and can be used like a table in the main query that follows.



-----------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

/*
SELECT *
FROM `my-project-furkan.NashvilleHousing.nashville_housing`;
*/

/*     -------IF YOU USE BILLING VERSION OF BIG QUERY. YOU CAN USE DDL COMMAND.------------
ALTER TABLE  `my-project-furkan.NashvilleHousing.nashville_housing`
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;
*/






