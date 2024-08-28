If Object_Id('CollectionMaster') Is Null
Begin
	Create Table CollectionMaster
	(
		CollectionId	Int Primary Key Identity(1,1),
		CollectionName	VarChar(100) Not Null,
		IsActive		Bit	Not Null,
		CreatedBy		BigInt	Not Null,
		CreatedOn		DateTime Not Null,
		ModifiedBy		BigInt,
		ModifiedOn		DateTime
	)
End

GO

/*
	Exec SaveCollectionDetails
		@CollectionId	= 1,
		@CollectionName	= 'Small',
		@IsActive		= 1,
		@LoggedInUserId	= 1
	
	Select * From CollectionMaster
*/
Create Or Alter Procedure SaveCollectionDetails
	@CollectionId	Int,
	@CollectionName	VarChar(100),
	@IsActive		Bit,
	@LoggedInUserId	BigInt
As
Begin
	Set NoCount On;

	DECLARE @Result Int = 0;
	DECLARE @NameExists Int = -2;
	DECLARE @NoRecordExists Int = -1;

	If (
		(@CollectionId = 0 And Exists(Select Top 1 1 From CollectionMaster With(NoLock) Where CollectionName=@CollectionName))
		Or
		(@CollectionId > 0 And Exists(Select Top 1 1 From CollectionMaster With(NoLock) Where CollectionName=@CollectionName And CollectionId <> @CollectionId))
	)
	Begin
		Set @Result = @NameExists;
	End
	Else If @CollectionId > 0 And Not Exists(Select Top 1 1 From CollectionMaster With(NoLock) Where CollectionId = @CollectionId)
	Begin
		Set @Result = @NoRecordExists;
	End
	Else If @CollectionId = 0
	Begin
		Insert Into CollectionMaster
		(
			CollectionName, IsActive, CreatedBy, CreatedOn	
		)
		Values
		(
			@CollectionName, @IsActive, @LoggedInUserId, GetDate()
		)

		SET @Result = SCOPE_IDENTITY();
	End
	Else If @CollectionId > 0
	Begin
		Update CollectionMaster
		Set CollectionName = @CollectionName,
			IsActive = @IsActive,
			ModifiedBy = @LoggedInUserId,
			ModifiedOn = GetDate()
		Where CollectionId = @CollectionId

		Set @Result = @CollectionId;
	End

	Select @Result As Result;
End

GO

-- GetCollectionDetailsById 1
Create Or Alter Procedure GetCollectionDetailsById
	@CollectionId	Int
As
Begin
	Set NoCount On;

	Select
		CollectionId,
		CollectionName,
		IsActive
	From CollectionMaster With(NoLock)
	Where CollectionId = @CollectionId
End

GO

