/* 

Cleaning Data in SQL Queries

*/


Select *
From [Data Cleaning].dbo.NashvilleHousing

---------------------------------------------------------------

--Standardize Date Format

ALTER TABLE [Data Cleaning].dbo.NashvilleHousing
Add saledateconverted Date;


Update [Data Cleaning].dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(date, Saledate)


Select Saledateconverted, CONVERT(date, Saledate)
From [Data Cleaning].dbo.NashvilleHousing

--------------------------------------------------------------

--Populate Property Address data

Select *
From [Data Cleaning].dbo.NashvilleHousing
order by parcelid


Select a.ParcelID, a.propertyAddress, b.ParcelID, b.propertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Data Cleaning].dbo.NashvilleHousing a
JOIN [Data Cleaning].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.uniqueID
Where a.PropertyAddress is null


Update a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Data Cleaning].dbo.NashvilleHousing a
JOIN [Data Cleaning].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.uniqueID
Where a.PropertyAddress is null

----------------------------------------------------------------

--Breaking out Address into individual Columns (Address, City, State)



Select PropertyAddress
From [Data Cleaning].dbo.NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From [Data Cleaning].dbo.NashvilleHousing


ALTER TABLE [Data Cleaning].dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update [Data Cleaning].dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [Data Cleaning].dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update [Data Cleaning].dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))





Select * 
From [Data Cleaning].dbo.NashvilleHousing






Select OwnerAddress
From [Data Cleaning].dbo.NashvilleHousing


Select
PARSENAME(REPLACE(Owneraddress, ',', '.'), 3)
, PARSENAME(REPLACE(Owneraddress, ',', '.'), 2)
, PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)
From [Data Cleaning].dbo.NashvilleHousing


ALTER TABLE [Data Cleaning].dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update [Data Cleaning].dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(Owneraddress, ',', '.'), 3)


ALTER TABLE [Data Cleaning].dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update [Data Cleaning].dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(Owneraddress, ',', '.'), 2)


ALTER TABLE [Data Cleaning].dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update [Data Cleaning].dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)

Select *
From [Data Cleaning].dbo.NashvilleHousing



--------------------------------------------------------------------------------------------


--Change Y and N to YES and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [Data Cleaning].dbo.NashvilleHousing
Group by SoldAsVacant
order by 2



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
From [Data Cleaning].dbo.NashvilleHousing


Update [Data Cleaning].dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END

------------------------------------------------------------------------------------------------

--Remove Duplicates

With RowNumCTE AS(
Select * ,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,    
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

From [Data Cleaning].dbo.NashvilleHousing
)
Select * 
From RowNumCTE
where row_num >1
order by PropertyAddress


Select *
From [Data Cleaning].dbo.NashvilleHousing

--------------------------------------------------------------------------------------

--Delete Unused Columns


Select * 
From [Data Cleaning].dbo.NashvilleHousing


ALTER TABLE [Data Cleaning].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
