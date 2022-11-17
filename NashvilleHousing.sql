#Cleaning Nashville Housing Data using SQL Queries#
/#


Test database dbo.nashville_housing
Select *
From Housing.dbo.Nashville_Housing


1. #Standardize Datetime Format#

Select Convert(Date, SaleDate) 
From Housing.dbo.Nashville_Housing

Alter Table Housing.dbo.Nashville_Housing
Add Sale_Date Date

Update Housing.dbo.Nashville_Housing
Set Sale_Date=Convert(Date, Saledate) 

Alter Table Housing.dbo.Nashville_Housing
Drop Column SaleDate

2. #Populate property address data using parcelid to replace null values#
Select *
From Housing.dbo.Nashville_Housing
order by ParcelID

#Using selfjoin#
Select a.parcelID, a.propertyaddress, b.parcelID, b. propertyaddress ,
ISNULL(a.propertyaddress,b.PropertyAddress)
From Housing.dbo.Nashville_Housing a
Join Housing.dbo.Nashville_Housing b
    on a.parcelid=b.parcelid
	And a.UniqueId <>b.UniqueID
Where a.propertyaddress is null


Update a
Set PropertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress)
From Housing.dbo.Nashville_Housing a
Join Housing.dbo.Nashville_Housing b
    on a.parcelid = b.parcelid
	And a.UniqueId <>b.UniqueID
Where a.propertyaddress is null


#Using Substring and Character Index to split street number from PropertyAddres#

Select Propertyaddress
From Housing.dbo.Nashville_Housing


Select 
Substring(propertyaddress,1,Charindex(',', propertyaddress)) as Streetaddress
,Charindex(',', propertyaddress)
From Housing.dbo.Nashville_Housing


Select 
Substring(propertyaddress,1,Charindex(',', propertyaddress)-1) as Streetaddress
,Substring(propertyaddress,Charindex(',', propertyaddress)+1,Len(propertyaddress)) as City
From Housing.dbo.Nashville_Housing


Alter Table Housing.dbo.Nashville_Housing
Add PropertyStreetAddress nvarchar(255)


Update Housing.dbo.Nashville_Housing
Set PropertyStreetAddress = Substring(propertyaddress,1,Charindex(',', propertyaddress)-1)


Alter Table Housing.dbo.Nashville_Housing
Add PropertyCity nvarchar(255)


Update Housing.dbo.Nashville_Housing
Set PropertyCity= Substring(propertyaddress,Charindex(',', propertyaddress)+1,Len(propertyaddress))


Select *
From Housing.dbo.Nashville_Housing


#Owner Address#
Select Owneraddress
From Housing.dbo.Nashville_Housing


Select
Parsename(Replace(Owneraddress, ',', '.'),3) as Ownerstreetaddress
From Housing.dbo.Nashville_Housing


Select
Parsename(Replace(Owneraddress, ',', '.'),2) as OwnerCity
From Housing.dbo.Nashville_Housing


Select
Parsename(Replace(Owneraddress, ',', '.'),1) as Ownerstate
From Housing.dbo.Nashville_Housing


Alter Table Housing.dbo.Nashville_Housing
Add OwnerStreetAddress nvarchar(255)

Update Housing.dbo.Nashville_Housing
Set OwnerStreetAddress = Parsename(Replace(Owneraddress, ',', '.'),3) 

Alter Table Housing.dbo.Nashville_Housing
Add OwnerCity nvarchar(255)

Update Housing.dbo.Nashville_Housing
Set OwnerCity=Parsename(Replace(Owneraddress, ',', '.'),2)

Alter Table Housing.dbo.Nashville_Housing
Add OwnerState nvarchar(255)

Update Housing.dbo.Nashville_Housing
Set OwnerState=Parsename(Replace(Owneraddress, ',', '.'),1)


Select *
From Housing.dbo.Nashville_Housing


3. #Standardize SoldasVacant column by replacing 'Y' and 'N'with 'Yes' and 'No'#

Select Distinct(Soldasvacant), Count(Soldasvacant)
From Housing.dbo.Nashville_Housing
Group by Soldasvacant
Order by 2

Select Soldasvacant
, Case When Soldasvacant = 'Y' THEN 'Yes'
       When Soldasvacant = 'N' THEN 'No'
	   Else Soldasvacant
	   End
From Housing.dbo.Nashville_Housing

Update Housing.dbo.Nashville_Housing
Set Soldasvacant =  Case When Soldasvacant = 'Y' THEN 'Yes'
       When Soldasvacant = 'N' THEN 'No'
	   Else Soldasvacant
	   End

4. #Removing Duplicates just to exhibit skills#

With RowNumberCTE AS(
Select *,
     Row_number() Over (
	 Partition by ParcelID,
	              PropertyAddress,
				  SalePrice,
				  Sale_Date,
				  LegalReference
				  Order by 
				     UniqueID
					 )Row_num
           
From Housing.dbo.Nashville_Housing
--Order by ParcelID
)
Delete
From RowNumberCTE
Where Row_num > 1
Order By PropertyAddress


With RowNumberCTE AS(
Select *,
     Row_number() Over (
	 Partition by ParcelID,
	              PropertyAddress,
				  SalePrice,
				  Sale_Date,
				  LegalReference
				  Order by 
				     UniqueID
					 )Row_num
           
From Housing.dbo.Nashville_Housing
--Order by ParcelID
)
Select *
From RowNumberCTE
Where Row_num > 1
Order By PropertyAddress


5. #Deleting unused columns just to exhibit skills#
Select *
From Housing.dbo.Nashville_Housing

Alter Table Housing.dbo.Nashville_Housing
Drop Column OwnerAddress, PropertyAddress
