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
(
AS
BEGIN
	SET NOCOUNT ON;
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
(
AS
BEGIN
	SET NOCOUNT ON;
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
(
AS
BEGIN
	SET NOCOUNT ON;
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
(
AS
BEGIN
	SET NOCOUNT ON;
END