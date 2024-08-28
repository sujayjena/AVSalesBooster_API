If OBJECT_ID('LeaveMaster') Is Not Null
Begin
	Drop Table LeaveMaster
End

GO

If OBJECT_ID('LeaveMaster') Is Null
Begin

	CREATE TABLE LeaveMaster
	(
		LeaveId BIGINT IDENTITY(1,1) PRIMARY KEY,
		StartDate DATETIME NOT NULL,
		EndDate DATETIME NOT NULL,
		EmployeeName VARCHAR(100) NOT NULL,
		LeaveTypeId BIGINT FOREIGN KEY REFERENCES LeaveTypeMaster(LeaveTypeId) ,
		Remark VARCHAR(100),
		Reason VARCHAR(100),
		IsActive BIT NOT NULL,
		CreatedBy BIGINT NOT NULL,
		CreatedOn DATETIME NOT NULL,
		ModifiedBy BIGINT,
		ModifiedOn DATETIME
	)
END

GO

Drop Procedure If Exists GetLeaves;

GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetLeaves]
Description : Get Leave from LeaveMaster
*/
CREATE Or Alter Procedure[dbo].[GetLeaves]
AS
BEGIN
	SELECT LeaveId,StartDate,EndDate,EmployeeName,LeaveTypeId,Remark,Reason,IsActive
	FROM LeaveMaster WITH(NOLOCK)
END

GO
Drop Procedure If Exists SaveLeaveDetails;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[SaveLeaveDetails] '0','Leave 1',1
Description : Insert Leave from LeaveMaster
*/
CREATE Or Alter Procedure[dbo].[SaveLeaveDetails]
(
	@LeaveId BIGINT,
	@StartDate DATETIME,
	@EndDate DATETIME,
	@EmployeeName VARCHAR(100),
	@LeaveTypeId BIGINT,
	@Remark VARCHAR(100),
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
		(@LeaveId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM LeaveMaster WITH(NOLOCK) 
				WHERE StartDate=@StartDate and EndDate=@EndDate 
			)
		)
		OR
		(@LeaveId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM LeaveMaster WITH(NOLOCK) 
				WHERE StartDate=@StartDate and EndDate=@EndDate and LeaveId<>@LeaveId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@LeaveId=0)
		BEGIN
			Insert into LeaveMaster(StartDate,EndDate,EmployeeName,LeaveTypeId,Remark, IsActive,CreatedBy,CreatedOn)
			Values(@StartDate,@EndDate,@EmployeeName,@LeaveTypeId,@Remark, @IsActive,@LoggedInUserId,GETDATE())
			SET @Result = SCOPE_IDENTITY();
		END
		ELSE IF(@LeaveId> 0 and EXISTS(SELECT TOP 1 1 FROM LeaveMaster WHERE LeaveId=@LeaveId))
		BEGIN
			UPDATE LeaveMaster
			SET StartDate=@StartDate,EndDate=@EndDate,EmployeeName=@EmployeeName,LeaveTypeId=@LeaveTypeId,Remark=@Remark,IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE LeaveId=@LeaveId
			SET @Result = @LeaveId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result
END

GO