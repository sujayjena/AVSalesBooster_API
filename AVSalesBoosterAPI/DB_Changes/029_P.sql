If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='CollectionMaster' And Column_Name='CollectionNameId')
Begin
	Alter Table CollectionMaster
	Add CollectionNameId VarChar(100)
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='CollectionMaster' And Column_Name='CollectionNameId')
Begin
	Update CollectionMaster Set CollectionNameId='' Where CollectionNameId Is Null
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='CollectionMaster' And Column_Name='CollectionNameId')
Begin
	Alter Table CollectionMaster
	Alter Column CollectionNameId VarChar(100) Not Null
End

GO

/*
	Exec SaveCollectionDetails
		@CollectionId		= 0,
		@CollectionName		= 'Test',
		@CollectionNameId	= 'Test_1',
		@IsActive			= 1,
		@LoggedInUserId		= 1
	
	Select * From CollectionMaster
*/
Alter Procedure SaveCollectionDetails
	@CollectionId		Int,
	@CollectionName		VarChar(100),
	@CollectionNameId	VarChar(100),
	@IsActive			Bit,
	@LoggedInUserId		BigInt
As
Begin
	Set NoCount On;

	Declare @Result Int = 0;
	Declare @CodeExists Int = -5;
	Declare @NameExists Int = -2;
	Declare @NoRecordExists Int = -1;

	If (
		(@CollectionId = 0 And Exists(Select Top 1 1 From CollectionMaster With(NoLock) Where CollectionName=@CollectionName))
		Or
		(@CollectionId > 0 And Exists(Select Top 1 1 From CollectionMaster With(NoLock) Where CollectionName=@CollectionName And CollectionId <> @CollectionId))
	)
	Begin
		Set @Result = @NameExists;
	End
	If (
		(@CollectionId = 0 And Exists(Select Top 1 1 From CollectionMaster With(NoLock) Where CollectionNameId=@CollectionNameId))
		Or
		(@CollectionId > 0 And Exists(Select Top 1 1 From CollectionMaster With(NoLock) Where CollectionNameId=@CollectionNameId And CollectionId <> @CollectionId))
	)
	Begin
		Set @Result = @CodeExists;
	End
	Else If @CollectionId > 0 And Not Exists(Select Top 1 1 From CollectionMaster With(NoLock) Where CollectionId = @CollectionId)
	Begin
		Set @Result = @NoRecordExists;
	End
	Else If @CollectionId = 0
	Begin
		Insert Into CollectionMaster
		(
			CollectionName, CollectionNameId, IsActive, CreatedBy, CreatedOn
		)
		Values
		(
			@CollectionName, @CollectionNameId, @IsActive, @LoggedInUserId, GetDate()
		)

		SET @Result = SCOPE_IDENTITY();
	End
	Else If @CollectionId > 0
	Begin
		Update CollectionMaster
		Set CollectionName = @CollectionName,
			CollectionNameId = @CollectionNameId,
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
Alter Procedure GetCollectionDetailsById
	@CollectionId	Int
As
Begin
	Set NoCount On;

	Select
		CollectionId,
		CollectionName,
		CollectionNameId,
		IsActive
	From CollectionMaster With(NoLock)
	Where CollectionId = @CollectionId
End

GO

/*
	Exec GetCollectionsList
		@PageNo			= 1,
		@PageSize		= 10,
		@SortBy			= 'CollectionId',
		@OrderBy		= '',
		@CollectionName	= '',
		@IsActive		= 1
*/
Alter Procedure GetCollectionsList
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
					CM.CollectionNameId,
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

If OBJECT_ID('DesignMaster') Is Not Null
Begin
	Drop Table DesignMaster
END

GO

If OBJECT_ID('DesignMaster') Is Null
Begin
	Create Table DesignMaster
	(
		DesignId			BIGINT IDENTITY(1,1) PRIMARY KEY,
		CollectionId		Int	FOREIGN KEY REFERENCES CollectionMaster(CollectionId),
		CollectionNameId	Int	FOREIGN KEY REFERENCES CollectionMaster(CollectionId),
		DesignCode			VARCHAR(100) NOT NULL,
		SizeId				BIGINT FOREIGN KEY REFERENCES SizeMaster(SizeId),
		SeriesId			BIGINT FOREIGN KEY REFERENCES SeriesMaster(SeriesId),
		BaseDesignId		BIGINT FOREIGN KEY REFERENCES BaseDesignMaster(BaseDesignId),
		IsActive			BIT NOT NULL,
		CreatedBy			BIGINT NOT NULL,
		CreatedOn			DATETIME NOT NULL,
		ModifiedBy			BIGINT,
		ModifiedOn			DATETIME
	)
End

GO

