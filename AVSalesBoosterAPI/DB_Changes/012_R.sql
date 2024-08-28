DROP PROCEDURE IF EXISTS GetCategoryDetailsById;

GO

CREATE Or Alter ProcedureGetCategoryDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CategoryId,CategoryName,IsActive
		FROM CategoryMaster WITH(NOLOCK)
	WHERE CategoryId = @Id
END

GO

DROP PROCEDURE IF EXISTS GetSizeDetailsById;

GO

CREATE Or Alter ProcedureGetSizeDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SizeId,SizeName,IsActive
				FROM SizeMaster WITH(NOLOCK)
	WHERE SizeId = @Id
END

GO

DROP PROCEDURE IF EXISTS GetDesignTypeDetailsById;

GO

CREATE Or Alter ProcedureGetDesignTypeDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DesignTypeId,DesignTypeName,IsActive
		    FROM DesignTypeMaster WITH(NOLOCK)
	WHERE DesignTypeId = @Id
END

GO

DROP PROCEDURE IF EXISTS GetSeriesDetailsById;

GO

CREATE Or Alter ProcedureGetSeriesDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SeriesId,SeriesName,IsActive
			FROM SeriesMaster WITH(NOLOCK)
	WHERE SeriesId = @Id
END

GO

DROP PROCEDURE IF EXISTS GetBaseDesignDetailsById;

GO

CREATE Or Alter ProcedureGetBaseDesignDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT BaseDesignId,BaseDesignName,IsActive
			FROM BaseDesignMaster WITH(NOLOCK)
	WHERE BaseDesignId = @Id
END

GO

DROP PROCEDURE IF EXISTS GetCustomerTypeDetailsById;

GO

CREATE Or Alter ProcedureGetCustomerTypeDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CustomerTypeId,CustomerTypeName,IsActive
					FROM CustomerTypeMaster WITH(NOLOCK)
	WHERE CustomerTypeId = @Id
END

GO

DROP PROCEDURE IF EXISTS GetLeaveDetailsById;

GO

CREATE Or Alter ProcedureGetLeaveDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT LeaveTypeId,LeaveTypeName,IsActive
					FROM LeaveTypeMaster WITH(NOLOCK)
	WHERE LeaveTypeId = @Id
END