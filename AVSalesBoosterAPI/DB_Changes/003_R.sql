If OBJECT_ID('DesignMaster') Is Null
Begin
	CREATE TABLE DesignMaster
	(
		DesignId BIGINT IDENTITY(1,1) PRIMARY KEY,
		ProductId BIGINT FOREIGN KEY REFERENCES ProductMaster(ProductId),
		BrandId BIGINT FOREIGN KEY REFERENCES BrandMaster(BrandId),
		SizeId BIGINT FOREIGN KEY REFERENCES SizeMaster(SizeId),
		CategoryId BIGINT FOREIGN KEY REFERENCES CategoryMaster(CategoryId),
		SeriesId BIGINT FOREIGN KEY REFERENCES SeriesMaster(SeriesId),
		DesignTypeId BIGINT FOREIGN KEY REFERENCES DesignTypeMaster(DesignTypeId),
		BaseDesignId BIGINT FOREIGN KEY REFERENCES SeriesMaster(SeriesId),
		DesignName VARCHAR(100) NOT NULL,
		DesignCode VARCHAR(100) NOT NULL,
		IsActive BIT NOT NULL,
		CreatedBy BIGINT NOT NULL,
		CreatedOn DATETIME NOT NULL,
		ModifiedBy BIGINT,
		ModifiedOn DATETIME
	)
END
GO

Drop Procedure If Exists GetDesignes;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetDesignes]
Description : Get Design list from DesignMaster
*/
CREATE Or Alter Procedure[dbo].[GetDesignes]
AS
BEGIN
	SELECT DesignId,ProductId,BrandId,SizeId,CategoryId,SeriesId,DesignTypeId
			BaseDesignId,DesignName,DesignCode,IsActive
	FROM DesignMaster WITH(NOLOCK)
END

GO

Drop Procedure If Exists SaveDesignDetails;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[SaveDesignDetails] 
Description : Insert Design from DesignMaster
*/
CREATE Or Alter Procedure[dbo].[SaveDesignDetails]
(
	@DesignId BIGINT,
	@ProductId BIGINT,
	@BrandId BIGINT,
	@SizeId BIGINT,
	@CategoryId BIGINT,
	@SeriesId BIGINT,
	@DesignTypeId BIGINT,
	@BaseDesignId BIGINT,
	@DesignName VARCHAR(100),
	@DesignCode VARCHAR(100),
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
		(@DesignId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM DesignMaster WITH(NOLOCK) 
				WHERE  DesignName=@DesignName
			)
		)
		OR
		(@BrandId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM DesignMaster WITH(NOLOCK) 
				WHERE  DesignName=@DesignName and DesignId<>@DesignId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@DesignId=0)
		BEGIN
			Insert into DesignMaster(ProductId,BrandId,SizeId,CategoryId,SeriesId,DesignTypeId,BaseDesignId,DesignName ,DesignCode, IsActive,CreatedBy,CreatedOn)
			Values(@ProductId,@BrandId,@SizeId,@CategoryId,@SeriesId,@DesignTypeId,@BaseDesignId,@DesignName ,@DesignCode, @IsActive,@LoggedInUserId,GETDATE())
			SET @Result = SCOPE_IDENTITY();
		END
		ELSE IF(@BrandId> 0 and EXISTS(SELECT TOP 1 1 FROM BrandMaster WHERE BrandId=@BrandId))
		BEGIN
			UPDATE DesignMaster
			SET ProductId=@ProductId,BrandId=@BrandId,SizeId=@SizeId,CategoryId=@CategoryId,SeriesId=@SeriesId,DesignTypeId=@DesignTypeId,
				BaseDesignId=@BaseDesignId,DesignName=@DesignName ,DesignCode=@DesignCode,IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE DesignId=@DesignId
			SET @Result = @DesignId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result 
END
GO



