If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitMaster' And Column_Name='CustomerId')
Begin
	Alter Table VisitMaster
	Alter Column CustomerId BigInt Not Null
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitMaster' And Column_Name='CustomerId')
Begin
	Alter Table VisitMaster
	Add Foreign Key (CustomerId) References CustomerDetails(CustomerId)
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitMaster' And Column_Name='ContactPerson')
Begin
	Alter Table VisitMaster
	Drop Column ContactPerson
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitMaster' And Column_Name='ContactNumber')
Begin
	Alter Table VisitMaster
	Drop Column ContactNumber
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitMaster' And Column_Name='EmailId')
Begin
	Alter Table VisitMaster
	Drop Column EmailId
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitMaster' And Column_Name='ContactId')
Begin
	Alter Table VisitMaster
	Add ContactId BigInt
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitMaster' And Column_Name='BaseVisitId')
Begin
	Alter Table VisitMaster
	Add BaseVisitId BigInt NULL References VisitMaster(VisitId)
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitMaster' And Column_Name='ContactId')
Begin
	Update VisitMaster Set ContactId = (Select Top 1 ContactId From ContactDetails) Where IsNull(ContactId,0) = 0
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitMaster' And Column_Name='ContactId')
Begin
	Alter Table VisitMaster
	Alter Column ContactId BigInt Not Null
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitMaster' And Column_Name='ContactId')
Begin
	Alter Table VisitMaster
	Add Foreign Key (ContactId) References ContactDetails(ContactId)
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitMaster' And Column_Name='Latitude')
Begin
	Alter Table VisitMaster
	Drop Column Latitude
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitMaster' And Column_Name='Longitude')
Begin
	Alter Table VisitMaster
	Drop Column Longitude
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitMaster' And Column_Name='HasVisited')
Begin
	Alter Table VisitMaster
	Add HasVisited Bit
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitPhotos' And Column_Name='Latitude')
Begin
	Alter Table VisitPhotos
	Add Latitude VarChar(15) Not Null Default('')
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitPhotos' And Column_Name='Longitude')
Begin
	Alter Table VisitPhotos
	Add Longitude VarChar(15) Not Null Default('')
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitPhotos' And Column_Name='VisitAddress')
Begin
	Alter Table VisitPhotos
	Add VisitAddress VarChar(100) Not Null Default('')
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='VisitPhotos' And Column_Name='VisitDateTime')
Begin
	Alter Table VisitPhotos
	Add VisitDateTime DateTime Not Null Default GetDate()
End

GO

If Object_Id('VisitHistory') Is Null
Begin
	Create Table VisitHistory
	(
		VisitHistoryId	BigInt		Primary Key Identity(1,1),
		VisitId			BigInt		Not Null References VisitMaster(VisitId),
		ContactId		BigInt		Not Null References ContactDetails(ContactId),
		ActualVisitDate	DateTime	Not Null,
		VisitedOn		DateTime,
		CreatedBy		BIGINT		NOT NULL References Users(UserId),
		CreatedOn		DATETIME	NOT NULL
	)
End

GO

