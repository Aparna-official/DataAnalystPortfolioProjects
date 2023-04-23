/*  Cleaning data using SQL queries */

----------------------------------------------------------------------------------------------------------------------
-- Standardise saledate format

SELECT * 
FROM First_Portfolio_Project..NashvilleHousing

SELECT SaleDate, CONVERT(DATE, SaleDate) 
FROM First_Portfolio_Project..NashvilleHousing


ALTER TABLE First_Portfolio_Project..NashvilleHousing
ADD SaleDateConverted DATE

UPDATE First_Portfolio_Project..NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate) 

-- Checking if it works
SELECT SaleDateConverted, CONVERT(DATE, SaleDate) 
FROM First_Portfolio_Project..NashvilleHousing


---------------------------------------------------------------------------------------------------------------------
-- Populate missing property address data
SELECT * 
FROM First_Portfolio_Project..NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT * 
FROM First_Portfolio_Project..NashvilleHousing
ORDER BY ParcelID


SELECT * 
FROM First_Portfolio_Project..NashvilleHousing a
JOIN First_Portfolio_Project..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]

-- finding repeating values for parcel id so that missing property address can be populated
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM First_Portfolio_Project..NashvilleHousing a
JOIN First_Portfolio_Project..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM First_Portfolio_Project..NashvilleHousing a
JOIN First_Portfolio_Project..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



--------------------------------------------------------------------------------------------------------------
--Breaking out address into individual columns

SELECT PropertyAddress
FROM First_Portfolio_Project..NashvilleHousing 

-- Trying splitting commands
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address1, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address2
FROM First_Portfolio_Project..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



-- Editing Owner Address
SELECT *
FROM First_Portfolio_Project..NashvilleHousing

SELECT OwnerAddress
FROM First_Portfolio_Project..NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM First_Portfolio_Project..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Verfying information 
SELECT OwnerSplitCity, OwnerSplitState, OwnerSplitAddress
FROM First_Portfolio_Project..NashvilleHousing


-------------------------------------------------------------------------------------------------------------------
-- Changing Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM First_Portfolio_Project..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM First_Portfolio_Project..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


	   

----------------------------------------------------------------------------------------------------------------
--Removing duplicate enteries

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM First_Portfolio_Project..NashvilleHousing
)
Select *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- Verifying changes
Select *
From First_Portfolio_Project..NashvilleHousing




-------------------------------------------------------------------------------------------------------------------
-- Deleting unused columns
Select *
From First_Portfolio_Project..NashvilleHousing


ALTER TABLE First_Portfolio_Project..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
