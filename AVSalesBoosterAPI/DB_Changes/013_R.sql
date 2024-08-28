

DROP PROCEDURE IF EXISTS GetCustomerDetailsById;

GO

CREATE Or Alter ProcedureGetCustomerDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CustomerId,CompanyName,LandlineNo,MobileNo as MobileNumber,EmailId,CustomerTypeId,
			SpecialRemarks,EmployeeId as EmployeeRoleId,IsActive
		FROM CustomerDetails WITH(NOLOCK)
	WHERE CustomerId = @Id
END

GO

DROP PROCEDURE IF EXISTS GetCustomerContactDetailsById;

GO

CREATE Or Alter ProcedureGetCustomerContactDetailsById
	@CustomerId BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CD.ContactId,CD.ContactName,CD.MobileNo,CD.EmailId,CD.RefPartyId,CD.IsActive
		FROM CustomerContactMapping CCM WITH(NOLOCK)
	INNER JOIN ContactDetails CD ON CD.ContactId=CCM.ContactId
	WHERE CustomerId = @CustomerId
END

GO

DROP PROCEDURE IF EXISTS GetCustomerAddressDetailsById;

GO

CREATE Or Alter ProcedureGetCustomerAddressDetailsById
	@CustomerId BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT AD.AddressId,Ad.[Address] as [Address],Ad.StateId,Ad.RegionId,Ad.DistrictId,AD.AreaId,
			AD.Pincode,AD.IsActive,AD.IsDefault,AD.NameForAddress,AD.MobileNo,AD.EmailId,Ad.AddressTypeId
		FROM CustomerAddressMapping CAM WITH(NOLOCK)
	INNER JOIN AddressMaster AD ON CAM.AddressId =AD.AddressId
	WHERE CustomerId = @CustomerId
END

GO
DROP PROCEDURE IF EXISTS GetReferenceDetailsById;

GO

CREATE Or Alter ProcedureGetReferenceDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT RM.ReferenceId,RM.
	UniqueNumber,RM.PartyName as ReferenceParty ,
			   AD.Address,AD.StateId,AD.RegionId,AD.DistrictId,AD.AreaId,AD.Pincode,RM.PhoneNumber,RM.MobileNumber,
			   RM.GSTNumber,RM.PanNumber,RM.EmailId,RM.IsActive
		FROM ReferenceMaster RM WITH(NOLOCK)
		INNER JOIN ReferenceAddressMapping RAM WITH(NOLOCK) ON RAM.ReferenceId = RM.ReferenceId
		INNER JOIN AddressMaster AD WITH(NOLOCK) ON Ad.AddressId=RAM.AddressId
		WHERE RM.ReferenceId=@Id
END

GO
DROP PROCEDURE IF EXISTS GetDesignDetailsById;

GO

CREATE Or Alter ProcedureGetDesignDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

    SELECT DesignId,ProductId,BrandId,SizeId,CategoryId,SeriesId,DesignTypeId
						BaseDesignId,DesignName,DesignCode,IsActive
						FROM DesignMaster WITH(NOLOCK)
	WHERE DesignId=@Id
END

GO

DROP PROCEDURE IF EXISTS GetLeaveTypeDetailsById;

GO

CREATE Or Alter ProcedureGetLeaveTypeDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT LeaveTypeId,LeaveTypeName,IsActive
					FROM LeaveTypeMaster WITH(NOLOCK)
	WHERE LeaveTypeId = @Id
END

GO

DROP PROCEDURE IF EXISTS GetLeaveDetailsById;

GO

CREATE Or Alter ProcedureGetLeaveDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	 SELECT LeaveId,StartDate,EndDate,EmployeeName,LeaveTypeId,Remark,Reason,IsActive
					FROM LeaveMaster WITH(NOLOCK)
	WHERE LeaveId = @Id
END

GO
DROP PROCEDURE IF EXISTS GetStateDetailsById;

GO

CREATE Or Alter ProcedureGetStateDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	 SELECT StateId,StateName,IsActive
					FROM StateMaster WITH(NOLOCK)
	WHERE StateId = @Id
END

GO
DROP PROCEDURE IF EXISTS GetRegionDetailsById;

GO

CREATE Or Alter ProcedureGetRegionDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	 SELECT RegionId,StateId,RegionName,IsActive
					FROM RegionMaster WITH(NOLOCK)
	WHERE RegionId = @Id
END

GO
DROP PROCEDURE IF EXISTS GetDistrictDetailsById;

GO

CREATE Or Alter ProcedureGetDistrictDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	 SELECT DistrictId,RegionId,DistrictName,IsActive
					FROM DistrictMaster WITH(NOLOCK)
	WHERE DistrictId = @Id
END

GO
DROP PROCEDURE IF EXISTS GetAreaDetailsById;

GO

CREATE Or Alter ProcedureGetAreaDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	 SELECT AreaId,DistrictId,AreaName,IsActive
						FROM AreaMaster WITH(NOLOCK)
	WHERE AreaId = @Id
END

GO
DROP PROCEDURE IF EXISTS GetRoleDetailsById;

GO

CREATE Or Alter ProcedureGetRoleDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	 SELECT RoleId,RoleName,IsActive
					FROM RoleMaster WITH(NOLOCK)
	WHERE RoleId = @Id
END

GO

DROP PROCEDURE IF EXISTS GetReportingToDetailsById;

GO

CREATE Or Alter ProcedureGetReportingToDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	 SELECT Id,RoleId,ReportingTo,IsActive
					FROM ReportingToMaster WITH(NOLOCK)
	WHERE Id = @Id
END

GO


DROP PROCEDURE IF EXISTS GetEmployeeDetailsById;

GO

CREATE Or Alter ProcedureGetEmployeeDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	 SELECT EM.EmployeeId,EM.EmployeeName,EM.EmployeeCode,EM.EmailId,EM.MobileNumber,EM.RoleId,EM.ReportingTo,
				 EM.DateOfBirth,EM.DateOfJoining,
				 EM.EmergencyContactNumber,EM.BloodGroup,EM.IsWebUser,Em.IsMobileUser,EM.IsActive,EM.FileOriginalName,EM.ImageUpload
				FROM EmployeeMaster EM WITH(NOLOCK)
	WHERE EmployeeId = @Id
END

