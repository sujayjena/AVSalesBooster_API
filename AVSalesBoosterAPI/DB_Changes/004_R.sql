If OBJECT_ID('EmployeeAddressMapping') Is Not Null
Begin
	Drop Table EmployeeAddressMapping
End

GO

If OBJECT_ID('EmployeeMaster') Is Not Null
Begin
	Drop Table EmployeeMaster
End

GO

If OBJECT_ID('EmployeeMaster') Is Null
Begin

	CREATE TABLE EmployeeMaster
	(
	EmployeeId BIGINT IDENTITY(1,1) PRIMARY KEY,
	EmployeeName VARCHAR(100),
	EmployeeCode VARCHAR(100),
	EmailId VARCHAR(100),
	MobileNumber VARCHAR(20),
	RoleId BIGINT FOREIGN KEY REFERENCES RoleMaster(RoleId),
	ReportingTo BIGINT FOREIGN KEY REFERENCES RoleMaster(RoleId),
	DateOfBirth Datetime,
	DateOfJoining Datetime,
	EmergencyContactNumber VARCHAR(20),
	BloodGroup VARCHAR(10),
	IsWebUser BIT,
	IsMobileUser BIT,
	IsActive BIT NOT NULL,
	FileOriginalName VARCHAR(2000),
	ImageUpload VARCHAR(2000),
	CreatedBy BIGINT NOT NULL,
	CreatedOn DATETIME NOT NULL,
	ModifiedBy BIGINT,
	ModifiedOn DATETIME
	)
END
GO
If OBJECT_ID('AddressMaster') Is Null
Begin
	Create Table AddressMaster
	(
		AddressId		BigInt Primary Key Identity(1,1),
		[Address]		VARCHAR(500) Not Null,
		AddressLineTwo	VarChar(500) Null,
		StateId			BIGINT FOREIGN KEY REFERENCES StateMaster(StateId) Not Null,
		RegionId		BIGINT FOREIGN KEY REFERENCES RegionMaster(RegionId) Not Null,
		DistrictId		BIGINT FOREIGN KEY REFERENCES DistrictMaster(DistrictId) Not Null,
		AreaId			BIGINT FOREIGN KEY REFERENCES AreaMaster(AreaId) Not Null,
		Pincode			VARCHAR(15) Not Null,
		IsActive		Bit Not Null,
		IsDefault		Bit Not Null,
		CreatedBy		BIGINT NOT NULL,
		CreatedOn		DATETIME NOT NULL,
		ModifiedBy		BIGINT,
		ModifiedOn		DATETIME
	)
End

GO

If Object_id('EmployeeAddressMapping') Is Null
Begin
CREATE TABLE EmployeeAddressMapping
(
EmployeeAddressId BIGINT IDENTITY(1,1) PRIMARY KEY,
EmployeeId BIGINT FOREIGN KEY REFERENCES EmployeeMaster(EmployeeId), 
AddressId  BIGINT FOREIGN KEY REFERENCES AddressMaster(AddressId)
)
End

Drop Procedure If Exists GetEmployees;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetEmployees]
Description : Get Employee Detail from EmployeeMaster
*/
CREATE Or Alter Procedure[dbo].[GetEmployees]
AS
BEGIN
	SELECT EM.EmployeeId,EM.EmployeeName,EM.EmployeeCode,EM.EmailId,EM.MobileNumber,EM.RoleId,EM.ReportingTo,
		   AD.Address,AD.StateId,AD.RegionId,AD.DistrictId,AD.AreaId,AD.Pincode,EM.DateOfBirth,EM.DateOfJoining,
		   EM.EmergencyContactNumber,EM.BloodGroup,EM.IsWebUser,Em.IsMobileUser,EM.IsActive,EM.FileOriginalName,EM.ImageUpload
	FROM EmployeeMaster EM WITH(NOLOCK)
	INNER JOIN EmployeeAddressMapping EAM WITH(NOLOCK) ON EAM.EmployeeId = EM.EmployeeId
	INNER JOIN AddressMaster AD WITH(NOLOCK) ON Ad.AddressId=EAM.AddressId
END

