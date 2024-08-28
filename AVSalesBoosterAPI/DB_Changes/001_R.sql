Drop Procedure If Exists GetBrands;

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetBrands]
Description : Get Brands List from BrandMaster
*/
CREATE Or Alter Procedure[dbo].[GetBrands]
AS
BEGIN
	SELECT BrandId,BrandName,IsActive
	FROM BrandMaster WITH(NOLOCK)
END

GO

Drop Procedure If Exists SaveBrandDetails;

GO

-- EXEC SaveBrandDetails 3,'TEST DEMO',1
CREATE Or Alter ProcedureSaveBrandDetails
(
	@BrandId BIGINT,
	@BrandName VARCHAR(100),
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
		(@BrandId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM BrandMaster WITH(NOLOCK) 
				WHERE  BrandName=@BrandName
			)
		)
		OR
		(@BrandId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM BrandMaster WITH(NOLOCK) 
				WHERE  BrandName=@BrandName and BrandId<>@BrandId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@BrandId=0)
		BEGIN
			Insert into BrandMaster(BrandName, IsActive,CreatedBy,CreatedOn)
			Values(@BrandName, @IsActive,@LoggedInUserId,GETDATE())
			SET @Result = SCOPE_IDENTITY();
		END
		ELSE IF(@BrandId> 0 and EXISTS(SELECT TOP 1 1 FROM BrandMaster WHERE BrandId=@BrandId))
		BEGIN
			UPDATE BrandMaster
			SET BrandName=@BrandName,IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE BrandId=@BrandId
			SET @Result = @BrandId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result 
END


GO

-- Category
Drop Procedure If Exists GetCategories;

GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetCategories]
Description : Get Brand from BrandMaster
*/
CREATE Or Alter Procedure[dbo].[GetCategories]
AS
BEGIN
	SELECT CategoryId,CategoryName,IsActive
	FROM CategoryMaster WITH(NOLOCK)
END


GO

Drop Procedure If Exists SaveCategoryDetails;

GO
-- EXEC SaveCategoryDetails 3,'TEST DEMO',1
CREATE Or Alter ProcedureSaveCategoryDetails
(
	@CategoryId BIGINT,
	@CategoryName VARCHAR(100),
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
		(@CategoryId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM CategoryMaster WITH(NOLOCK) 
				WHERE  CategoryName=@CategoryName
			)
		)
		OR
		(@CategoryId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM CategoryMaster WITH(NOLOCK) 
				WHERE  CategoryName=@CategoryName and CategoryId<>@CategoryId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@CategoryId=0)
		BEGIN
			Insert into CategoryMaster(CategoryName, IsActive,CreatedBy,CreatedOn)
			Values(@CategoryName, @IsActive,@LoggedInUserId,GETDATE())
			SET @Result = SCOPE_IDENTITY();
		END
		ELSE IF(@CategoryId> 0 and EXISTS(SELECT TOP 1 1 FROM CategoryMaster WHERE CategoryId=@CategoryId))
		BEGIN
			UPDATE CategoryMaster
			SET CategoryName=@CategoryName,IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE CategoryId=@CategoryId
			SET @Result = @CategoryId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result 
END

GO

-- Size Script
Drop Procedure If Exists GetSizes;

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetSizes]
Description : Get Size from SizeMaster
*/
CREATE Or Alter Procedure[dbo].[GetSizes]
AS
BEGIN
	SELECT SizeId,SizeName,IsActive
	FROM SizeMaster WITH(NOLOCK)
END;

GO
Drop Procedure If Exists SaveSizeDetails
GO
-- EXEC SaveSizeDetails 3,'TEST DEMO',1
;CREATE Or Alter ProcedureSaveSizeDetails
(
	@SizeId BIGINT,
	@SizeName VARCHAR(100),
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
		(@SizeId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM SizeMaster WITH(NOLOCK) 
				WHERE  SizeName=@SizeName
			)
		)
		OR
		(@SizeId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM SizeMaster WITH(NOLOCK) 
				WHERE  SizeName=@SizeName and SizeId<>@SizeId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@SizeId=0)
		BEGIN
			Insert into SizeMaster(SizeName, IsActive,CreatedBy,CreatedOn)
			Values(@SizeName, @IsActive,@LoggedInUserId,GETDATE())
			SET @Result = SCOPE_IDENTITY();
		END
		ELSE IF(@SizeId> 0 and EXISTS(SELECT TOP 1 1 FROM SizeMaster WHERE SizeId=@SizeId))
		BEGIN
			UPDATE SizeMaster
			SET SizeName=@SizeName,IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE SizeId=@SizeId
			SET @Result = @SizeId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result 
