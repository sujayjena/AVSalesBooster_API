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
		   RM.GSTNumber,RM.PanNumber,RM.EmailId,RM.IsActive
	FROM ReferenceMaster RM WITH(NOLOCK)
	INNER JOIN ReferenceAddressMapping RAM WITH(NOLOCK) ON RAM.ReferenceId = RM.ReferenceId
	INNER JOIN AddressMaster AD WITH(NOLOCK) ON Ad.AddressId=RAM.AddressId
	WHERE (@ReferenceParty='''' OR RM.PartyName like ''%''+@ReferenceParty+''%'')
		and (@IsActive IS NULL OR RM.IsActive=@IsActive)
    '+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@ReferenceParty VARCHAR(100),@IsActive BIT',
						@ReferenceParty,@IsActive

END

GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetProducts]
Description : Get Product from ProductMaster
EXEC [dbo].[GetProducts]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@ProductName='',
	@IsActive=NULL
*/
ALTER PROCEDURE [dbo].[GetProducts]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@ProductName VARCHAR(100)=null,
	@IsActive BIT
)
AS
BEGIN

 SET NOCOUNT ON;

DECLARE @STR NVARCHAR(MAX)

--DECLARE @ID INT=1;


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
	SET @ProductName = ISNULL(@ProductName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by ProductId DESC ';
		END


	SET @STR = N'SELECT ProductId,ProductName,IsActive
			FROM ProductMaster WITH(NOLOCK)
				WHERE (@ProductName='''' OR ProductName like ''%''+@ProductName+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@ProductName VARCHAR(100),@IsActive BIT',
						@ProductName,@IsActive
END

GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetBrands]
Description : Get Brand from BrandMaster
EXEC [dbo].[GetBrands]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@BrandName='',
	@IsActive=NULL
