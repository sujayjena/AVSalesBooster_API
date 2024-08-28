/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetCustomers]
Description : Get Customer Detail from CustomerDetails
EXEC [dbo].[GetCustomers]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@CompanyName='',
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetCustomers]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@CompanyName VARCHAR(100)=null,
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
	SET @CompanyName = ISNULL(@CompanyName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by CustomerId DESC ';
		END


	SET @STR = N'SELECT CD.CustomerId,CD.CompanyName,CD.LandlineNo,CD.MobileNo as MobileNumber,CD.EmailId,
					CD.CustomerTypeId,CTM.CustomerTypeName as CustomerTypeName,CD.SpecialRemarks,CD.EmployeeId,EM.EmployeeName as EmployeeName
					FROM CustomerDetails CD WITH(NOLOCK)
				LEFT JOIN CustomerTypeMaster CTM  WITH(NOLOCK) ON CTM.CustomerTypeId = CD.CustomerTypeId
				LEFT JOIN EmployeeMaster EM WITH(NOLOCK) ON EM.EmployeeId=CD.EmployeeId
				WHERE (@CompanyName='''' OR CompanyName like ''%''+@CompanyName+''%'')
				and (@IsActive IS NULL OR CD.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@CompanyName VARCHAR(100),@IsActive BIT',
						@CompanyName,@IsActive
END

GO

ALTER PROCEDURE GetCustomerDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CD.CustomerId,CD.CompanyName,CD.LandlineNo,CD.MobileNo as MobileNumber,CD.EmailId,
					CD.CustomerTypeId,CTM.CustomerTypeName as CustomerTypeName,CD.SpecialRemarks,CD.EmployeeId,EM.EmployeeName as EmployeeName
					FROM CustomerDetails CD WITH(NOLOCK)
				LEFT JOIN CustomerTypeMaster CTM  WITH(NOLOCK) ON CTM.CustomerTypeId = CD.CustomerTypeId
				LEFT JOIN EmployeeMaster EM WITH(NOLOCK) ON EM.EmployeeId=CD.EmployeeId
	WHERE CustomerId = @Id
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetDesignes]
Description : Get Design list from DesignMaster
EXEC [dbo].[GetDesignes]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@DesignName='',
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetDesignes]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@DesignName VARCHAR(100)=null,
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
	SET @DesignName = ISNULL(@DesignName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by DesignId DESC ';
		END


	SET @STR = N'SELECT DesignId,DM.ProductId,P.ProductName,DM.BrandId,B.BrandName,DM.SizeId,SM.SizeName,DM.CategoryId,CM.CategoryName,DM.SeriesId,SM1.SeriesName,DM.DesignTypeId,DTM.DesignTypeName,
						DM.BaseDesignId,BDM.BaseDesignName,DesignName,DesignCode,DM.IsActive
						FROM DesignMaster DM WITH(NOLOCK)
				LEFT JOIN ProductMaster P WITH(NOLOCK) ON P.ProductId=DM.ProductId
				LEFT JOIN BrandMaster  B WITH(NOLOCK) ON B.BrandId=DM.BrandId
				LEFT JOIN SizeMaster  SM WITH(NOLOCK) ON SM.SizeId=DM.SizeId
				LEFT JOIN CategoryMaster  CM WITH(NOLOCK) ON CM.CategoryId=DM.CategoryId
				LEFT JOIN SeriesMaster  SM1 WITH(NOLOCK) ON SM1.SeriesId=DM.SeriesId
				LEFT JOIN DesignTypeMaster  DTM WITH(NOLOCK) ON DTM.DesignTypeId=DM.DesignTypeId
				LEFT JOIN BaseDesignMaster BDM WITH(NOLOCK) ON BDM.BaseDesignId=DM.BaseDesignId
				WHERE (@DesignName='''' OR DesignName like ''%''+@DesignName+''%'')
				and (@IsActive IS NULL OR DM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@DesignName VARCHAR(100),@IsActive BIT',

						@DesignName,@IsActive
END

GO

ALTER PROCEDURE GetDesignDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

    SELECT DesignId,DM.ProductId,P.ProductName,DM.BrandId,B.BrandName,DM.SizeId,SM.SizeName,DM.CategoryId,CM.CategoryName,DM.SeriesId,SM1.SeriesName,DM.DesignTypeId,DTM.DesignTypeName,
						DM.BaseDesignId,BDM.BaseDesignName,DesignName,DesignCode,DM.IsActive
						FROM DesignMaster DM WITH(NOLOCK)
				LEFT JOIN ProductMaster P WITH(NOLOCK) ON P.ProductId=DM.ProductId
				LEFT JOIN BrandMaster  B WITH(NOLOCK) ON B.BrandId=DM.BrandId
				LEFT JOIN SizeMaster  SM WITH(NOLOCK) ON SM.SizeId=DM.SizeId
				LEFT JOIN CategoryMaster  CM WITH(NOLOCK) ON CM.CategoryId=DM.CategoryId
				LEFT JOIN SeriesMaster  SM1 WITH(NOLOCK) ON SM1.SeriesId=DM.SeriesId
				LEFT JOIN DesignTypeMaster  DTM WITH(NOLOCK) ON DTM.DesignTypeId=DM.DesignTypeId
				LEFT JOIN BaseDesignMaster BDM WITH(NOLOCK) ON BDM.BaseDesignId=DM.BaseDesignId
	WHERE DM.DesignId=@Id
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetLeaves]
Description : Get Leave from LeaveMaster
EXEC [dbo].[GetLeaves]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@EmployeeName='',
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetLeaves]
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
			SET @OrderByQuery='ORDER by LeaveId DESC ';
		END


	SET @STR = N'SELECT LeaveId,StartDate,EndDate,EmployeeName,LM.LeaveTypeId,LTM.LeaveTypeName,Remark,Reason,LM.IsActive
					FROM LeaveMaster LM WITH(NOLOCK)
				LEFT JOIN LeaveTypeMaster LTM WITH(NOLOCK) ON LTM.LeaveTypeId=LM.LeaveTypeId
				WHERE (@EmployeeName='''' OR EmployeeName like ''%''+@EmployeeName+''%'')
				and (@IsActive IS NULL OR LM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@EmployeeName VARCHAR(100),@IsActive BIT',
						@EmployeeName,@IsActive
END


GO


ALTER PROCEDURE GetLeaveDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	 SELECT LeaveId,StartDate,EndDate,EmployeeName,LM.LeaveTypeId,LTM.LeaveTypeName,Remark,Reason,LM.IsActive
					FROM LeaveMaster LM WITH(NOLOCK)
				LEFT JOIN LeaveTypeMaster LTM WITH(NOLOCK) ON LTM.LeaveTypeId=LM.LeaveTypeId
	WHERE LM.LeaveId = @Id
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetRegions]
Description : Get Region from RegionMaster
EXEC [dbo].[GetRegions]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@RegionName='',
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetRegions]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@RegionName VARCHAR(100)=null,
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
	SET @RegionName = ISNULL(@RegionName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by RegionId DESC ';
		END


	SET @STR = N'SELECT R.RegionId,R.StateId,M.StateName,R.RegionName,R.IsActive
					FROM RegionMaster R WITH(NOLOCK)
					INNER JOIN StateMaster M WITH(NOLOCK) ON M.StateId=R.StateId
				WHERE (@RegionName='''' OR RegionName like ''%''+@RegionName+''%'')
				and (@IsActive IS NULL OR R.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@RegionName VARCHAR(100),@IsActive BIT',

						@RegionName,@IsActive
END

GO

ALTER PROCEDURE GetRegionDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	 SELECT R.RegionId,R.StateId,M.StateName,R.RegionName,R.IsActive
					FROM RegionMaster R WITH(NOLOCK)
					INNER JOIN StateMaster M WITH(NOLOCK) ON M.StateId=R.StateId
	WHERE RegionId = @Id
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetDistricts]
Description : Get District from DistrictMaster
EXEC [dbo].[GetDistricts]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@DistrictName='',
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetDistricts]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@DistrictName VARCHAR(100)=null,
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
	SET @DistrictName = ISNULL(@DistrictName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by RegionId DESC ';
		END


	SET @STR = N'SELECT D.DistrictId,D.RegionId,RM.RegionName,D.DistrictName,D.IsActive
					FROM DistrictMaster D WITH(NOLOCK)
				INNER JOIN RegionMaster RM  WITH(NOLOCK) ON RM.RegionId=D.RegionId
				WHERE (@DistrictName='''' OR DistrictName like ''%''+@DistrictName+''%'')
				and (@IsActive IS NULL OR D.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@DistrictName VARCHAR(100),@IsActive BIT',
						@DistrictName,@IsActive
END

GO
ALTER PROCEDURE GetDistrictDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT D.DistrictId,D.RegionId,RM.RegionName,D.DistrictName,D.IsActive
					FROM DistrictMaster D WITH(NOLOCK)
				INNER JOIN RegionMaster RM  WITH(NOLOCK) ON RM.RegionId=D.RegionId
	WHERE D.DistrictId = @Id
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetAreas]
Description : Get Area from AreaMaster
EXEC [dbo].[GetAreas]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@AreaName='',
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetAreas]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@AreaName VARCHAR(100)=null,
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
	SET @AreaName = ISNULL(@AreaName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by AreaId DESC ';
		END


	SET @STR = N'SELECT AM.AreaId,AM.DistrictId,D.DistrictName,AM.AreaName,AM.IsActive
						FROM AreaMaster AM WITH(NOLOCK)
					INNER JOIN DistrictMaster D WITH(NOLOCK) ON D.DistrictId=AM.DistrictId
				WHERE (@AreaName='''' OR AM.AreaName like ''%''+@AreaName+''%'')
				and (@IsActive IS NULL OR AM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@AreaName VARCHAR(100),@IsActive BIT',
						@AreaName,@IsActive
END

GO

ALTER PROCEDURE GetAreaDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	 SELECT AM.AreaId,AM.DistrictId,D.DistrictName,AM.AreaName,AM.IsActive
			FROM AreaMaster AM WITH(NOLOCK)
			INNER JOIN DistrictMaster D WITH(NOLOCK) ON D.DistrictId=AM.DistrictId
	WHERE AreaId = @Id
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetReportingTos]
Description : Get ReportingTo from ReportingToMaster
EXEC [dbo].[GetReportingTos]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@ReportingTo=0,
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetReportingTos]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@ReportingTo VARCHAR(100)=null,
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
	SET @ReportingTo = ISNULL(@ReportingTo,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by Id DESC ';
		END


	SET @STR = N'SELECT RTM.Id,RTM.RoleId,RM.RoleName,RTM.ReportingTo,RTM.IsActive
					FROM ReportingToMaster RTM WITH(NOLOCK)
				LEFT JOIN RoleMaster RM WITH(NOLOCK) ON RM.RoleId=RTM.RoleId
				WHERE (@ReportingTo=0 OR RTM.ReportingTo =@ReportingTo)
				and (@IsActive IS NULL OR RTM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@ReportingTo VARCHAR(100),@IsActive BIT',
						@ReportingTo,@IsActive
END


GO

ALTER PROCEDURE GetReportingToDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	 SELECT RTM.Id,RTM.RoleId,RM.RoleName,RTM.ReportingTo,RTM.IsActive
					FROM ReportingToMaster RTM WITH(NOLOCK)
				LEFT JOIN RoleMaster RM WITH(NOLOCK) ON RM.RoleId=RTM.RoleId
	WHERE RTM.Id = @Id
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


	SET @STR = N'SELECT EM.EmployeeId,EM.EmployeeName,EM.EmployeeCode,EM.EmailId,EM.MobileNumber,EM.RoleId,RM.RoleName,EM.ReportingTo,RM1.RoleName as ReportingToName,
				 AM.Address,AM.StateId,SM.StateName,AM.RegionId,RGM.RegionName,AM.DistrictId,DM.DistrictName,AM.AreaId,ARM.AreaName,AM.Pincode
				 EM.DateOfBirth,EM.DateOfJoining,
				 EM.EmergencyContactNumber,EM.BloodGroup,EM.IsWebUser,Em.IsMobileUser,EM.IsActive,EM.FileOriginalName,EM.ImageUpload
				FROM EmployeeMaster EM WITH(NOLOCK)
				INNER JOIN EmployeeAddressMapping EAM WITH(NOLOCK) ON EAM.EmployeeId=EM.EmployeeId
				INNER JOIN AddressMaster AM WITH(NOLOCK) ON AM.AddressId=EAM.AddressId
				INNER JOIN RoleMaster RM WITH(NOLOCK) ON RM.RoleId=EM.RoleId
				INNER JOIN RoleMaster RM1 WITH(NOLOCK) ON RM1.RoleId=EM.ReportingTo
				INNER JOIN StateMaster SM WITH(NOLOCK) ON SM.StateId=AM.StateId
				INNER JOIN RegionMaster RGM WITH(NOLOCK) ON RGM.RegionId=AM.RegionId
				INNER JOIN DistrictMaster DM WITH(NOLOCK) ON DM.DistrictId=AM.DistrictId
				INNER JOIN AreaMaster ARM WITH(NOLOCK) ON ARM.AreaId=AM.AreaId
				WHERE (@EmployeeName='''' OR EM.EmployeeName like ''%''+@EmployeeName+''%'')
				and (@IsActive IS NULL OR EM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@EmployeeName VARCHAR(100),@IsActive BIT',
						@EmployeeName,@IsActive
END

GO
ALTER PROCEDURE GetEmployeeDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT EM.EmployeeId,EM.EmployeeName,EM.EmployeeCode,EM.EmailId,EM.MobileNumber,EM.RoleId,RM.RoleName,EM.ReportingTo,RM1.RoleName as ReportingToName,
				 AM.Address,AM.StateId,SM.StateName,AM.RegionId,RGM.RegionName,AM.DistrictId,DM.DistrictName,AM.AreaId,ARM.AreaName,AM.Pincode,
				 EM.DateOfBirth,EM.DateOfJoining,
				 EM.EmergencyContactNumber,EM.BloodGroup,EM.IsWebUser,Em.IsMobileUser,EM.IsActive,EM.FileOriginalName,EM.ImageUpload
				FROM EmployeeMaster EM WITH(NOLOCK)
				INNER JOIN EmployeeAddressMapping EAM WITH(NOLOCK) ON EAM.EmployeeId=EM.EmployeeId
				INNER JOIN AddressMaster AM WITH(NOLOCK) ON AM.AddressId=EAM.AddressId
				INNER JOIN RoleMaster RM WITH(NOLOCK) ON RM.RoleId=EM.RoleId
				INNER JOIN RoleMaster RM1 WITH(NOLOCK) ON RM1.RoleId=EM.ReportingTo
				INNER JOIN StateMaster SM WITH(NOLOCK) ON SM.StateId=AM.StateId
				INNER JOIN RegionMaster RGM WITH(NOLOCK) ON RGM.RegionId=AM.RegionId
				INNER JOIN DistrictMaster DM WITH(NOLOCK) ON DM.DistrictId=AM.DistrictId
				INNER JOIN AreaMaster ARM WITH(NOLOCK) ON ARM.AreaId=AM.AreaId
	WHERE EM.EmployeeId = @Id
END

GO

/*
EXEC [dbo].[GetReferences]  @PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@ReferenceParty='',
	@IsActive=0
	*/
ALTER PROCEDURE [dbo].[GetReferences]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@ReferenceParty VARCHAR(100)=null,
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
	SET @ReferenceParty = ISNULL(@ReferenceParty,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by ReferenceId DESC ';
		END


SET @STR = N'SELECT RM.ReferenceId,RM.UniqueNumber,RM.PartyName as ReferenceParty ,
		   AD.Address,AD.StateId,AD.RegionId,AD.DistrictId,AD.AreaId,AD.Pincode,RM.PhoneNumber,RM.MobileNumber,
				SM.StateName,RGM.RegionName,DM.DistrictName,ARM.AreaName,
		   RM.GSTNumber,RM.PanNumber,RM.EmailId,RM.IsActive
	FROM ReferenceMaster RM WITH(NOLOCK)
	INNER JOIN ReferenceAddressMapping RAM WITH(NOLOCK) ON RAM.ReferenceId = RM.ReferenceId
	INNER JOIN AddressMaster AD WITH(NOLOCK) ON Ad.AddressId=RAM.AddressId
	INNER JOIN StateMaster SM WITH(NOLOCK) ON SM.StateId=AD.StateId
	INNER JOIN RegionMaster RGM WITH(NOLOCK) ON RGM.RegionId=AD.RegionId
	INNER JOIN DistrictMaster DM WITH(NOLOCK) ON DM.DistrictId=AD.DistrictId
	INNER JOIN AreaMaster ARM WITH(NOLOCK) ON ARM.AreaId=AD.AreaId
	WHERE (@ReferenceParty='''' OR RM.PartyName like ''%''+@ReferenceParty+''%'')
		and (@IsActive IS NULL OR RM.IsActive=@IsActive)
    '+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@ReferenceParty VARCHAR(100),@IsActive BIT',
						@ReferenceParty,@IsActive

END

GO
ALTER PROCEDURE GetReferenceDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT RM.ReferenceId,RM.UniqueNumber,RM.PartyName as ReferenceParty ,
		   AD.Address,AD.StateId,AD.RegionId,AD.DistrictId,AD.AreaId,AD.Pincode,RM.PhoneNumber,RM.MobileNumber,
				SM.StateName,RGM.RegionName,DM.DistrictName,ARM.AreaName,
		   RM.GSTNumber,RM.PanNumber,RM.EmailId,RM.IsActive
	FROM ReferenceMaster RM WITH(NOLOCK)
	INNER JOIN ReferenceAddressMapping RAM WITH(NOLOCK) ON RAM.ReferenceId = RM.ReferenceId
	INNER JOIN AddressMaster AD WITH(NOLOCK) ON Ad.AddressId=RAM.AddressId
	INNER JOIN StateMaster SM WITH(NOLOCK) ON SM.StateId=AD.StateId
	INNER JOIN RegionMaster RGM WITH(NOLOCK) ON RGM.RegionId=AD.RegionId
	INNER JOIN DistrictMaster DM WITH(NOLOCK) ON DM.DistrictId=AD.DistrictId
	INNER JOIN AreaMaster ARM WITH(NOLOCK) ON ARM.AreaId=AD.AreaId
		WHERE RM.ReferenceId=@Id
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
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetVisits]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@ContactPerson VARCHAR(100)=null,
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
	SET @ContactPerson = ISNULL(@ContactPerson,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by VisitId DESC ';
		END


	SET @STR = N'SELECT EM.VisitId,EM.EmployeeId,EM.VisitDate,EM.CustomerId,EM.CustomerTypeId,EM.ContactPerson,EM.ContactNumber,
					EM.EmailId,EM.NextActionDate,EM.Latitude,EM.Longitude,VR.Remarks,EM.IsActive,
					 AD.Address,AD.StateId,AD.RegionId,AD.DistrictId,AD.AreaId,
					 SM.StateName,RGM.RegionName,DM.DistrictName,ARM.AreaName
					FROM VisitMaster EM WITH(NOLOCK)
				INNER JOIN VisitAddressMapping VAM WITH(NOLOCK) ON VAM.VisitId=EM.VisitId
				INNER JOIN AddressMaster AD WITH(NOLOCK) ON AD.AddressId=VAM.AddressId
				INNER JOIN StateMaster SM WITH(NOLOCK) ON SM.StateId=AD.StateId
				INNER JOIN RegionMaster RGM WITH(NOLOCK) ON RGM.RegionId=AD.RegionId
				INNER JOIN DistrictMaster DM WITH(NOLOCK) ON DM.DistrictId=AD.DistrictId
				INNER JOIN AreaMaster ARM WITH(NOLOCK) ON ARM.AreaId=AD.AreaId
				LEFT JOIN VisitRemarks vr WITH(NOLOCK)	ON vr.VisitId = EM.VisitId
				WHERE (@ContactPerson='''' OR EM.ContactPerson like ''%''+@ContactPerson+''%'')
				and (@IsActive IS NULL OR EM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@ContactPerson VARCHAR(100),@IsActive BIT',
						@ContactPerson,@IsActive
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetCustomers]
Description : Get Customer Detail from CustomerDetails
EXEC [dbo].[GetCustomers]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@CompanyName='',
	@IsActive=null
*/

ALTER PROCEDURE [dbo].[GetCustomers]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@CompanyName VARCHAR(100)=null,
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
	SET @CompanyName = ISNULL(@CompanyName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by CustomerId DESC ';
		END


	SET @STR = N'SELECT CD.CustomerId,CD.CompanyName,CD.LandlineNo,CD.MobileNo as MobileNumber,CD.EmailId,
					CD.CustomerTypeId,CTM.CustomerTypeName as CustomerTypeName,CD.SpecialRemarks,CD.EmployeeId,EM.EmployeeName as EmployeeName,
					CD.IsActive
					FROM CustomerDetails CD WITH(NOLOCK)
				LEFT JOIN CustomerTypeMaster CTM  WITH(NOLOCK) ON CTM.CustomerTypeId = CD.CustomerTypeId
				LEFT JOIN EmployeeMaster EM WITH(NOLOCK) ON EM.EmployeeId=CD.EmployeeId
				WHERE (@CompanyName='''' OR CompanyName like ''%''+@CompanyName+''%'')
				and (@IsActive IS NULL OR CD.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	------PRINT @STR;
	exec sp_executesql @STR,
						N'@CompanyName VARCHAR(100),@IsActive BIT',
						@CompanyName,@IsActive
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetDistricts]
Description : Get District from DistrictMaster
EXEC [dbo].[GetDistricts]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@DistrictName='',
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetDistricts]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@DistrictName VARCHAR(100)=null,
	@IsActive BIT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @STR NVARCHAR(MAX)='';

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
	SET @DistrictName = ISNULL(@DistrictName,'');

	IF @SortBy <> ''
	BEGIN
		SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
	END
	ELSE
	BEGIN
		SET @OrderByQuery='ORDER by RegionId DESC ';
	END

	SET @STR = N'SELECT D.DistrictId,D.RegionId,RM.RegionName,ST.StateName,D.DistrictName,D.IsActive
					FROM DistrictMaster D WITH(NOLOCK)
				INNER JOIN RegionMaster RM  WITH(NOLOCK) ON RM.RegionId=D.RegionId
				INNER JOIN StateMaster ST  WITH(NOLOCK) ON ST.StateId=RM.StateId
				WHERE (@DistrictName='''' OR DistrictName like ''%''+@DistrictName+''%'')
				and (@IsActive IS NULL OR D.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	------PRINT @STR;

	exec sp_executesql @STR,
						N'@DistrictName VARCHAR(100),@IsActive BIT',
						@DistrictName,@IsActive
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetAreas]
Description : Get Area from AreaMaster
EXEC [dbo].[GetAreas]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@AreaName='',
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetAreas]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@AreaName VARCHAR(100)=null,
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
	SET @AreaName = ISNULL(@AreaName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by AreaId DESC ';
		END
		

	SET @STR = N'SELECT AM.AreaId,ST.StateName, RM.RegionName, AM.DistrictId,D.DistrictName,AM.AreaName,AM.IsActive
						FROM AreaMaster AM WITH(NOLOCK)
					INNER JOIN DistrictMaster D WITH(NOLOCK) ON D.DistrictId=AM.DistrictId

					INNER JOIN RegionMaster RM  WITH(NOLOCK) ON RM.RegionId = D.RegionId

					INNER JOIN StateMaster ST  WITH(NOLOCK) ON ST.StateId=RM.StateId
				WHERE (@AreaName='''' OR AM.AreaName like ''%''+@AreaName+''%'')
				and (@IsActive IS NULL OR AM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	--PRINT @STR;

	exec sp_executesql @STR,
						N'@AreaName VARCHAR(100),@IsActive BIT',
						@AreaName,@IsActive
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
					EM.EmergencyContactNumber,EM.BloodGroup,EM.IsWebUser,Em.IsMobileUser,EM.IsActive,EM.FileOriginalName,EM.ImageUpload
				FROM EmployeeMaster EM WITH(NOLOCK)
				INNER JOIN EmployeeAddressMapping EAM WITH(NOLOCK) ON EAM.EmployeeId=EM.EmployeeId
				INNER JOIN AddressMaster AM WITH(NOLOCK) ON AM.AddressId=EAM.AddressId
				INNER JOIN RoleMaster RM WITH(NOLOCK) ON RM.RoleId=EM.RoleId
				INNER JOIN RoleMaster RM1 WITH(NOLOCK) ON RM1.RoleId=EM.ReportingTo
				INNER JOIN StateMaster SM WITH(NOLOCK) ON SM.StateId=AM.StateId
				INNER JOIN RegionMaster RGM WITH(NOLOCK) ON RGM.RegionId=AM.RegionId
				INNER JOIN DistrictMaster DM WITH(NOLOCK) ON DM.DistrictId=AM.DistrictId
				INNER JOIN AreaMaster ARM WITH(NOLOCK) ON ARM.AreaId=AM.AreaId
				WHERE (@EmployeeName='''' OR EM.EmployeeName like ''%''+@EmployeeName+''%'')
					AND (@IsActive IS NULL OR EM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	------PRINT @STR;

	exec sp_executesql @STR,
						N'@EmployeeName VARCHAR(100),@IsActive BIT',
						@EmployeeName,@IsActive
END

GO

