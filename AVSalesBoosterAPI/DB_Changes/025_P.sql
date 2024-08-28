Update RoleMaster Set RoleName='Superadmin' Where RoleName='Administrator'

GO

If Object_Id('VisitPhotos') Is Null
Begin
	Create Table VisitPhotos
	(
		VisitPhotoId		BigInt Primary Key Identity(1,1),
		VisitId				BigInt Not Null References VisitMaster(VisitId),
		UploadedFileName	VarChar(200) Not Null,
		SavedFileName		VarChar(200) Not Null,
		IsDeleted			Bit Not Null,
		ModifiedBy			BigInt NULL References Users(UserId),
		ModifiedOn			DateTime NULL
	)
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitMaster' And Column_Name='VisitNo')
Begin
	Alter Table VisitMaster
	Add VisitNo VarChar(15)
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitMaster' And Column_Name='VisitNo')
Begin
	Update VisitMaster
	Set VisitNo='VISIT'+Cast(VisitId As varchar(5))
	Where VisitNo Is Null
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitMaster' And Column_Name='VisitNo')
Begin
	Alter Table VisitMaster
	Alter Column VisitNo VarChar(15) Not Null	
End

GO

/*
	Execution : EXEC [dbo].[SaveVisitDetails] 
	Description : Insert Visit Detail from VisitMaster
*/
Alter Procedure SaveVisitDetails
(
	@VisitId BIGINT,
	@EmployeeId BIGINT,
	@VisitDate Datetime,
	@CustomerId BIGINT,
	@CustomerTypeId BIGINT,
	@StateId BIGINT,
	@RegionId BIGINT,
	@DistrictId BIGINT,
	@AreaId BIGINT,
	@Address VARCHAR(500),
	@ContactPerson VARCHAR(100),
	@ContactNumber VARCHAR(20),
	@EmailId VARCHAR(100),
	@NextActionDate Datetime,
	@Latitude DECIMAL(9,6),
	@Longitude DECIMAL(9,6),
	@IsActive BIT,
	@VisitStatusId INT,
	@XmlRemarks XML,
	@XmlVisitFiles XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;
	DECLARE @NewVisitNo As VarChar(15);

	If (
		(@VisitId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM VisitMaster WITH(NOLOCK) 
				WHERE EmployeeId=@EmployeeId and VisitDate=@VisitDate and CustomerId=@CustomerId
			)
		)
		OR
		(@VisitId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM VisitMaster WITH(NOLOCK) 
				WHERE  EmployeeId=@EmployeeId and VisitDate=@VisitDate and CustomerId=@CustomerId and VisitId<>@VisitId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@VisitId=0)
		BEGIN
			Select @NewVisitNo = 'VISIT'+Cast(Max(VisitId)+1 as varchar(10))
			From VisitMaster
			
			Insert into VisitMaster
			(
				VisitNo,EmployeeId,VisitDate,CustomerId,CustomerTypeId,ContactPerson,ContactNumber,EmailId,NextActionDate,
				Latitude,Longitude,IsActive,VisitStatusId,CreatedBy,CreatedOn
			)
			VALUES
			(
				@NewVisitNo,@EmployeeId,@VisitDate,@CustomerId,@CustomerTypeId,@ContactPerson,@ContactNumber,@EmailId,@NextActionDate,
				@Latitude,@Longitude,@IsActive,@VisitStatusId,@LoggedInUserId,GETDATE()
			)

			SET @Result = SCOPE_IDENTITY();
			
			-- Insert Into Address 
			INSERT INTO AddressMaster
			(
				Address,StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn
			)
			Values
			(
				@Address,@StateId,@RegionId,@DistrictId,@AreaId,0,0,@IsActive,@LoggedInUserId,GETDATE()
			)

			SET @AddressId = SCOPE_IDENTITY();

			INSERT INTO VisitAddressMapping
			(
				VisitId,AddressId
			)
			Values
			(
				@Result, @AddressId
			)
		END
		ELSE IF(@VisitId> 0 and EXISTS(SELECT TOP 1 1 FROM VisitMaster WHERE VisitId=@VisitId))
		BEGIN
			Update VisitMaster
			Set EmployeeId=@EmployeeId,
				VisitDate=@VisitDate,
				CustomerId=@CustomerId,
				CustomerTypeId=@CustomerTypeId,
				ContactPerson=@ContactPerson,
				ContactNumber=@ContactNumber,
				EmailId=@EmailId,
				NextActionDate=@NextActionDate,
				Latitude=@Latitude,
				Longitude=@Longitude,
				IsActive=@IsActive,
				VisitStatusId=@VisitStatusId,
				ModifiedBy=@LoggedInUserId,
				ModifiedOn=GETDATE()
			Where VisitId = @VisitId
			
			Update AD
			Set Address=@Address,StateId=@StateId,RegionId=@RegionId,DistrictId=@DistrictId,
				AreaId=@AreaId,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			From VisitAddressMapping vam
			Inner Join AddressMaster AD
				On AD.AddressId=vam.AddressId
			Where vam.VisitId = @VisitId
			
			Set @Result = @VisitId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END

		-- Start: To add update visit remarks and visit photos
		If @Result > 0 -- @Result is Visit ID here
		Begin
			Declare @TempVisitRemarks Table
			(
				VisitId BIGINT,
				VisitRemarkId BIGINT NOT NULL,
				Remarks VARCHAR(2000) NOT NULL
			);

			Declare @TempVisitPhotos Table
			(
				VisitId BIGINT,
				VisitPhotoId BIGINT,
				UploadedFileName VarChar(200) NOT NULL,
				SavedFileName VarChar(200) NOT NULL
			);
			
			INSERT INTO @TempVisitRemarks
			(
				VisitId, VisitRemarkId, Remarks
			)
			SELECT
				VisitId = @Result,
				VisitRemarkId = T.Item.value('VisitRemarkId[1]', 'BIGINT'),
				Remarks = T.Item.value('Remarks[1]', 'varchar(2000)')
			FROM @XmlRemarks.nodes('/ArrayOfVisitRemarks/VisitRemarks') AS T(Item)

			Insert Into @TempVisitPhotos
			(
				VisitId, VisitPhotoId, UploadedFileName, SavedFileName
			)
			Select
				VisitId = @Result,
				VisitPhotoId = T.Item.value('VisitPhotoId[1]', 'BigInt'),
				UploadedFileName = T.Item.value('UploadedFileName[1]', 'varchar(200)'),
				SavedFileName = T.Item.value('SavedFileName[1]', 'varchar(200)')
			From @XmlVisitFiles.nodes('/ArrayOfVisitPhotosRequest/VisitPhotosRequest') AS T(Item)

			-- To Insert new records with VisitRemarkId = 0
			Insert Into VisitRemarks
			(
				VisitId, Remarks, IsDeleted, CreatedOn, CreatedBy
			)
			Select
				@Result, Remarks, 0, GETDATE(), @LoggedInUserId
			From @TempVisitRemarks
			Where VisitRemarkId = 0

			-- To update existing records
			Update vr
			Set vr.Remarks = tvr.Remarks,
				vr.ModifiedOn = GETDATE(),
				vr.ModifiedBy = @LoggedInUserId
			From VisitRemarks vr WITH(NOLOCK)
			Inner Join @TempVisitRemarks tvr
				On tvr.VisitRemarkId = vr.VisitRemarkId
			Where vr.VisitId = @Result AND tvr.VisitRemarkId <> 0

			-- To delete removed remarks
			UPDATE vr
			SET vr.IsDeleted = 1,
				vr.ModifiedOn = GETDATE(),
				vr.ModifiedBy = @LoggedInUserId
			FROM @TempVisitRemarks tvr
			LEFT JOIN VisitRemarks vr WITH(NOLOCK)
				ON tvr.VisitRemarkId = vr.VisitRemarkId
			WHERE vr.VisitId = @Result AND vr.VisitRemarkId IS NULL

			/*--------------- Visit Photos --------------- */
			-- To Insert new records with VisitPhotoId = 0
			Insert Into VisitPhotos
			(
				VisitId, UploadedFileName, SavedFileName, IsDeleted
			)
			Select
				@Result, UploadedFileName, SavedFileName, 0
			From @TempVisitPhotos
			Where VisitPhotoId = 0
			
			-- To update existing records
			Update vp
			Set vp.UploadedFileName = tvp.UploadedFileName,
				vp.SavedFileName = tvp.SavedFileName,
				vp.ModifiedOn = GETDATE(),
				vp.ModifiedBy = @LoggedInUserId
			From VisitPhotos vp WITH(NOLOCK)
			Inner Join @TempVisitPhotos tvp
				On tvp.VisitPhotoId = vp.VisitPhotoId
			Where vp.VisitId = @Result
				And tvp.VisitPhotoId <> 0

			-- To delete removed remarks
			UPDATE vp
			SET vp.IsDeleted = 1,
				vp.ModifiedOn = GETDATE(),
				vp.ModifiedBy = @LoggedInUserId
			FROM @TempVisitPhotos tvp
			LEFT JOIN VisitPhotos vp WITH(NOLOCK)
				ON tvp.VisitPhotoId = vp.VisitPhotoId
			WHERE vp.VisitId = @Result
				And vp.VisitPhotoId IS NULL
		END
	END
	
	Select @Result as Result
END

GO

-- GetVisitPhotosByVisitId 3
Create Or Alter Procedure GetVisitPhotosByVisitId
	@VisitId BigInt
As
Begin
	Set NoCount On;

	Select
		VP.VisitPhotoId, VP.UploadedFileName, VP.SavedFileName
	From VisitPhotos VP With(NoLock)
	Where VP.VisitId = @VisitId And VP.IsDeleted = 0
End

GO

/*
	EXEC [dbo].[GetVisits]  
		@PageSize=10,
	    @PageNo=1,
	    @SortBy='',
	    @OrderBy='',
		@VisitNo='',
		@ContactPerson='',
		@CustomerType='',
		@CustomerName='',
		@ContactPersonName = '',
		@ContactPersonNumber = '',
		@AreaName='',
		@Address = '',
		@FromVisitDate = null,
		@ToVisitDate = null,
		@VisitStatusId = 1,
		@IsActive=NULL,
		@LoggedInUserId=0
*/
Alter Procedure [dbo].[GetVisits]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@VisitNo VarChar(15),
	@ContactPerson VARCHAR(100) = '',
	@CustomerType VARCHAR(50) = '',
	@CustomerName VARCHAR(50) = '',
	@ContactPersonName VARCHAR(50) = '',
	@ContactPersonNumber VARCHAR(20) = '',
	@AreaName VARCHAR(20) = '',
	@Address VARCHAR(100) = '',
	@FromVisitDate Date = null,
	@ToVisitDate Date = null,
	@VisitStatusId Int = 0,
	@IsActive BIT = null,
	@LoggedInUserId BigInt = 0
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @STR NVARCHAR(MAX);
	DECLARE @Offset INT, @RowCount INT;
	DECLARE @OrderSortByConcate VARCHAR(100);
	DECLARE @OrderByQuery VARCHAR(1000)='';
	DECLARE @PaginationQuery VARCHAR(100)='';

	If @PageSize > 0
	BEGIN
		SET @Offset = (@PageNo - 1) * @PageSize;
		SET @RowCount = @PageSize * @PageNo;
		SET @PaginationQuery='OFFSET '+CAST(@Offset as VARCHAR(5))+'  ROWS
								 FETCH NEXT '+CAST(@RowCount as VARCHAR(5))+' ROWS ONLY';
	END
	
	SET @OrderSortByConcate= @SortBy + ' ' + @OrderBy;
	SET @ContactPerson = ISNULL(@ContactPerson,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by VisitId DESC ';
		END
	
	SET @STR = N'SELECT
					EM.VisitId,
					EM.VisitNo,
					EM.EmployeeId,Emp.EmployeeName,EM.VisitDate,EM.CustomerId,EM.CustomerTypeId,EM.ContactPerson,EM.ContactNumber,
					EM.EmailId,EM.NextActionDate,EM.Latitude,EM.Longitude,
					EM.IsActive,
					AD.Address,AD.StateId,AD.RegionId,AD.DistrictId,AD.AreaId,
					SM.StateName,RGM.RegionName,DM.DistrictName,ARM.AreaName,
					AD.Pincode,EM.VisitStatusId,StsM.StatusName, CD.CompanyName as CustomerName,
					CTM.CustomerTypeName,
					CreatorEM.EmployeeName As CreatorName,
					EM.CreatedBy,
					EM.CreatedOn
				FROM VisitMaster EM WITH(NOLOCK)
				Inner Join StatusMaster StsM WIth(NoLock)
					On StsM.StatusId = EM.VisitStatusId
				INNER JOIN VisitAddressMapping VAM WITH(NOLOCK)
					ON VAM.VisitId=EM.VisitId
				INNER JOIN AddressMaster AD WITH(NOLOCK)
					ON AD.AddressId=VAM.AddressId
				INNER JOIN StateMaster SM WITH(NOLOCK)
					ON SM.StateId=AD.StateId
				INNER JOIN RegionMaster RGM WITH(NOLOCK)
					ON RGM.RegionId=AD.RegionId
				INNER JOIN DistrictMaster DM WITH(NOLOCK)
					ON DM.DistrictId=AD.DistrictId
				INNER JOIN AreaMaster ARM WITH(NOLOCK)
					ON ARM.AreaId=AD.AreaId
				Inner Join Users U With(NoLock)
					On U.UserId = EM.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId
						And U.EmployeeId Is Not Null
				Left Join EmployeeMaster Emp With(NoLock)
					On Emp.EmployeeId = EM.EmployeeId
				Left Join CustomerDetails CD WITH(NOLOCK)
					On CD.CustomerId = EM.CustomerId
				Left Join CustomerTypeMaster CTM With(NoLock)
					On CTM.CustomerTypeId = EM.CustomerTypeId
				WHERE (@VisitNo='''' OR EM.VisitNo like ''%''+@VisitNo+''%'')
					And (@ContactPerson='''' OR EM.ContactPerson like ''%''+@ContactPerson+''%'')
					And (@IsActive IS NULL OR EM.IsActive=@IsActive)
					And (@VisitStatusId = 0 OR EM.VisitStatusId = @VisitStatusId)
					And (@CustomerType = '''' Or CTM.CustomerTypeName like ''%''+ @CustomerType +''%'')
					And (@CustomerName = '''' Or CD.CompanyName like ''%''+@CustomerName+''%'')
					And (@ContactPersonName = '''' Or EM.ContactPerson like ''%''+@ContactPersonName+''%'')
					And (@ContactPersonNumber = '''' Or EM.ContactNumber like ''%''+@ContactPersonNumber+''%'')
					And (@AreaName = '''' Or ARM.AreaName like ''%''+@AreaName+''%'')
					And (@Address = '''' Or AD.[Address] Like ''%''+@Address+''%'')
					And (@ToVisitDate Is Null Or EM.VisitDate >= @ToVisitDate)
					And (@ToVisitDate Is Null Or EM.VisitDate <= @ToVisitDate)
					And (@LoggedInUserId = 0 Or EM.CreatedBy=@LoggedInUserId)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	--PRINT @STR;

	exec sp_executesql @STR,
			N'@VisitNo VarChar(15),
			@ContactPerson VARCHAR(100),
			@IsActive BIT,
			@VisitStatusId Int,
			@CustomerType VARCHAR(50),
			@CustomerName VARCHAR(50),
			@ContactPersonName VARCHAR(50),
			@ContactPersonNumber VARCHAR(20),
			@AreaName VARCHAR(20),
			@Address VARCHAR(100),
			@FromVisitDate Date, 
			@ToVisitDate Date,
			@LoggedInUserId BigInt',
			@VisitNo,
			@ContactPerson,
			@IsActive,
			@VisitStatusId,
			@CustomerType,
			@CustomerName,
			@ContactPersonName,
			@ContactPersonNumber,
			@AreaName,
			@Address,
			@FromVisitDate, 
			@ToVisitDate,
			@LoggedInUserId
END

GO

Drop Procedure If Exists ValidateUserLoginByEmail;

GO

-- ValidateUserLoginByUsername @Username = '1111111111', @Password='Y+ZeQ74DLebrzzB+ogmTLg=='
-- ValidateUserLoginByUsername @Username = '1111111111', @Password='test'
Create Or ALTER Procedure ValidateUserLoginByUsername
	@Username VarChar(100),
	@Password VarChar(200)
As
Begin
	SET NOCOUNT ON;

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
End

GO

/*
	Exec GetLeaves
		@PageSize = 10,
	    @PageNo = 1,
	    @SortBy = '',
	    @OrderBy = '',
		@EmployeeName = '',
		@LeaveType = '',
		@LeaveReason = '',
		@LeaveStatusId = 0,
		@IsActive = NULL,
		@LoggedInUserId=0
*/

Alter Procedure GetLeaves
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50) = '',
    @OrderBy VARCHAR(4) = '',
	@EmployeeName VARCHAR(100)='',
	@LeaveType VarChar(20) = '',
	@LeaveReason VarChar(100) = '',
	@LeaveStatusId Int = 0,
	@IsActive BIT=null,
	@LoggedInUserId BigInt = 0
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @STR NVARCHAR(MAX);
	DECLARE @Offset INT, @RowCount INT;
	DECLARE @OrderSortByConcate VARCHAR(100);
	DECLARE @OrderByQuery VARCHAR(1000)='';
	DECLARE @PaginationQuery VARCHAR(100)='';

	If @PageSize > 0
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
			SET @OrderByQuery='ORDER by LeaveId DESC ';
		END
	
	SET @STR = N'SELECT
					LM.LeaveId,LM.StartDate,LM.EndDate,LM.EmployeeName,LM.LeaveTypeId,
					LTM.LeaveTypeName,Remark,Reason,LM.IsActive,LM.StatusId,SM.StatusName,
					CreatorEM.EmployeeName As CreatorName,
					LM.CreatedBy,
					LM.CreatedOn
				FROM LeaveMaster LM WITH(NOLOCK)
				Inner Join StatusMaster SM With(NoLock)
					On SM.StatusId = LM.StatusId
				Inner Join Users U With(NoLock)
					On U.UserId = LM.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId
						And U.EmployeeId Is Not Null
				LEFT JOIN LeaveTypeMaster LTM WITH(NOLOCK)
					ON LTM.LeaveTypeId=LM.LeaveTypeId
				WHERE (@EmployeeName='''' OR LM.EmployeeName like ''%''+@EmployeeName+''%'')
					And (@IsActive IS NULL OR LM.IsActive=@IsActive)
					And (@LeaveType = '''' OR LTM.LeaveTypeName like ''%''+@LeaveType+''%'')
					And (@LeaveReason = '''' OR LM.Remark like ''%''+@LeaveReason+''%'')
					And (@LeaveStatusId = 0 OR LM.StatusId = @LeaveStatusId)
					And (@LoggedInUserId = 0 Or LM.CreatedBy=@LoggedInUserId)
			'+@OrderByQuery+' '+@PaginationQuery+'	'
			
	--PRINT @STR;

	Exec sp_executesql @STR,
						N'@EmployeeName VARCHAR(100),
						@IsActive BIT,
						@LeaveType VarChar(20),
						@LeaveReason VarChar(100),
						@LeaveStatusId Int,
						@LoggedInUserId BigInt',
						@EmployeeName,
						@IsActive,
						@LeaveType,
						@LeaveReason,
						@LeaveStatusId,
						@LoggedInUserId
End

GO