GO
Drop Procedure If Exists SaveEmployeeDetails;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[SaveEmployeeDetails] 
Description : Insert Employee Detail from EmployeeMaster
*/
CREATE Or Alter Procedure[dbo].[SaveEmployeeDetails]
(
	@EmployeeId BIGINT,
	@EmployeeName VARCHAR(100),
	@EmployeeCode VARCHAR(100),
	@EmailId VARCHAR(100),
	@MobileNumber VARCHAR(20),
	@RoleId BIGINT,
	@ReportingTo BIGINT,
	@Address VARCHAR(500),
	@StateId BIGINT,
	@RegionId BIGINT,
	@DistrictId BIGINT,
	@AreaId BIGINT,
	@Pincode VARCHAR(15),
	@DateOfBirth Datetime,
	@DateOfJoining Datetime,
	@EmergencyContactNumber VARCHAR(20),
	@BloodGroup VARCHAR(10),
	@IsWebUser BIT,
	@IsMobileUser BIT,
	@IsActive BIT,
	@FileOriginalName VARCHAR(2000),
	@ImageUpload VARCHAR(2000),
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	If (
		(@EmployeeId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM EmployeeMaster WITH(NOLOCK) 
				WHERE  EmployeeCode=@EmployeeCode and EmployeeName=@EmployeeName
			)
		)
		OR
		(@EmployeeId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM EmployeeMaster WITH(NOLOCK) 
				WHERE  EmployeeCode=@EmployeeCode and EmployeeName=@EmployeeName and EmployeeId<>@EmployeeId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@EmployeeId=0)
		BEGIN
			Insert into EmployeeMaster(EmployeeName,EmployeeCode,EmailId,MobileNumber,RoleId,ReportingTo,DateOfBirth,DateOfJoining,
						EmergencyContactNumber,BloodGroup,IsWebUser,IsMobileUser,IsActive,FileOriginalName,ImageUpload,CreatedBy,CreatedOn)
			Values(@EmployeeName,@EmployeeCode,@EmailId ,@MobileNumber,@RoleId,@ReportingTo,
					@DateOfBirth,@DateOfJoining,@EmergencyContactNumber,@BloodGroup,@IsWebUser,@IsMobileUser,@IsActive,@FileOriginalName,
					@ImageUpload,@LoggedInUserId,GETDATE())

			SET @Result = SCOPE_IDENTITY();
			
			-- Insert Into Address 
			INSERT INTO AddressMaster(Address,StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn)
			Values (@Address,@StateId,@RegionId,@DistrictId,@AreaId,@Pincode,1,@IsActive,@LoggedInUserId,GETDATE())

			SET @AddressId = SCOPE_IDENTITY();

			INSERT INTO EmployeeAddressMapping(EmployeeId,AddressId)
			Values (@Result,@AddressId)
		
		END
		ELSE IF(@EmployeeId> 0 and EXISTS(SELECT TOP 1 1 FROM EmployeeMaster WHERE EmployeeId=@EmployeeId))
		BEGIN
			UPDATE EmployeeMaster
			SET EmployeeName=@EmployeeName,EmployeeCode=@EmployeeCode,EmailId=@EmailId,MobileNumber=@MobileNumber,RoleId=@RoleId,
						ReportingTo=@ReportingTo,DateOfBirth=@DateOfBirth,DateOfJoining=@DateOfJoining,
						EmergencyContactNumber=@EmergencyContactNumber,BloodGroup=@BloodGroup,IsWebUser=@IsWebUser,IsMobileUser=@IsMobileUser,
						IsActive=@IsActive,FileOriginalName=@FileOriginalName,ImageUpload=@ImageUpload
						,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE EmployeeId=@EmployeeId

			UPDATE AD
			SET Address=@Address,StateId=@StateId,RegionId=@RegionId,DistrictId=@DistrictId,AreaId=@AreaId,Pincode=@Pincode
				,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			 FROM EmployeeAddressMapping EAM
			INNER JOIN AddressMaster AD ON AD.AddressId=EAM.AddressId
			WHERE EAM.EmployeeId=@EmployeeId

			
			SET @Result = @EmployeeId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result
END

GO

If OBJECT_ID('ReferenceAddressMapping') Is Not Null
Begin
	Drop Table ReferenceAddressMapping
End

GO

If OBJECT_ID('ReferenceMaster') Is Not Null
Begin
	Drop Table ReferenceMaster
End

GO

If OBJECT_ID('ReferenceMaster') Is Null
Begin

	CREATE TABLE ReferenceMaster
	(
	ReferenceId BIGINT IDENTITY(1,1) PRIMARY KEY,
	UniqueNumber VARCHAR(100),
	PartyName VARCHAR(100),
	PhoneNumber VARCHAR(15),
	MobileNumber VARCHAR(15),
	GSTNumber VARCHAR(15),
	PanNumber VARCHAR(10),
	EmailId VARCHAR(100),
	IsActive BIT NOT NULL,
	CreatedBy BIGINT NOT NULL,
	CreatedOn DATETIME NOT NULL,
	ModifiedBy BIGINT,
	ModifiedOn DATETIME
	)
END

GO
If OBJECT_ID('ReferenceAddressMapping') Is Null
Begin
	CREATE TABLE ReferenceAddressMapping
	(
	ReferenceAddressId BIGINT IDENTITY(1,1) PRIMARY KEY,
	ReferenceId BIGINT FOREIGN KEY REFERENCES ReferenceMaster(ReferenceId), 
	AddressId  BIGINT FOREIGN KEY REFERENCES AddressMaster(AddressId)
	)
END

GO

Drop Procedure If Exists GetReferences;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetReferences]
Description : Get Reference Detail from ReferenceMaster
*/
CREATE Or Alter Procedure[dbo].[GetReferences]
AS
BEGIN
	SELECT RM.ReferenceId,RM.UniqueNumber,RM.PartyName,
		   AD.Address,AD.StateId,AD.RegionId,AD.DistrictId,AD.AreaId,AD.Pincode,RM.PhoneNumber,RM.MobileNumber,
		   RM.GSTNumber,RM.PanNumber,RM.EmailId,RM.IsActive
	FROM ReferenceMaster RM WITH(NOLOCK)
	INNER JOIN ReferenceAddressMapping RAM WITH(NOLOCK) ON RAM.ReferenceId = RM.ReferenceId
	INNER JOIN AddressMaster AD WITH(NOLOCK) ON Ad.AddressId=RAM.AddressId

