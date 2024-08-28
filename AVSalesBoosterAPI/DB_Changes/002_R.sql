Drop Procedure If Exists GetStates;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetStates]
Description : Get State from StateMaster
*/
CREATE Or Alter Procedure[dbo].[GetStates]
AS
BEGIN
	SELECT StateId,StateName,IsActive
	FROM StateMaster WITH(NOLOCK)
END

GO
Drop Procedure If Exists SaveStateDetails;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[SaveStateDetails] '0','State 1',1
Description : Insert State from StateMaster
*/
CREATE Or Alter Procedure[dbo].[SaveStateDetails]
(	@StateId BIGINT,	@StateName VARCHAR(100),	@IsActive BIT,	@LoggedInUserId BIGINT)
AS
BEGIN
	SET NOCOUNT ON;	DECLARE @Result BIGINT=0;	DECLARE @IsNameExists BIGINT=-2;	DECLARE @NoRecordExists BIGINT=-1;	If (		(@StateId=0 AND 			EXISTS			(				SELECT TOP 1 1 				FROM StateMaster WITH(NOLOCK) 				WHERE  StateName=@StateName			)		)		OR		(@StateId>0 AND 			EXISTS			(				SELECT TOP 1 1 				FROM StateMaster WITH(NOLOCK) 				WHERE  StateName=@StateName and StateId<>@StateId			)		))	BEGIN		SET @Result=@IsNameExists;	END	ELSE	BEGIN		IF (@StateId=0)		BEGIN			Insert into StateMaster(StateName, IsActive,CreatedBy,CreatedOn)			Values(@StateName, @IsActive,@LoggedInUserId,GETDATE())			SET @Result = SCOPE_IDENTITY();		END		ELSE IF(@StateId> 0 and EXISTS(SELECT TOP 1 1 FROM StateMaster WHERE StateId=@StateId))		BEGIN			UPDATE StateMaster			SET StateName=@StateName,IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()			WHERE StateId=@StateId			SET @Result = @StateId;		END		ELSE		BEGIN			SET @Result=@NoRecordExists		END	END		SELECT @Result as Result
END

GO
-- Region
Drop Procedure If Exists GetRegions;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetRegions]
Description : Get Region from RegionMaster
*/
CREATE Or Alter Procedure[dbo].[GetRegions]
AS
BEGIN
	SELECT RegionId,StateId,RegionName,IsActive
	FROM RegionMaster WITH(NOLOCK)
END

GO
Drop Procedure If Exists SaveRegionDetails;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[SaveRegionDetails] '0','Region 1',1
Description : Insert Region from RegionMaster
*/
CREATE Or Alter Procedure[dbo].[SaveRegionDetails]
(	@RegionId BIGINT,	@StateId BIGINT,	@RegionName VARCHAR(100),	@IsActive BIT,	@LoggedInUserId BIGINT)
AS
BEGIN
	SET NOCOUNT ON;	DECLARE @Result BIGINT=0;	DECLARE @IsNameExists BIGINT=-2;	DECLARE @NoRecordExists BIGINT=-1;	If (		(@RegionId=0 AND 			EXISTS			(				SELECT TOP 1 1 				FROM RegionMaster WITH(NOLOCK) 				WHERE  RegionName=@RegionName			)		)		OR		(@RegionId>0 AND 			EXISTS			(				SELECT TOP 1 1 				FROM RegionMaster WITH(NOLOCK) 				WHERE  RegionName=@RegionName and RegionId<>@RegionId			)		))	BEGIN		SET @Result=@IsNameExists;	END	ELSE	BEGIN		IF (@RegionId=0)		BEGIN			Insert into RegionMaster(StateId, RegionName, IsActive,CreatedBy,CreatedOn)			Values(@StateId,@RegionName, @IsActive,@LoggedInUserId,GETDATE())			SET @Result = SCOPE_IDENTITY();		END		ELSE IF(@RegionId> 0 and EXISTS(SELECT TOP 1 1 FROM RegionMaster WHERE RegionId=@RegionId))		BEGIN			UPDATE RegionMaster			SET StateId=@StateId, RegionName=@RegionName,IsActive=@IsActive,				ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()			WHERE RegionId=@RegionId			SET @Result = @RegionId;		END		ELSE		BEGIN			SET @Result=@NoRecordExists		END	END		SELECT @Result as Result
END

GO

