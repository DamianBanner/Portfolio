use PortfolioProject

select * 
from NashvilleHousing
----------------------------------------------------------------------------------------------------

-- standardize date format

select SaleDateconverted
from NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date,saledate)

alter table nashvillehousing
add saledateconverted date;

go 

update NashvilleHousing
set saledateconverted = CONVERT(date,saledate);

-------------------------------------------------------------------------------------------------------

-- populate property address using parcellid with a property adress 

select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.propertyaddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------

-- Breaking out address into individual columns (address, City, state)

select PropertyAddress
from NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(propertyaddress, 1, charindex(',', propertyaddress) -1) as address
, SUBSTRING(propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress)) as address
from NashvilleHousing

alter table nashvillehousing
add propertysplitaddress nvarchar(255);

update NashvilleHousing
set PropertysplitAddress = SUBSTRING(propertyaddress, 1, charindex(',', propertyaddress) -1)

alter table nashvillehousing
add propertysplitcity nvarchar(255);

update NashvilleHousing
set Propertysplitcity = SUBSTRING(propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress))

select * from NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------

-- breaking up owneraddress into 3 parts (a different way of doing the method above)

select OwnerAddress 
from NashvilleHousing

select
PARSENAME(REPLACE(owneraddress, ',','.'), 3)
, PARSENAME(REPLACE(owneraddress, ',','.'), 2)
, PARSENAME(REPLACE(owneraddress, ',','.'), 1)
from NashvilleHousing

alter table nashvillehousing
add ownersplitaddress nvarchar(255);

update NashvilleHousing
set ownersplitaddress = PARSENAME(REPLACE(owneraddress, ',','.'), 3)

alter table nashvillehousing
add ownersplitcity nvarchar(255);

update NashvilleHousing
set ownersplitcity = PARSENAME(REPLACE(owneraddress, ',','.'), 2)

alter table nashvillehousing
add ownersplitstate nvarchar(255);

update NashvilleHousing
set ownersplitstate = PARSENAME(REPLACE(owneraddress, ',','.'), 1)


-----------------------------------------------------------------------------------------------------------

--change Y and N to Yes and No in "sold as vacant" field

select Distinct(soldasvacant), count(soldasvacant)
from NashvilleHousing
group by SoldAsVacant
order by count(soldasvacant)

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from NashvilleHousing

---------------------------------------------------------------------------------------------------

-- remove duplicates

with rownumcte as(
select *,
	ROW_NUMBER() over(
	partition by parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by uniqueid) row_num

from NashvilleHousing
--order by ParcelID
)
select *
from rownumcte
where row_num > 1


--------------------------------------------------------------------------------------------------------

-- delete unused columns

alter table nashvillehousing
drop column owneraddress, taxdistrict,propertyaddress, saledate

select * from NashvilleHousing 