END

GO
Drop Procedure If Exists SaveReferenceDetails;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[SaveEmployeeDetails] 
Description : Insert Employee Detail from EmployeeMaster
*/
CREATE Or Alter Procedure[dbo].[SaveReferenceDetails]
(
	@ReferenceId BIGINT,
	@UniqueNumber VARCHAR(100),
	@PartyName VARCHAR(100),
	@Address VARCHAR(500),
	@StateId BIGINT,
	@RegionId BIGINT,
	@DistrictId BIGINT,
	@AreaId BIGINT,
	@Pincode VARCHAR(15),
	@PhoneNumber VARCHAR(20),
	@MobileNumber VARCHAR(20),
	@GSTNumber VARCHAR(15),
	@PanNumber VARCHAR(10),
	@EmailId VARCHAR(100),
	@IsActive BIT,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;

	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	If (
		(@ReferenceId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM ReferenceMaster WITH(NOLOCK) 
				WHERE  UniqueNumber=@UniqueNumber and PartyName=@PartyName
			)
		)
		OR
		(@ReferenceId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM ReferenceMaster WITH(NOLOCK) 
				WHERE  UniqueNumber=@UniqueNumber and PartyName=@PartyName and ReferenceId<>@ReferenceId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@ReferenceId=0)
		BEGIN
			DECLARE @UniqueNo BIGINT=0;
			SELECT @UniqueNo= COUNT(0) FROM ReferenceMaster

			Insert into ReferenceMaster(UniqueNumber,PartyName,PhoneNumber,MobileNumber,GSTNumber,PanNumber,EmailId,IsActive,CreatedBy,CreatedOn)
			Values(CONCAT('Ref00', @UniqueNo+1),@PartyName,@PhoneNumber,@MobileNumber,@GSTNumber,@PanNumber,@EmailId ,@IsActive,@LoggedInUserId,GETDATE())

			SET @Result = SCOPE_IDENTITY();
			
			-- Insert Into Address 
			INSERT INTO AddressMaster(Address,StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn)
			Values (@Address,@StateId,@RegionId,@DistrictId,@AreaId,@Pincode,1,@IsActive,@LoggedInUserId,GETDATE())

			SET @AddressId = SCOPE_IDENTITY();

			INSERT INTO ReferenceAddressMapping(ReferenceId,AddressId)
			Values (@Result,@AddressId)
		
		END
		ELSE IF(@ReferenceId> 0 and EXISTS(SELECT TOP 1 1 FROM ReferenceMaster WHERE ReferenceId=@ReferenceId))
		BEGIN
			UPDATE ReferenceMaster
			SET PartyName=@PartyName,PhoneNumber=@PhoneNumber,MobileNumber=@MobileNumber,
				GSTNumber=@GSTNumber,PanNumber=@PanNumber,EmailId=@EmailId,	IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE ReferenceId=@ReferenceId

			UPDATE AD
			SET Address=@Address,StateId=@StateId,RegionId=@RegionId,DistrictId=@DistrictId,AreaId=@AreaId,Pincode=@Pincode
				,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			 FROM ReferenceAddressMapping RAM
			INNER JOIN AddressMaster AD ON AD.AddressId=RAM.AddressId
			WHERE RAM.ReferenceId=@ReferenceId

			SET @Result = @ReferenceId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result
END