Drop Procedure If Exists SaveLeaveTypeDetails;GOCREATE Or Alter ProcedureSaveLeaveTypeDetails(	@LeaveTypeId BIGINT,	@LeaveTypeName VARCHAR(100),	@IsActive BIT,	@LoggedInUserId BIGINT)-- EXEC SaveLeaveTypeDetails 3,'TEST DEMO',1ASBEGIN	SET NOCOUNT ON;	DECLARE @Result BIGINT=0;	DECLARE @IsNameExists BIGINT=-2;	DECLARE @NoRecordExists BIGINT=-1;	If (		(@LeaveTypeId=0 AND 			EXISTS			(				SELECT TOP 1 1 				FROM LeaveTypeMaster WITH(NOLOCK) 				WHERE  LeaveTypeName=@LeaveTypeName			)		)		OR		(@LeaveTypeId>0 AND 			EXISTS			(				SELECT TOP 1 1 				FROM LeaveTypeMaster WITH(NOLOCK) 				WHERE  LeaveTypeName=@LeaveTypeName and LeaveTypeId<>@LeaveTypeId			)		))	BEGIN		SET @Result=@IsNameExists;	END	ELSE	BEGIN		IF (@LeaveTypeId=0)		BEGIN			Insert into LeaveTypeMaster(LeaveTypeName, IsActive,CreatedBy,CreatedOn)			Values(@LeaveTypeName, @IsActive,@LoggedInUserId,GETDATE())			SET @Result = SCOPE_IDENTITY();		END		ELSE IF(@LeaveTypeId> 0 and EXISTS(SELECT TOP 1 1 FROM LeaveTypeMaster WHERE LeaveTypeId=@LeaveTypeId))		BEGIN			UPDATE LeaveTypeMaster			SET LeaveTypeName=@LeaveTypeName,IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()			WHERE LeaveTypeId=@LeaveTypeId			SET @Result = @LeaveTypeId;		END		ELSE		BEGIN			SET @Result=@NoRecordExists		END	END		SELECT @Result as Result END
GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetReferences]
Description : Get Reference Detail from ReferenceMaster
*/
ALTER PROCEDURE [dbo].[GetReferences]
AS
BEGIN
	SELECT RM.ReferenceId,RM.UniqueNumber,RM.PartyName AS ReferenceParty,
		   AD.Address,AD.StateId,AD.RegionId,AD.DistrictId,AD.AreaId,AD.Pincode,RM.PhoneNumber,RM.MobileNumber,
		   RM.GSTNumber,RM.PanNumber,RM.EmailId,RM.IsActive
	FROM ReferenceMaster RM WITH(NOLOCK)
	INNER JOIN ReferenceAddressMapping RAM WITH(NOLOCK) ON RAM.ReferenceId = RM.ReferenceId
	INNER JOIN AddressMaster AD WITH(NOLOCK) ON Ad.AddressId=RAM.AddressId
END

GO

DROP PROCEDURE IF EXISTS GetStatesForSelectList;

GO

CREATE Or Alter ProcedureGetStatesForSelectList
	@IsActive BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT StateId AS [Value], StateName AS [Text]
	FROM StateMaster WITH(NOLOCK)
	WHERE @IsActive IS NULL OR IsActive = @IsActive
END

GO

DROP PROCEDURE IF EXISTS GetRegionsForSelectList;

GO

CREATE Or Alter ProcedureGetRegionsForSelectList
	@StateId BIGINT,
	@IsActive BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT RegionId AS [Value], RegionName AS [Text]
	FROM RegionMaster WITH(NOLOCK)
	WHERE StateId = @StateId AND
		(@IsActive IS NULL OR IsActive = @IsActive)
END

GO

DROP PROCEDURE IF EXISTS GetDistrictsForSelectList;

GO

CREATE Or Alter ProcedureGetDistrictsForSelectList
	@RegionId BIGINT,
	@IsActive BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DistrictId AS [Value], DistrictName AS [Text]
	FROM DistrictMaster WITH(NOLOCK)
	WHERE RegionId = @RegionId AND
		(@IsActive IS NULL OR IsActive = @IsActive)
END

GO

DROP PROCEDURE IF EXISTS GetAreasForSelectList;

GO

CREATE Or Alter ProcedureGetAreasForSelectList
	@DistrictId BIGINT,
	@IsActive BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT AreaId AS [Value], AreaName AS [Text]
	FROM AreaMaster WITH(NOLOCK)
	WHERE DistrictId = @DistrictId AND
		(@IsActive IS NULL OR IsActive = @IsActive)
END

GO

DROP PROCEDURE IF EXISTS GetProductDetailsById;

GO

CREATE Or Alter ProcedureGetProductDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		ProductId, ProductName, IsActive
	FROM ProductMaster WITH(NOLOCK)
	WHERE ProductId = @Id
END

GO

DROP PROCEDURE IF EXISTS GetBrandDetailsById;

GO

CREATE Or Alter ProcedureGetBrandDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		BrandId, BrandName, IsActive
	FROM BrandMaster WITH(NOLOCK)
	WHERE BrandId = @Id
END

GO
