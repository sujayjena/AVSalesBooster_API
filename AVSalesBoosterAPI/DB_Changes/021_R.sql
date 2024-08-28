/*
EXEC SaveImportProductDetails
'<ArrayOfImportedProductDetails xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <ImportedProductDetails>
    <ProductName>Pro-11</ProductName>
    <IsActive>True</IsActive>
  </ImportedProductDetails>
  <ImportedProductDetails>
    <ProductName>Pro-11</ProductName>
    <IsActive>True</IsActive>
  </ImportedProductDetails>
  <ImportedProductDetails>
    <ProductName>Pro-22</ProductName>
    <IsActive>False</IsActive>
  </ImportedProductDetails>
  <ImportedProductDetails>
    <ProductName>33</ProductName>
    <IsActive>aaa</IsActive>
  </ImportedProductDetails>
</ArrayOfImportedProductDetails>',1
*/
CREATE Or Alter Procedure[dbo].[SaveImportProductDetails]
(
	@XmlProductData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempProductDetail TABLE
	(
		ProductName VARCHAR(100),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	INSERT INTO @tempProductDetail(ProductName,IsActive,IsValid)
	SELECT
		ProductName = T.Item.value('ProductName[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1 
	FROM @XmlProductData.nodes('/ArrayOfImportedProductDetails/ImportedProductDetails') AS T(Item)

	
	-- 3. Validation of records
	Update @tempProductDetail
	Set IsValid = 0,
		ValidationMessage = 'Product Name value is invalid'
	Where RTRIM(LTRIM(IsNull(ProductName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempProductDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Product Name already Exists'
	FROM @tempProductDetail T
	INNER JOIN  ProductMaster PM 
		ON PM.ProductName = T.ProductName and T.IsValid=1

	Insert into ProductMaster
	(
		ProductName, IsActive,CreatedBy,CreatedOn
	)
	select ProductName,CASE WHEN IsActive='TRUE' THEN 1 ELSE 0 END,@LoggedInUserId,GETDATE() 
	from @tempProductDetail 
	Where IsValid = 1


	-- 5. Returning Invalid records
	Select ProductName,IsActive,ValidationMessage
	From @tempProductDetail
	Where IsValid = 0;

END

GO

CREATE Or Alter Procedure[dbo].[SaveImportBrandDetails]
(
	@XmlBrandData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempBrandDetail TABLE
	(
		BrandName VARCHAR(100),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	INSERT INTO @tempBrandDetail(BrandName,IsActive,IsValid)
	SELECT
		BrandName = T.Item.value('BrandName[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlBrandData.nodes('/ArrayOfImportedBrandDetails/ImportedBrandDetails') AS T(Item)

	
	-- 3. Validation of records
	Update @tempBrandDetail
	Set IsValid = 0,
		ValidationMessage = 'Brand Name value is invalid'
	Where RTRIM(LTRIM(IsNull(BrandName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempBrandDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Brand Name already Exists'
	FROM @tempBrandDetail T
	INNER JOIN BrandMaster PM ON PM.BrandName = T.BrandName and T.IsValid=1

	 Insert into BrandMaster(BrandName, IsActive,CreatedBy,CreatedOn)
			select BrandName,
			CASE WHEN IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() from @tempBrandDetail Where IsValid = 1


	-- 5. Returning Invalid records
	Select BrandName,IsActive,ValidationMessage
	From @tempBrandDetail
	Where IsValid = 0;

END

GO
CREATE Or Alter Procedure[dbo].[SaveImportCategoryDetails]
(
	@XmlCategoryData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempCategoryDetail TABLE
	(
		CategoryName VARCHAR(100),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	INSERT INTO @tempCategoryDetail(CategoryName,IsActive,IsValid)
	SELECT
		CategoryName = T.Item.value('CategoryName[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlCategoryData.nodes('/ArrayOfImportedCategoryDetails/ImportedCategoryDetails') AS T(Item)

	
	-- 3. Validation of records
	Update @tempCategoryDetail
	Set IsValid = 0,
		ValidationMessage = 'Category Name value is invalid'
	Where RTRIM(LTRIM(IsNull(CategoryName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempCategoryDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Category Name already Exists'
	FROM @tempCategoryDetail T
	INNER JOIN CategoryMaster PM ON PM.CategoryName = T.CategoryName and T.IsValid=1

	 Insert into CategoryMaster(CategoryName, IsActive,CreatedBy,CreatedOn)
			select CategoryName,
			CASE WHEN IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() from @tempCategoryDetail Where IsValid = 1


	-- 5. Returning Invalid records
	Select CategoryName,IsActive,ValidationMessage
	From @tempCategoryDetail
	Where IsValid = 0;

END

GO

CREATE Or Alter Procedure[dbo].[SaveImportSizeDetails]
(
	@XmlSizeData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempSizeDetail TABLE
	(
		SizeName VARCHAR(100),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	INSERT INTO @tempSizeDetail(SizeName,IsActive,IsValid)
	SELECT
		SizeName = T.Item.value('SizeName[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlSizeData.nodes('/ArrayOfImportedSizeDetails/ImportedSizeDetails') AS T(Item)

	
	-- 3. Validation of records
	Update @tempSizeDetail
	Set IsValid = 0,
		ValidationMessage = 'Size Name value is invalid'
	Where RTRIM(LTRIM(IsNull(SizeName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempSizeDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Size Name already Exists'
	FROM @tempSizeDetail T
	INNER JOIN SizeMaster PM ON PM.SizeName = T.SizeName and T.IsValid=1

	 Insert into SizeMaster(SizeName, IsActive,CreatedBy,CreatedOn)
			select SizeName,
			CASE WHEN IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() from @tempSizeDetail Where IsValid = 1


	-- 5. Returning Invalid records
	Select SizeName,IsActive,ValidationMessage
	From @tempSizeDetail
	Where IsValid = 0;

END

GO

CREATE Or Alter Procedure[dbo].[SaveImportDesignTypeDetails]
(
	@XmlDesignTypeData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempDesignTypeDetail TABLE
	(
		DesignTypeName VARCHAR(100),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	INSERT INTO @tempDesignTypeDetail(DesignTypeName,IsActive,IsValid)
	SELECT
		DesignTypeName = T.Item.value('DesignTypeName[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlDesignTypeData.nodes('/ArrayOfImportedDesignTypeDetails/ImportedDesignTypeDetails') AS T(Item)

	
	-- 3. Validation of records
	Update @tempDesignTypeDetail
	Set IsValid = 0,
		ValidationMessage = 'Design Type Name value is invalid'
	Where RTRIM(LTRIM(IsNull(DesignTypeName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempDesignTypeDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Design Type Name already Exists'
	FROM @tempDesignTypeDetail T
	INNER JOIN DesignTypeMaster PM ON PM.DesignTypeName = T.DesignTypeName and T.IsValid=1

	 Insert into DesignTypeMaster(DesignTypeName, IsActive,CreatedBy,CreatedOn)
			select DesignTypeName,
			CASE WHEN IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() from @tempDesignTypeDetail Where IsValid = 1


	-- 5. Returning Invalid records
	Select DesignTypeName,IsActive,ValidationMessage
	From @tempDesignTypeDetail
	Where IsValid = 0;

END

GO

CREATE Or Alter Procedure[dbo].[SaveImportSeriesDetails]
(
	@XmlSeriesData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempSeriesDetail TABLE
	(
		SeriesName VARCHAR(100),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	INSERT INTO @tempSeriesDetail(SeriesName,IsActive,IsValid)
	SELECT
		SeriesName = T.Item.value('SeriesName[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlSeriesData.nodes('/ArrayOfImportedSeriesDetails/ImportedSeriesDetails') AS T(Item)

	
	-- 3. Validation of records
	Update @tempSeriesDetail
	Set IsValid = 0,
		ValidationMessage = 'Series Name value is invalid'
	Where RTRIM(LTRIM(IsNull(SeriesName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempSeriesDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Series Name already Exists'
	FROM @tempSeriesDetail T
	INNER JOIN SeriesMaster PM ON PM.SeriesName = T.SeriesName and T.IsValid=1

	 Insert into SeriesMaster(SeriesName, IsActive,CreatedBy,CreatedOn)
			select SeriesName,
			CASE WHEN IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() from @tempSeriesDetail Where IsValid = 1


	-- 5. Returning Invalid records
	Select SeriesName,IsActive,ValidationMessage
	From @tempSeriesDetail
	Where IsValid = 0;

END

GO

CREATE Or Alter Procedure[dbo].[SaveImportBaseDesignDetails]
(
	@XmlBaseDesignData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempBaseDesignDetail TABLE
	(
		BaseDesignName VARCHAR(100),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	INSERT INTO @tempBaseDesignDetail(BaseDesignName,IsActive,IsValid)
	SELECT
		BaseDesignName = T.Item.value('BaseDesignName[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlBaseDesignData.nodes('/ArrayOfImportedBaseDesignDetails/ImportedBaseDesignDetails') AS T(Item)

	
	-- 3. Validation of records
	Update @tempBaseDesignDetail
	Set IsValid = 0,
		ValidationMessage = 'Base Design Name value is invalid'
	Where RTRIM(LTRIM(IsNull(BaseDesignName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempBaseDesignDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Base Design Name already Exists'
	FROM @tempBaseDesignDetail T
	INNER JOIN BaseDesignMaster PM ON PM.BaseDesignName = T.BaseDesignName and T.IsValid=1

	 Insert into BaseDesignMaster(BaseDesignName, IsActive,CreatedBy,CreatedOn)
			select BaseDesignName,
			CASE WHEN IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() from @tempBaseDesignDetail Where IsValid = 1


	-- 5. Returning Invalid records
	Select BaseDesignName,IsActive,ValidationMessage
	From @tempBaseDesignDetail
	Where IsValid = 0;

END

GO

CREATE Or Alter Procedure[dbo].[SaveImportCustomerTypeDetails]
(
	@XmlCustomerTypeData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempCustomerTypeDetail TABLE
	(
		CustomerTypeName VARCHAR(100),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	INSERT INTO @tempCustomerTypeDetail(CustomerTypeName,IsActive,IsValid)
	SELECT
		CustomerTypeName = T.Item.value('CustomerTypeName[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlCustomerTypeData.nodes('/ArrayOfImportedCustomerTypeDetails/ImportedCustomerTypeDetails') AS T(Item)

	
	-- 3. Validation of records
	Update @tempCustomerTypeDetail
	Set IsValid = 0,
		ValidationMessage = 'Customer Type Name value is invalid'
	Where RTRIM(LTRIM(IsNull(CustomerTypeName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempCustomerTypeDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Customer Type Name already Exists'
	FROM @tempCustomerTypeDetail T
	INNER JOIN CustomerTypeMaster PM ON PM.CustomerTypeName = T.CustomerTypeName and T.IsValid=1

	 Insert into CustomerTypeMaster(CustomerTypeName, IsActive,CreatedBy,CreatedOn)
			select CustomerTypeName,
			CASE WHEN IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() from @tempCustomerTypeDetail Where IsValid = 1


	-- 5. Returning Invalid records
	Select CustomerTypeName,IsActive,ValidationMessage
	From @tempCustomerTypeDetail
	Where IsValid = 0;

END

GO

CREATE Or Alter Procedure[dbo].[SaveImportLeaveTypeDetails]
(
	@XmlLeaveTypeData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempLeaveTypeDetail TABLE
	(
		LeaveTypeName VARCHAR(100),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	INSERT INTO @tempLeaveTypeDetail(LeaveTypeName,IsActive,IsValid)
	SELECT
		LeaveTypeName = T.Item.value('LeaveTypeName[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlLeaveTypeData.nodes('/ArrayOfImportedLeaveTypeDetails/ImportedLeaveTypeDetails') AS T(Item)

	
	-- 3. Validation of records
	Update @tempLeaveTypeDetail
	Set IsValid = 0,
		ValidationMessage = 'Leave Type Name value is invalid'
	Where RTRIM(LTRIM(IsNull(LeaveTypeName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempLeaveTypeDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Leave Type Name already Exists'
	FROM @tempLeaveTypeDetail T
	INNER JOIN LeaveTypeMaster PM ON PM.LeaveTypeName = T.LeaveTypeName and T.IsValid=1

	 Insert into LeaveTypeMaster(LeaveTypeName, IsActive,CreatedBy,CreatedOn)
			select LeaveTypeName,
			CASE WHEN IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() from @tempLeaveTypeDetail Where IsValid = 1


	-- 5. Returning Invalid records
	Select LeaveTypeName,IsActive,ValidationMessage
	From @tempLeaveTypeDetail
	Where IsValid = 0;

END

GO

CREATE Or Alter Procedure[dbo].[SaveImportRoleDetails]
(
	@XmlRoleData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempRoleDetail TABLE
	(
		RoleName VARCHAR(100),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	INSERT INTO @tempRoleDetail(RoleName,IsActive,IsValid)
	SELECT
		RoleName = T.Item.value('RoleName[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlRoleData.nodes('/ArrayOfImportedRoleDetails/ImportedRoleDetails') AS T(Item)

	
	-- 3. Validation of records
	Update @tempRoleDetail
	Set IsValid = 0,
		ValidationMessage = 'Role Name value is invalid'
	Where RTRIM(LTRIM(IsNull(RoleName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempRoleDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Role Name already Exists'
	FROM @tempRoleDetail T
	INNER JOIN RoleMaster RM ON RM.RoleName = T.RoleName and T.IsValid=1

	 Insert into RoleMaster(RoleName, IsActive,CreatedBy,CreatedOn)
			select RoleName,
			CASE WHEN IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() from @tempRoleDetail Where IsValid = 1


	-- 5. Returning Invalid records
	Select RoleName,IsActive,ValidationMessage
	From @tempRoleDetail
	Where IsValid = 0;

END

GO

/*
EXEC [dbo].[SaveImportReportingToDetails]
'<ArrayOfImportedReportingToDetails>
  <ImportedReportingToDetails>
    <RoleName>Role 1</RoleName>
    <ReportingToName>Role 2</ReportingToName>
    <IsActive>True</IsActive>
  </ImportedReportingToDetails>
  <ImportedReportingToDetails>
    <RoleName>Role 2</RoleName>
    <ReportingToName>Role 1</ReportingToName>
    <IsActive>False</IsActive>
  </ImportedReportingToDetails>
  <ImportedReportingToDetails>
    <RoleName>Role 1</RoleName>
    <ReportingToName>DD33</ReportingToName>
    <IsActive>kkk</IsActive>
  </ImportedReportingToDetails>
  <ImportedReportingToDetails>
    <RoleName>Demo1</RoleName>
    <ReportingToName>Test</ReportingToName>
    <IsActive>True</IsActive>
  </ImportedReportingToDetails>
  <ImportedReportingToDetails>
    <RoleName>Role 1</RoleName>
    <ReportingToName>De</ReportingToName>
    <IsActive>True</IsActive>
  </ImportedReportingToDetails>
  <ImportedReportingToDetails>
    <RoleName>FF</RoleName>
    <ReportingToName>Role 2</ReportingToName>
    <IsActive>False</IsActive>
  </ImportedReportingToDetails>
</ArrayOfImportedReportingToDetails>',1
*/
CREATE Or Alter Procedure[dbo].[SaveImportReportingToDetails]
(
	@XmlReportingToData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempReportingToDetail TABLE
	(
		RoleName VARCHAR(100),
		ReportingToName VARCHAR(100),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	INSERT INTO @tempReportingToDetail(RoleName,ReportingToName,IsActive,IsValid)
	SELECT
		RoleName = T.Item.value('RoleName[1]', 'varchar(100)'),
		ReportingToName = T.Item.value('ReportingToName[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlReportingToData.nodes('/ArrayOfImportedReportingToDetails/ImportedReportingToDetails') AS T(Item)

	 --3. Validation of records
	Update @tempReportingToDetail
	Set IsValid = 0,
		ValidationMessage = 'Role Name value is invalid'
	Where RTRIM(LTRIM(IsNull(RoleName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempReportingToDetail
	Set IsValid = 0,
		ValidationMessage = 'Reporting To Name value is invalid'
	Where RTRIM(LTRIM(IsNull(ReportingToName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempReportingToDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Role Name is not exists'
	FROM @tempReportingToDetail T
	 LEFT JOIN RoleMaster RM ON  T.RoleName = RM.RoleName  
	 WHERE  RM.RoleName IS NULL  and T.IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Reporting To Name is not exists'
	FROM @tempReportingToDetail T
	LEFT JOIN RoleMaster RM ON  T.ReportingToName = RM.RoleName  
	 WHERE  RM.RoleName IS NULL  and T.IsValid=1

	Insert into ReportingToMaster(RoleId,ReportingTo, IsActive,CreatedBy,CreatedOn)
		select RM.RoleId,RM2.RoleId,
			CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() 
			from @tempReportingToDetail T
			INNER JOIN RoleMaster RM ON RM.RoleName = T.RoleName
			INNER JOIN RoleMaster RM2 ON RM2.RoleName = T.ReportingToName
			Where IsValid = 1


	-- 5. Returning Invalid records
	Select RoleName,ReportingToName,IsActive,ValidationMessage
	From @tempReportingToDetail
	Where IsValid = 0;

END

GO

/*
EXEC SaveImportEmployeeDetails 
'<ArrayOfImportedEmployeeDetails>
  <ImportedEmployeeDetails>
    <EmployeeName>Ronak Test</EmployeeName>
    <EmployeeCode>E00031</EmployeeCode>
    <EmailId>ronaksuchak@gmail.com</EmailId>
    <MobileNumber>8849847882</MobileNumber>
    <RoleName>Admin</RoleName>
    <ReportingToName>Project Manager</ReportingToName>
    <Address>test</Address>
    <StateName>Gujarat</StateName>
    <RegionName>North</RegionName>
    <DistrictName>Rajkot1</DistrictName>
    <AreaName>SK</AreaName>
    <Pincode>101010</Pincode>
    <DateOfBirth>2010-12-10T00:00:00</DateOfBirth>
    <DateOfJoining>2020-01-11T00:00:00</DateOfJoining>
    <EmergencyContactNumber>88888888888</EmergencyContactNumber>
    <BloodGroup>o+</BloodGroup>
    <IsWebUser>Yes</IsWebUser>
    <IsMobileUser>No </IsMobileUser>
    <IsActive>TRUE</IsActive>
  </ImportedEmployeeDetails>
</ArrayOfImportedEmployeeDetails>',1
*/
CREATE Or Alter Procedure[dbo].[SaveImportEmployeeDetails]
(
	@XmlEmployeeData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempEmployeeDetail TABLE
	(
		EmployeeName VARCHAR(100),
		EmployeeCode VARCHAR(100),
		EmailId VARCHAR(100),
		MobileNumber VARCHAR(100),
		RoleName VARCHAR(100),
		ReportingToName VARCHAR(100),
		Address VARCHAR(500),
		StateName VARCHAR(100),
		RegionName VARCHAR(100),
		DistrictName VARCHAR(100),
		AreaName VARCHAR(100),
		Pincode VARCHAR(100),
		DateOfBirth DATETIME,
		DateOfJoining DATETIME,
		EmergencyContactNumber VARCHAR(100),
		BloodGroup VARCHAR(10),
		IsWebUser VARCHAR(10),
		IsMobileUser VARCHAR(10),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	INSERT INTO @tempEmployeeDetail(EmployeeName,EmployeeCode,EmailId,MobileNumber,RoleName,ReportingToName,Address,
				StateName,RegionName,DistrictName,AreaName,Pincode,DateOfBirth,DateOfJoining,EmergencyContactNumber,
				BloodGroup,IsWebUser,IsMobileUser,IsActive,IsValid)
	SELECT
		EmployeeName = T.Item.value('EmployeeName[1]', 'varchar(100)'),
		EmployeeCode = T.Item.value('EmployeeCode[1]', 'varchar(100)'),
		EmailId = T.Item.value('EmailId[1]', 'varchar(100)'),
		MobileNumber = T.Item.value('MobileNumber[1]', 'varchar(100)'),
		RoleName = T.Item.value('RoleName[1]', 'varchar(100)'),
		ReportingToName = T.Item.value('ReportingToName[1]', 'varchar(100)'),
		Address = T.Item.value('Address[1]', 'varchar(500)'),
		StateName = T.Item.value('StateName[1]', 'varchar(100)'),
		RegionName = T.Item.value('RegionName[1]', 'varchar(100)'),
		DistrictName = T.Item.value('DistrictName[1]', 'varchar(100)'),
		AreaName = T.Item.value('AreaName[1]', 'varchar(100)'),
		Pincode = T.Item.value('Pincode[1]', 'varchar(100)'),
		DateOfBirth = T.Item.value('DateOfBirth[1]', 'DATETIME'),
		DateOfJoining = T.Item.value('DateOfJoining[1]', 'DATETIME'),
		EmergencyContactNumber = T.Item.value('EmergencyContactNumber[1]', 'varchar(100)'),
		BloodGroup = T.Item.value('BloodGroup[1]', 'varchar(10)'),
		IsWebUser = T.Item.value('IsWebUser[1]', 'varchar(10)'),
		IsMobileUser = T.Item.value('IsMobileUser[1]', 'varchar(10)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlEmployeeData.nodes('/ArrayOfImportedEmployeeDetails/ImportedEmployeeDetails') AS T(Item)


	 --3. Validation of records
	Update @tempEmployeeDetail
	Set IsValid = 0,
		ValidationMessage = 'Employee Name value is invalid'
	Where RTRIM(LTRIM(IsNull(EmployeeName,''))) Not Like '%[a-zA-Z0-9]%' AND IsValid=1

	Update @tempEmployeeDetail
	Set IsValid = 0,
		ValidationMessage = 'Employee Code value is invalid'
	Where RTRIM(LTRIM(IsNull(EmployeeCode,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempEmployeeDetail
	Set IsValid = 0,
		ValidationMessage = 'Mobile Number is invalid'
	Where ISNUMERIC(RTRIM(LTRIM(IsNull(MobileNumber,''))))=0 AND IsValid=1

	Update @tempEmployeeDetail
	Set IsValid = 0,
		ValidationMessage = 'Email Id is invalid'
	Where RTRIM(LTRIM(IsNull(EmailId,'')))  NOT LIKE '_%@_%._%' AND IsValid=1

	Update @tempEmployeeDetail
	Set IsValid = 0,
		ValidationMessage = 'Role Name value is invalid'
	Where RTRIM(LTRIM(IsNull(RoleName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempEmployeeDetail
	Set IsValid = 0,
		ValidationMessage = 'Reporting To Name value is invalid'
	Where RTRIM(LTRIM(IsNull(ReportingToName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempEmployeeDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Role Name is not exists'
	FROM @tempEmployeeDetail T
	 LEFT JOIN RoleMaster RM ON  T.RoleName = RM.RoleName  
	 WHERE  RM.RoleName IS NULL  and T.IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Reporting To Name is not exists'
	FROM @tempEmployeeDetail T
	LEFT JOIN RoleMaster RM ON  T.ReportingToName = RM.RoleName  
	 WHERE  RM.RoleName IS NULL  and T.IsValid=1

	 UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'State Name is not exists'
	FROM @tempEmployeeDetail T
	LEFT JOIN StateMaster ST ON  T.StateName = ST.StateName  
	 WHERE  ST.StateName IS NULL  and T.IsValid=1

	 UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Region Name is not exists'
	FROM @tempEmployeeDetail T
	LEFT JOIN RegionMaster RM ON  T.RegionName = RM.RegionName  
	LEFT JOIN StateMaster ST ON ST.StateId = RM.StateId
	 WHERE  RM.RegionName IS NULL  and T.IsValid=1

	 UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'District Name is not exists'
	FROM @tempEmployeeDetail T
	LEFT JOIN DistrictMaster DM ON DM.DistrictName=T.DistrictName
	LEFT JOIN RegionMaster RM ON  RM.RegionId = DM.RegionId  
	LEFT JOIN StateMaster ST ON ST.StateId = RM.StateId
	 WHERE  DM.DistrictName IS NULL  and T.IsValid=1


	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Area Name is not exists'
	FROM @tempEmployeeDetail T
	LEFT JOIN AreaMaster AM ON AM.AreaName=T.AreaName
	LEFT JOIN DistrictMaster DM ON DM.DistrictId=AM.DistrictId
	LEFT JOIN RegionMaster RM ON  RM.RegionId = DM.RegionId  
	LEFT JOIN StateMaster ST ON ST.StateId = RM.StateId
	 WHERE  AM.AreaName IS NULL  and T.IsValid=1

	 Update @tempEmployeeDetail
	Set IsValid = 0,
		ValidationMessage = 'Pincode is invalid'
	Where ISNUMERIC(RTRIM(LTRIM(IsNull(Pincode,''))))=0 AND IsValid=1

	DECLARE @tblCnt BIGINT=1,@TotalRecord BIGINT=0;
	 SELECT @TotalRecord=COUNT(0) FROM @tempEmployeeDetail

	 WHILE (@tblCnt <= @TotalRecord)
	 BEGIN

		Insert into EmployeeMaster(EmployeeName,EmployeeCode,EmailId,MobileNumber,RoleId,ReportingTo,DateOfBirth,DateOfJoining,
						EmergencyContactNumber,BloodGroup,IsWebUser,IsMobileUser,IsActive,CreatedBy,CreatedOn)
		select T.EmployeeName,T.EmployeeCode,T.EmailId,T.MobileNumber, RM.RoleId,RM2.RoleId,T.DateOfBirth,T.DateOfJoining,T.EmergencyContactNumber,T.BloodGroup,T.IsWebUser,
			T.IsMobileUser,CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() 
			from @tempEmployeeDetail T
			INNER JOIN RoleMaster RM ON RM.RoleName = T.RoleName
			INNER JOIN RoleMaster RM2 ON RM2.RoleName = T.ReportingToName
			Where IsValid = 1

		SET @Result = SCOPE_IDENTITY();
			
			-- Insert Into Address 
		INSERT INTO AddressMaster(Address,StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn)
		SELECT Address,ST.StateId,RM.RegionId,DM.DistrictId,AM.AreaId,T.Pincode,1,CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END ,@LoggedInUserId,GETDATE() 
			FROM @tempEmployeeDetail T
			INNER JOIN StateMaster ST ON ST.StateName=T.StateName
			INNER JOIN RegionMaster RM ON RM.StateId= ST.StateId AND RM.RegionName=T.RegionName
			INNER JOIN DistrictMaster DM ON DM.RegionId=RM.RegionId AND DM.DistrictName=T.DistrictName
			INNER JOIN AreaMaster AM ON AM.DistrictId=DM.DistrictId AND AM.AreaName=T.AreaName
			Where IsValid = 1
		
		SET @AddressId = SCOPE_IDENTITY();

		INSERT INTO EmployeeAddressMapping(EmployeeId,AddressId) Values (@Result,@AddressId)

		 SET @tblCnt = @tblCnt + 1;

	 END


	-- 5. Returning Invalid records
	Select EmployeeName,EmployeeCode,EmailId,MobileNumber, RoleName,ReportingToName,Address,StateName,RegionName,DistrictName,AreaName,Pincode
			,DateOfBirth,DateOfJoining,EmergencyContactNumber,BloodGroup,IsWebUser,
			IsMobileUser, IsActive,ValidationMessage
	From @tempEmployeeDetail
	Where IsValid = 0;

END


GO

CREATE Or Alter Procedure[dbo].[SaveImportStateDetails]
(
	@XmlStateData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempStateDetail TABLE
	(
		StateName VARCHAR(100),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	INSERT INTO @tempStateDetail(StateName,IsActive,IsValid)
	SELECT
		StateName = T.Item.value('StateName[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlStateData.nodes('/ArrayOfImportedStateDetails/ImportedStateDetails') AS T(Item)

	
	-- 3. Validation of records
	Update @tempStateDetail
	Set IsValid = 0,
		ValidationMessage = 'State Name is invalid'
	Where RTRIM(LTRIM(IsNull(StateName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempStateDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'State Name already Exists'
	FROM @tempStateDetail T
	INNER JOIN  StateMaster PM ON PM.StateName = T.StateName and T.IsValid=1

	 Insert into StateMaster(StateName, IsActive,CreatedBy,CreatedOn)
			select StateName,
			CASE WHEN IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() from @tempStateDetail Where IsValid = 1


	-- 5. Returning Invalid records
	Select StateName,IsActive,ValidationMessage
	From @tempStateDetail
	Where IsValid = 0;

END

GO/*
EXEC SaveImportRegionDetails
'<ArrayOfImportedRegionDetails>
  <ImportedRegionDetails>
    <RegionName>Region 1</RegionName>
    <StateName>Maharastra</StateName>
    <IsActive>True</IsActive>
  </ImportedRegionDetails>
  <ImportedRegionDetails>
    <RegionName>Region 2</RegionName>
    <StateName>Rajasthan</StateName>
    <IsActive>False</IsActive>
  </ImportedRegionDetails>
  <ImportedRegionDetails>
    <RegionName>Region 3</RegionName>
    <StateName>UP</StateName>
    <IsActive>kkk</IsActive>
  </ImportedRegionDetails>
</ArrayOfImportedRegionDetails>',1
*/
CREATE Or Alter Procedure[dbo].[SaveImportRegionDetails]
(
	@XmlRegionData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempRegionDetail TABLE
	(
		StateName VARCHAR(100),
		RegionName VARCHAR(100),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	INSERT INTO @tempRegionDetail(StateName,RegionName,IsActive,IsValid)
	SELECT
		StateName = T.Item.value('StateName[1]', 'varchar(100)'),
		RegionName = T.Item.value('RegionName[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlRegionData.nodes('/ArrayOfImportedRegionDetails/ImportedRegionDetails') AS T(Item)

	 --3. Validation of records
	Update @tempRegionDetail
	Set IsValid = 0,
		ValidationMessage = 'Region Name is invalid'
	Where RTRIM(LTRIM(IsNull(RegionName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempRegionDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Region Name already Exists'
	FROM @tempRegionDetail T
	INNER JOIN  RegionMaster PM ON PM.RegionName = T.RegionName and T.IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'State Name is not exists'
	FROM @tempRegionDetail T
	LEFT JOIN StateMaster ST ON ST.StateName = T.StateName
	 WHERE  ST.StateName IS NULL  and T.IsValid=1

	 Insert into RegionMaster(StateId,RegionName, IsActive,CreatedBy,CreatedOn)
			select ST.StateId,RegionName,
			CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() from @tempRegionDetail T
			INNER JOIN StateMaster ST on ST.StateName=T.StateName
			Where IsValid = 1


	-- 5. Returning Invalid records
	Select StateName,RegionName,IsActive,ValidationMessage
	From @tempRegionDetail
	Where IsValid = 0;

END

GO

CREATE Or Alter Procedure[dbo].[SaveImportDistrictDetails]
(
	@XmlDistrictData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempDistrictDetail TABLE
	(
		StateName VARCHAR(100),
		RegionName VARCHAR(100),
		DistrictName VARCHAR(100),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	INSERT INTO @tempDistrictDetail(StateName,RegionName,DistrictName,IsActive,IsValid)
	SELECT
		StateName = T.Item.value('StateName[1]', 'varchar(100)'),
		RegionName = T.Item.value('RegionName[1]', 'varchar(100)'),
		DistrictName = T.Item.value('DistrictName[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlDistrictData.nodes('/ArrayOfImportedDistrictDetails/ImportedDistrictDetails') AS T(Item)

	
	-- 3. Validation of records
	Update @tempDistrictDetail
	Set IsValid = 0,
		ValidationMessage = 'District Name is invalid'
	Where RTRIM(LTRIM(IsNull(DistrictName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempDistrictDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'District Name already Exists'
	FROM @tempDistrictDetail T
	INNER JOIN  DistrictMaster DM ON DM.DistrictName = T.DistrictName and T.IsValid=1

	
	  UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'State Name is not exists'
	FROM @tempDistrictDetail T
	LEFT JOIN StateMaster ST ON ST.StateName=T.StateName
	 WHERE ST.StateName IS NULL AND  T.IsValid=1

	   UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Region Name is not exists'
	FROM @tempDistrictDetail T
	LEFT JOIN RegionMaster RM ON RM.RegionName=T.RegionName
	LEFT JOIN StateMaster ST ON ST.StateId=RM.StateId AND ST.StateName=T.StateName
	 WHERE ST.StateName IS NULL AND T.IsValid=1

	 Insert into DistrictMaster(RegionId,DistrictName, IsActive,CreatedBy,CreatedOn)
			select RG.RegionId,T.DistrictName,
			CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() 
			from @tempDistrictDetail T
			INNER JOIN RegionMaster RG ON RG.RegionName=T.RegionName
			--INNER JOIN StateMaster ST on ST.StateName=T.StateName
			Where IsValid = 1


	-- 5. Returning Invalid records
	Select StateName,RegionName,DistrictName,IsActive,ValidationMessage
	From @tempDistrictDetail
	Where IsValid = 0;

END

GO

/*
EXEC SaveImportAreaDetails 
'<ArrayOfImportedAreaDetails>
  <ImportedAreaDetails>
    <AreaName>Ring Road11155</AreaName>
    <DistrictName>Rajkot</DistrictName>
    <RegionName>North</RegionName>
    <StateName>Maharastra</StateName>
    <IsActive>True</IsActive>
  </ImportedAreaDetails>
</ArrayOfImportedAreaDetails>',1
*/
CREATE Or Alter Procedure[dbo].[SaveImportAreaDetails]
(
	@XmlAreaData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempAreaDetail TABLE
	(
		StateName VARCHAR(100),
		RegionName VARCHAR(100),
		DistrictName VARCHAR(100),
		AreaName VARCHAR(100),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	INSERT INTO @tempAreaDetail(StateName,RegionName,DistrictName,AreaName, IsActive,IsValid)
	SELECT
		StateName = T.Item.value('StateName[1]', 'varchar(100)'),
		RegionName = T.Item.value('RegionName[1]', 'varchar(100)'),
		DistrictName = T.Item.value('DistrictName[1]', 'varchar(100)'),
		AreaName = T.Item.value('AreaName[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlAreaData.nodes('/ArrayOfImportedAreaDetails/ImportedAreaDetails') AS T(Item)

	-- 3. Validation of records
	Update @tempAreaDetail
	Set IsValid = 0,
		ValidationMessage = 'Area Name is invalid'
	Where RTRIM(LTRIM(IsNull(AreaName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempAreaDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Area Name already Exists'
	FROM @tempAreaDetail T
	INNER JOIN  AreaMaster AM ON AM.AreaName = T.AreaName and T.IsValid=1

	

	  UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'State Name is not exists'
	FROM @tempAreaDetail T
	LEFT JOIN StateMaster ST ON ST.StateName=T.StateName
	 WHERE ST.StateName IS NULL AND  T.IsValid=1

	   UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Region Name is not exists'
	FROM @tempAreaDetail T
	LEFT JOIN RegionMaster RM ON RM.RegionName=T.RegionName
	LEFT JOIN StateMaster ST ON ST.StateId=RM.StateId AND ST.StateName=T.StateName
	 WHERE ST.StateName IS NULL AND T.IsValid=1

	 UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'District Name is not exists'
	 FROM @tempAreaDetail T
	LEFT JOIN DistrictMaster DM ON  T.DistrictName = DM.DistrictName  
	LEFT JOIN RegionMaster RM ON DM.RegionId=RM.RegionId AND T.RegionName=RM.RegionName
	LEFT JOIN StateMaster ST ON ST.StateId=RM.StateId AND ST.StateName=T.StateName
	 WHERE RM.RegionName IS NULL  and T.IsValid=1


	-- UPDATE T
	--SET IsValid = 0,
	--	ValidationMessage = 'Region Name is not exists'
	--FROM @tempAreaDetail T
	--LEFT JOIN DistrictMaster DM ON  T.DistrictName = DM.DistrictName  
	--INNER JOIN RegionMaster RM ON RM.RegionId=DM.RegionId
	-- WHERE  RM.RegionName IS NULL  and T.IsValid=1

	--  UPDATE T
	--SET IsValid = 0,
	--	ValidationMessage = 'State Name is not exists'
	--FROM @tempAreaDetail T
	--LEFT JOIN DistrictMaster DM ON  T.DistrictName = DM.DistrictName  
	--INNER JOIN RegionMaster RM ON RM.RegionId=DM.RegionId
	--INNER JOIN StateMaster ST ON ST.StateId=RM.StateId
	-- WHERE  ST.StateName IS NULL  and T.IsValid=1

	 Insert into AreaMaster(DistrictId,AreaName, IsActive,CreatedBy,CreatedOn)
			select RG.DistrictId,T.AreaName,
			CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() 
			from @tempAreaDetail T
			INNER JOIN DistrictMaster RG ON RG.DistrictName=T.DistrictName
			Where IsValid = 1


	-- 5. Returning Invalid records
	Select StateName,RegionName,DistrictName,AreaName,IsActive,ValidationMessage
	From @tempAreaDetail
	Where IsValid = 0;

END

GO

CREATE Or Alter Procedure[dbo].[SaveImportReferenceDetails]
(
	@XmlReferenceData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempReferenceDetail TABLE
	(
		UniqueNumber VARCHAR(100),
		ReferenceParty VARCHAR(100),
		Address VARCHAR(500),
		StateName VARCHAR(100),
		RegionName VARCHAR(100),
		DistrictName VARCHAR(100),
		AreaName VARCHAR(100),
		Pincode VARCHAR(10),
		PhoneNumber VARCHAR(100),
		MobileNumber VARCHAR(50),
		GSTNumber VARCHAR(20),
		PanNumber VARCHAR(10),
		EmailId VARCHAR(250),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	INSERT INTO @tempReferenceDetail(ReferenceParty,Address,StateName,RegionName,DistrictName,AreaName,Pincode,PhoneNumber,MobileNumber,
				GSTNumber,PanNumber,EmailId,IsActive,IsValid)
	SELECT
		ReferenceParty = T.Item.value('ReferenceParty[1]', 'varchar(100)'),
		Address = T.Item.value('Address[1]', 'varchar(500)'),
		StateName = T.Item.value('StateName[1]', 'varchar(100)'),
		RegionName = T.Item.value('RegionName[1]', 'varchar(100)'),
		DistrictName = T.Item.value('DistrictName[1]', 'varchar(100)'),
		AreaName = T.Item.value('AreaName[1]', 'varchar(100)'),
		Pincode = T.Item.value('Pincode[1]', 'varchar(10)'),
		PhoneNumber = T.Item.value('PhoneNumber[1]', 'varchar(100)'),
		MobileNumber = T.Item.value('MobileNumber[1]', 'varchar(50)'),
		GSTNumber = T.Item.value('GSTNumber[1]', 'varchar(10)'),
		PanNumber = T.Item.value('PanNumber[1]', 'varchar(250)'),
		EmailId = T.Item.value('EmailId[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlReferenceData.nodes('/ArrayOfImportedReferenceDetails/ImportedReferenceDetails') AS T(Item)

	
	-- 3. Validation of records
	Update @tempReferenceDetail
	Set IsValid = 0,
		ValidationMessage = 'Reference Party is invalid'
	Where RTRIM(LTRIM(IsNull(ReferenceParty,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempReferenceDetail
	Set IsValid = 0,
		ValidationMessage = 'Mobile Number is invalid'
	Where ISNUMERIC(RTRIM(LTRIM(IsNull(MobileNumber,''))))=0 AND IsValid=1

	Update @tempReferenceDetail
	Set IsValid = 0,
		ValidationMessage = 'Phone Number is invalid'
	Where ISNUMERIC(RTRIM(LTRIM(IsNull(PhoneNumber,''))))=0 AND IsValid=1

	Update @tempReferenceDetail
	Set IsValid = 0,
		ValidationMessage = 'Email Id is invalid'
	Where RTRIM(LTRIM(IsNull(EmailId,'')))  NOT LIKE '_%@_%._%' AND IsValid=1

	Update @tempReferenceDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Reference Party already Exists'
	FROM @tempReferenceDetail T
	INNER JOIN  ReferenceMaster RM ON RM.PartyName = T.ReferenceParty and T.IsValid=1

	 UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'State Name is not exists'
	FROM @tempReferenceDetail T
	LEFT JOIN StateMaster ST ON ST.StateName=T.StateName
	 WHERE ST.StateName IS NULL AND  T.IsValid=1

	   UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Region Name is not exists'
	FROM @tempReferenceDetail T
	LEFT JOIN RegionMaster RM ON RM.RegionName=T.RegionName
	LEFT JOIN StateMaster ST ON ST.StateId=RM.StateId AND ST.StateName=T.StateName
	 WHERE ST.StateName IS NULL AND T.IsValid=1

	 UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'District Name is not exists'
	 FROM @tempReferenceDetail T
	LEFT JOIN DistrictMaster DM ON  T.DistrictName = DM.DistrictName  
	LEFT JOIN RegionMaster RM ON DM.RegionId=RM.RegionId AND T.RegionName=RM.RegionName
	LEFT JOIN StateMaster ST ON ST.StateId=RM.StateId AND ST.StateName=T.StateName
	 WHERE RM.RegionName IS NULL  and T.IsValid=1

	 UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Area Name is not exists'
	 FROM @tempReferenceDetail T
	LEFT JOIN AreaMaster AM ON  T.AreaName = AM.AreaName  
	LEFT JOIN DistrictMaster DM ON DM.DistrictId=AM.DistrictId AND  T.DistrictName = DM.DistrictName  
	LEFT JOIN RegionMaster RM ON DM.RegionId=RM.RegionId AND T.RegionName=RM.RegionName
	LEFT JOIN StateMaster ST ON ST.StateId=RM.StateId AND ST.StateName=T.StateName
	 WHERE DM.DistrictName IS NULL  and T.IsValid=1

	 Update @tempReferenceDetail
	Set IsValid = 0,
		ValidationMessage = 'Pincode is invalid'
	Where ISNUMERIC(RTRIM(LTRIM(IsNull(Pincode,''))))=0 AND IsValid=1


	 DECLARE @tblCnt BIGINT=1,@TotalRecord BIGINT=0;
	 SELECT @TotalRecord=COUNT(0) FROM @tempReferenceDetail

	 DECLARE @UniqueNo BIGINT=0;
	 SELECT @UniqueNo= COUNT(0) FROM ReferenceMaster

	 WHILE (@tblCnt <= @TotalRecord)
	 BEGIN
		 Insert into ReferenceMaster(UniqueNumber,PartyName,PhoneNumber,MobileNumber,GSTNumber,PanNumber,EmailId, IsActive,CreatedBy,CreatedOn)
			select CONCAT('Ref00', @UniqueNo+@tblCnt),ReferenceParty,PhoneNumber,MobileNumber,GSTNumber,PanNumber,EmailId,
			CASE WHEN IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() from @tempReferenceDetail Where IsValid = 1

			SET @Result = SCOPE_IDENTITY();


		 INSERT INTO AddressMaster(Address,StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn)
		 SELECT Address,ST.StateId,RM.RegionId,DM.DistrictId,AM.AreaId,T.Pincode,1,CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END ,@LoggedInUserId,GETDATE() 
			FROM @tempReferenceDetail T
			INNER JOIN StateMaster ST ON ST.StateName=T.StateName
			INNER JOIN RegionMaster RM ON RM.StateId= ST.StateId AND RM.RegionName=T.RegionName
			INNER JOIN DistrictMaster DM ON DM.RegionId=RM.RegionId AND DM.DistrictName=T.DistrictName
			INNER JOIN AreaMaster AM ON AM.DistrictId=DM.DistrictId AND AM.AreaName=T.AreaName
			Where IsValid = 1

			SET @AddressId = SCOPE_IDENTITY();

			INSERT INTO ReferenceAddressMapping(ReferenceId,AddressId)
			Values (@Result,@AddressId)
			
		 SET @tblCnt = @tblCnt + 1;
			
	 END

	-- 5. Returning Invalid records
	Select ReferenceParty,Address,StateName,RegionName,DistrictName,AreaName,Pincode, PhoneNumber,MobileNumber,GSTNumber,PanNumber,EmailId, IsActive,ValidationMessage
	From @tempReferenceDetail
	Where IsValid = 0;

END

GO

/*
EXEC SaveImportVisitDetails
'<ArrayOfImportedVisitDetails>
  <ImportedVisitDetails>
    <VisitDate>2023-08-19T00:00:00</VisitDate>
    <EmployeeName>piyush</EmployeeName>
    <CustomerTypeName>test</CustomerTypeName>
    <CustomerName>Vishal and Co</CustomerName>
    <StateName>Gujarat</StateName>
    <RegionName>NORTH</RegionName>
    <DistrictName>Rajkot</DistrictName>
    <AreaName>SK</AreaName>
    <ContactPerson>Ronak</ContactPerson>
    <ContactNumber>8849847882</ContactNumber>
    <EmailId>ronak@gmail.com</EmailId>
    <NextActionDate>2023-08-20T00:00:00</NextActionDate>
    <Latitude>111.2525</Latitude>
    <Longitude>912.12633</Longitude>
    <Address>Jesar Road</Address>
    <Remarks>SK</Remarks>
    <IsActive>True</IsActive>
  </ImportedVisitDetails>
  <ImportedVisitDetails>
    <VisitDate>2023-08-19T00:00:00</VisitDate>
    <EmployeeName>piyush</EmployeeName>
    <CustomerTypeName>test</CustomerTypeName>
    <StateName>Gujarat</StateName>
    <RegionName>NORTH</RegionName>
    <DistrictName>Rajkot</DistrictName>
    <AreaName>SK</AreaName>
    <ContactPerson>Ronak</ContactPerson>
    <ContactNumber>8849847882</ContactNumber>
    <EmailId>ronak@gmail.com</EmailId>
    <NextActionDate>2023-08-20T00:00:00</NextActionDate>
    <Latitude>111.2525</Latitude>
    <Longitude>912.12633</Longitude>
    <Address>Jesar Road</Address>
    <Remarks>SK</Remarks>
    <IsActive>True</IsActive>
  </ImportedVisitDetails>
  <ImportedVisitDetails>
    <VisitDate>2023-08-19T00:00:00</VisitDate>
    <EmployeeName>piyush</EmployeeName>
    <CustomerTypeName>test</CustomerTypeName>
    <StateName>Gujarat</StateName>
    <RegionName>NORTH</RegionName>
    <DistrictName>Rajkot</DistrictName>
    <AreaName>SK</AreaName>
    <ContactPerson>Ronak</ContactPerson>
    <ContactNumber>8849847882</ContactNumber>
    <EmailId>ronak@gmail.com</EmailId>
    <NextActionDate>2023-08-20T00:00:00</NextActionDate>
    <Latitude>111.2525</Latitude>
    <Longitude>912.12633</Longitude>
    <Address>Jesar Road</Address>
    <Remarks>SK</Remarks>
    <IsActive>True</IsActive>
  </ImportedVisitDetails>
  <ImportedVisitDetails>
    <VisitDate>2023-08-19T00:00:00</VisitDate>
    <EmployeeName>piyush</EmployeeName>
    <CustomerTypeName>test</CustomerTypeName>
    <StateName>Gujarat</StateName>
    <RegionName>NORTH</RegionName>
    <DistrictName>Rajkot</DistrictName>
    <AreaName>SK</AreaName>
    <ContactPerson>Ronak</ContactPerson>
    <ContactNumber>8849847882</ContactNumber>
    <EmailId>ronak@gmail.com</EmailId>
    <NextActionDate>2023-08-20T00:00:00</NextActionDate>
    <Latitude>111.2525</Latitude>
    <Longitude>912.12633</Longitude>
    <Address>Jesar Road</Address>
    <Remarks>SK</Remarks>
    <IsActive>True</IsActive>
  </ImportedVisitDetails>
  <ImportedVisitDetails>
    <VisitDate>2023-08-19T00:00:00</VisitDate>
    <EmployeeName>piyush</EmployeeName>
    <CustomerTypeName>test</CustomerTypeName>
    <StateName>Gujarat</StateName>
    <RegionName>NORTH</RegionName>
    <DistrictName>Rajkot</DistrictName>
    <AreaName>SK</AreaName>
    <ContactPerson>Ronak</ContactPerson>
    <ContactNumber>8849847882</ContactNumber>
    <EmailId>ronak@gmail.com</EmailId>
    <NextActionDate>2023-08-20T00:00:00</NextActionDate>
    <Latitude>111.2525</Latitude>
    <Longitude>912.12633</Longitude>
    <Address>Jesar Road</Address>
    <Remarks>SK</Remarks>
    <IsActive>True</IsActive>
  </ImportedVisitDetails>
  <ImportedVisitDetails>
    <VisitDate>2023-08-19T00:00:00</VisitDate>
    <EmployeeName>piyush</EmployeeName>
    <CustomerTypeName>test</CustomerTypeName>
    <CustomerName>Vishal and Co</CustomerName>
    <StateName>Gujarat</StateName>
    <RegionName>NORTH</RegionName>
    <DistrictName>Rajkot</DistrictName>
    <AreaName>SK</AreaName>
    <ContactPerson>Ronak</ContactPerson>
    <ContactNumber>8849847882</ContactNumber>
    <EmailId>ronak@gmail.com</EmailId>
    <NextActionDate>2023-08-20T00:00:00</NextActionDate>
    <Latitude>111.2525</Latitude>
    <Longitude>912.12633</Longitude>
    <Address>Jesar Road</Address>
    <Remarks>SK</Remarks>
    <IsActive>True</IsActive>
  </ImportedVisitDetails>
</ArrayOfImportedVisitDetails>',1

*/

CREATE Or Alter Procedure[dbo].[SaveImportVisitDetails]
(
	@XmlVisitData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempVisitDetail TABLE
	(
		VisitDate Datetime,
		RoleName VARCHAR(100),
		EmployeeName VARCHAR(100),
		CustomerTypeName VARCHAR(100),
		CustomerName VARCHAR(100),
		StateName VARCHAR(100),
		RegionName VARCHAR(100),
		DistrictName VARCHAR(100),
		AreaName VARCHAR(100),
		ContactPerson VARCHAR(100),
		ContactNumber VARCHAR(100),
		EmailId VARCHAR(100),
		NextActionDate Datetime,
		Latitude Decimal(9,6),
		Longitude Decimal(9,6),
		Address VARCHAR(500),
		Remarks VARCHAR(500),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	INSERT INTO @tempVisitDetail(VisitDate,RoleName,EmployeeName,CustomerTypeName,CustomerName,StateName,RegionName,DistrictName,AreaName,ContactPerson,ContactNumber,EmailId,NextActionDate,
				Latitude,Longitude,Address,Remarks,IsActive,IsValid)
	SELECT
		VisitDate = T.Item.value('VisitDate[1]', 'DATETIME'),
		RoleName = T.Item.value('RoleName[1]', 'varchar(100)'),
		EmployeeName = T.Item.value('EmployeeName[1]', 'varchar(100)'),
		CustomerTypeName = T.Item.value('CustomerTypeName[1]', 'varchar(100)'),
		CustomerName = T.Item.value('CustomerName[1]', 'varchar(100)'),
		StateName = T.Item.value('StateName[1]', 'varchar(100)'),
		RegionName = T.Item.value('RegionName[1]', 'varchar(100)'),
		DistrictName = T.Item.value('DistrictName[1]', 'varchar(100)'),
		AreaName = T.Item.value('AreaName[1]', 'varchar(100)'),
		ContactPerson = T.Item.value('ContactPerson[1]', 'varchar(100)'),
		ContactNumber = T.Item.value('ContactNumber[1]', 'varchar(100)'),
		EmailId = T.Item.value('EmailId[1]', 'varchar(100)'),
		NextActionDate = T.Item.value('NextActionDate[1]', 'DATETIME'),
		Latitude = T.Item.value('Latitude[1]', 'Decimal(9,6)'),
		Longitude = T.Item.value('Longitude[1]', 'Decimal(9,6)'),
		Address = T.Item.value('Address[1]', 'varchar(500)'),
		Remarks = T.Item.value('Remarks[1]', 'varchar(500)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlVisitData.nodes('/ArrayOfImportedVisitDetails/ImportedVisitDetails') AS T(Item)

	 
	-- 3. Validation of records
	Update @tempVisitDetail
	Set IsValid = 0,
		ValidationMessage = 'Visit Date is invalid'
	Where ISDATE((IsNull(VisitDate,'')))=0  AND IsValid=1

	Update @tempVisitDetail
	Set IsValid = 0,
		ValidationMessage = 'Employee Name is invalid'
	Where RTRIM(LTRIM(IsNull(EmployeeName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempVisitDetail
	Set IsValid = 0,
		ValidationMessage = 'Customer Type Name is invalid'
	Where RTRIM(LTRIM(IsNull(CustomerTypeName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempVisitDetail
	Set IsValid = 0,
		ValidationMessage = 'Customer Name is invalid'
	Where RTRIM(LTRIM(IsNull(CustomerName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempVisitDetail
	Set IsValid = 0,
		ValidationMessage = 'State Name is invalid'
	Where RTRIM(LTRIM(IsNull(StateName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempVisitDetail
	Set IsValid = 0,
		ValidationMessage = 'Region Name is invalid'
	Where RTRIM(LTRIM(IsNull(RegionName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempVisitDetail
	Set IsValid = 0,
		ValidationMessage = 'District Name is invalid'
	Where RTRIM(LTRIM(IsNull(DistrictName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempVisitDetail
	Set IsValid = 0,
		ValidationMessage = 'Contact Number is invalid'
	Where ISNUMERIC(RTRIM(LTRIM(IsNull(ContactNumber,''))))=0 AND IsValid=1

	Update @tempVisitDetail
	Set IsValid = 0,
		ValidationMessage = 'Email Id is invalid'
	Where RTRIM(LTRIM(IsNull(EmailId,'')))  NOT LIKE '_%@_%._%' AND IsValid=1

	Update @tempVisitDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Employee Name is not exists'
	FROM @tempVisitDetail T
	LEFT JOIN EmployeeMaster EM ON EM.EmployeeName = T.EmployeeName
	 WHERE  EM.EmployeeName IS NULL  and T.IsValid=1

	 UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Customer Name is not exists'
	FROM @tempVisitDetail T
	LEFT JOIN CustomerDetails CM ON CM.CompanyName = T.CustomerName
	 WHERE  CM.CompanyName IS NULL  and T.IsValid=1

	 UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'State Name is not exists'
	FROM @tempVisitDetail T
	LEFT JOIN StateMaster ST ON ST.StateName=T.StateName
	 WHERE ST.StateName IS NULL AND  T.IsValid=1

	   UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Region Name is not exists'
	FROM @tempVisitDetail T
	LEFT JOIN RegionMaster RM ON RM.RegionName=T.RegionName
	LEFT JOIN StateMaster ST ON ST.StateId=RM.StateId AND ST.StateName=T.StateName
	 WHERE ST.StateName IS NULL AND T.IsValid=1

	 UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'District Name is not exists'
	 FROM @tempVisitDetail T
	LEFT JOIN DistrictMaster DM ON  T.DistrictName = DM.DistrictName  
	LEFT JOIN RegionMaster RM ON DM.RegionId=RM.RegionId AND T.RegionName=RM.RegionName
	LEFT JOIN StateMaster ST ON ST.StateId=RM.StateId AND ST.StateName=T.StateName
	 WHERE RM.RegionName IS NULL  and T.IsValid=1

	 UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Area Name is not exists'
	 FROM @tempVisitDetail T
	LEFT JOIN AreaMaster AM ON  T.AreaName = AM.AreaName  
	LEFT JOIN DistrictMaster DM ON DM.DistrictId=AM.DistrictId AND  T.DistrictName = DM.DistrictName  
	LEFT JOIN RegionMaster RM ON DM.RegionId=RM.RegionId AND T.RegionName=RM.RegionName
	LEFT JOIN StateMaster ST ON ST.StateId=RM.StateId AND ST.StateName=T.StateName
	 WHERE DM.DistrictName IS NULL  and T.IsValid=1


	 DECLARE @tblCnt BIGINT=1,@TotalRecord BIGINT=0;
	 SELECT @TotalRecord=COUNT(0) FROM @tempVisitDetail

	 WHILE (@tblCnt <= @TotalRecord)
	 BEGIN
		 Insert into VisitMaster(
				EmployeeId,VisitDate,CustomerId,CustomerTypeId,ContactPerson,ContactNumber,EmailId,NextActionDate,
				Latitude,Longitude,IsActive,CreatedBy,CreatedOn,VisitStatusId)
			select EM.EmployeeId,T.VisitDate,CD.CustomerId,CTM.CustomerTypeId,ContactPerson,ContactNumber,T.EmailId,NextActionDate,
				Latitude,Longitude,
			CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE(),1 from @tempVisitDetail T
			INNER JOIN EmployeeMaster EM ON EM.EmployeeName=T.EmployeeName
			Inner Join CustomerDetails CD ON CD.CompanyName=T.CustomerName
			Inner JOIN CustomerTypeMaster CTM ON CTM.CustomerTypeName = T.CustomerTypeName
			Where IsValid = 1

			SET @Result = SCOPE_IDENTITY();

		 INSERT INTO AddressMaster(Address,StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn)
		 SELECT Address,ST.StateId,RM.RegionId,DM.DistrictId,AM.AreaId,0,1,CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END ,@LoggedInUserId,GETDATE() 
			FROM @tempVisitDetail T
			INNER JOIN StateMaster ST ON ST.StateName=T.StateName
			INNER JOIN RegionMaster RM ON RM.StateId= ST.StateId AND RM.RegionName=T.RegionName
			INNER JOIN DistrictMaster DM ON DM.RegionId=RM.RegionId AND DM.DistrictName=T.DistrictName
			INNER JOIN AreaMaster AM ON AM.DistrictId=DM.DistrictId AND AM.AreaName=T.AreaName
			Where IsValid = 1

			SET @AddressId = SCOPE_IDENTITY();

			INSERT INTO VisitRemarks
			(
				VisitId, Remarks, IsDeleted, CreatedOn, CreatedBy
			)
			SELECT
				@Result, Remarks, 0, GETDATE(), @LoggedInUserId FROM @tempVisitDetail Where IsValid = 1

			INSERT INTO VisitAddressMapping(VisitId,AddressId)
			Values (@Result,@AddressId)
			
		 SET @tblCnt = @tblCnt + 1;
			
	 END

	-- 5. Returning Invalid records
	Select 
		VisitDate ,RoleName ,EmployeeName ,CustomerTypeName ,CustomerName,StateName,RegionName,DistrictName,AreaName,ContactPerson,
		ContactNumber,EmailId,NextActionDate,Latitude,Longitude,Address,Remarks,IsValid, IsActive,ValidationMessage
	From @tempVisitDetail
	Where IsValid = 0;
END

GO

CREATE Or Alter Procedure[dbo].[SaveImportCustomerDetails]
(
	@XmlCustomerData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @ContactId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempCustomerDetail TABLE
	(
		CompanyName VARCHAR(100),
		LandlineNo VARCHAR(100),
		MobileNumber VARCHAR(100),
		EmailId VARCHAR(100),
		CustomerTypeName VARCHAR(100),
		SpecialRemarks VARCHAR(250),
		EmployeeRoleName VARCHAR(100),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	DECLARE @tempCustomerContactDetail TABLE
	(
		
		ContactName VARCHAR(100),
		MobileNo VARCHAR(100),
		EmailAddress VARCHAR(100),
		RefPartyName VARCHAR(100),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)

	)
	DECLARE @tempCustomerAddressDetail TABLE 
	(
		Address VARCHAR(500),
		StateName VARCHAR(100),
		RegionName VARCHAR(100),
		DistrictName VARCHAR(100),
		AreaName VARCHAR(100),
		Pincode VARCHAR(100),
		NameForAddress VARCHAR(100),
		BuyerMobileNo VARCHAR(100),
		BuyerEmailId VARCHAR(100),
		AddressTypeName VARCHAR(100),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)

	)
	INSERT INTO @tempCustomerDetail(CompanyName,LandlineNo,MobileNumber,EmailId,CustomerTypeName,SpecialRemarks,EmployeeRoleName,
				IsActive,IsValid)
	SELECT
		CompanyName = T.Item.value('CompanyName[1]', 'varchar(100)'),
		LandlineNo = T.Item.value('LandlineNo[1]', 'varchar(100)'),
		MobileNumber = T.Item.value('MobileNumber[1]', 'varchar(100)'),
		EmailId = T.Item.value('EmailId[1]', 'varchar(500)'),
		CustomerTypeName = T.Item.value('CustomerTypeName[1]', 'varchar(100)'),
		SpecialRemarks = T.Item.value('SpecialRemarks[1]', 'varchar(250)'),
		EmployeeRoleName = T.Item.value('EmployeeRoleName[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlCustomerData.nodes('/ArrayOfImportedCustomerDetails/ImportedCustomerDetails') AS T(Item)

	INSERT INTO @tempCustomerContactDetail(ContactName,MobileNo,EmailAddress,RefPartyName,IsActive,IsValid)
	SELECT
		ContactName = T.Item.value('ContactName[1]', 'varchar(100)'),
		MobileNo = T.Item.value('MobileNo[1]', 'varchar(100)'),
		EmailAddress = T.Item.value('EmailAddress[1]', 'varchar(100)'),
		RefPartyName = T.Item.value('RefPartyName[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),
		1
		FROM
	 @XmlCustomerData.nodes('/ArrayOfImportedCustomerDetails/ImportedCustomerDetails/contactDetails/ImportContactDetail') AS T(Item)

	 INSERT INTO @tempCustomerAddressDetail(Address,StateName,RegionName,DistrictName,AreaName,Pincode,NameForAddress,BuyerMobileNo,BuyerEmailId,AddressTypeName,IsActive,IsValid)
	SELECT
		Address = T.Item.value('Address[1]', 'varchar(500)'),
		StateName = T.Item.value('StateName[1]', 'varchar(100)'),
		RegionName = T.Item.value('RegionName[1]', 'varchar(100)'),
		DistrictName = T.Item.value('DistrictName[1]', 'varchar(100)'),
		AreaName = T.Item.value('AreaName[1]', 'varchar(100)'),
		Pincode = T.Item.value('Pincode[1]', 'varchar(100)'),
		NameForAddress = T.Item.value('NameForAddress[1]', 'varchar(100)'),
		BuyerMobileNo = T.Item.value('BuyerMobileNo[1]', 'varchar(100)'),
		BuyerEmailId = T.Item.value('BuyerEmailId[1]', 'varchar(100)'),
		AddressTypeName = T.Item.value('AddressTypeName[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),
		1
		FROM
	 @XmlCustomerData.nodes('/ArrayOfImportedCustomerDetails/ImportedCustomerDetails/addressDetails/ImportAddressDetail') AS T(Item)


	-- 3. Validation of records

	Update @tempCustomerDetail
	Set IsValid = 0,
		ValidationMessage = 'Company Name is invalid'
	Where RTRIM(LTRIM(IsNull(CompanyName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempCustomerDetail
	Set IsValid = 0,
		ValidationMessage = 'Landline No is invalid'
	Where ISNUMERIC(RTRIM(LTRIM(IsNull(LandlineNo,''))))=0 AND IsValid=1

	Update @tempCustomerDetail
	Set IsValid = 0,
		ValidationMessage = 'Mobile Number is invalid'
	Where ISNUMERIC(RTRIM(LTRIM(IsNull(MobileNumber,''))))=0 AND IsValid=1

	Update @tempCustomerDetail
	Set IsValid = 0,
		ValidationMessage = 'Email Id is invalid'
	Where RTRIM(LTRIM(IsNull(EmailId,'')))  NOT LIKE '_%@_%._%' AND IsValid=1

	Update @tempCustomerDetail
	Set IsValid = 0,
		ValidationMessage = 'Customer Type Name is invalid'
	Where RTRIM(LTRIM(IsNull(CustomerTypeName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempCustomerDetail
	Set IsValid = 0,
		ValidationMessage = 'Employee Role Name is invalid'
	Where RTRIM(LTRIM(IsNull(EmployeeRoleName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempCustomerContactDetail
	Set IsValid = 0,
		ValidationMessage = 'Contact Name is invalid'
	Where RTRIM(LTRIM(IsNull(ContactName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempCustomerContactDetail
	Set IsValid = 0,
		ValidationMessage = 'Mobile Number is invalid'
	Where ISNUMERIC(RTRIM(LTRIM(IsNull(MobileNo,''))))=0 AND IsValid=1

	Update @tempCustomerContactDetail
	Set IsValid = 0,
		ValidationMessage = 'Email Address is invalid'
	Where RTRIM(LTRIM(IsNull(EmailAddress,'')))  NOT LIKE '_%@_%._%' AND IsValid=1

	Update @tempCustomerAddressDetail
	Set IsValid = 0,
		ValidationMessage = 'State Name is invalid'
	Where RTRIM(LTRIM(IsNull(StateName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempCustomerAddressDetail
	Set IsValid = 0,
		ValidationMessage = 'Region Name is invalid'
	Where RTRIM(LTRIM(IsNull(RegionName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempCustomerAddressDetail
	Set IsValid = 0,
		ValidationMessage = 'District Name is invalid'
	Where RTRIM(LTRIM(IsNull(DistrictName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempCustomerAddressDetail
	Set IsValid = 0,
		ValidationMessage = 'Area Name is invalid'
	Where RTRIM(LTRIM(IsNull(AreaName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1
	
	Update 	@tempCustomerAddressDetail
	Set IsValid = 0,
		ValidationMessage = 'Pincode is invalid'
	Where ISNUMERIC(RTRIM(LTRIM(IsNull(Pincode,''))))=0 AND IsValid=1

	Update @tempCustomerAddressDetail
	Set IsValid = 0,
		ValidationMessage = 'Buyer Email Address is invalid'
	Where RTRIM(LTRIM(IsNull(BuyerEmailId,'')))  NOT LIKE '_%@_%._%' AND IsValid=1
	
	Update 	@tempCustomerAddressDetail
	Set IsValid = 0,
		ValidationMessage = 'Buyer Mobile Number is invalid'
	Where ISNUMERIC(RTRIM(LTRIM(IsNull(BuyerMobileNo,''))))=0 AND IsValid=1

	Update @tempCustomerDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Company Name already Exists'
	FROM @tempCustomerDetail T
	INNER JOIN  CustomerDetails CD ON CD.CompanyName = T.CompanyName and T.IsValid=1


	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Customer Type Name is not exists'
	FROM @tempCustomerDetail T
	LEFT JOIN CustomerTypeMaster CT ON CT.CustomerTypeName = T.CustomerTypeName
	 WHERE  CT.CustomerTypeName IS NULL  and T.IsValid=1

	 UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'State Name is not exists'
	FROM @tempCustomerAddressDetail T
	LEFT JOIN StateMaster ST ON ST.StateName=T.StateName
	 WHERE ST.StateName IS NULL AND  T.IsValid=1

	   UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Region Name is not exists'
	FROM @tempCustomerAddressDetail T
	LEFT JOIN RegionMaster RM ON RM.RegionName=T.RegionName
	LEFT JOIN StateMaster ST ON ST.StateId=RM.StateId AND ST.StateName=T.StateName
	 WHERE ST.StateName IS NULL AND T.IsValid=1

	 UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'District Name is not exists'
	 FROM @tempCustomerAddressDetail T
	LEFT JOIN DistrictMaster DM ON  T.DistrictName = DM.DistrictName  
	LEFT JOIN RegionMaster RM ON DM.RegionId=RM.RegionId AND T.RegionName=RM.RegionName
	LEFT JOIN StateMaster ST ON ST.StateId=RM.StateId AND ST.StateName=T.StateName
	 WHERE RM.RegionName IS NULL  and T.IsValid=1

	 UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Area Name is not exists'
	 FROM @tempCustomerAddressDetail T
	LEFT JOIN AreaMaster AM ON  T.AreaName = AM.AreaName  
	LEFT JOIN DistrictMaster DM ON DM.DistrictId=AM.DistrictId AND  T.DistrictName = DM.DistrictName  
	LEFT JOIN RegionMaster RM ON DM.RegionId=RM.RegionId AND T.RegionName=RM.RegionName
	LEFT JOIN StateMaster ST ON ST.StateId=RM.StateId AND ST.StateName=T.StateName
	 WHERE DM.DistrictName IS NULL  and T.IsValid=1


	 DECLARE @tblCnt BIGINT=1,@TotalRecord BIGINT=0;
	 SELECT @TotalRecord=COUNT(0) FROM @tempCustomerDetail

	 WHILE (@tblCnt <= @TotalRecord)
	 BEGIN
		 Insert into CustomerDetails(CompanyName,LandlineNo,MobileNo,EmailId,CustomerTypeId,SpecialRemarks,EmployeeId,
						IsActive,CreatedBy,CreatedOn)
			select CompanyName,LandlineNo,T.MobileNumber,T.EmailId,CTM.CustomerTypeId,T.SpecialRemarks,EM.EmployeeId,
			CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() from @tempCustomerDetail T
			INNER JOIN EmployeeMaster EM ON EM.EmployeeName=T.EmployeeRoleName
			Inner JOIN CustomerTypeMaster CTM ON CTM.CustomerTypeName = T.CustomerTypeName
			Where IsValid = 1

			SET @Result = SCOPE_IDENTITY();

		 IF(ISNULL(@Result,0) > 0)
		 BEGIN
		    INSERT INTO AddressMaster(Address,StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn)
		 SELECT Address,ST.StateId,RM.RegionId,DM.DistrictId,AM.AreaId,Pincode,1,CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END ,@LoggedInUserId,GETDATE() 
			FROM @tempCustomerAddressDetail T
			INNER JOIN StateMaster ST ON ST.StateName=T.StateName
			INNER JOIN RegionMaster RM ON RM.StateId= ST.StateId AND RM.RegionName=T.RegionName
			INNER JOIN DistrictMaster DM ON DM.RegionId=RM.RegionId AND DM.DistrictName=T.DistrictName
			INNER JOIN AreaMaster AM ON AM.DistrictId=DM.DistrictId AND AM.AreaName=T.AreaName
			Where IsValid = 1

			SET @AddressId = SCOPE_IDENTITY();

			INSERT INTO CustomerAddressMapping(CustomerId,AddressId)
			Values (@Result,@AddressId)

			INSERT INTO ContactDetails(ContactName,MobileNo,EmailId,RefPartyId,IsActive,CreatedBy,CreatedOn)
			SELECT ContactName,MobileNo,EmailAddress,RefPartyName,CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END ,@LoggedInUserId,GETDATE() 
			FROM @tempCustomerContactDetail T Where IsValid = 1
			
			SET @ContactId = SCOPE_IDENTITY();

			INSERT into CustomerContactMapping(CustomerId,ContactId) values (@Result,@ContactId)
		 END
			
		 SET @tblCnt = @tblCnt + 1;
			
	 END

	-- 5. Returning Invalid records
	Select 
		CompanyName,LandlineNo,MobileNumber,EmailId,CustomerTypeName,SpecialRemarks,EmployeeRoleName
		--,ContactName,
		--Mobile_Num,EmailAddress,RefPartyName,Address,StateName,RegionName,DistrictName,AreaName,Pincode,NameForAddress,BuyerMobileNo,BuyerEmailId,AddressTypeName,
				IsValid, IsActive,ValidationMessage
	From @tempCustomerDetail
	Where IsValid = 0;
END

GO

CREATE Or Alter Procedure[dbo].[SaveImportDesignDetails]
(
	@XmlDesignData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempDesignDetail TABLE
	(
		ProductName VARCHAR(100),
		BrandName VARCHAR(100),
		SizeName VARCHAR(100),
		CategoryName VARCHAR(100),
		SeriesName VARCHAR(100),
		DesignTypeName VARCHAR(100),
		BaseDesignName VARCHAR(100),
		DesignName VARCHAR(100),
		DesignCode VARCHAR(100),
		IsActive VARCHAR(100),
		IsValid BIT,
		ValidationMessage VarChar(Max)
	)

	INSERT INTO @tempDesignDetail(ProductName,BrandName,SizeName,CategoryName,SeriesName,DesignTypeName,BaseDesignName,DesignName,DesignCode,IsActive,IsValid)
	SELECT
		ProductName = T.Item.value('ProductName[1]', 'varchar(100)'),
		BrandName = T.Item.value('BrandName[1]', 'varchar(100)'),
		SizeName = T.Item.value('SizeName[1]', 'varchar(100)'),
		CategoryName = T.Item.value('CategoryName[1]', 'varchar(100)'),
		SeriesName = T.Item.value('SeriesName[1]', 'varchar(100)'),
		DesignTypeName = T.Item.value('DesignTypeName[1]', 'varchar(100)'),
		BaseDesignName = T.Item.value('BaseDesignName[1]', 'varchar(100)'),
		DesignName = T.Item.value('DesignName[1]', 'varchar(100)'),
		DesignCode = T.Item.value('DesignCode[1]', 'varchar(100)'),
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlDesignData.nodes('/ArrayOfImportedDesignDetails/ImportedDesignDetails') AS T(Item)

	-- 3. Validation of records
	Update @tempDesignDetail
	Set IsValid = 0,
		ValidationMessage = 'Product Name is invalid'
	Where RTRIM(LTRIM(IsNull(ProductName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempDesignDetail
	Set IsValid = 0,
		ValidationMessage = 'Brand Name is invalid'
	Where RTRIM(LTRIM(IsNull(BrandName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempDesignDetail
	Set IsValid = 0,
		ValidationMessage = 'Size Name is invalid'
	Where RTRIM(LTRIM(IsNull(SizeName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempDesignDetail
	Set IsValid = 0,
		ValidationMessage = 'Category Name is invalid'
	Where RTRIM(LTRIM(IsNull(CategoryName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempDesignDetail
	Set IsValid = 0,
		ValidationMessage = 'Series Name is invalid'
	Where RTRIM(LTRIM(IsNull(SeriesName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempDesignDetail
	Set IsValid = 0,
		ValidationMessage = 'Design Type Name is invalid'
	Where RTRIM(LTRIM(IsNull(DesignTypeName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempDesignDetail
	Set IsValid = 0,
		ValidationMessage = 'Base Design Type Name is invalid'
	Where RTRIM(LTRIM(IsNull(BaseDesignName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempDesignDetail
	Set IsValid = 0,
		ValidationMessage = 'IsActive value is invalid'
	Where RTRIM(LTRIM(IsNull(IsActive,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Design Name is already exists'
	FROM @tempDesignDetail T
	INNER JOIN DesignMaster DM ON DM.DesignName=T.DesignName
	WHERE IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Product Name is not exists'
	FROM @tempDesignDetail T
	LEFT JOIN ProductMaster PM ON PM.ProductName=T.ProductName
	WHERE PM.ProductName IS NULL AND  T.IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Brand Name is not exists'
	FROM @tempDesignDetail T
	LEFT JOIN BrandMaster BM ON BM.BrandName=T.BrandName
	WHERE BM.BrandName IS NULL AND  T.IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Size Name is not exists'
	FROM @tempDesignDetail T
	LEFT JOIN SizeMaster SM ON SM.SizeName=T.SizeName
	WHERE SM.SizeName IS NULL AND  T.IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Category Name is not exists'
	FROM @tempDesignDetail T
	LEFT JOIN CategoryMaster CM ON CM.CategoryName=T.CategoryName
	WHERE CM.CategoryName IS NULL AND  T.IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Series Name is not exists'
	FROM @tempDesignDetail T
	LEFT JOIN SeriesMaster SM1 ON SM1.SeriesName=T.SeriesName
	WHERE SM1.SeriesName IS NULL AND  T.IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Design Type Name is not exists'
	FROM @tempDesignDetail T
	LEFT JOIN DesignTypeMaster DTM ON DTM.DesignTypeName=T.DesignTypeName
	WHERE DTM.DesignTypeName IS NULL AND  T.IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Base Design Name is not exists'
	FROM @tempDesignDetail T
	LEFT JOIN BaseDesignMaster BD ON BD.BaseDesignName=T.BaseDesignName
	WHERE BD.BaseDesignName IS NULL AND  T.IsValid=1

	--SELECT * FROM @tempDesignDetail

	 Insert into DesignMaster(ProductId,BrandId,SizeId,CategoryId,SeriesId,DesignTypeId,BaseDesignId,DesignName,DesignCode,IsActive,CreatedBy,CreatedOn)
	 select PM.ProductId,BM.BrandId,SM.SizeId,CM.CategoryId,SM1.SeriesId,DTM.DesignTypeId,BD.BaseDesignId,T.DesignName,T.DesignCode, CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() 
	 FROM @tempDesignDetail T
	 INNER JOIN ProductMaster PM ON PM.ProductName=T.ProductName
	 INNER JOIN BrandMaster BM ON BM.BrandName=T.BrandName
	 INNER JOIN SizeMaster SM ON SM.SizeName=T.SizeName
	 INNER JOIN CategoryMaster CM ON CM.CategoryName=T.CategoryName
	 INNER JOIN SeriesMaster SM1 ON SM1.SeriesName=T.SeriesName
	 INNER JOIN DesignTypeMaster DTM ON DTM.DesignTypeName=T.DesignTypeName
	 INNER JOIN BaseDesignMaster BD ON BD.BaseDesignName=T.BaseDesignName
	 Where IsValid = 1


	-- 5. Returning Invalid records
	Select ProductName,BrandName,SizeName,CategoryName,SeriesName,DesignTypeName,BaseDesignName,DesignName,DesignCode,IsActive,ValidationMessage
	From @tempDesignDetail
	Where IsValid = 0;

END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[SaveDesignDetails] 
Description : Insert Design from DesignMaster
*/
ALTER PROCEDURE [dbo].[SaveDesignDetails]
(
	@DesignId BIGINT,
	@ProductId BIGINT,
	@BrandId BIGINT,
	@SizeId BIGINT,
	@CategoryId BIGINT,
	@SeriesId BIGINT,
	@DesignTypeId BIGINT,
	@BaseDesignId BIGINT,
	@DesignName VARCHAR(100),
	@DesignCode VARCHAR(100),
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
		(@DesignId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM DesignMaster WITH(NOLOCK) 
				WHERE  DesignName=@DesignName

			)
		)
		OR
		(@DesignId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM DesignMaster WITH(NOLOCK) 
				WHERE  DesignName=@DesignName and DesignId<>@DesignId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@DesignId=0)
		BEGIN
		INSERT INTO DesignMaster(ProductId,BrandId,SizeId,CategoryId,SeriesId,DesignTypeId,BaseDesignId,DesignName ,DesignCode, IsActive,CreatedBy,CreatedOn)
			Values(@ProductId,@BrandId,@SizeId,@CategoryId,@SeriesId,@DesignTypeId,@BaseDesignId,@DesignName ,@DesignCode, @IsActive,@LoggedInUserId,GETDATE())
			SET @Result = SCOPE_IDENTITY();
		END
		ELSE IF(@DesignId> 0 and EXISTS(SELECT TOP 1 1 FROM DesignMaster WHERE DesignId=@DesignId))
		BEGIN
			UPDATE DesignMaster
			SET ProductId=@ProductId,BrandId=@BrandId,SizeId=@SizeId,CategoryId=@CategoryId,SeriesId=@SeriesId,DesignTypeId=@DesignTypeId,
				BaseDesignId=@BaseDesignId,DesignName=@DesignName ,DesignCode=@DesignCode,IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE DesignId=@DesignId
			SET @Result = @DesignId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result 
END