If Object_Id('DesignMasterImages') Is Null
Begin
	Create Table DesignMasterImages
	(
		DesignImageId		BigInt Primary Key Identity(1,1),
		DesignId			BigInt Not Null References DesignMaster(DesignId),
		UploadedFilesName	VarChar(500) Not Null,
		SavedFilesName		VarChar(500) Not Null,
		IsDeleted			BIT			 Not Null,
		ModifiedBy			BIGINT,
		ModifiedOn			DATETIME
	)
End

GO

/*
	Version: 1.0
	Created Date: 03 JULY 2023
	Execution: EXEC [dbo].[SaveDesignDetails]
	Description: Insert Design from DesignMaster
*/
Alter Procedure SaveDesignDetails
(
	@DesignId				BigInt,
	@CollectionId			Int,
	@CollectionNameId		Int,
	@DesignCode				VarChar(100),
	@SizeId					BigInt,
	@SeriesId				BigInt,
	@BaseDesignId			BigInt,
	@IsActive				BIT,
	@XmlDesignImagesData	XML,
	@DesignImagesIdToDelete	VarChar(200),
	@LoggedInUserId			BIGINT
)
As
Begin
	Set NoCount On;

	Declare @Result			BigInt = 0;
	Declare @CodeExists		BigInt = -5;
	Declare @IsNameExists	BigInt = -2;
	Declare @NoRecordExists BigInt = -1;

	Declare @TempDesignImages Table
	(
		DesignImageId		BigInt,
		UploadedFilesName	VarChar(500),
		SavedFilesName		VarChar(500)
	)

	Insert Into @TempDesignImages
	(
		DesignImageId,UploadedFilesName,SavedFilesName
	)
	Select
		DesignImageId		= T.Item.value('DesignImageId[1]', 'BIGINT'),
		UploadedFilesName	= T.Item.value('UploadedFilesName[1]', 'varchar(500)'),
		SavedFilesName		= T.Item.value('SavedFilesName[1]', 'varchar(500)')
	From @XmlDesignImagesData.nodes('/ArrayOfDesignMasterImages/DesignMasterImages') As T(Item)

	If (
		(@DesignId=0 AND 
			EXISTS
			(
				Select Top 1 1 
				From DesignMaster With(NoLock)
				Where DesignCode=@DesignCode
			)
		)
		Or
		(@DesignId>0 And 
			Exists
			(
				Select Top 1 1 
				From DesignMaster With(NoLock)
				Where DesignCode = @DesignCode
					And DesignId <> @DesignId
			)
		))
	Begin
		Set @Result = @CodeExists;
	End
	Else If (
		(@DesignId = 0 And 
			Exists
			(
				Select Top 1 1 
				From DesignMaster With(NoLock)
				Where SizeId = @SizeId
					And SeriesId = @SeriesId
					And BaseDesignId = @BaseDesignId
			)
		)
		Or
		(@DesignId > 0 And
			Exists
			(
				Select Top 1 1 
				From DesignMaster With(NoLock)
				Where SizeId = @SizeId
						And SeriesId = @SeriesId
						And BaseDesignId = @BaseDesignId
						And DesignId <> @DesignId
			)
		))
	Begin
		Set @Result = @IsNameExists;
	End
	Else
	Begin
		If @DesignId = 0
		Begin
			Insert Into DesignMaster
			(
				CollectionId,CollectionNameId,DesignCode,SizeId,SeriesId,BaseDesignId,IsActive,CreatedBy,CreatedOn
			)
			Values
			(
				@CollectionId,@CollectionNameId,@DesignCode,@SizeId,@SeriesId,@BaseDesignId,@IsActive,@LoggedInUserId,GetDate()
			)

			Set @Result = SCOPE_IDENTITY();
		End
		Else If (@DesignId> 0 and EXISTS(SELECT TOP 1 1 FROM DesignMaster WHERE DesignId=@DesignId))
		Begin
			Update DesignMaster
			Set CollectionId		= @CollectionId,
				CollectionNameId	= @CollectionNameId,
				DesignCode			= @DesignCode,
				SizeId				= @SizeId,
				SeriesId			= @SeriesId,
				BaseDesignId		= @BaseDesignId,
				IsActive			= @IsActive,
				ModifiedBy			= @LoggedInUserId,
				ModifiedOn			= GetDate()
			Where DesignId = @DesignId;
			
			Set @Result = @DesignId;

			-- To mark images as deleted
			Update DesignMasterImages
			Set IsDeleted = 1,
				ModifiedBy = @LoggedInUserId,
				ModifiedOn = GetDate()
			Where DesignId = @Result And DesignImageId In(Select [value] from string_split(@DesignImagesIdToDelete,','))
		End
		Else
		Begin
			Set @Result=@NoRecordExists
		End
	End

	-- To store Uploaded Design Images
	If @Result > 0
	Begin
		Insert Into DesignMasterImages
		(
			DesignId,UploadedFilesName,SavedFilesName,IsDeleted,ModifiedBy,ModifiedOn
		)
		Select
			@Result,UploadedFilesName,SavedFilesName,0,@LoggedInUserId,GetDate()
		From @TempDesignImages
	End

	Select @Result As Result;
