--Clean data using SQL Queries. 

Select * from Portfolio_Project.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------------------------
--Standardized Date Format
Alter table NashvilleHousing
Add SaleDateConverted Date;


Update NashvilleHousing
SET SaleDateConverted= CONVERT(Date, Saledate)

Select SaleDateConverted
from Portfolio_Project.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------------------------------------------
--Populate Property Address Data
Select *
from Portfolio_Project.dbo.NashvilleHousing
Where PropertyAddress is NULL

--so we have many NULL property address
Select Top 10 *
from Portfolio_Project.dbo.NashvilleHousing
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from Portfolio_Project.dbo.NashvilleHousing a
Join Portfolio_Project.dbo.NashvilleHousing b
  on a.ParcelID=b.ParcelID
  AND a.UniqueID <> b.UniqueID
Where a.Propertyaddress is null


Update a 
SET PropertyAddress= ISNULL(a.propertyaddress, b.propertyaddress)
from Portfolio_Project.dbo.NashvilleHousing a
Join Portfolio_Project.dbo.NashvilleHousing b
  on a.ParcelID=b.ParcelID
  AND a.UniqueID <> b.UniqueID
Where a.Propertyaddress is null
-----------------------------------------------------------------------------------------------------------------------------------------------------
--Breaking out address into individual columns(Address, City, State)
Select PropertyAddress
from Portfolio_Project.dbo.NashvilleHousing

Select 
Substring(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
Substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
from Portfolio_Project.dbo.NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Alter table NashvilleHousing
Add
SplitCity nvarchar(255);


Update NashvilleHousing
SET PropertySplitAddress= Substring(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1);

Update NashvilleHousing
SET
SplitCity=Substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress));

Select *
from Portfolio_Project.dbo.NashvilleHousing


Alter table NashvilleHousing
Drop Column Address;

Alter table NashvilleHousing
Drop Column City;
-------------------------Parse----------------------------
Select parsename(Replace(owneraddress,',', '.'),3)
,parsename(Replace(owneraddress,',', '.'),2)
,parsename(Replace(owneraddress,',', '.'),1)
from Portfolio_Project.dbo.NashvilleHousing


Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress=parsename(Replace(owneraddress,',', '.'),3)



Alter table NashvilleHousing
Add
OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity= parsename(Replace(owneraddress,',', '.'),2)



Alter table NashvilleHousing
Add
OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState= parsename(Replace(owneraddress,',', '.'),1)


--Change Y and N to Yes and NO respectively under 'Sold as Vacant' field

Select distinct(SoldAsVacant)
from Portfolio_Project.dbo.NashvilleHousing

Select SOldASVacant
, Case When SoldAsVacant='Y' THEN 'YES'
       When SoldAsVacant='N' THEN 'No'
       ELSE SoldAsVacant
	   END
From Portfolio_Project.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant=  Case When SoldAsVacant='Y' THEN 'YES'
       When SoldAsVacant='N' THEN 'No'
       ELSE SoldAsVacant
	   END


--Remove Duplicates
--using ROW Number, find total duplicates= 104 row and tehn delete
--Find DUplicates
With RowNumCTE AS
(Select *, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID
			 )row_num
from Portfolio_Project.dbo.NashvilleHousing
)
Select  *
From RowNumCTE
Where row_num >1
Order by PropertyAddress


--Remove Duplicates
With RowNumCTE AS
(Select *, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID
			 )row_num
from Portfolio_Project.dbo.NashvilleHousing
)
Delete
From RowNumCTE
Where row_num >1
--Order by PropertyAddress

--56,477-104 rows left


--Delete unused columns

Alter table Portfolio_Project.dbo.NashvilleHousing
Drop column OwnerAddress,TaxDistrict

Select *
from Portfolio_Project.dbo.NashvilleHousing

--Data is more usable and efficient to find insights