Drop Procedure If Exists GetRoles;

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetRoles]
Description : Get Role from RoleMaster
*/
CREATE Or Alter Procedure[dbo].[GetRoles]
AS
BEGIN
	SELECT RoleId,RoleName,IsActive
	FROM RoleMaster WITH(NOLOCK)
END

GO
Drop Procedure If Exists SaveRoleDetails;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[SaveRoleDetails] '0','Role 1',1
Description : Insert Role from RoleMaster
*/
CREATE Or Alter Procedure[dbo].[SaveRoleDetails]
(
	@RoleId BIGINT,
	@RoleName VARCHAR(100),
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
		(@RoleId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM RoleMaster WITH(NOLOCK) 
				WHERE  RoleName=@RoleName
			)
		)
		OR
		(@RoleId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM RoleMaster WITH(NOLOCK) 
				WHERE  RoleName=@RoleName and RoleId<>@RoleId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@RoleId=0)
		BEGIN
			Insert into RoleMaster(RoleName, IsActive,CreatedBy,CreatedOn)
			Values(@RoleName, @IsActive,@LoggedInUserId,GETDATE())
			SET @Result = SCOPE_IDENTITY();
		END
		ELSE IF(@RoleId> 0 and EXISTS(SELECT TOP 1 1 FROM RoleMaster WHERE RoleId=@RoleId))
		BEGIN
			UPDATE RoleMaster
			SET RoleName=@RoleName,IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE RoleId=@RoleId
			SET @Result = @RoleId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result
END


GO

Drop Procedure If Exists GetReportingTos;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetReportingTos]
Description : Get ReportingTo from ReportingToMaster
*/
CREATE Or Alter Procedure[dbo].[GetReportingTos]
AS
BEGIN
	SELECT Id,RoleId,ReportingTo,IsActive
	FROM ReportingToMaster WITH(NOLOCK)
END

GO
Drop Procedure If Exists SaveReportingToDetails;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[SaveReportingToDetails] '0','ReportingTo 1',1
Description : Insert ReportingTo from ReportingToMaster
*/
CREATE Or Alter Procedure[dbo].[SaveReportingToDetails]
(
	@Id BIGINT,
	@RoleId BIGINT,
	@ReportingTo BIGINT,
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
		(@Id=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM ReportingToMaster WITH(NOLOCK) 
				WHERE  ReportingTo=@ReportingTo
			)
		)
		OR
		(@Id>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM ReportingToMaster WITH(NOLOCK) 
				WHERE ReportingTo=@ReportingTo and Id<>@Id
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@Id=0)
		BEGIN
			Insert into ReportingToMaster(RoleId,ReportingTo, IsActive,CreatedBy,CreatedOn)
			Values(@RoleId,@ReportingTo, @IsActive,@LoggedInUserId,GETDATE())
			SET @Result = SCOPE_IDENTITY();
		END
		ELSE IF(@Id> 0 and EXISTS(SELECT TOP 1 1 FROM ReportingToMaster WHERE Id=@Id))
		BEGIN
			UPDATE ReportingToMaster
			SET RoleId=@RoleId,ReportingTo=@ReportingTo,IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE Id=@Id
			SET @Result = @Id;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result
END

GO

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
If OBJECT_ID('EmployeeAddressMapping') Is Not Null
Begin
	Drop Table EmployeeAddressMapping
End

GO
CREATE TABLE EmployeeAddressMapping
(
EmployeeAddressId BIGINT IDENTITY(1,1) PRIMARY KEY,
EmployeeId BIGINT FOREIGN KEY REFERENCES EmployeeMaster(EmployeeId), 
Address VARCHAR(500),
StateId BIGINT FOREIGN KEY REFERENCES StateMaster(StateId),
RegionId BIGINT FOREIGN KEY REFERENCES RegionMaster(RegionId),
DistrictId BIGINT FOREIGN KEY REFERENCES DistrictMaster(DistrictId),
AreaId BIGINT FOREIGN KEY REFERENCES AreaMaster(AreaId),
Pincode VARCHAR(15)
)

