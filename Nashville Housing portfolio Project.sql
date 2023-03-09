/*

Cleaning Data in SQL Queries

*/

select * 
from [Portfolio Project]..NashvillHousing


----------------------------------------------------------------------------------------------------------


-- Standardize Date Format

select saledateconverted, cast(saledate as date) as SaleDate
from [Portfolio Project]..NashvillHousing

---

alter table nashvillhousing
add SaleDateConverted date;

update NashvillHousing
set SaleDateConverted = cast(saledate as date)


----------------------------------------------------------------------------------------------------------


-- Populate Property Address data

select *
from [Portfolio Project]..NashvillHousing
order by ParcelID

---

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
isnull(a.propertyaddress, b.PropertyAddress)
from [Portfolio Project]..NashvillHousing a
join [Portfolio Project]..NashvillHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

---

update a
set PropertyAddress = isnull(a.propertyaddress, b.PropertyAddress)
from [Portfolio Project]..NashvillHousing a
join [Portfolio Project]..NashvillHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


----------------------------------------------------------------------------------------------------------


--Breaking out Address into Individual columns (Address, City, State)

select PropertyAddress
from [Portfolio Project]..NashvillHousing

---

select 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyaddress)) as Address
from [Portfolio Project]..NashvillHousing

---

alter table NashvillHousing
add PropertySplitAddress nvarchar(255);

update NashvillHousing
set PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1)

---

alter table NashvillHousing
add PropertySplitCity nvarchar(255);

update NashvillHousing
set PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyaddress))

---

select *
from [Portfolio Project]..NashvillHousing

-------

select OwnerAddress
from [Portfolio Project]..NashvillHousing

---

select
parsename(replace(owneraddress, ',', '.'), 3) as Address,
parsename(replace(owneraddress, ',', '.'), 2) as City,
parsename(replace(owneraddress, ',', '.'), 1) as State
from [Portfolio Project]..NashvillHousing

---

alter table NashvillHousing
add OwnerSplitAddress nvarchar(255);

update NashvillHousing
set OwnerSplitAddress = parsename(replace(owneraddress, ',', '.'), 3)

---

alter table NashvillHousing
add OwnerSplitCity nvarchar(255);

update NashvillHousing
set OwnerSplitCity = parsename(replace(owneraddress, ',', '.'), 2)

---

alter table NashvillHousing
add OwnerSplitState nvarchar(255);

update NashvillHousing
set OwnerSplitState = parsename(replace(owneraddress, ',', '.'), 1)

---

select *
from [Portfolio Project]..NashvillHousing


----------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(soldasvacant)
from [Portfolio Project]..NashvillHousing
group by SoldAsVacant
order by 2 desc

---

select SoldAsVacant,
	case when SoldAsVacant  = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
	end
from [Portfolio Project]..NashvillHousing

---

update NashvillHousing
set SoldAsVacant = case when SoldAsVacant  = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
				  	    else SoldAsVacant
					end

---

select distinct(SoldAsVacant)
from [Portfolio Project]..NashvillHousing


----------------------------------------------------------------------------------------------------------


--Remove Duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by uniqueid
						)  Duplicates_row_num
from [Portfolio Project]..NashvillHousing
					)
select *
from RowNumCTE
where Duplicates_row_num > 1
order by propertyaddress

---

with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by uniqueid
						)  Duplicates_row_num
from [Portfolio Project]..NashvillHousing
					)
DELETE
from RowNumCTE
where Duplicates_row_num > 1
--order by propertyaddress


----------------------------------------------------------------------------------------------------------


-- Delete Unused Columns

select *
from [Portfolio Project]..NashvillHousing

---

alter table [Portfolio Project]..NashvillHousing
drop column saledate, owneraddress, taxdistrict, propertyaddress