END

GO

-- Design Type Script
Drop Procedure If Exists GetDesignTypes;

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetDesignTypes]
Description : Get DesignType from DesignTypeMaster
*/
CREATE Or Alter Procedure[dbo].[GetDesignTypes]
AS
BEGIN
	SELECT DesignTypeId,DesignTypeName,IsActive
	FROM DesignTypeMaster WITH(NOLOCK)
END;

GO
Drop Procedure If Exists SaveDesignTypeDetails
GO
-- EXEC SaveDesignTypeDetails 3,'TEST DEMO',1
;CREATE Or Alter ProcedureSaveDesignTypeDetails
(
	@DesignTypeId BIGINT,
	@DesignTypeName VARCHAR(100),
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
		(@DesignTypeId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM DesignTypeMaster WITH(NOLOCK) 
				WHERE  DesignTypeName=@DesignTypeName
			)
		)
		OR
		(@DesignTypeId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM DesignTypeMaster WITH(NOLOCK) 
				WHERE  DesignTypeName=@DesignTypeName and DesignTypeId<>@DesignTypeId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@DesignTypeId=0)
		BEGIN
			Insert into DesignTypeMaster(DesignTypeName, IsActive,CreatedBy,CreatedOn)
			Values(@DesignTypeName, @IsActive,@LoggedInUserId,GETDATE())
			SET @Result = SCOPE_IDENTITY();
		END
		ELSE IF(@DesignTypeId> 0 and EXISTS(SELECT TOP 1 1 FROM DesignTypeMaster WHERE DesignTypeId=@DesignTypeId))
		BEGIN
			UPDATE DesignTypeMaster
			SET DesignTypeName=@DesignTypeName,IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE DesignTypeId=@DesignTypeId
			SET @Result = @DesignTypeId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result 
END

GO
-- Series MAster Script

Drop Procedure If Exists GetSeriess
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetSeriess]
Description : Get Series from SeriesMaster
*/
;CREATE Or Alter Procedure[dbo].[GetSeriess]
AS
BEGIN
	SELECT SeriesId,SeriesName,IsActive
	FROM SeriesMaster WITH(NOLOCK)
END;

GO
Drop Procedure If Exists SaveSeriesDetails
GO
-- EXEC SaveSeriesDetails 3,'TEST DEMO',1
;CREATE Or Alter ProcedureSaveSeriesDetails
(
	@SeriesId BIGINT,
	@SeriesName VARCHAR(100),
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
		(@SeriesId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM SeriesMaster WITH(NOLOCK) 
				WHERE  SeriesName=@SeriesName
			)
		)
		OR
		(@SeriesId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM SeriesMaster WITH(NOLOCK) 
				WHERE  SeriesName=@SeriesName and SeriesId<>@SeriesId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@SeriesId=0)
		BEGIN
			Insert into SeriesMaster(SeriesName, IsActive,CreatedBy,CreatedOn)
			Values(@SeriesName, @IsActive,@LoggedInUserId,GETDATE())
			SET @Result = SCOPE_IDENTITY();
		END
		ELSE IF(@SeriesId> 0 and EXISTS(SELECT TOP 1 1 FROM SeriesMaster WHERE SeriesId=@SeriesId))
		BEGIN
			UPDATE SeriesMaster
			SET SeriesName=@SeriesName,IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE SeriesId=@SeriesId
			SET @Result = @SeriesId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result 
END

GO

-- Base Design Script

CREATE TABLE BaseDesignMaster
(
BaseDesignId BIGINT IDENTITY(1,1) PRIMARY KEY,
BaseDesignName VARCHAR(100),
IsActive BIT,
CreatedBy BIGINT,
CreatedOn DATETIME,
ModifiedBy BIGINT,
ModifiedOn DATETIME
) 

