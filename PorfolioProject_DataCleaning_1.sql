

select * 
from PortfolioProject.dbo.NashvilleHousing

--STANDARDIZE DATE FORMAT

select saledate, convert(Date, SaleDate) 
from PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing
set SaleDate = convert(Date, SaleDate)

alter table PortfolioProject.dbo.NashvilleHousing
add SaleDateConverted Date;

alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDateCoverted

update PortfolioProject.dbo.NashvilleHousing
set SaleDateConverted=convert(Date, SaleDate)

select SaleDateConverted 
from PortfolioProject.dbo.NashvilleHousing

--POPULATE PROPERTY ADDRESS DATA

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing as a
join PortfolioProject.dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress =  isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing as a
join PortfolioProject.dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

--BREAKING OUT PROPERTY ADDRESS INTO INDIVIDUAL COLUMNS (Address, City, State)

select PropertyAddress, 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, CHARINDEX(',', PropertyAddress)-1) as City
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255), ProprrtySplitCity nvarchar(255)

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
    ProprrtySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, CHARINDEX(',', PropertyAddress)-1)

select *
from PortfolioProject.dbo.NashvilleHousing

--BREAKING OUT PROPERTY ADDRESS INTO INDIVIDUAL COLUMNS (Address, City, State)

select OwnerAddress, PARSENAME(replace(OwnerAddress, ',', '.'),3),
					 PARSENAME(replace(OwnerAddress, ',', '.'),2),
					 PARSENAME(replace(OwnerAddress, ',', '.'),1)
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255), 
	OwnerSplitCity nvarchar(255),
	OwnerSplitState nvarchar(255)

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'),3),
    OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'),2),
	OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'),1)

select * 
from PortfolioProject.dbo.NashvilleHousing

--CHANGE Y AND N TO YES AND NO IN 'Sold As Vacant' FIELD

select distinct(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing

select SoldAsVacant, count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant

select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant='Y' then 'Yes'
						when SoldAsVacant='N' then 'No'
						else SoldAsVacant
						end
from PortfolioProject.dbo.NashvilleHousing

--DELETE DUPLICATE COLUMNS

with RowNumCTE as(
select *, 
 ROW_NUMBER() over (
 partition by ParcelID,
			  PropertyAddress, 
			  SalePrice,
			  SaleDate, 
			  LegalReference 
			  order by UniqueID) 
from PortfolioProject.dbo.NashvilleHousing)
--order by ParcelID

--where NoOfDuplicates >1


select *
from RowNumCTE
where NoOfDulpicates > 1


select *
from PortfolioProject.dbo.NashvilleHousing