/*
	Exec SaveVisitDetails
*/
Alter Procedure SaveVisitDetails
(
	@VisitId			BIGINT,
	@EmployeeId			BIGINT,
	@VisitDate			Datetime,
	@CustomerId			BIGINT,
	@CustomerTypeId		BIGINT,
	@ContactId			BIGINT,
	@StateId			BIGINT,
	@RegionId			BIGINT,
	@DistrictId			BIGINT,
	@AreaId				BIGINT,
	@Address			VARCHAR(500),
	@NextActionDate		Datetime,
	@HasVisited			Bit,
	@IsActive			BIT,
	@VisitStatusId		INT,
	@BaseVisitId		BIGINT,	-- @BaseVisitId will be Greater Than 0 When request to create new visit based on existing one is occur
	@XmlRemarks			XML,
	@XmlVisitFiles		XML,
	@LoggedInUserId		BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @Result				BIGINT = 0;
	Declare @AddressId			BIGINT = 0;
	Declare @IsNameExists		BIGINT = -2;
	Declare @NoRecordExists		BIGINT = -1;
	Declare @NewVisitNo			VarChar(15);
	Declare @TempNextVisitDate	DateTime;

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
		-- To close existing visit when request to create new visit based on existing one is occur
		Update VisitMaster
		Set VisitStatusId = (Select StatusId From StatusMaster With(NoLock) Where StatusCode='C' And StatusName='Closed')
		Where VisitId = @BaseVisitId

		Select
			@TempNextVisitDate = NextActionDate
		From VisitMaster With(NoLock)
		Where VisitId = @VisitId

		If @VisitId=0
		Begin
			Select
				@NewVisitNo = 'VISIT'+Cast(Max(VisitId)+1 as varchar(10))
			From VisitMaster;
			
			Insert into VisitMaster
			(
				VisitNo,EmployeeId,VisitDate,CustomerId,CustomerTypeId,ContactId,NextActionDate,HasVisited,
				IsActive,VisitStatusId,BaseVisitId,CreatedBy,CreatedOn
			)
			Values
			(
				@NewVisitNo,@EmployeeId,@VisitDate,@CustomerId,@CustomerTypeId,@ContactId,@NextActionDate,1,
				@IsActive,@VisitStatusId,@BaseVisitId,@LoggedInUserId,GETDATE()
			)

			SET @Result = SCOPE_IDENTITY();
			
			-- Insert Into Address 
			INSERT INTO AddressMaster
			(
				[Address],StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn
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
		End
		Else If (@VisitId> 0 and @TempNextVisitDate Is Not Null)	-- @TempNextVisitDate Will Not be NULL where Visit record with @VisitId is existing
		Begin
			-- To maintain Visit History
			--If Cast(@VisitDate As Date) = Cast(@TempNextVisitDate As Date)
			--Begin
				Insert Into VisitHistory
				(
					VisitId, ContactId, ActualVisitDate, VisitedOn, CreatedBy, CreatedOn
				)
				Select
					VisitId, ContactId, NextActionDate, @VisitDate, @LoggedInUserId, GetDate()
				From VisitMaster With(NoLock)
				Where VisitId = @VisitId
			--End

			-- To Update VisitMaster and other related tables
			Update VisitMaster
			Set EmployeeId		= @EmployeeId,
				VisitDate		= @VisitDate,
				CustomerId		= @CustomerId,
				CustomerTypeId	= @CustomerTypeId,
				ContactId		= @ContactId,
				NextActionDate	= @NextActionDate,
				HasVisited		= @HasVisited,
				IsActive		= @IsActive,
				VisitStatusId	= @VisitStatusId,
				ModifiedBy		= @LoggedInUserId,
				ModifiedOn		= GETDATE()
			Where VisitId = @VisitId
			
			Update AD
			Set [Address]	= @Address,
				StateId		= @StateId,
				RegionId	= @RegionId,
				DistrictId	= @DistrictId,
				AreaId		= @AreaId,
				ModifiedBy	= @LoggedInUserId,
				ModifiedOn	= GETDATE()
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
				VisitId				BIGINT,
				VisitPhotoId		BIGINT,
				Latitude			VarChar(15),
				Longitude			VarChar(15),
				VisitAddress		VarChar(100),
				VisitDateTime		DateTime,
				UploadedFileName	VarChar(200),
				SavedFileName		VarChar(200)
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
			Insert Into @TempVisitPhotos
			(
				VisitId, VisitPhotoId, Latitude, Longitude, VisitAddress, VisitDateTime, UploadedFileName, SavedFileName
			)
			Select
				VisitId				= @Result,
				VisitPhotoId		= T.Item.value('VisitPhotoId[1]', 'BigInt'),
				Latitude			= T.Item.value('Latitude[1]', 'VarChar(15)'),
				Longitude			= T.Item.value('Longitude[1]', 'VarChar(15)'),
				VisitAddress		= T.Item.value('VisitAddress[1]', 'VarChar(100)'),
				VisitDateTime		= T.Item.value('VisitDateTime[1]', 'DateTime'),
				UploadedFileName	= T.Item.value('UploadedFileName[1]', 'VarChar(200)'),
				SavedFileName		= T.Item.value('SavedFileName[1]', 'VarChar(200)')
			From @XmlVisitFiles.nodes('/ArrayOfVisitPhotosRequest/VisitPhotosRequest') AS T(Item)

			-- To Insert new records with VisitPhotoId = 0
			Insert Into VisitPhotos
			(
				VisitId, Latitude, Longitude, VisitAddress, VisitDateTime, UploadedFileName, SavedFileName, IsDeleted
			)
			Select
				@Result, Latitude, Longitude, VisitAddress, VisitDateTime, UploadedFileName, SavedFileName, 0
			From @TempVisitPhotos
			Where VisitPhotoId = 0
			
			-- To update existing records
			Update vp
			Set vp.Latitude			= tvp.Latitude,
				vp.Longitude		= tvp.Longitude,
				vp.VisitAddress		= tvp.VisitAddress,
				vp.VisitDateTime	= tvp.VisitDateTime,
				vp.UploadedFileName = tvp.UploadedFileName,
				vp.SavedFileName	= tvp.SavedFileName,
				vp.ModifiedOn		= GETDATE(),
				vp.ModifiedBy		= @LoggedInUserId
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
End

GO

-- GetVisitDetailsById 6
Alter Procedure GetVisitDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		vm.VisitId,
		vm.VisitNo,
		vm.VisitDate,
		em.RoleId AS EmployeeRoleId,
		rm.RoleName,
		vm.CustomerId,
		em.EmployeeId,
		em.EmployeeName,
		EM.EmailId,
		ctm.CustomerTypeId,
		cd.CompanyName AS CustomerName,
		CTM.CustomerTypeName,
		sm.StateId,
		sm.StateName,
		region.RegionId,
		region.RegionName,
		dm.DistrictId,
		dm.DistrictName,
		am.AreaId,
		area.AreaName,
		vm.NextActionDate,
		am.[Address],
		vm.IsActive,
		vm.VisitStatusId,
		StsM.StatusName,
		contact.ContactName As ContactPerson,
		contact.MobileNo As ContactNumber,
		vm.CreatedOn,
		vm.ModifiedOn
	FROM VisitMaster vm WITH(NOLOCK)
	Inner Join StatusMaster StsM WIth(NoLock)
		On StsM.StatusId = VM.VisitStatusId
	INNER JOIN VisitAddressMapping vam WITH(NOLOCK)
		ON vam.VisitId = vm.VisitId
	INNER JOIN AddressMaster am WITH(NOLOCK)
		ON am.AddressId = vam.AddressId
	INNER JOIN StateMaster sm WITH(NOLOCK)
		ON sm.StateId = am.StateId
	INNER JOIN RegionMaster region WITH(NOLOCK)
		ON region.RegionId = am.RegionId
	INNER JOIN DistrictMaster dm WITH(NOLOCK)
		ON dm.DistrictId = am.DistrictId
	INNER JOIN AreaMaster area WITH(NOLOCK)
		ON area.AreaId = am.AreaId
	Inner Join CustomerDetails cd WITH(NOLOCK)
		ON cd.CustomerId = vm.CustomerId
	Inner Join ContactDetails contact WITH(NOLOCK)
		ON contact.ContactId = vm.ContactId
	LEFT JOIN EmployeeMaster em WITH(NOLOCK)
		ON em.EmployeeId = vm.EmployeeId
	LEFT JOIN RoleMaster rm WITH(NOLOCK)
		ON rm.RoleId = em.RoleId
	LEFT JOIN CustomerTypeMaster ctm WITH(NOLOCK)
		ON ctm.CustomerTypeId = cd.CustomerTypeId
	WHERE vm.VisitId = @Id
END

GO

-- GetVisitPhotosByVisitId 3
Alter Procedure GetVisitPhotosByVisitId
	@VisitId BigInt
As
Begin
	Set NoCount On;

	Select
		VP.VisitPhotoId,
		VP.Latitude,
		VP.Longitude,
		VP.VisitDateTime,
		VP.VisitAddress,
		VP.UploadedFileName,
		VP.SavedFileName
	From VisitPhotos VP With(NoLock)
	Where VP.VisitId = @VisitId
		And VP.IsDeleted = 0
End

GO

/*
	EXEC [dbo].[GetVisits]  
		@PageSize=10,
	    @PageNo=1,
	    @SortBy='',
	    @OrderBy='',
		@VisitNo='',
		@EmployeeId=0,
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
Alter Procedure GetVisits
(
    @PageSize INT,	
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@VisitNo VarChar(15),
	@EmployeeId BigInt = 0,
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
	SET @ContactPersonName = ISNULL(@ContactPersonName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by VisitId DESC ';
		END
	
	SET @STR = N'Select
					EM.VisitId,
					EM.VisitNo,
					EM.EmployeeId,
					Emp.EmployeeName,
					EM.VisitDate,
					AD.StateId,
					SM.StateName,
					AD.RegionId,
					RGM.RegionName,
					AD.DistrictId,
					DM.DistrictName,
					AD.AreaId,
					ARM.AreaName,
					AD.Address,
					AD.Pincode,
					contact.ContactName As ContactPerson,
					contact.MobileNo As ContactNumber,
					EM.NextActionDate,
					EM.IsActive,
					EM.VisitStatusId,
					StsM.StatusName,
					EM.CustomerId,
					CD.CompanyName as CustomerName,
					EM.CustomerTypeId,
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
				Inner Join CustomerDetails cd WITH(NOLOCK)
					On cd.CustomerId = EM.CustomerId
				Inner Join ContactDetails contact WITH(NOLOCK)
					On contact.ContactId = EM.ContactId
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId
						And U.EmployeeId Is Not Null
				Left Join EmployeeMaster Emp With(NoLock)
					On Emp.EmployeeId = EM.EmployeeId
				Left Join CustomerTypeMaster CTM With(NoLock)
					On CTM.CustomerTypeId = EM.CustomerTypeId
				WHERE (@VisitNo='''' OR EM.VisitNo like ''%''+@VisitNo+''%'')
					And (@EmployeeId = 0 OR EM.EmployeeId = @EmployeeId)
					And (@IsActive IS NULL OR EM.IsActive=@IsActive)
					And (@VisitStatusId = 0 OR EM.VisitStatusId = @VisitStatusId)
					And (@CustomerType = '''' Or CTM.CustomerTypeName like ''%''+ @CustomerType +''%'')
					And (@CustomerName = '''' Or CD.CompanyName like ''%''+@CustomerName+''%'')
					And (@ContactPersonName = '''' Or contact.ContactName like ''%''+@ContactPersonName+''%'')
					And (@ContactPersonNumber = '''' Or contact.MobileNo like ''%''+@ContactPersonNumber+''%'')
					And (@AreaName = '''' Or ARM.AreaName like ''%''+@AreaName+''%'')
					And (@Address = '''' Or AD.[Address] Like ''%''+@Address+''%'')
					And (@ToVisitDate Is Null Or EM.VisitDate >= @ToVisitDate)
					And (@ToVisitDate Is Null Or EM.VisitDate <= @ToVisitDate)
					And (@LoggedInUserId = 0 Or EM.CreatedBy=@LoggedInUserId)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	--PRINT @STR;

	exec sp_executesql @STR,
			N'@VisitNo VarChar(15),
			@EmployeeId BigInt,
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
			@EmployeeId,
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

-- GetCustomerContactsList 7,NULL
Create Or Alter Procedure GetCustomerContactsList
	@CustomerId	BigInt,
	@IsActive	Bit = NULL
As
Begin
	Set NoCount On;

	Select
		CD.ContactId,
		CD.ContactName,
		CD.MobileNo,
		CD.EmailId
		--,CCM.CustomerId
	From ContactDetails CD With(NoLock)
	Inner Join CustomerContactMapping CCM With(NoLock)
		On CD.ContactId = CCM.ContactId
	Where CCM.CustomerId = @CustomerId
		And (@IsActive Is Null Or CD.IsActive = @IsActive)
	Order By CD.ContactId Desc
End

GO

-- SaveContactDetails 14,7,'Demo Contact','3321331445','demo-test@gmail.com',1,1
Create Or Alter Procedure SaveContactDetails
	@ContactId			BigInt,
	@CustomerId			BigInt,
	@ContactName		VarChar(50),
	@MobileNo			VarChar(10),
	@EmailAddress		VarChar(200),
	@IsActive			Bit,
	@LoggedInUserId		BigInt
As
Begin
	Set NoCount On;

	Declare @Result				BIGINT = 0;
	Declare @IsEmailExists		BIGINT = -4;
	Declare @IsMobileExists		BIGINT = -3;
	Declare @IsNameExists		BIGINT = -2;
	Declare @NoRecordExists		BIGINT = -1;
	
	If (
		(@CustomerId=0 AND 
			EXISTS
			(
				Select Top 1 1 
				From ContactDetails CD WITH(NOLOCK) 
				Where CD.ContactName = @ContactName
			)
		)
		OR
		(@CustomerId > 0 AND 
			EXISTS
			(
				Select Top 1 1 
				From ContactDetails CD WITH(NOLOCK) 
				Where CD.ContactName = @ContactName
					And CD.ContactId <> @ContactId
			)
		))
	BEGIN
		SET @Result = @IsNameExists;
	END
	Else If (
		(@CustomerId=0 AND 
			EXISTS
			(
				Select Top 1 1 
				From ContactDetails CD WITH(NOLOCK) 
				Where CD.MobileNo = @MobileNo
			)
		)
		OR
		(@CustomerId > 0 AND 
			EXISTS
			(
				Select Top 1 1 
				From ContactDetails CD WITH(NOLOCK) 
				Where CD.MobileNo = @MobileNo
					And CD.ContactId <> @ContactId
			)
		))
	BEGIN
		SET @Result = @IsMobileExists;
	END
	Else If (
		(@CustomerId=0 AND 
			EXISTS
			(
				Select Top 1 1 
				From ContactDetails CD WITH(NOLOCK) 
				Where CD.EmailId = @EmailAddress
			)
		)
		OR
		(@CustomerId > 0 AND 
			EXISTS
			(
				Select Top 1 1 
				From ContactDetails CD WITH(NOLOCK) 
				Where CD.EmailId = @EmailAddress
					And CD.ContactId <> @ContactId
			)
		))
	BEGIN
		SET @Result = @IsEmailExists;
	END
	Else If @ContactId = 0
	Begin
		Insert Into ContactDetails
		(
			ContactName,MobileNo,EmailId,RefPartyName,IsActive,CreatedBy,CreatedOn
		)
		Values
		(
			@ContactName,@MobileNo,@EmailAddress,'',@IsActive,@LoggedInUserId,GetDate()
		)

		Set @Result = Scope_Identity();

		Insert Into CustomerContactMapping
		(
			CustomerId, ContactId
		)
		Values
		(
			@CustomerId, @Result
		)
	End
	Else If @ContactId > 0
	Begin
		Update ContactDetails
		Set ContactName	= @ContactName,
			MobileNo	= @MobileNo,
			EmailId		= @EmailAddress,
			IsActive	= @IsActive,
			ModifiedBy	= @LoggedInUserId,
			ModifiedOn	= GetDate()
		Where ContactId = @ContactId

		Set @Result = @ContactId;
	End

	Select @Result As Result;
End

GO
