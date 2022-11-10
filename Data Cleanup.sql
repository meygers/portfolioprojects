Select *
From PortfolioProject..[nashville housing]


-- Standarize Date Format

Select SaleDateconverted, CONVERT(Date, Saledate)
From PortfolioProject..[nashville housing]

Update [nashville housing]
SET SaleDate = CONVERT(Date, Saledate)


--Didn't convert to had to alter table

ALTER TABLE [nashville housing]
Add Saledateconverted Date; 

Update [nashville housing]
SET SaleDateconverted = CONVERT(Date, Saledate)


--Populate Property Address Data

Select *
From PortfolioProject..[nashville housing]
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..[nashville housing] a
JOIN PortfolioProject..[nashville housing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set Propertyaddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..[nashville housing] a
JOIN PortfolioProject..[nashville housing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--Breaking out address into individual columns (address, city, state)

Select PropertyAddress
From PortfolioProject..[nashville housing]

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From PortfolioProject..[nashville housing]


--Cant separate 2 values from 1 column without adding 2 new columns so adding table below

ALTER TABLE [nashville housing]
Add PropertySplitAddress Nvarchar(255);

Update [nashville housing]
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [nashville housing]
Add PropertySplitCity Nvarchar(255);

Update [nashville housing]
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject..[nashville housing]

Select OwnerAddress
From PortfolioProject..[nashville housing]

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..[nashville housing]



ALTER TABLE [nashville housing]
Add OwnerSplitAddress Nvarchar(255);

Update [nashville housing]
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [nashville housing]
Add OwnerSplitCity Nvarchar(255);

Update [nashville housing]
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [nashville housing]
Add OwnerSplitState Nvarchar(255);

Update [nashville housing]
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioProject..[nashville housing]


--Change Y and N and No in 'Sold as Vacant' field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..[nashville housing]
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From PortfolioProject..[nashville housing]

Update [nashville housing]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


--Remove duplicates

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
From PortfolioProject..[nashville housing]
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num >1


--Delete unused columns

Select *
From PortfolioProject..[nashville housing]

ALTER TABLE PortfolioProject..[nashville housing]
DROP COLUMN OwnerAddress, TaxDistrict

ALTER TABLE PortfolioProject..[nashville housing]
DROP COLUMN SaleDate