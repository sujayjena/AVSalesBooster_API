/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetCategories]
Description : Get Category from CategoryMaster
EXEC [dbo].[GetCategories]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@CategoryName='',
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetCategories]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@CategoryName VARCHAR(100)=null,
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
	SET @CategoryName = ISNULL(@CategoryName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by CategoryId DESC ';
		END

	SET @STR = N'SELECT
					C.CategoryId,C.CategoryName,C.IsActive,
					CreatorEM.EmployeeName As CreatorName,
					C.CreatedBy,
					C.CreatedOn
				FROM CategoryMaster C WITH(NOLOCK)
				Inner Join Users U With(NoLock)
					On U.UserId = C.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId And U.EmployeeId Is Not Null
				WHERE (@CategoryName='''' OR C.CategoryName like ''%''+@CategoryName+''%'')
					and (@IsActive IS NULL OR C.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	--PRINT @STR;

	exec sp_executesql @STR,
						N'@CategoryName VARCHAR(100),@IsActive BIT',
						@CategoryName,@IsActive
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetSeriess]
Description : Get Series from SeriesMaster
EXEC [dbo].[GetSeriess]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@SeriesName='',
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetSeriess]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@SeriesName VARCHAR(100)=null,
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
	SET @SeriesName = ISNULL(@SeriesName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by SeriesId DESC ';
		END

	SET @STR = N'SELECT
					SM.SeriesId, SM.SeriesName, SM.IsActive,
					CreatorEM.EmployeeName As CreatorName,
					SM.CreatedBy,
					SM.CreatedOn
				FROM SeriesMaster SM WITH(NOLOCK)
				Inner Join Users U With(NoLock)
					On U.UserId = SM.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId And U.EmployeeId Is Not Null
				WHERE (@SeriesName='''' OR SM.SeriesName like ''%''+@SeriesName+''%'')
					and (@IsActive IS NULL OR SM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	--PRINT @STR;

	exec sp_executesql @STR,
						N'@SeriesName VARCHAR(100),@IsActive BIT',
						@SeriesName,@IsActive
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetSizes]
Description : Get Size from SizeMaster
EXEC [dbo].[GetSizes]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@SizeName='',
	@IsActive=NULL
*/
ALTER PROCEDURE [dbo].[GetSizes]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@SizeName VARCHAR(100)=null,
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
	SET @SizeName = ISNULL(@SizeName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by SizeId DESC ';
		END


	SET @STR = N'SELECT
					SM.SizeId,SM.SizeName,SM.IsActive,
					CreatorEM.EmployeeName As CreatorName,
					SM.CreatedBy,
					SM.CreatedOn
				FROM SizeMaster SM WITH(NOLOCK)
				Inner Join Users U With(NoLock)
					On U.UserId = SM.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId And U.EmployeeId Is Not Null
				WHERE (@SizeName='''' OR SM.SizeName like ''%''+@SizeName+''%'')
				and (@IsActive IS NULL OR SM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	-- PRINT @STR;

	exec sp_executesql @STR,
						N'@SizeName VARCHAR(100),@IsActive BIT',
						@SizeName,@IsActive
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetBaseDesigns]
Description : Get BaseDesign from BaseDesignMaster
EXEC [dbo].[GetBaseDesigns]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@BaseDesignName='',
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetBaseDesigns]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@BaseDesignName VARCHAR(100)=null,
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
	SET @BaseDesignName = ISNULL(@BaseDesignName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by BaseDesignId DESC ';
		END


	SET @STR = N'SELECT
					BDM.BaseDesignId, BDM.BaseDesignName, BDM.IsActive,
					CreatorEM.EmployeeName As CreatorName,
					BDM.CreatedBy,
					BDM.CreatedOn
				FROM BaseDesignMaster BDM WITH(NOLOCK)
				Inner Join Users U With(NoLock)
					On U.UserId = BDM.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId And U.EmployeeId Is Not Null
				WHERE (@BaseDesignName='''' OR BDM.BaseDesignName like ''%''+@BaseDesignName+''%'')
					and (@IsActive IS NULL OR BDM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	--PRINT @STR;

	exec sp_executesql @STR,
						N'@BaseDesignName VARCHAR(100),@IsActive BIT',
						@BaseDesignName,@IsActive
END

GO

If Object_Id('BloodGroupMaster') Is Null
Begin
	Create Table BloodGroupMaster
	(
		BloodGroupId	Int Primary Key Identity(1,1),
		BloodGroup		VarChar(10) Not Null,
		IsActive		Bit Not Null,
		CreatedBy		BigInt Not Null,
		CreatedOn		DateTime Not Null,
		ModifiedBy		BigInt,
		ModifiedOn		DateTime
	)
End

GO

/*
	SaveBloodGroupDetails 1,'B+',1,1
*/
Create Or Alter Procedure SaveBloodGroupDetails
	@BloodGroupId	Int,
	@BloodGroup		VarChar(10),
	@IsActive		Bit,
	@LoggedInUserId	BigInt
As
Begin
	Set NoCount On;

	DECLARE @Result Int = 0;
	DECLARE @IsNameExists Int = -2;
	DECLARE @NoRecordExists Int = -1;

	If (
		(@BloodGroupId = 0 And Exists(Select Top 1 1 From BloodGroupMaster With(NoLock) Where BloodGroup = @BloodGroup))
		Or
		(@BloodGroupId > 0 And Exists(Select Top 1 1 From BloodGroupMaster With(NoLock) Where BloodGroup = @BloodGroup And BloodGroupId <> @BloodGroupId))
	)
	Begin
		Set @Result = @IsNameExists;
	End
	Else If @BloodGroupId > 0 And Not Exists(Select Top 1 1 From BloodGroupMaster With(NoLock) Where BloodGroupId = @BloodGroupId)
	Begin
		Set @Result = @NoRecordExists;
	End
	Else If @BloodGroupId = 0
	Begin
		Insert Into BloodGroupMaster
		(
			BloodGroup, IsActive, CreatedBy, CreatedOn	
		)
		Values
		(
			@BloodGroup, @IsActive, @LoggedInUserId, GetDate()
		)

		SET @Result = SCOPE_IDENTITY();
	End
	Else If @BloodGroupId > 0
	Begin
		Update BloodGroupMaster
		Set BloodGroup = @BloodGroup,
			IsActive = @IsActive,
			ModifiedBy = @LoggedInUserId,
			ModifiedOn = GetDate()
		Where BloodGroupId = @BloodGroupId

		Set @Result = @BloodGroupId;
	End

	Select @Result As Result;
End

GO

-- GetBloodGroupDetailsById 1
Create Or Alter Procedure GetBloodGroupDetailsById
	@BloodGroupId	Int
As
Begin
	Set NoCount On;

	Select
		BloodGroupId,
		BloodGroup,
		IsActive
	From BloodGroupMaster With(NoLock)
	Where BloodGroupId = @BloodGroupId
End

GO

/*
	GetBloodGroupMasterList
		@PageNo=1, 
		@PageSize=10,
		@SortBy='',
		@OrderBy='',
		@BloodGroup='',@IsActive=null
*/
Create Or Alter Procedure GetBloodGroupMasterList
	@PageSize		INT,
    @PageNo			INT,
    @SortBy			VARCHAR(50) = '',
    @OrderBy		VARCHAR(4) = '',
	@BloodGroup		VARCHAR(10) = '',
	@IsActive		BIT = null
As
Begin
	Set NoCount On;

	DECLARE @stringQuery	NVARCHAR(MAX);
	DECLARE @Offset		INT, 
			@RowCount	INT;

	DECLARE @OrderByQuery VARCHAR(1000) = '';
	DECLARE @PaginationQuery VARCHAR(100) = '';

	If @PageNo > 0 And @PageSize > 0
	Begin
		SET @Offset = (@PageNo - 1) * @PageSize;
		SET @RowCount = @PageSize * @PageNo;
		SET @PaginationQuery='OFFSET '+CAST(@Offset as VARCHAR(5))+'  ROWS
								 FETCH NEXT '+CAST(@RowCount as VARCHAR(5))+' ROWS ONLY';
	End

	If @SortBy <> '' And @OrderBy <> ''
	Begin
		Set @OrderByQuery=' Order By '+@SortBy+' '+@OrderBy+' ';
	End
	Else 
	Begin
		Set @OrderByQuery=' Order By BloodGroupId DESC ';
	End

	SET @stringQuery = N'Select
					BGM.BloodGroupId,
					BGM.BloodGroup,
					BGM.IsActive,
					CreatorEM.EmployeeName As CreatorName,
					BGM.CreatedBy,
					BGM.CreatedOn
				From BloodGroupMaster BGM With(NoLock)
				Inner Join Users U With(NoLock)
					On U.UserId = BGM.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId
						And U.EmployeeId Is Not Null
				WHERE (@BloodGroup='''' OR BGM.BloodGroup Like ''%''+@BloodGroup+''%'')
					And (@IsActive IS NULL OR BGM.IsActive = @IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	Exec sp_executesql @stringQuery,
			N'@BloodGroup VARCHAR(10), @IsActive BIT',
			@BloodGroup, @IsActive
End

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
	@BloodGroup VARCHAR(10),
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
					@DateOfBirth,@DateOfJoining,@EmergencyContactNumber,@BloodGroup,@IsWebUser,@IsMobileUser,@IsActive,@FileOriginalName,
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