*/
ALTER PROCEDURE [dbo].[GetBrands]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@BrandName VARCHAR(100)=null,
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
	SET @BrandName = ISNULL(@BrandName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by BrandId DESC ';
		END


	SET @STR = N'SELECT BrandId,BrandName,IsActive
					FROM BrandMaster WITH(NOLOCK)
				WHERE (@BrandName='''' OR BrandName like ''%''+@BrandName+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@BrandName VARCHAR(100),@IsActive BIT',
						@BrandName,@IsActive
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetCategories]
Description : Get Category from CategoryMaster
EXEC [dbo].[GetCategorys]  
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


	SET @STR = N'SELECT CategoryId,CategoryName,IsActive
				FROM CategoryMaster WITH(NOLOCK)
				WHERE (@CategoryName='''' OR CategoryName like ''%''+@CategoryName+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@CategoryName VARCHAR(100),@IsActive BIT',
						@CategoryName,@IsActive
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


	SET @STR = N'SELECT SizeId,SizeName,IsActive
				FROM SizeMaster WITH(NOLOCK)
				WHERE (@SizeName='''' OR SizeName like ''%''+@SizeName+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@SizeName VARCHAR(100),@IsActive BIT',
						@SizeName,@IsActive
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetDesignTypes]
Description : Get DesignType from DesignTypeMaster
EXEC [dbo].[GetDesignTypes]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@DesignTypeName='',
	@IsActive=NULL
*/
ALTER PROCEDURE [dbo].[GetDesignTypes]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@DesignTypeName VARCHAR(100)=null,
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
	SET @DesignTypeName = ISNULL(@DesignTypeName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by DesignTypeId DESC ';
		END


	SET @STR = N'SELECT DesignTypeId,DesignTypeName,IsActive
				     FROM DesignTypeMaster WITH(NOLOCK)
				WHERE (@DesignTypeName='''' OR DesignTypeName like ''%''+@DesignTypeName+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@DesignTypeName VARCHAR(100),@IsActive BIT',
						@DesignTypeName,@IsActive
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


	SET @STR = N'SELECT SeriesId,SeriesName,IsActive
					FROM SeriesMaster WITH(NOLOCK)
				WHERE (@SeriesName='''' OR SeriesName like ''%''+@SeriesName+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@SeriesName VARCHAR(100),@IsActive BIT',
						@SeriesName,@IsActive
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


	SET @STR = N'SELECT BaseDesignId,BaseDesignName,IsActive
					FROM BaseDesignMaster WITH(NOLOCK)
				WHERE (@BaseDesignName='''' OR BaseDesignName like ''%''+@BaseDesignName+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@BaseDesignName VARCHAR(100),@IsActive BIT',
						@BaseDesignName,@IsActive
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetCustomerTypes]
Description : Get CustomerType from CustomTypeMaster
EXEC [dbo].[GetCustomerTypes]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@CustomerTypeName='',
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetCustomerTypes]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@CustomerTypeName VARCHAR(100)=null,
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
	SET @CustomerTypeName = ISNULL(@CustomerTypeName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by CustomerTypeId DESC ';
		END


	SET @STR = N'SELECT CustomerTypeId,CustomerTypeName,IsActive
					FROM CustomerTypeMaster WITH(NOLOCK)
				WHERE (@CustomerTypeName='''' OR CustomerTypeName like ''%''+@CustomerTypeName+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@CustomerTypeName VARCHAR(100),@IsActive BIT',
						@CustomerTypeName,@IsActive
END

GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetLeaveTypes]
Description : Get LeaveType from LeaveTypeMaster
EXEC [dbo].[GetLeaveTypes]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@LeaveTypeName='',
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetLeaveTypes]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@LeaveTypeName VARCHAR(100)=null,
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
	SET @LeaveTypeName = ISNULL(@LeaveTypeName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by LeaveTypeId DESC ';
		END


	SET @STR = N'SELECT LeaveTypeId,LeaveTypeName,IsActive
					FROM LeaveTypeMaster WITH(NOLOCK)
				WHERE (@LeaveTypeName='''' OR LeaveTypeName like ''%''+@LeaveTypeName+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@LeaveTypeName VARCHAR(100),@IsActive BIT',
						@LeaveTypeName,@IsActive
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


	SET @STR = N'SELECT LeaveId,StartDate,EndDate,EmployeeName,LeaveTypeId,Remark,Reason,IsActive
					FROM LeaveMaster WITH(NOLOCK)
				WHERE (@EmployeeName='''' OR EmployeeName like ''%''+@EmployeeName+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@EmployeeName VARCHAR(100),@IsActive BIT',
						@EmployeeName,@IsActive
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


	SET @STR = N'SELECT DesignId,ProductId,BrandId,SizeId,CategoryId,SeriesId,DesignTypeId
						BaseDesignId,DesignName,DesignCode,IsActive
						FROM DesignMaster WITH(NOLOCK)
				WHERE (@DesignName='''' OR DesignName like ''%''+@DesignName+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@DesignName VARCHAR(100),@IsActive BIT',
						@DesignName,@IsActive
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetStates]
Description : Get State from StateMaster
EXEC [dbo].[GetStates]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@StateName='',
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetStates]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@StateName VARCHAR(100)=null,
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
	SET @StateName = ISNULL(@StateName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by StateId DESC ';
		END


	SET @STR = N'SELECT StateId,StateName,IsActive
					FROM StateMaster WITH(NOLOCK)
				WHERE (@StateName='''' OR StateName like ''%''+@StateName+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@StateName VARCHAR(100),@IsActive BIT',
						@StateName,@IsActive
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


	SET @STR = N'SELECT RegionId,StateId,RegionName,IsActive
					FROM RegionMaster WITH(NOLOCK)
				WHERE (@RegionName='''' OR RegionName like ''%''+@RegionName+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@RegionName VARCHAR(100),@IsActive BIT',
						@RegionName,@IsActive
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


	SET @STR = N'SELECT DistrictId,RegionId,DistrictName,IsActive
					FROM DistrictMaster WITH(NOLOCK)
				WHERE (@DistrictName='''' OR DistrictName like ''%''+@DistrictName+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
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


	SET @STR = N'SELECT AreaId,DistrictId,AreaName,IsActive
						FROM AreaMaster WITH(NOLOCK)
				WHERE (@AreaName='''' OR AreaName like ''%''+@AreaName+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@AreaName VARCHAR(100),@IsActive BIT',
						@AreaName,@IsActive
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
					CD.CustomerTypeId,CD.SpecialRemarks,CD.EmployeeId
					FROM CustomerDetails CD WITH(NOLOCK)
				WHERE (@CompanyName='''' OR CompanyName like ''%''+@CompanyName+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@CompanyName VARCHAR(100),@IsActive BIT',
						@CompanyName,@IsActive
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetRoles]
Description : Get Role from RoleMaster
EXEC [dbo].[GetRoles]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@RoleName='',
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetRoles]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@RoleName VARCHAR(100)=null,
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
	SET @RoleName = ISNULL(@RoleName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by RoleId DESC ';
		END


	SET @STR = N'SELECT RoleId,RoleName,IsActive
					FROM RoleMaster WITH(NOLOCK)
				WHERE (@RoleName='''' OR RoleName like ''%''+@RoleName+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@RoleName VARCHAR(100),@IsActive BIT',
						@RoleName,@IsActive
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


	SET @STR = N'SELECT Id,RoleId,ReportingTo,IsActive
					FROM ReportingToMaster WITH(NOLOCK)
				WHERE (@ReportingTo=0 OR ReportingTo =@ReportingTo)
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@ReportingTo VARCHAR(100),@IsActive BIT',
						@ReportingTo,@IsActive
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


	SET @STR = N'SELECT EM.EmployeeId,EM.EmployeeName,EM.EmployeeCode,EM.EmailId,EM.MobileNumber,EM.RoleId,EM.ReportingTo,
				 EM.DateOfBirth,EM.DateOfJoining,
				 EM.EmergencyContactNumber,EM.BloodGroup,EM.IsWebUser,Em.IsMobileUser,EM.IsActive,EM.FileOriginalName,EM.ImageUpload
				FROM EmployeeMaster EM WITH(NOLOCK)
				WHERE (@EmployeeName='''' OR EmployeeName like ''%''+@EmployeeName+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
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
					EM.EmailId,EM.NextActionDate,EM.Latitude,EM.Longitude,EM.Remarks,EM.IsActive
					FROM VisitMaster EM WITH(NOLOCK)
				WHERE (@ContactPerson='''' OR ContactPerson like ''%''+@ContactPerson+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
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
Execution : EXEC [dbo].[SaveVisitDetails] 
Description : Insert Visit Detail from VisitMaster
*/
ALTER PROCEDURE [dbo].[SaveVisitDetails]
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
	@Remarks VARCHAR(500),
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
			Insert into VisitMaster(EmployeeId,VisitDate,CustomerId,CustomerTypeId,ContactPerson,ContactNumber,EmailId,NextActionDate,
									Latitude,Longitude,Remarks,IsActive,CreatedBy,CreatedOn)
			Values(@EmployeeId,@VisitDate,@CustomerId,@CustomerTypeId,@ContactPerson,@ContactNumber,@EmailId,@NextActionDate,
									@Latitude,@Longitude,@Remarks,@IsActive,@LoggedInUserId,GETDATE())

			SET @Result = SCOPE_IDENTITY();
			
			-- Insert Into Address 
			INSERT INTO AddressMaster(Address,StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn)
			Values (@Address,@StateId,@RegionId,@DistrictId,@AreaId,0,0,@IsActive,@LoggedInUserId,GETDATE())

			SET @AddressId = SCOPE_IDENTITY();

			INSERT INTO VisitAddressMapping(VisitId,AddressId)
			Values (@Result,@AddressId)
		
		END
		ELSE IF(@VisitId> 0 and EXISTS(SELECT TOP 1 1 FROM VisitMaster WHERE VisitId=@VisitId))
		BEGIN
			UPDATE VisitMaster
			SET EmployeeId=@EmployeeId,VisitDate=@VisitDate,CustomerId=@CustomerId,CustomerTypeId=@CustomerTypeId,ContactPerson=@ContactPerson,
									ContactNumber=@ContactNumber,EmailId=@EmailId,NextActionDate=@NextActionDate,
									Latitude=@Latitude,Longitude=@Longitude,Remarks=@Remarks,
						IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE VisitId=@VisitId

			UPDATE AD
			SET Address=@Address,StateId=@StateId,RegionId=@RegionId,DistrictId=@DistrictId,AreaId=@AreaId
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

Drop Procedure If Exists SaveBaseDesignDetails
GO

-- EXEC SaveBaseDesignDetails 3,'TEST DEMO',1
CREATE Or Alter ProcedureSaveBaseDesignDetails
(
	@BaseDesignId BIGINT,
	@BaseDesignName VARCHAR(100),
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
		(@BaseDesignId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM BaseDesignMaster WITH(NOLOCK) 
				WHERE  BaseDesignName=@BaseDesignName
			)
		)
		OR
		(@BaseDesignId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM BaseDesignMaster WITH(NOLOCK) 
				WHERE  BaseDesignName=@BaseDesignName and BaseDesignId<>@BaseDesignId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@BaseDesignId=0)
		BEGIN
			Insert into BaseDesignMaster(BaseDesignName, IsActive,CreatedBy,CreatedOn)
			Values(@BaseDesignName, @IsActive,@LoggedInUserId,GETDATE())
			SET @Result = SCOPE_IDENTITY();
		END
		ELSE IF(@BaseDesignId> 0 and EXISTS(SELECT TOP 1 1 FROM BaseDesignMaster WHERE BaseDesignId=@BaseDesignId))
		BEGIN
			UPDATE BaseDesignMaster
			SET BaseDesignName=@BaseDesignName,IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE BaseDesignId=@BaseDesignId
			SET @Result = @BaseDesignId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result 
END
