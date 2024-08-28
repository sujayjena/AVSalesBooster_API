Update EmployeeMaster Set BloodGroup=NULL;

GO

Update EmployeeMaster Set BloodGroup=1;

GO

Alter Table EmployeeMaster
Alter Column BloodGroup Int NULL;

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[SaveEmployeeDetails] 
Description : Insert Employee Detail from EmployeeMaster
*/
ALTER PROCEDURE [dbo].[SaveEmployeeDetails]
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
	@LoggedInUserId BIGINT,
	@Password VARCHAR(250)
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
					@DateOfBirth,@DateOfJoining,@EmergencyContactNumber,@BloodGroupId,@IsWebUser,@IsMobileUser,@IsActive,@FileOriginalName,
					@ImageUpload,@LoggedInUserId,GETDATE())

			SET @Result = SCOPE_IDENTITY();
			
			-- Insert Into Address 
			INSERT INTO AddressMaster(Address,StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn)
			Values (@Address,@StateId,@RegionId,@DistrictId,@AreaId,@Pincode,1,@IsActive,@LoggedInUserId,GETDATE())

			SET @AddressId = SCOPE_IDENTITY();

			INSERT INTO EmployeeAddressMapping(EmployeeId,AddressId)
			Values (@Result,@AddressId)

			INSERT INTO Users(EmailId,MobileNo,Passwords,EmployeeId,IsActive,TermsConditionsAccepted,CreatedBy,CreatedOn)
			SELECT @EmailId,@MobileNumber,@Password,@Result,@IsActive,1,@LoggedInUserId,GETDATE()
		
		END
		ELSE IF(@EmployeeId> 0 and EXISTS(SELECT TOP 1 1 FROM EmployeeMaster WHERE EmployeeId=@EmployeeId))
		BEGIN
			UPDATE EmployeeMaster
			SET EmployeeName=@EmployeeName,EmployeeCode=@EmployeeCode,EmailId=@EmailId,MobileNumber=@MobileNumber,RoleId=@RoleId,
						ReportingTo=@ReportingTo,DateOfBirth=@DateOfBirth,DateOfJoining=@DateOfJoining,
						EmergencyContactNumber=@EmergencyContactNumber,BloodGroup=@BloodGroupId,IsWebUser=@IsWebUser,IsMobileUser=@IsMobileUser,
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

-- GetEmployeeDetailsById 1
ALTER PROCEDURE [dbo].[GetEmployeeDetailsById]
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		EM.EmployeeId, EM.EmployeeName, EM.EmployeeCode, EM.EmailId, EM.MobileNumber, EM.RoleId, RM.RoleName,
		EM.ReportingTo, Manager.EmployeeName as ReportingToName, Manager.MobileNumber AS ManagerMobileNo,
		AM.AddressId,
		AM.[Address],AM.StateId,SM.StateName,AM.RegionId,RGM.RegionName,AM.DistrictId,DM.DistrictName,AM.AreaId,ARM.AreaName,AM.Pincode,
		EM.DateOfBirth,EM.DateOfJoining,
		EM.EmergencyContactNumber,
		BGM.BloodGroupId,
		BGM.BloodGroup,
		EM.IsWebUser,Em.IsMobileUser,EM.IsActive,EM.FileOriginalName,EM.ImageUpload
	FROM EmployeeMaster EM WITH(NOLOCK)
	LEFT JOIN EmployeeMaster Manager WITH(NOLOCK)
		ON Manager.EmployeeId = EM.ReportingTo
	LEFT JOIN EmployeeAddressMapping EAM WITH(NOLOCK)
		ON EAM.EmployeeId=EM.EmployeeId
	LEFT JOIN AddressMaster AM WITH(NOLOCK)
		ON AM.AddressId=EAM.AddressId
			AND AM.IsDefault = 1
	LEFT JOIN RoleMaster RM WITH(NOLOCK)
		ON RM.RoleId=EM.RoleId
	LEFT JOIN RoleMaster RM1 WITH(NOLOCK)
		ON RM1.RoleId=EM.ReportingTo
	LEFT JOIN StateMaster SM WITH(NOLOCK)
		ON SM.StateId=AM.StateId
	LEFT JOIN RegionMaster RGM WITH(NOLOCK)
		ON RGM.RegionId=AM.RegionId
	LEFT JOIN DistrictMaster DM WITH(NOLOCK)
		ON DM.DistrictId=AM.DistrictId
	LEFT JOIN AreaMaster ARM WITH(NOLOCK)
		ON ARM.AreaId=AM.AreaId
	Left Join BloodGroupMaster BGM With(NoLock)
		On BGM.BloodGroupId = EM.BloodGroup
	WHERE EM.EmployeeId = @Id
