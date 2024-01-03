-- Standardize SaleDate
Alter TABLE NashvileHousing
ADD SaleDateConverted Date

UPDATE NashvileHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDate,SaleDateConverted
FROM PortfolioProject1..NashvileHousing

--Populate property address data
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject1..NashvileHousing a
JOIN PortfolioProject1..NashvileHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.Propertyaddress,b.PropertyAddress)
FROM PortfolioProject1..NashvileHousing a
join PortfolioProject1..NashvileHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

	-- Breaking out Address into Individual Columns (Address, City, State)
SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
FROM PortfolioProject1..NashvileHousing

Alter TABLE NashvileHousing
ADD PropertySpliAddress NVARCHAR(255)

UPDATE NashvileHousing
SET PropertySpliAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter TABLE NashvileHousing
ADD PropertySpliCity NVARCHAR(255)

UPDATE NashvileHousing
SET PropertySpliCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT
PropertySpliAddress,PropertySpliCity
FROM PortfolioProject1..NashvileHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject1..NashvileHousing

Alter TABLE NashvileHousing
ADD OwnerSpliAddress NVARCHAR(255)

UPDATE NashvileHousing
SET OwnerSpliAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter TABLE NashvileHousing
ADD OwnerSpliCity NVARCHAR(255)

UPDATE NashvileHousing
SET OwnerSpliCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter TABLE NashvileHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvileHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM PortfolioProject1..NashvileHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVAcant),COUNT(SoldAsVacant)
FROM PortfolioProject1..NashvileHousing
GROUP BY SoldAsVAcant

SELECT SoldAsVAcant,
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	 WHEN SoldAsVacant ='N' THEN 'No'
	 ELSE SoldAsVacant
	 END
	 FROM PortfolioProject1..NashvileHousing

UPDATE NashvileHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
				   WHEN SoldAsVacant ='N' THEN 'No'
				   ELSE SoldAsVacant
				   END

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject1..NashvileHousing
--order by ParcelID
)
--DELETE
--From RowNumCTE
--Where row_num > 1

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- Delete Unused Columns
SELECT * 
FROM PortfolioProject1..NashvileHousing

Alter TABLE NashvileHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate

Alter TABLE NashvileHousing
