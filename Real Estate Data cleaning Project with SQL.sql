/* THIS IS A PROJECT ON DATA CLEANING USING VARIOUS SQL COMMANDS*/

select * 
from PortfolioProject..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardizing the Date Format
select SaleDate2,convert(date, SaleDate)
from PortfolioProject..NashvilleHousing

/*update NashvilleHousing
set saleDate = convert(date, SaleDate)    this didnt work  */

alter table NashvilleHousing
add SaleDate2 date;

update NashvilleHousing
set saleDate2 = convert(date, SaleDate)




--------------------------------------------------------------------------------------------------------------------------

-- Populating Property Address data
--some properties have the same parcel Id but missing property adresses

select * 
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress) 
from PortfolioProject..NashvilleHousing a
	join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress) 
from PortfolioProject..NashvilleHousing a
	join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- spliting out Address into Individual Columns (Address, City, State) to improve readability and meaning
--on Property Adresses

select PropertyAddress 
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID 

SELECT
substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)as Address
,substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))


--On owners' Addresses

select OwnerAddress
from PortfolioProject..NashvilleHousing

select
parsename(replace(OwnerAddress,',', '.'),3) 
,parsename(replace(OwnerAddress,',', '.'),2)
,parsename(replace(OwnerAddress,',', '.'),1)
from PortfolioProject..NashvilleHousing
--where OwnerAddress is not null


alter table NashvilleHousing
add ownerSplitAddress nvarchar(255);

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress,',', '.'),3)

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress,',', '.'),2)

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress,',', '.'),1)


select *
from PortfolioProject..NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------

--vacant field
-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant 
order by 2

select SoldAsVacant,
case
	when SoldAsVacant = 'Y' then 'Yes' 
	when SoldAsVacant = 'N' then 'No' 
	else SoldAsVacant 
	end
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set 
SoldAsVacant= case
	when SoldAsVacant = 'Y' then 'Yes' 
	when SoldAsVacant = 'N' then 'No' 
	else SoldAsVacant 
	end
from PortfolioProject..NashvilleHousing




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates

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

From PortfolioProject..NashvilleHousing
--order by ParcelID
)

delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


select*
From PortfolioProject.dbo.NashvilleHousing



---------------------------------------------------------------------------------------------------------

-- Deleteing Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate