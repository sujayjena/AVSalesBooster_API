If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='EmployeeMaster' And Column_Name='MobileUniqueId')
Begin
	Alter Table EmployeeMaster
	Add MobileUniqueId VarChar(200) Null
End

GO

/*
	Version : 1.0
	Created Date : 03 JULY 2023
	Execution : EXEC [dbo].[SaveEmployeeDetails] 
	Description : Insert Employee Detail from EmployeeMaster
*/
Alter Procedure SaveEmployeeDetails
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
	@BloodGroupId Int,
	@IsWebUser BIT,
	@IsMobileUser BIT,
	@IsActive BIT,
	@FileOriginalName VARCHAR(2000),
	@ImageUpload VARCHAR(2000),
	@AdharCardFileName VarChar(200),
	@AdharCardSavedFileName VarChar(200),
	@PanCardFileName VarChar(200),
	@PanCardSavedFileName VarChar(200),
	@LoggedInUserId BIGINT,
	@Password VARCHAR(250),
	@MobileUniqueId VarChar(200)
)
AS
BEGIN
	Set NoCount On;

	Declare @Result BIGINT=0;
	Declare @AddressId BIGINT=0;
	Declare @IsEmpCodeExists BIGINT=-5;
	Declare @IsNameExists BIGINT=-2;
	Declare @NoRecordExists BIGINT=-1;

	If (
		(@EmployeeId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM EmployeeMaster WITH(NOLOCK) 
				WHERE EmployeeName=@EmployeeName
			)
		)
		OR
		(@EmployeeId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM EmployeeMaster WITH(NOLOCK) 
				WHERE EmployeeName=@EmployeeName and EmployeeId<>@EmployeeId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	Else If (
		@EmployeeId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM EmployeeMaster WITH(NOLOCK) 
				WHERE EmployeeCode=@EmployeeCode
			)
		)
	BEGIN
		SET @Result = @IsEmpCodeExists;
	END
	ELSE
	BEGIN
		IF @EmployeeId=0
		BEGIN
			Insert Into EmployeeMaster
			(
				EmployeeName,EmployeeCode,EmailId,MobileNumber,RoleId,ReportingTo,DateOfBirth,DateOfJoining,EmergencyContactNumber,BloodGroup,
				IsWebUser,IsMobileUser,IsActive,FileOriginalName,ImageUpload,
				AdharCardFileName,AdharCardSavedFileName,PanCardFileName,PanCardSavedFileName,MobileUniqueId,
				CreatedBy,CreatedOn
			)
			Values
			(
				@EmployeeName,@EmployeeCode,@EmailId ,@MobileNumber,@RoleId,@ReportingTo,@DateOfBirth,@DateOfJoining,@EmergencyContactNumber,@BloodGroupId,
				@IsWebUser,@IsMobileUser,@IsActive,@FileOriginalName,@ImageUpload,
				@AdharCardFileName,@AdharCardSavedFileName,@PanCardFileName,@PanCardSavedFileName,@MobileUniqueId,
				@LoggedInUserId,GETDATE()
			)

			SET @Result = SCOPE_IDENTITY();
			
			-- Insert Into Address 
			Insert Into AddressMaster
			(
				[Address],StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn
			)
			Values
			(
				@Address,@StateId,@RegionId,@DistrictId,@AreaId,@Pincode,1,@IsActive,@LoggedInUserId,GETDATE()
			)

			SET @AddressId = SCOPE_IDENTITY();

			INSERT INTO EmployeeAddressMapping
			(
				EmployeeId,AddressId
			)
			Values
			(
				@Result,@AddressId
			)

			Insert Into Users
			(
				EmailId,MobileNo,Passwords,EmployeeId,IsActive,CreatedBy,CreatedOn
			)
			Select @EmailId,@MobileNumber,@Password,@Result,@IsActive,@LoggedInUserId,GETDATE()
		END
		ELSE IF @EmployeeId> 0 and EXISTS(SELECT TOP 1 1 FROM EmployeeMaster WHERE EmployeeId=@EmployeeId)
		BEGIN
			UPDATE EmployeeMaster
			SET EmployeeName=@EmployeeName,
				--EmployeeCode=@EmployeeCode,
				EmailId=@EmailId,
				MobileNumber=@MobileNumber,
				RoleId=@RoleId,
				ReportingTo=@ReportingTo,
				DateOfBirth=@DateOfBirth,
				DateOfJoining=@DateOfJoining,
				EmergencyContactNumber=@EmergencyContactNumber,
				BloodGroup=@BloodGroupId,
				IsWebUser=@IsWebUser,
				IsMobileUser=@IsMobileUser,
				IsActive=@IsActive,
				FileOriginalName=@FileOriginalName,
				ImageUpload=@ImageUpload,
				AdharCardFileName=@AdharCardFileName,
				AdharCardSavedFileName=@AdharCardSavedFileName,
				PanCardFileName=@PanCardFileName,
				PanCardSavedFileName=@PanCardSavedFileName,
				ModifiedBy=@LoggedInUserId, 
				ModifiedOn=GETDATE()
			WHERE EmployeeId = @EmployeeId

			Update AD
			Set [Address]=@Address,
				StateId=@StateId,
				RegionId=@RegionId,
				DistrictId=@DistrictId,
				AreaId=@AreaId,
				Pincode=@Pincode,
				ModifiedBy=@LoggedInUserId,
				ModifiedOn=GETDATE()
			From EmployeeAddressMapping EAM
			Inner Join AddressMaster AD
				On AD.AddressId=EAM.AddressId
			Where EAM.EmployeeId = @EmployeeId
			
			Update Users
			Set EmailId=@EmailId,
				MobileNo=@MobileNumber,
				ModifiedBy=@LoggedInUserId,
				ModifiedOn=GETDATE()
			Where EmployeeId = @EmployeeId

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