End

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
Alter Procedure GetDesignes
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

	DECLARE @STR NVARCHAR(MAX);
	DECLARE @Offset INT, @RowCount INT;
	DECLARE @OrderSortByConcate VARCHAR(100);
	DECLARE @OrderByQuery VARCHAR(1000)='';
	DECLARE @PaginationQuery VARCHAR(100)='';

	If @PageSize>0
	Begin
		Set @Offset = (@PageNo - 1) * @PageSize;
		Set @RowCount = @PageSize * @PageNo;
		Set @PaginationQuery='OFFSET '+CAST(@Offset as VARCHAR(5))+'  ROWS
								 FETCH NEXT '+CAST(@RowCount as VARCHAR(5))+' ROWS ONLY';
	End
	
	Set @OrderSortByConcate= @SortBy + ' ' + @OrderBy;
	Set @DesignName = ISNULL(@DesignName,'');

	IF @SortBy <> ''
	BEGIN
		SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
	END
	ELSE
	BEGIN
		SET @OrderByQuery='ORDER by DesignId DESC ';
	END

	SET @STR = N'SELECT
					DesignId
					,DM.CollectionId
					,CName.CollectionName
					,DM.CollectionNameId
					,CNameId.CollectionNameId As CollectionNameIdValue
					,DM.DesignCode
					,DM.SizeId
					,SM.SizeName
					,DM.SeriesId
					,Series.SeriesName
					,DM.BaseDesignId
					,BDM.BaseDesignName
					,DM.IsActive
					,DM.CreatedBy
					,EM.EmployeeName As CreatorName
					,DM.CreatedOn
				From DesignMaster DM WITH(NOLOCK)
				Inner Join Users U  WITH(NOLOCK)
					On U.UserId = DM.CreatedBy
				Inner Join EmployeeMaster EM With(NoLock)
					On EM.EmployeeId = U.EmployeeID
				Left Join CollectionMaster CName With(NoLock)
					On CName.CollectionId = DM.CollectionId
				Left Join CollectionMaster CNameId With(NoLock)
					On CNameId.CollectionId = DM.CollectionNameId
				Left Join SizeMaster  SM WITH(NOLOCK)
					On SM.SizeId=DM.SizeId
				Left Join SeriesMaster Series WITH(NOLOCK)
					On Series.SeriesId = DM.SeriesId
				Left Join BaseDesignMaster BDM WITH(NOLOCK)
					On BDM.BaseDesignId=DM.BaseDesignId
				WHERE (@DesignName='''' OR BDM.BaseDesignName like ''%''+@DesignName+''%'')
					And (@IsActive IS NULL OR DM.IsActive = @IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	------PRINT @STR;

	Exec sp_executesql @STR,
		N'@DesignName VARCHAR(100),@IsActive BIT',
		@DesignName,@IsActive
END

GO

-- GetDesignDetailsById 7
Alter Procedure GetDesignDetailsById
	@Id BIGINT
AS
BEGIN
	Set NoCount On;

    Select
		DesignId
		,DM.CollectionId
		,CName.CollectionName
		,DM.CollectionNameId
		,CNameId.CollectionNameId As CollectionNameIdValue
		,DM.DesignCode
		,DM.SizeId
		,SM.SizeName
		,DM.SeriesId
		,Series.SeriesName
		,DM.BaseDesignId
		,BDM.BaseDesignName
		,DM.IsActive
		,DM.CreatedBy
		,EM.EmployeeName As CreatorName
		,DM.CreatedOn
	From DesignMaster DM WITH(NOLOCK)
	Inner Join Users U  WITH(NOLOCK)
		On U.UserId = DM.CreatedBy
	Inner Join EmployeeMaster EM With(NoLock)
		On EM.EmployeeId = U.EmployeeID
	Left Join CollectionMaster CName With(NoLock)
		On CName.CollectionId = DM.CollectionId
	Left Join CollectionMaster CNameId With(NoLock)
		On CNameId.CollectionId = DM.CollectionNameId
	Left Join SizeMaster  SM WITH(NOLOCK)
		On SM.SizeId=DM.SizeId
	Left Join SeriesMaster Series WITH(NOLOCK)
		On Series.SeriesId = DM.SeriesId
	Left Join BaseDesignMaster BDM WITH(NOLOCK)
		On BDM.BaseDesignId=DM.BaseDesignId
	WHERE DM.DesignId=@Id
END

GO

-- GetDesignImagesList 7
Create Or Alter Procedure GetDesignImagesList
	@DesignId	BigInt
As
Begin
	Set NoCount On;

	Select
		DesignImageId
		,DesignId
		,UploadedFilesName
		,SavedFilesName
	From DesignMasterImages With(NoLock)
	Where DesignId = @DesignId
		And IsDeleted = 0
End

GO