END

GO

/*
	Version : 1.0
	Created Date : 03 JULY 2023
	Execution : EXEC [dbo].[GetEmployees]
	Description : Get ReportingTo from ReportingToMaster
	EXEC [dbo].[GetEmployees]  
		@PageSize=10,
	    @PageNo=1,
	    @SortBy='',
	    @OrderBy='',
		@EmployeeName='',
		@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetEmployees]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@EmployeeName VARCHAR(100)=null,
	@IsActive BIT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @STR NVARCHAR(MAX)

	DECLARE @Offset INT, @RowCount INT;
	DECLARE @OrderSortByConcate VARCHAR(100);
	DECLARE @OrderByQuery VARCHAR(1000)='';
	DECLARE @PaginationQuery VARCHAR(100)='';

	if @PageSize>0
	BEGIN
		SET @Offset = (@PageNo - 1) * @PageSize;
		SET @RowCount = @PageSize * @PageNo;
		SET @PaginationQuery='OFFSET '+CAST(@Offset as VARCHAR(5))+'  ROWS
								 FETCH NEXT '+CAST(@RowCount as VARCHAR(5))+' ROWS ONLY';
	END
	
	SET @OrderSortByConcate= @SortBy + ' ' + @OrderBy;
	SET @EmployeeName = ISNULL(@EmployeeName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by EmployeeId DESC ';
		END

		
	SET @STR = N'SELECT
					EM.EmployeeId,EM.EmployeeName,EM.EmployeeCode,EM.EmailId,EM.MobileNumber,EM.RoleId,RM.RoleName,
					EM.ReportingTo,RM1.RoleName as ReportingToName,AM.Address,AM.StateId,SM.StateName,AM.RegionId,
					RGM.RegionName,AM.DistrictId,DM.DistrictName,AM.AreaId,ARM.AreaName,AM.Pincode,EM.DateOfBirth,EM.DateOfJoining,
					EM.EmergencyContactNumber,
					BGM.BloodGroupId,BGM.BloodGroup,
					EM.IsWebUser,Em.IsMobileUser,EM.IsActive,
					CreatorEM.EmployeeName As CreatorName,
					EM.CreatedBy,
					EM.CreatedOn,
					EM.FileOriginalName,EM.ImageUpload
				FROM EmployeeMaster EM WITH(NOLOCK)
				INNER JOIN EmployeeAddressMapping EAM WITH(NOLOCK) ON EAM.EmployeeId=EM.EmployeeId
				INNER JOIN AddressMaster AM WITH(NOLOCK) ON AM.AddressId=EAM.AddressId
				INNER JOIN RoleMaster RM WITH(NOLOCK) ON RM.RoleId=EM.RoleId
				INNER JOIN StateMaster SM WITH(NOLOCK) ON SM.StateId=AM.StateId
				INNER JOIN RegionMaster RGM WITH(NOLOCK) ON RGM.RegionId=AM.RegionId
				INNER JOIN DistrictMaster DM WITH(NOLOCK) ON DM.DistrictId=AM.DistrictId
				INNER JOIN AreaMaster ARM WITH(NOLOCK) ON ARM.AreaId=AM.AreaId
				Inner Join Users U With(NoLock)
					On U.UserId = EM.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId
						And U.EmployeeId Is Not Null
				Left JOIN RoleMaster RM1 WITH(NOLOCK)
					ON RM1.RoleId = EM.ReportingTo
				Left Join BloodGroupMaster BGM With(NoLock)
					On BGM.BloodGroupId = EM.BloodGroup
				WHERE (@EmployeeName='''' OR EM.EmployeeName like ''%''+@EmployeeName+''%'')
					AND (@IsActive IS NULL OR EM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	------PRINT @STR;

	exec sp_executesql @STR,
						N'@EmployeeName VARCHAR(100),@IsActive BIT',
						@EmployeeName,@IsActive
END

GO
