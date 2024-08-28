Drop Procedure If Exists GetCustomerTypes;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetCustomTypes]
Description : Get CustomType from CustomTypeMaster
*/
CREATE Or Alter Procedure[dbo].[GetCustomerTypes]
AS
BEGIN
	SELECT CustomerTypeId,CustomerTypeName,IsActive
	FROM CustomerTypeMaster WITH(NOLOCK)
END


GO
Drop Procedure If Exists SaveCustomerTypeDetails;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[SaveCustomerTypeDetails] '0','Leave 1',1
Description : Insert CustomerType from CustomerTypeMaster
*/

CREATE Or Alter Procedure[dbo].[SaveCustomerTypeDetails]
(
	@CustomerTypeId BIGINT,
	@CustomerTypeName VARCHAR(100),
	@IsActive BIT,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	If (
		(@CustomerTypeId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM CustomerTypeMaster WITH(NOLOCK) 
				WHERE  CustomerTypeName=@CustomerTypeName
			)
		)
		OR
		(@CustomerTypeId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM CustomerTypeMaster WITH(NOLOCK) 
				WHERE  CustomerTypeName=@CustomerTypeName and CustomerTypeId<>@CustomerTypeId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@CustomerTypeId=0)
		BEGIN
			Insert into CustomerTypeMaster(CustomerTypeName, IsActive,CreatedBy,CreatedOn)
			Values(@CustomerTypeName, @IsActive,@LoggedInUserId,GETDATE())
			SET @Result = SCOPE_IDENTITY();
		END
		ELSE IF(@CustomerTypeId> 0 and EXISTS(SELECT TOP 1 1 FROM CustomerTypeMaster WHERE CustomerTypeId=@CustomerTypeId))
		BEGIN
			UPDATE CustomerTypeMaster
	
		SET CustomerTypeName=@CustomerTypeName,IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE CustomerTypeId=@CustomerTypeId
			SET @Result = @CustomerTypeId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result 
END


GO
If OBJECT_ID('AddressTypesMaster') Is Not Null
Begin
	Drop Table AddressTypesMaster
End

GO

If OBJECT_ID('AddressTypesMaster') Is Null
Begin
	Create Table AddressTypesMaster
	(
		Id BIGINT Primary Key Identity(1,1),
		AddressType VarChar(10) Not Null
	)
End

GO

If Not Exists(Select * From AddressTypesMaster Where AddressType In('Home','Work','Other'))
Begin
	Set Identity_Insert AddressTypesMaster On;

	Insert Into AddressTypesMaster(Id, AddressType)
	Values(1,'Home'), (2,'Work'), (3,'Other');

	Set Identity_Insert AddressTypesMaster Off;
End

GO
  
 ALTER TABLE EmployeeAddressMapping
 ADD NameForAddress VARCHAR(100),MobileNo VARCHAR(15),EmailId VARCHAR(100),AddressTypeId BIGINT


 GO

If OBJECT_ID('CompanyDetails') Is Not Null
Begin
	Drop Table CompanyDetails
End

GO

If OBJECT_ID('CompanyDetails') Is Null
Begin

	CREATE TABLE CompanyDetails
	(
		CompanyId BIGINT IDENTITY(1,1) PRIMARY KEY,
		CompanyName VARCHAR(100) NOT NULL,
		LandlineNo VARCHAR(15),
		MobileNo VARCHAR(15),
		EmailId VARCHAR(100),
		CustomerTypeId BIGINT,
		SpecialRemarks VARCHAR(250),
		EmployeeId  BIGINT FOREIGN KEY REFERENCES EmployeeMaster(EmployeeId),
		IsActive BIT NOT NULL,
		CreatedBy BIGINT NOT NULL,
		CreatedOn DATETIME NOT NULL,
		ModifiedBy BIGINT,
		ModifiedOn DATETIME
	)
END

GO

If OBJECT_ID('ContactDetails') Is Not Null
Begin
	Drop Table ContactDetails
End

GO

If OBJECT_ID('ContactDetails') Is Null
Begin

	CREATE TABLE ContactDetails
	(
		ContactDetailId BIGINT IDENTITY(1,1) PRIMARY KEY,
		ContactName VARCHAR(100) NOT NULL,
		MobileNo VARCHAR(15),
		RefPartyId  BIGINT FOREIGN KEY REFERENCES ReferenceMaster(ReferenceId),
		IsActive BIT NOT NULL,
		CreatedBy BIGINT NOT NULL,
		CreatedOn DATETIME NOT NULL,
		ModifiedBy BIGINT,
		ModifiedOn DATETIME
	)
END