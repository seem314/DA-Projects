select *
from Portfolio_Project..nashvilleHousing

--------------------------------------

--Standring Date Format

select  SaleDate2, Convert(Date, SaleDate)
from Portfolio_Project..nashvilleHousing

alter table nashvilleHousing
add saledate2 Date; 

update nashvilleHousing
set SaleDate2 = Convert(Date, SaleDate)


--------------------------------------

--populate property Address Data

select *
from Portfolio_Project..nashvilleHousing
where PropertyAddress is null
order by ParcelID

select joi1.ParcelID, joi1.PropertyAddress, joi2.ParcelID, joi2.PropertyAddress
, isnull(joi1.PropertyAddress,joi2.PropertyAddress)
from Portfolio_Project..nashvilleHousing joi1
join Portfolio_Project..nashvilleHousing joi2
	on joi1.ParcelID = joi2.ParcelID
	and joi1.[UniqueID ]<>joi2.[UniqueID ]
where joi1.PropertyAddress is not null

update joi1
set PropertyAddress = isnull(joi1.PropertyAddress,joi2.PropertyAddress)
from Portfolio_Project..nashvilleHousing joi1
join Portfolio_Project..nashvilleHousing joi2
	on joi1.ParcelID = joi2.ParcelID
	and joi1.[UniqueID ]<>joi2.[UniqueID ]
where joi1.PropertyAddress is null

--------------------------------------

-- Breaking out Address(Property) into Individual Columns (Address, City, State)

select PropertyAddress
from Portfolio_Project..nashvilleHousing

select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))as Address2
from Portfolio_Project..nashvilleHousing

ALTER TABLE nashvilleHousing
add PropertySplitAddress nvarchar(255)

UPDATE nashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE nashvilleHousing
add PropertySplitCity nvarchar(255)

UPDATE nashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) 

select *
from Portfolio_Project..nashvilleHousing

--------------------------------------

-- Breaking out Address(Owener) into Individual Columns (Address, City, State)

select OwnerAddress
from Portfolio_Project..nashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) 
,PARSENAME(REPLACE(OwnerAddress,',','.'),2) 
,PARSENAME(REPLACE(OwnerAddress,',','.'),1) 
from Portfolio_Project..nashvilleHousing
--order by OwnerAddress desc


Alter table nashvilleHousing
add OwnerSplitAddress nvarchar(255)

Update nashvillehousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

Alter table nashvillehousing
add OwnerSplitCity nvarchar(255)

Update nashvillehousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 

Alter table nashvillehousing
add OwnerSplitState nvarchar(255)

Update nashvillehousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 

--------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From Portfolio_Project..nashvilleHousing
group by SoldAsVacant
order by 2

select Distinct(SoldAsVacant),
Case	
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
End 
From Portfolio_Project..nashvilleHousing

update nashvilleHousing
Set SoldAsVacant = Case	
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
End

 --------------------------------------

 --Removing Duplicates
 With RawNumCTE as(
 Select *,
	ROW_NUMBER() over( 
	partition by parcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference 
				 Order by 
					UniqueID
					) Row_num
 from Portfolio_Project..nashvilleHousing
 --order by ParcelID
 )
 select *
 from RawNumCTE
 where Row_num > 1
 order by PropertyAddress

 select*
 from Portfolio_Project..nashvilleHousing

--------------------------------------

-- Delete Unused Column 

 select *
 from Portfolio_Project..nashvilleHousing

 Alter Table Portfolio_Project..nashvilleHousing
 Drop Column OwnerAddress, TaxDistrict, PropertyAddress