-- ValidateUserLoginByUsername @Username = '1231230000', @Password='dGtrBwz8aZUv441//2EISA==', @MobileUniqueId=''
-- ValidateUserLoginByUsername @Username = '1231230000', @Password='dGtrBwz8aZUv441//2EISA==', @MobileUniqueId='mmlKQejiwew243bkda'
Alter Procedure ValidateUserLoginByUsername
	@Username VarChar(100),
	@Password VarChar(200),
	@MobileUniqueId VarChar(200) = ''
As
Begin
	SET NOCOUNT ON;
	Declare @IsValidUniqueId Bit = 0;

	If @MobileUniqueId = '' Or
		Exists (
			Select Top 1 1 From EmployeeMaster With(NoLock)
			Where (EmailId = @Username Or MobileNumber = @Username) And MobileUniqueId = @MobileUniqueId
		)
	Begin
		Set @IsValidUniqueId = 1
	End

	Select
		U.UserId,
		U.EmailId,
		U.MobileNo,
		U.EmployeeId,
		--U.CustomerId,
		U.IsActive,
		EM.EmployeeName,
		EM.EmployeeCode,
		EM.RoleId,
		RM.RoleName
		--,CD.CompanyName,
		--CD.CustomerTypeId,
		--CTM.CustomerTypeName
	From Users U With(NoLock)
	Left Join EmployeeMaster EM With(NoLock)
		On EM.EmployeeId = U.EmployeeId
	Left Join RoleMaster RM With(NoLock)
		On RM.RoleId = EM.RoleId
	--Left Join CustomerDetails CD With(NoLock)
	--	On CD.CustomerId = U.CustomerId
	--Left Join CustomerTypeMaster CTM With(NoLock)
		--On CTM.CustomerTypeId = CD.CustomerTypeId
	Where (U.EmailId = @Username Or U.MobileNo = @Username)
		And U.Passwords = @Password COLLATE Latin1_General_BIN
		And @IsValidUniqueId = 1
End

GO
