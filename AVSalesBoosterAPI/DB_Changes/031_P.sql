-- GetReportingToEmployeeForSelectList 1,0
Alter Procedure GetReportingToEmployeeForSelectList
	@RoleId		BigInt,
	@RegionId	BigInt = 0
As
Begin
	Set NoCount On;

	SELECT
		EM.EmployeeId AS [Value], EM.EmployeeName AS [Text]
	From EmployeeMaster EM With(NoLock)
	Left Join EmployeeAddressMapping EAM With(NoLock)
		On EAM.EmployeeId = EM.EmployeeId
	Left Join AddressMaster AM With(NoLock)
		On AM.AddressId = EAM.AddressId
	Where EM.RoleId = @RoleId
		And (@RegionId = 0 Or AM.RegionId = @RegionId)
End

GO

If Object_Id('CatalogMaster') Is Null
Begin
	Create Table CatalogMaster
	(
		CatalogId		Int				Primary Key Identity(1,1),
		CollectionId	Int				Not Null	References CollectionMaster(CollectionId),
		Remarks			VarChar(500),
		IsActive		BIT				Not Null,
		CreatedBy		BIGINT			Not Null,
		CreatedOn		DATETIME		Not Null,
		ModifiedBy		BIGINT,
		ModifiedOn		DATETIME
	)
End

GO

If Object_Id('CatalogFiles') Is Null
Begin
	Create Table CatalogFiles
	(
		CatalogFileId		Int				Primary Key		Identity(1,1),
		CatalogId			Int				Not Null		References CatalogMaster(CatalogId),
		UploadedFilesName	varchar(500)	Not Null,
		SavedFilesName		varchar(500)	Not Null,
		IsDeleted			Bit				Not Null,
		ModifiedBy			BigInt			Null,
		ModifiedOn			DateTime		Null
	)
End

GO

Create Or Alter Procedure SaveCatalogMasterDetails
As
Begin
	Set NoCount On;

	Select *
	From CatalogMaster
End

GO
