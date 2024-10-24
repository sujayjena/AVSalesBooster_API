-- GetEmployeeDetailsById 1
ALTER PROCEDURE GetEmployeeDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		EM.EmployeeId, EM.EmployeeName, EM.EmployeeCode, EM.EmailId, EM.MobileNumber, EM.RoleId, RM.RoleName,
		EM.ReportingTo, Manager.EmployeeName as ReportingToName, Manager.MobileNumber AS ManagerMobileNo,
		AM.AddressId,
		AM.[Address],AM.StateId,SM.StateName,AM.RegionId,RGM.RegionName,AM.DistrictId,DM.DistrictName,AM.AreaId,ARM.AreaName,AM.Pincode,
		EM.DateOfBirth,EM.DateOfJoining,
		EM.EmergencyContactNumber,EM.BloodGroup,EM.IsWebUser,Em.IsMobileUser,EM.IsActive,EM.FileOriginalName,EM.ImageUpload
	FROM EmployeeMaster EM WITH(NOLOCK)
	LEFT JOIN EmployeeMaster Manager WITH(NOLOCK)
		ON Manager.EmployeeId = EM.ReportingTo
	LEFT JOIN EmployeeAddressMapping EAM WITH(NOLOCK)
		ON EAM.EmployeeId=EM.EmployeeId
	LEFT JOIN AddressMaster AM WITH(NOLOCK)
		ON AM.AddressId=EAM.AddressId
			AND AM.IsDefault = 1
	LEFT JOIN RoleMaster RM WITH(NOLOCK)
		ON RM.RoleId=EM.RoleId
	LEFT JOIN RoleMaster RM1 WITH(NOLOCK)
		ON RM1.RoleId=EM.ReportingTo
	LEFT JOIN StateMaster SM WITH(NOLOCK)
		ON SM.StateId=AM.StateId
	LEFT JOIN RegionMaster RGM WITH(NOLOCK)
		ON RGM.RegionId=AM.RegionId
	LEFT JOIN DistrictMaster DM WITH(NOLOCK)
		ON DM.DistrictId=AM.DistrictId
	LEFT JOIN AreaMaster ARM WITH(NOLOCK)
		ON ARM.AreaId=AM.AreaId
	WHERE EM.EmployeeId = @Id
END

GO

CREATE OR ALTER PROCEDURE UpdateEmpDetailsThroughApp
(
	@EmployeeId BIGINT,
	@MobileNumber VARCHAR(20),
	@AddressId BIGINT,
	@Address VARCHAR(500),
	@StateId BIGINT,
	@RegionId BIGINT,
	@DistrictId BIGINT,
	@AreaId BIGINT,
	@Pincode VARCHAR(15),
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Result BIGINT = 0;
	DECLARE @NoRecordExists BIGINT = -1;
	DECLARE @NameExists BIGINT = -2;
	DECLARE @MobileNoExists BIGINT = -3;
	DECLARE @EmailAddressExists BIGINT = -4;

	IF NOT EXISTS(SELECT TOP 1 1 FROM EmployeeMaster WITH(NOLOCK) WHERE EmployeeId = @EmployeeId)
	BEGIN
		SET @Result = @NoRecordExists;
	END
	ELSE IF EXISTS(SELECT TOP 1 1 FROM EmployeeMaster WITH(NOLOCK) WHERE MobileNumber = @MobileNumber AND EmployeeId <> @EmployeeId)
	BEGIN
		SET @Result = @MobileNoExists;
	END
	ELSE
	BEGIN
		UPDATE EmployeeMaster
		SET MobileNumber = @MobileNumber
		WHERE EmployeeId = @EmployeeId

		UPDATE am
		SET [Address] = @Address
			,StateId = @StateId
			,RegionId = @RegionId
			,DistrictId = @DistrictId
			,AreaId = @AreaId
			,Pincode = @Pincode
		FROM AddressMaster am WITH(NOLOCK)
		INNER JOIN EmployeeAddressMapping eam WITH(NOLOCK)
			ON am.AddressId = eam.AddressId
		WHERE am.AddressId = @AddressId AND eam.EmployeeId = @EmployeeId

		SET @Result = @EmployeeId;
	END

	SELECT @Result AS Result
END
