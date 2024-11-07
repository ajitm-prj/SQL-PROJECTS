-- CLEANING DATA IN SQL

select * 
from PortfolioProjects.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------

--Standardize Date Format

select SaleDate, CONVERT(Date, SaleDate)
from PortfolioProjects.dbo.NashvilleHousing

Alter table  NashvilleHousing
Add SaleDateConverted Date

update  NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

------------------------------------------------------------------------------------------------

---Populate Property Address data

select * 
from 
PortfolioProjects.dbo.NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID

select a.ParcelId,a.PropertyAddress,b.ParcelId, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from
PortfolioProjects.dbo.NashvilleHousing a
JOIN
PortfolioProjects.dbo.NashvilleHousing b
On
a.ParcelId = b.ParcelID
AND
a.[UniqueID]<>b.[UniqueID]
where 
a.PropertyAddress is Null

Update a
set 
PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from
PortfolioProjects.dbo.NashvilleHousing a
JOIN
PortfolioProjects.dbo.NashvilleHousing b
On
a.ParcelId = b.ParcelID
AND
a.[UniqueID]<>b.[UniqueID]
where 
a.PropertyAddress is Null
---------------------------------------------------------------------------------------

--Breaking out Address into Individual coloumns(Address,city, State)

Select propertyAddress 
from
PortfolioProjects.dbo.NashvilleHousing

select 
substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address,
substring(PropertyAddress,  Charindex(',', Propertyaddress) +1, len(PropertyAddress)) as City
from
PortfolioProjects.dbo.NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1)

Alter table NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, Charindex(',', PropertyAddress) +1, len(PropertyAddress))

select * 
from PortfolioProjects.dbo.NashvilleHousing

select OwnerAddress
from PortfolioProjects.dbo.NashvilleHousing

select 
parsename(Replace(OwnerAddress, ',','.'),3),
parsename(Replace(OwnerAddress, ',','.'),2),
parsename(Replace(OwnerAddress, ',','.'),1)
from
PortfolioProjects.dbo.NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
set OwnerSplitAddress = parsename(Replace(OwnerAddress, ',','.'),3)

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
set OwnerSplitCity = parsename(Replace(OwnerAddress, ',','.'),2)

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
set OwnerSplitState = parsename(Replace(OwnerAddress, ',','.'),1)

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from 
PortfolioProjects.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

select SoldAsVacant
, CASE 
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
END
From PortfolioProjects.dbo.NashvilleHousing

update PortfolioProjects.dbo.NashvilleHousing
set SoldAsVacant = CASE
                   When SoldAsVacant = 'Y' Then 'Yes'
                   When SoldAsVacant = 'N' Then 'No'
                   Else SoldAsVacant
                   END

----------------------------------------------------------------------------------------------------------------------------

----REMOVE DUPLICATES--------

WITH RowNumCTE AS(
select *,
 ROW_NUMBER() OVER(
 PARTITION BY ParcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY
			   UniqueID
			   ) row_num

From PortfolioProjects.dbo.NashvilleHousing
 )
Select * 
 FROM
 RowNumCTE
 where row_num>1
 order by PropertyAddress


 Delete 
 from RowNumCTE
 where
 row_num > 1

 --------------------------------------------------------------------------------------------------

 --------DELETE UNUSED COLOUMNS-------------------------

 Alter table PortfolioProjects.dbo.NashvilleHousing 
 drop
 Column OwnerAddress,PropertyAddress, TaxDistrict

 select * 
from PortfolioProjects.dbo.NashvilleHousing