/*
	Exec GetCollectionsList
		@PageNo			= 1,
		@PageSize		= 10,
		@SortBy			= 'CollectionName',
		@OrderBy		= 'Desc',
		@CollectionName	= '',
		@IsActive		= 1
*/
Create Or Alter Procedure GetCollectionsList
	@PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@CollectionName VARCHAR(100) = '',
	@IsActive BIT = null
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
		Set @OrderByQuery=' Order By CollectionId DESC ';
	End
	
	SET @stringQuery = N'Select
					CM.CollectionId,
					CM.CollectionName,
					CM.IsActive,
					CreatorEM.EmployeeName As CreatorName,
					CM.CreatedBy,
					CM.CreatedOn
				From CollectionMaster CM With(NoLock)
				Inner Join Users U With(NoLock)
					On U.UserId = CM.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId
						And U.EmployeeId Is Not Null
				WHERE (@CollectionName='''' OR CM.CollectionName Like ''%''+@CollectionName+''%'')
					And (@IsActive IS NULL OR CM.IsActive = @IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	Exec sp_executesql @stringQuery,
			N'@CollectionName VARCHAR(100), @IsActive BIT',
			@CollectionName, @IsActive
End

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
					EM.EmergencyContactNumber,EM.BloodGroup,EM.IsWebUser,Em.IsMobileUser,EM.IsActive,
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
				WHERE (@EmployeeName='''' OR EM.EmployeeName like ''%''+@EmployeeName+''%'')
					AND (@IsActive IS NULL OR EM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	------PRINT @STR;

	exec sp_executesql @STR,
						N'@EmployeeName VARCHAR(100),@IsActive BIT',
						@EmployeeName,@IsActive
END

GO

/*
	Version : 1.0
	Created Date : 03 JULY 2023
	Execution : EXEC [dbo].[GetVisits]
	Description : Get Visit Detail from GetVisits
	EXEC [dbo].[GetVisits]  
		@PageSize=10,
	    @PageNo=1,
	    @SortBy='',
	    @OrderBy='',
		@ContactPerson='',
		@CustomerType='',
		@CustomerName='',
		@ContactPersonName = '',
		@ContactPersonNumber = '',
		@AreaName = '',
		@FromDate = null,
		@ToDate = null,
		@VisitStatusId = 1,
		@IsActive=NULL
*/
ALTER PROCEDURE [dbo].[GetVisits]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@ContactPerson VARCHAR(100) = '',
	@CustomerType VARCHAR(50) = '',
	@CustomerName VARCHAR(50) = '',
	@ContactPersonName VARCHAR(50) = '',
	@ContactPersonNumber VARCHAR(20) = '',
	@AreaName VARCHAR(20) = '',
	@FromDate Date = null,
	@ToDate Date = null,
	@VisitStatusId Int = 0,
	@IsActive BIT = null
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
					Cast(EM.VisitId as VarChar(10)) As VisitNo, /* Here, VisitId for VisitNo needs to be replace with actual column when added */
					EM.EmployeeId,Emp.EmployeeName,EM.VisitDate,EM.CustomerId,EM.CustomerTypeId,EM.ContactPerson,EM.ContactNumber,
					EM.EmailId,EM.NextActionDate,EM.Latitude,EM.Longitude,
					/*VR.Remarks,*/
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
				WHERE (@ContactPerson='''' OR EM.ContactPerson like ''%''+@ContactPerson+''%'')
					and (@IsActive IS NULL OR EM.IsActive=@IsActive)
					And (@VisitStatusId = 0 OR EM.VisitStatusId = @VisitStatusId)
					And (@CustomerType = '''' Or CTM.CustomerTypeName like ''%''+ @CustomerType +''%'')
					And (@CustomerName = '''' Or CD.CompanyName like ''%''+@CustomerName+''%'')
					And (@ContactPersonName = '''' Or EM.ContactPerson like ''%''+@ContactPersonName+''%'')
					And (@ContactPersonNumber = '''' Or EM.ContactNumber like ''%''+@ContactPersonNumber+''%'')
					And (@AreaName = '''' Or ARM.AreaName like ''%''+@AreaName+''%'')
					And (@FromDate Is Null Or EM.VisitDate >= @FromDate)
					And (@ToDate Is Null Or EM.VisitDate <= @ToDate)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	--PRINT @STR;

	exec sp_executesql @STR,
			N'@ContactPerson VARCHAR(100),@IsActive BIT,@VisitStatusId Int,@CustomerType VARCHAR(50), @CustomerName VARCHAR(50),
				@ContactPersonName VARCHAR(50), @ContactPersonNumber VARCHAR(20),@AreaName VARCHAR(20),
				@FromDate Date, @ToDate Date',
			@ContactPerson,@IsActive,@VisitStatusId,@CustomerType,@CustomerName,
			@ContactPersonName, @ContactPersonNumber,@AreaName,@FromDate, @ToDate
END

GO

-- GetVisitDetailsById 1
ALTER PROCEDURE [dbo].[GetVisitDetailsById]
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		vm.VisitId,
		Cast(vm.VisitId as VarChar(10)) As VisitNo, /* Here, VisitId for VisitNo needs to be replace with actual column when added in both SPs GetVisitDetailsById and GetVisits */
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
		vm.ContactPerson,
		vm.ContactNumber,
		vm.NextActionDate,
		vm.Latitude,
		vm.Longitude,
		am.[Address],
		--vr.Remarks
		vm.IsActive,
		vm.VisitStatusId,
		StsM.StatusName,
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
	--INNER JOIN Users creator WITH(NOLOCK)
	--	ON creator.UserId = vm.CreatedBy
	--LEFT JOIN Users modifier WITH(NOLOCK)
	--	ON modifier.UserId = vm.ModifiedBy
	LEFT JOIN EmployeeMaster em WITH(NOLOCK)
		ON em.EmployeeId = vm.EmployeeId
	LEFT JOIN RoleMaster rm WITH(NOLOCK)
		ON rm.RoleId = em.RoleId
	LEFT JOIN CustomerDetails cd WITH(NOLOCK)
		ON cd.CustomerId = vm.CustomerId
	LEFT JOIN CustomerTypeMaster ctm WITH(NOLOCK)
		ON ctm.CustomerTypeId = cd.CustomerTypeId
	--LEFT JOIN VisitRemarks vr WITH(NOLOCK)
	--	ON vr.VisitId = vm.VisitId
	WHERE vm.VisitId = @Id
END

GO