GO

Drop Procedure If Exists GetBaseDesigns;

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetBaseDesigns]
Description : Get BaseDesign from BaseDesignMaster
*/
CREATE Or Alter Procedure[dbo].[GetBaseDesigns]
AS
BEGIN
	SELECT BaseDesignId,BaseDesignName,IsActive
	FROM BaseDesignMaster WITH(NOLOCK)
END;

GO

Drop Procedure If Exists SaveBaseDesignDetails;

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

GO

-- Custom Type Script

Drop Procedure If Exists GetCustomTypes;

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetCustomTypes]
Description : Get CustomType from CustomerTypeMaster
*/
CREATE Or Alter Procedure[dbo].[GetCustomTypes]
AS
BEGIN
	SELECT CustomerTypeId,CustomerTypeName,IsActive
	FROM CustomerTypeMaster WITH(NOLOCK)
END

GO

Drop Procedure If Exists SaveCustomTypeDetails;

GO

-- EXEC SaveCustomTypeDetails 3,'TEST DEMO',1
CREATE Or Alter ProcedureSaveCustomTypeDetails
(
	@CustomTypeId BIGINT,
	@CustomTypeName VARCHAR(100),
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
		(@CustomTypeId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM CustomerTypeMaster WITH(NOLOCK) 
				WHERE  CustomerTypeName=@CustomTypeName
			)
		)
		OR
		(@CustomTypeId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM CustomerTypeMaster WITH(NOLOCK) 
				WHERE  CustomerTypeName=@CustomTypeName and CustomerTypeId<>@CustomTypeId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@CustomTypeId=0)
		BEGIN
			Insert into CustomerTypeMaster(CustomerTypeName, IsActive,CreatedBy,CreatedOn)
			Values(@CustomTypeName, @IsActive,@LoggedInUserId,GETDATE())
			SET @Result = SCOPE_IDENTITY();
		END
		ELSE IF(@CustomTypeId> 0 and EXISTS(SELECT TOP 1 1 FROM CustomerTypeMaster WHERE CustomerTypeId=@CustomTypeId))
		BEGIN
			UPDATE CustomerTypeMaster
			SET CustomerTypeName=@CustomTypeName,IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE CustomerTypeId=@CustomTypeId
			SET @Result = @CustomTypeId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result 
END

GO

-- Leave Type 
Drop Procedure If Exists GetLeaveTypes;

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetLeaveTypes]
Description : Get LeaveType from LeaveTypeMaster
*/
CREATE Or Alter Procedure[dbo].[GetLeaveTypes]
AS
BEGIN
	SELECT LeaveTypeId,LeaveTypeName,IsActive
	FROM LeaveTypeMaster WITH(NOLOCK)
END;

Drop Procedure If Exists SaveLeaveTypeDetails
GO
-- EXEC SaveLeaveTypeDetails 3,'TEST DEMO',1
CREATE Or Alter ProcedureSaveLeaveTypeDetails
(
	@LeaveTypeId BIGINT,
	@LeaveTypeName VARCHAR(100),
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
		(@LeaveTypeId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM LeaveTypeMaster WITH(NOLOCK) 
				WHERE  LeaveTypeName=@LeaveTypeName
			)
		)
		OR
		(@LeaveTypeId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM LeaveTypeMaster WITH(NOLOCK) 
				WHERE  LeaveTypeName=@LeaveTypeName and LeaveTypeId<>@LeaveTypeId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@LeaveTypeId=0)
		BEGIN
			Insert into LeaveTypeMaster(LeaveTypeName, IsActive,CreatedBy,CreatedOn)
			Values(@LeaveTypeName, @IsActive,@LoggedInUserId,GETDATE())
			SET @Result = SCOPE_IDENTITY();
		END
		ELSE IF(@LeaveTypeId> 0 and EXISTS(SELECT TOP 1 1 FROM LeaveTypeMaster WHERE LeaveTypeId=@LeaveTypeId))
		BEGIN
			UPDATE LeaveTypeMaster
			SET LeaveTypeName=@LeaveTypeName,IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE LeaveTypeId=@LeaveTypeId
			SET @Result = @LeaveTypeId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result 
END