GO

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
		   EAM.Address,EAM.StateId,EAM.RegionId,EAM.DistrictId,EAM.AreaId,EAM.Pincode,EM.DateOfBirth,EM.DateOfJoining,
		   EM.EmergencyContactNumber,EM.BloodGroup,EM.IsWebUser,Em.IsMobileUser,EM.IsActive,EM.FileOriginalName,EM.ImageUpload
	FROM EmployeeMaster EM WITH(NOLOCK)
	INNER JOIN EmployeeAddressMapping EAM WITH(NOLOCK) ON EAM.EmployeeId = EM.EmployeeId
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
			
			INSERT INTO EmployeeAddressMapping(EmployeeId,Address,StateId,RegionId,DistrictId,AreaId,Pincode)
			Values (@Result,@Address,@StateId,@RegionId,@DistrictId,@AreaId,@Pincode)
		
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

			UPDATE EmployeeAddressMapping
			SET  Address=@Address,StateId=@StateId,RegionId=@RegionId,DistrictId=@DistrictId,AreaId=@AreaId,Pincode=@Pincode
			WHERE EmployeeId=@EmployeeId

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

CREATE TABLE ReferenceAddressMapping
(
ReferenceAddressId BIGINT IDENTITY(1,1) PRIMARY KEY,
ReferenceId BIGINT FOREIGN KEY REFERENCES ReferenceMaster(ReferenceId), 
Address VARCHAR(500),
StateId BIGINT FOREIGN KEY REFERENCES StateMaster(StateId),
RegionId BIGINT FOREIGN KEY REFERENCES RegionMaster(RegionId),
DistrictId BIGINT FOREIGN KEY REFERENCES DistrictMaster(DistrictId),
AreaId BIGINT FOREIGN KEY REFERENCES AreaMaster(AreaId),
Pincode VARCHAR(15)
)

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
		   RAM.Address,RAM.StateId,RAM.RegionId,RAM.DistrictId,RAM.AreaId,RAM.Pincode,RM.PhoneNumber,RM.MobileNumber,
		   RM.GSTNumber,RM.PanNumber,RM.EmailId,RM.IsActive
	FROM ReferenceMaster RM WITH(NOLOCK)
	INNER JOIN ReferenceAddressMapping RAM WITH(NOLOCK) ON RAM.ReferenceId = RM.ReferenceId
END

GO

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
			Insert into ReferenceMaster(UniqueNumber,PartyName,PhoneNumber,MobileNumber,GSTNumber,PanNumber,EmailId,IsActive,CreatedBy,CreatedOn)
			Values(@UniqueNumber,@PartyName,@PhoneNumber,@MobileNumber,@GSTNumber,@PanNumber,@EmailId ,@IsActive,@LoggedInUserId,GETDATE())

			SET @Result = SCOPE_IDENTITY();
			
			INSERT INTO ReferenceAddressMapping(ReferenceId,Address,StateId,RegionId,DistrictId,AreaId,Pincode)
			Values (@Result,@Address,@StateId,@RegionId,@DistrictId,@AreaId,@Pincode)
		
		END
		ELSE IF(@ReferenceId> 0 and EXISTS(SELECT TOP 1 1 FROM ReferenceMaster WHERE ReferenceId=@ReferenceId))
		BEGIN
			UPDATE ReferenceMaster
			SET PartyName=@PartyName,PhoneNumber=@PhoneNumber,MobileNumber=@MobileNumber,
				GSTNumber=@GSTNumber,PanNumber=@PanNumber,EmailId=@EmailId,	IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE ReferenceId=@ReferenceId

			UPDATE ReferenceAddressMapping
			SET  Address=@Address,StateId=@StateId,RegionId=@RegionId,DistrictId=@DistrictId,AreaId=@AreaId,Pincode=@Pincode
			WHERE ReferenceId=@ReferenceId

			SET @Result = @ReferenceId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result
END