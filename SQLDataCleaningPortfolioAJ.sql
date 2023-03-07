/*

Cleaning Data in SQL Queries

*/

Select *
From NashvilleHousing

--------------------------------------------------------------------------

-- Standardize Date Format (convert date-time format to just date)
Select SaleDateConverted, Convert(Date, SaleDate)
From NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)

--------------------------------------------------------------------------

--Populate Property Address data
Select *
From NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
Isnull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = Isnull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

-------------------------------------------------------------------------

--Breaking out Address into individual columns (address, city, state)
Select PropertyAddress
From NashvilleHousing

Select
Substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
Substring(PropertyAddress, charindex(',', PropertyAddress)+1, Len(PropertyAddress)) as Address
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, charindex(',', PropertyAddress) +1, Len(PropertyAddress))


Select *
From NashvilleHousing


Select OwnerAddress
From NashvilleHousing


Select
PARSENAME(Replace(OwnerAddress,',', '.'),3)
, PARSENAME(Replace(OwnerAddress,',', '.'),2)
, PARSENAME(Replace(OwnerAddress,',', '.'),1)
From NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',', '.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',', '.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',', '.'),1)

Select *
From NashvilleHousing

-----------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldasVacant), Count(SoldasVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

Select Soldasvacant,	
	Case When Soldasvacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When Soldasvacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End

----------------------------------------------------------------

--Remove Duplicates
With RowNumCTE As(
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by 
					UniqueID
					) row_num

From NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From NashvilleHousing

-----------------------------------------------------------------

--Delete Unused Columns
Select *
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