Drop Procedure If Exists GetDistricts;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetDistricts]
Description : Get District from DistrictMaster
*/
CREATE Or Alter Procedure[dbo].[GetDistricts]
AS
BEGIN
	SELECT DistrictId,RegionId,DistrictName,IsActive
	FROM DistrictMaster WITH(NOLOCK)
END

GO
Drop Procedure If Exists SaveDistrictDetails;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[SaveDistrictDetails] '0','District 1',1
Description : Insert District from DistrictMaster
*/
CREATE Or Alter Procedure[dbo].[SaveDistrictDetails]
(	@DistrictId BIGINT,	@RegionId BIGINT,	@DistrictName VARCHAR(100),	@IsActive BIT,	@LoggedInUserId BIGINT)
AS
BEGIN
	SET NOCOUNT ON;	DECLARE @Result BIGINT=0;	DECLARE @IsNameExists BIGINT=-2;	DECLARE @NoRecordExists BIGINT=-1;	If (		(@DistrictId=0 AND 			EXISTS			(				SELECT TOP 1 1 				FROM DistrictMaster WITH(NOLOCK) 				WHERE  DistrictName=@DistrictName			)		)		OR		(@DistrictId>0 AND 			EXISTS			(				SELECT TOP 1 1 				FROM DistrictMaster WITH(NOLOCK) 				WHERE  DistrictName=@DistrictName and DistrictId<>@DistrictId			)		))	BEGIN		SET @Result=@IsNameExists;	END	ELSE	BEGIN		IF (@DistrictId=0)		BEGIN			Insert into DistrictMaster(RegionId, DistrictName, IsActive,CreatedBy,CreatedOn)			Values(@RegionId,@DistrictName, @IsActive,@LoggedInUserId,GETDATE())			SET @Result = SCOPE_IDENTITY();		END		ELSE IF(@DistrictId> 0 and EXISTS(SELECT TOP 1 1 FROM DistrictMaster WHERE DistrictId=@DistrictId))		BEGIN			UPDATE DistrictMaster			SET RegionId=@RegionId, DistrictName=@DistrictName,IsActive=@IsActive,				ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()			WHERE DistrictId=@DistrictId			SET @Result = @DistrictId;		END		ELSE		BEGIN			SET @Result=@NoRecordExists		END	END		SELECT @Result as Result
END

GO
-- Area
Drop Procedure If Exists GetAreas;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetAreas]
Description : Get Area from AreaMaster
*/
CREATE Or Alter Procedure[dbo].[GetAreas]
AS
BEGIN
	SELECT AreaId,DistrictId,AreaName,IsActive
	FROM AreaMaster WITH(NOLOCK)
END

GO
Drop Procedure If Exists SaveAreaDetails;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[SaveAreaDetails] '0','Area 1',1
Description : Insert Area from AreaMaster
*/
CREATE Or Alter Procedure[dbo].[SaveAreaDetails]
(	@AreaId BIGINT,	@DistrictId BIGINT,	@AreaName VARCHAR(100),	@IsActive BIT,	@LoggedInUserId BIGINT)
AS
BEGIN
	SET NOCOUNT ON;	DECLARE @Result BIGINT=0;	DECLARE @IsNameExists BIGINT=-2;	DECLARE @NoRecordExists BIGINT=-1;	If (		(@AreaId=0 AND 			EXISTS			(				SELECT TOP 1 1 				FROM AreaMaster WITH(NOLOCK) 				WHERE  AreaName=@AreaName			)		)		OR		(@AreaId>0 AND 			EXISTS			(				SELECT TOP 1 1 				FROM AreaMaster WITH(NOLOCK) 				WHERE  AreaName=@AreaName and AreaId<>@AreaId			)		))	BEGIN		SET @Result=@IsNameExists;	END	ELSE	BEGIN		IF (@AreaId=0)		BEGIN			Insert into AreaMaster(DistrictId, AreaName, IsActive,CreatedBy,CreatedOn)			Values(@DistrictId,@AreaName, @IsActive,@LoggedInUserId,GETDATE())			SET @Result = SCOPE_IDENTITY();		END		ELSE IF(@AreaId> 0 and EXISTS(SELECT TOP 1 1 FROM AreaMaster WHERE AreaId=@AreaId))		BEGIN			UPDATE AreaMaster			SET DistrictId=@DistrictId, AreaName=@AreaName,IsActive=@IsActive,				ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()			WHERE AreaId=@AreaId			SET @Result = @AreaId;		END		ELSE		BEGIN			SET @Result=@NoRecordExists		END	END		SELECT @Result as Result
END