Select *
From ProjectPortfolio..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------

-- Standarized Date Formate

Select SaleDateConverted , CONVERT(Date,SaleDate) 
From ProjectPortfolio..NashvilleHousing

Update ProjectPortfolio..NashvilleHousing
Set SaleDate =  CONVERT(Date,SaleDate)

Alter Table NashVilleHousing 
Add SaleDateConverted Date;

Update ProjectPortfolio..NashvilleHousing
Set SaleDateConverted =  CONVERT(Date,SaleDate)


-- Populate Property Address Data

Select *
From ProjectPortfolio..NashvilleHousing
Where PropertyAddress is null

Select x.ParcelID , x.PropertyAddress , y.ParcelID , y.PropertyAddress , ISNULL(x.PropertyAddress,y.PropertyAddress)
From ProjectPortfolio..NashvilleHousing x
Join ProjectPortfolio..NashvilleHousing y
On x.ParcelID = y.ParcelID
and x.[UniqueID ] <> y.[UniqueID ]
Where x.PropertyAddress is null

Update x
Set PropertyAddress = ISNULL(x.PropertyAddress,y.PropertyAddress)
From ProjectPortfolio..NashvilleHousing x
Join ProjectPortfolio..NashvilleHousing y
On x.ParcelID = y.ParcelID
and x.[UniqueID ] <> y.[UniqueID ]
Where x.PropertyAddress is null


-- Breaking Out Address Into Indivisual Column( Address,City,State )

Select PropertyAddress
From ProjectPortfolio..NashvilleHousing
Where PropertyAddress is null

Select 
SUBSTRING(propertyAddress ,1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(propertyAddress , CHARINDEX(',',PropertyAddress)+1 , Len(propertyAddress)) as Address
From ProjectPortfolio..NashvilleHousing

Alter Table ProjectPortfolio..NashVilleHousing 
Add PropertySplitAddress Nvarchar(255);

Update ProjectPortfolio..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(propertyAddress ,1, CHARINDEX(',',PropertyAddress)-1) 

Alter Table ProjectPortfolio..NashVilleHousing 
Add PropertySplitCity Nvarchar(255);

Update ProjectPortfolio..NashvilleHousing
Set PropertySplitCity = SUBSTRING(propertyAddress , CHARINDEX(',',PropertyAddress)+1 , Len(propertyAddress))  

Select *
From ProjectPortfolio..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From ProjectPortfolio..NashvilleHousing
--Where OwnerAddress is not null

Alter Table ProjectPortfolio..NashVilleHousing 
Add OwnerSplitAddress Nvarchar(255);

Update ProjectPortfolio..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table ProjectPortfolio..NashVilleHousing 
Add OwnerSplitCity Nvarchar(255);

Update ProjectPortfolio..NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table ProjectPortfolio..NashVilleHousing 
Add OwnerSplitState Nvarchar(255);

Update ProjectPortfolio..NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From ProjectPortfolio..NashvilleHousing


-- Change Y and N to Yes and No in 'Sold and Vacant' Field

Select Distinct(SoldAsVacant) , COUNT(SoldAsVacant)
From ProjectPortfolio..NashvilleHousing
Group by SoldAsVacant
Order by 1

Select SoldAsVacant
,Case 
When SoldAsVacant = 'Y' then 'Yes'
When SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
End
From ProjectPortfolio..NashvilleHousing

Update ProjectPortfolio..NashvilleHousing
Set SoldAsVacant = Case 
When SoldAsVacant = 'Y' then 'Yes'
When SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
End 


-- Remove Duplicates

With RowNumCTE as(
Select *,
Row_Number() Over(
                   Partition By ParcelId,
				                PropertyAddress,
				                SaleDate,
				                SalePrice,
								LegalReference
								Order by 
								        UniqueId
										) row_num
From ProjectPortfolio..NashvilleHousing					
)
Select *
From RowNumCTE
Where row_num>1
--Order by PropertyAddress


-- Drop Unused Column

Select *
From ProjectPortfolio..NashvilleHousing 

Alter Table  ProjectPortfolio..NashvilleHousing
Drop Column PropertyAddress , OwnerAddress , TaxDistrict , SaleDate

------------------------------------------------------------------------------------------------------------------------------------------------------

