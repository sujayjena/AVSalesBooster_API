/*
EXEC SaveImportCustomerDetails
'<ArrayOfImportedCustomerDetails >
  <ImportedCustomerDetails>
    <CompanyName>Royal Medical</CompanyName>
    <LandlineNo>212544222442</LandlineNo>
    <MobileNumber>2020202020</MobileNumber>
    <EmailId>ss@gmail.com</EmailId>
    <CustomerTypeName>ronak set</CustomerTypeName>
    <SpecialRemarks>testing</SpecialRemarks>
    <EmployeeName>Ronak bhuro</EmployeeName>
    <ContactName>Mukesh</ContactName>
    <MobileNo>9988774455</MobileNo>
    <EmailAddress>mukesh@gmail.com</EmailAddress>
    <RefPartyName>1</RefPartyName>
    <Address>test</Address>
    <StateName>Maharastra</StateName>
    <RegionName>Region 1</RegionName>
    <DistrictName>Rajkot Dist</DistrictName>
    <AreaName>Kalawad Road</AreaName>
    <Pincode>112233</Pincode>
    <NameForAddress>Vishal</NameForAddress>
    <BuyerMobileNo>997978014</BuyerMobileNo>
    <BuyerEmailId>vishal@g,mail.com</BuyerEmailId>
    <AddressTypeName>Office</AddressTypeName>
    <IsActive>True</IsActive>
  </ImportedCustomerDetails>
  <ImportedCustomerDetails>
    <CompanyName>Shivam Mdedical</CompanyName>
    <LandlineNo>aaa</LandlineNo>
    <MobileNumber>aaaa</MobileNumber>
    <EmailId>tt@gmail.com</EmailId>
    <CustomerTypeName>test</CustomerTypeName>
    <SpecialRemarks>testing</SpecialRemarks>
    <EmployeeName>piyush</EmployeeName>
    <ContactName>lalo</ContactName>
    <MobileNo>8855</MobileNo>
    <EmailAddress>lal@gmail.com</EmailAddress>
    <RefPartyName>1</RefPartyName>
    <Address>test</Address>
    <StateName>Rajasthan</StateName>
    <RegionName>Region 2</RegionName>
    <DistrictName>Ahmedabad</DistrictName>
    <AreaName>Satellite</AreaName>
    <Pincode>395001</Pincode>
    <NameForAddress>Ronak</NameForAddress>
    <BuyerMobileNo>8849847882</BuyerMobileNo>
    <BuyerEmailId>ff@gmail.com</BuyerEmailId>
    <AddressTypeName>Home</AddressTypeName>
    <IsActive>True</IsActive>
  </ImportedCustomerDetails>
  <ImportedCustomerDetails>
    <LandlineNo>aaa</LandlineNo>
    <MobileNumber>aaaa</MobileNumber>
    <EmailId>tt@gmail.com</EmailId>
    <CustomerTypeName>test</CustomerTypeName>
    <SpecialRemarks>testing</SpecialRemarks>
    <EmployeeName>piyush</EmployeeName>
    <ContactName>lalo</ContactName>
    <MobileNo>8855</MobileNo>
    <EmailAddress>lal@gmail.com</EmailAddress>
    <RefPartyName>1</RefPartyName>
    <Address>test</Address>
  </ImportedCustomerDetails>
</ArrayOfImportedCustomerDetails>',2

*/
ALTER PROCEDURE [dbo].[SaveImportCustomerDetails]
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
		EmployeeName VARCHAR(100),
		ContactName VARCHAR(100),
		MobileNo VARCHAR(100),
		EmailAddress VARCHAR(100),
		RefPartyName VARCHAR(100),
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

	DECLARE @tempCustomerValidDetail TABLE
	(
		Id BIGINT IDENTITY(1,1) PRIMARY KEY,
		CompanyName VARCHAR(100),
		LandlineNo VARCHAR(100),
		MobileNumber VARCHAR(100),
		EmailId VARCHAR(100),
		CustomerTypeName VARCHAR(100),
		SpecialRemarks VARCHAR(250),
		EmployeeName VARCHAR(100),
		ContactName VARCHAR(100),
		MobileNo VARCHAR(100),
		EmailAddress VARCHAR(100),
		RefPartyName VARCHAR(100),
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

	
	INSERT INTO @tempCustomerDetail(CompanyName,LandlineNo,MobileNumber,EmailId,CustomerTypeName,SpecialRemarks,EmployeeName,
				ContactName,MobileNo,EmailAddress,RefPartyName,
				Address,StateName,RegionName,DistrictName,AreaName,Pincode,NameForAddress,BuyerMobileNo,BuyerEmailId,AddressTypeName,
				IsActive,IsValid)
	SELECT
		CompanyName = T.Item.value('CompanyName[1]', 'varchar(100)'),
		LandlineNo = T.Item.value('LandlineNo[1]', 'varchar(100)'),
		MobileNumber = T.Item.value('MobileNumber[1]', 'varchar(100)'),
		EmailId = T.Item.value('EmailId[1]', 'varchar(500)'),
		CustomerTypeName = T.Item.value('CustomerTypeName[1]', 'varchar(100)'),
		SpecialRemarks = T.Item.value('SpecialRemarks[1]', 'varchar(250)'),
		EmployeeName = T.Item.value('EmployeeName[1]', 'varchar(100)'),
		ContactName = T.Item.value('ContactName[1]', 'varchar(100)'),
		MobileNo = T.Item.value('MobileNo[1]', 'varchar(100)'),
		EmailAddress = T.Item.value('EmailAddress[1]', 'varchar(100)'),
		RefPartyName = T.Item.value('RefPartyName[1]', 'varchar(100)'),
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
		IsActive = UPPER(T.Item.value('IsActive[1]', 'VARCHAR(100)')),1
		FROM
	 @XmlCustomerData.nodes('/ArrayOfImportedCustomerDetails/ImportedCustomerDetails') AS T(Item)


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
		ValidationMessage = 'Employee Name is invalid'
	Where RTRIM(LTRIM(IsNull(EmployeeName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempCustomerDetail
	Set IsValid = 0,
		ValidationMessage = 'Contact Name is invalid'
	Where RTRIM(LTRIM(IsNull(ContactName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempCustomerDetail
	Set IsValid = 0,
		ValidationMessage = 'Mobile Number is invalid'
	Where ISNUMERIC(RTRIM(LTRIM(IsNull(MobileNo,''))))=0 AND IsValid=1

	Update @tempCustomerDetail
	Set IsValid = 0,
		ValidationMessage = 'Email Address is invalid'
	Where RTRIM(LTRIM(IsNull(EmailAddress,'')))  NOT LIKE '_%@_%._%' AND IsValid=1

	Update @tempCustomerDetail
	Set IsValid = 0,
		ValidationMessage = 'State Name is invalid'
	Where RTRIM(LTRIM(IsNull(StateName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempCustomerDetail
	Set IsValid = 0,
		ValidationMessage = 'Region Name is invalid'
	Where RTRIM(LTRIM(IsNull(RegionName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempCustomerDetail
	Set IsValid = 0,
		ValidationMessage = 'District Name is invalid'
	Where RTRIM(LTRIM(IsNull(DistrictName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1

	Update @tempCustomerDetail
	Set IsValid = 0,
		ValidationMessage = 'Area Name is invalid'
	Where RTRIM(LTRIM(IsNull(AreaName,''))) Not Like '%[a-zA-Z ]%' AND IsValid=1
	
	Update 	@tempCustomerDetail
	Set IsValid = 0,
		ValidationMessage = 'Pincode is invalid'
	Where ISNUMERIC(RTRIM(LTRIM(IsNull(Pincode,''))))=0 AND IsValid=1

	Update @tempCustomerDetail
	Set IsValid = 0,
		ValidationMessage = 'Buyer Email Address is invalid'
	Where RTRIM(LTRIM(IsNull(BuyerEmailId,'')))  NOT LIKE '_%@_%._%' AND IsValid=1
	
	Update 	@tempCustomerDetail
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
	FROM @tempCustomerDetail T
	LEFT JOIN StateMaster ST ON ST.StateName=T.StateName
	 WHERE ST.StateName IS NULL AND  T.IsValid=1

	   UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Region Name is not exists'
	FROM @tempCustomerDetail T
	LEFT JOIN RegionMaster RM ON RM.RegionName=T.RegionName
	LEFT JOIN StateMaster ST ON ST.StateId=RM.StateId AND ST.StateName=T.StateName
	 WHERE ST.StateName IS NULL AND T.IsValid=1

	 UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'District Name is not exists'
	 FROM @tempCustomerDetail T
	LEFT JOIN DistrictMaster DM ON  T.DistrictName = DM.DistrictName  
	LEFT JOIN RegionMaster RM ON DM.RegionId=RM.RegionId AND T.RegionName=RM.RegionName
	LEFT JOIN StateMaster ST ON ST.StateId=RM.StateId AND ST.StateName=T.StateName
	 WHERE RM.RegionName IS NULL  and T.IsValid=1

	 UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Area Name is not exists'
	 FROM @tempCustomerDetail T
	LEFT JOIN AreaMaster AM ON  T.AreaName = AM.AreaName  
	LEFT JOIN DistrictMaster DM ON DM.DistrictId=AM.DistrictId AND  T.DistrictName = DM.DistrictName  
	LEFT JOIN RegionMaster RM ON DM.RegionId=RM.RegionId AND T.RegionName=RM.RegionName
	LEFT JOIN StateMaster ST ON ST.StateId=RM.StateId AND ST.StateName=T.StateName
	 WHERE DM.DistrictName IS NULL  and T.IsValid=1

	 INSERT INTO @tempCustomerValidDetail
	 SELECT * FROM  @tempCustomerDetail Where IsValid = 1
	 
	 DECLARE @tblCnt BIGINT=1,@TotalRecord BIGINT=0;
	 SELECT @TotalRecord=COUNT(0) FROM @tempCustomerValidDetail 

	 WHILE (@tblCnt <= @TotalRecord)
	 BEGIN
		 Insert into CustomerDetails(CompanyName,LandlineNo,MobileNo,EmailId,CustomerTypeId,SpecialRemarks,EmployeeId,
						IsActive,CreatedBy,CreatedOn)
			select CompanyName,LandlineNo,T.MobileNumber,T.EmailId,CTM.CustomerTypeId,T.SpecialRemarks,EM.EmployeeId,
			CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() from @tempCustomerValidDetail T
			INNER JOIN EmployeeMaster EM ON EM.EmployeeName=T.EmployeeName
			Inner JOIN CustomerTypeMaster CTM ON CTM.CustomerTypeName = T.CustomerTypeName
			Where IsValid = 1 and T.Id=@tblCnt

			SET @Result = SCOPE_IDENTITY();

		 IF(ISNULL(@Result,0) > 0)
		 BEGIN
		    INSERT INTO AddressMaster(Address,StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn)
		 SELECT Address,ST.StateId,RM.RegionId,DM.DistrictId,AM.AreaId,Pincode,1,CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END ,@LoggedInUserId,GETDATE() 
			FROM @tempCustomerValidDetail T
			INNER JOIN StateMaster ST ON ST.StateName=T.StateName
			INNER JOIN RegionMaster RM ON RM.StateId= ST.StateId AND RM.RegionName=T.RegionName
			INNER JOIN DistrictMaster DM ON DM.RegionId=RM.RegionId AND DM.DistrictName=T.DistrictName
			INNER JOIN AreaMaster AM ON AM.DistrictId=DM.DistrictId AND AM.AreaName=T.AreaName
			Where IsValid = 1 and T.Id=@tblCnt

			SET @AddressId = SCOPE_IDENTITY();

			INSERT INTO CustomerAddressMapping(CustomerId,AddressId)
			Values (@Result,@AddressId)

			INSERT INTO ContactDetails(ContactName,MobileNo,EmailId,RefPartyId,IsActive,CreatedBy,CreatedOn)
			SELECT ContactName,MobileNo,EmailAddress,RefPartyName,CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END ,@LoggedInUserId,GETDATE() 
			FROM @tempCustomerValidDetail T Where IsValid = 1 and T.Id=@tblCnt
			
			SET @ContactId = SCOPE_IDENTITY();

			INSERT into CustomerContactMapping(CustomerId,ContactId) values (@Result,@ContactId)
		 END
			
		 SET @tblCnt = @tblCnt + 1;
			
	 END

	-- 5. Returning Invalid records
	Select 
		CompanyName,LandlineNo,MobileNumber,EmailId,CustomerTypeName,SpecialRemarks,EmployeeName
		,ContactName,
		MobileNo,EmailAddress,RefPartyName,Address,StateName,RegionName,DistrictName,AreaName,Pincode,NameForAddress,BuyerMobileNo,BuyerEmailId,AddressTypeName,
				IsValid, IsActive,ValidationMessage
	From @tempCustomerDetail
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
ALTER PROCEDURE [dbo].[SaveImportEmployeeDetails]
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

	DECLARE @tempEmployeeValidDetail TABLE
	(
		Id BIGINT IDENTITY(1,1) PRIMARY KEY,
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
		ValidationMessage = 'Employee Name is already exists'
	FROM @tempEmployeeDetail T
	INNER JOIN EmployeeMaster EM ON EM.EmployeeName=T.EmployeeName 
	WHERE T.IsValid=1

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Employee Code is already exists'
	FROM @tempEmployeeDetail T
	INNER JOIN EmployeeMaster EM ON EM.EmployeeCode=T.EmployeeCode 
	WHERE T.IsValid=1

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

	UPDATE T
	SET IsValid = 0,
		ValidationMessage = 'Blood Group is not exists'
	FROM @tempEmployeeDetail T
	LEFT JOIN BloodGroupMaster BM ON  T.BloodGroup = BM.BloodGroup
	 WHERE  BM.BloodGroup IS NULL  and T.IsValid=1

	 Update @tempEmployeeDetail
	Set IsValid = 0,
		ValidationMessage = 'IsWebUser value is invalid'
	Where RTRIM(LTRIM(IsNull(IsWebUser,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	Update @tempEmployeeDetail
	Set IsValid = 0,
		ValidationMessage = 'IsMobileUser value is invalid'
	Where RTRIM(LTRIM(IsNull(IsMobileUser,''))) Not IN ('TRUE','FALSE') AND IsValid=1

	INSERT INTO @tempEmployeeValidDetail 
	SELECT * FROM @tempEmployeeDetail Where IsValid = 1

	DECLARE @tblCnt BIGINT=1,@TotalRecord BIGINT=0;
	 SELECT @TotalRecord=COUNT(0) FROM @tempEmployeeValidDetail 

	 WHILE (@tblCnt <= @TotalRecord)
	 BEGIN

		Insert into EmployeeMaster(EmployeeName,EmployeeCode,EmailId,MobileNumber,RoleId,ReportingTo,DateOfBirth,DateOfJoining,
						EmergencyContactNumber,BloodGroup,IsWebUser,IsMobileUser,IsActive,CreatedBy,CreatedOn)
		select T.EmployeeName,T.EmployeeCode,T.EmailId,T.MobileNumber, RM.RoleId,RM2.RoleId,T.DateOfBirth,T.DateOfJoining,T.EmergencyContactNumber,BM.BloodGroupId,
			CASE WHEN T.IsWebUser='TRUE' THEN 1 ELSE 0 END,
			CASE WHEN T.IsMobileUser='TRUE' THEN 1 ELSE 0 END,
			CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() 
			from @tempEmployeeValidDetail T
			INNER JOIN RoleMaster RM ON RM.RoleName = T.RoleName
			INNER JOIN RoleMaster RM2 ON RM2.RoleName = T.ReportingToName
			INNER JOIN BloodGroupMaster BM ON BM.BloodGroup = T.BloodGroup
			Where IsValid = 1 and T.id=@tblCnt

		SET @Result = SCOPE_IDENTITY();
			
			-- Insert Into Address 
		INSERT INTO AddressMaster(Address,StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn)
		SELECT Address,ST.StateId,RM.RegionId,DM.DistrictId,AM.AreaId,T.Pincode,1,CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END ,@LoggedInUserId,GETDATE() 
			FROM @tempEmployeeValidDetail T
			INNER JOIN StateMaster ST ON ST.StateName=T.StateName
			INNER JOIN RegionMaster RM ON RM.StateId= ST.StateId AND RM.RegionName=T.RegionName
			INNER JOIN DistrictMaster DM ON DM.RegionId=RM.RegionId AND DM.DistrictName=T.DistrictName
			INNER JOIN AreaMaster AM ON AM.DistrictId=DM.DistrictId AND AM.AreaName=T.AreaName
			Where IsValid = 1 and T.id=@tblCnt
		
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

ALTER PROCEDURE [dbo].[SaveImportReferenceDetails]
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

	DECLARE @tempReferenceValidDetail TABLE
	(
		Id BIGINT IDENTITY(1,1) PRIMARY KEY,
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

	INSERT INTO @tempReferenceValidDetail
	SELECT * FROM @tempReferenceDetail  Where IsValid = 1

	 DECLARE @tblCnt BIGINT=1,@TotalRecord BIGINT=0;
	 SELECT @TotalRecord=COUNT(0) FROM @tempReferenceValidDetail

	 DECLARE @UniqueNo BIGINT=0;
	 SELECT @UniqueNo= COUNT(0) FROM ReferenceMaster

	 WHILE (@tblCnt <= @TotalRecord)
	 BEGIN
		 Insert into ReferenceMaster(UniqueNumber,PartyName,PhoneNumber,MobileNumber,GSTNumber,PanNumber,EmailId, IsActive,CreatedBy,CreatedOn)
			select CONCAT('Ref00', @UniqueNo+@tblCnt),ReferenceParty,PhoneNumber,MobileNumber,GSTNumber,PanNumber,EmailId,
			CASE WHEN IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE() from @tempReferenceValidDetail Where IsValid = 1 and Id=@tblCnt

			SET @Result = SCOPE_IDENTITY();


		 INSERT INTO AddressMaster(Address,StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn)
		 SELECT Address,ST.StateId,RM.RegionId,DM.DistrictId,AM.AreaId,T.Pincode,1,CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END ,@LoggedInUserId,GETDATE() 
			FROM @tempReferenceValidDetail T
			INNER JOIN StateMaster ST ON ST.StateName=T.StateName
			INNER JOIN RegionMaster RM ON RM.StateId= ST.StateId AND RM.RegionName=T.RegionName
			INNER JOIN DistrictMaster DM ON DM.RegionId=RM.RegionId AND DM.DistrictName=T.DistrictName
			INNER JOIN AreaMaster AM ON AM.DistrictId=DM.DistrictId AND AM.AreaName=T.AreaName
			Where IsValid = 1 and Id=@tblCnt

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

ALTER PROCEDURE [dbo].[SaveImportVisitDetails]
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

	DECLARE @tempVisitValidDetail TABLE
	(
		Id BIGINT IDENTITY(1,1) PRIMARY KEY,
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


	 INSERT INTO @tempVisitValidDetail
	 SELECT * FROM @tempVisitDetail where IsValid=1

	 DECLARE @tblCnt BIGINT=1,@TotalRecord BIGINT=0;
	 SELECT @TotalRecord=COUNT(0) FROM @tempVisitValidDetail

	 WHILE (@tblCnt <= @TotalRecord)
	 BEGIN
		 Insert into VisitMaster(
				EmployeeId,VisitDate,CustomerId,CustomerTypeId,ContactPerson,ContactNumber,EmailId,NextActionDate,
				Latitude,Longitude,IsActive,CreatedBy,CreatedOn,VisitStatusId)
			select EM.EmployeeId,T.VisitDate,CD.CustomerId,CTM.CustomerTypeId,ContactPerson,ContactNumber,T.EmailId,NextActionDate,
				Latitude,Longitude,
			CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END
			,@LoggedInUserId,GETDATE(),1 from @tempVisitValidDetail T
			INNER JOIN EmployeeMaster EM ON EM.EmployeeName=T.EmployeeName
			Inner Join CustomerDetails CD ON CD.CompanyName=T.CustomerName
			Inner JOIN CustomerTypeMaster CTM ON CTM.CustomerTypeName = T.CustomerTypeName
			Where IsValid = 1 and T.Id=@tblCnt

			SET @Result = SCOPE_IDENTITY();

		 INSERT INTO AddressMaster(Address,StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn)
		 SELECT Address,ST.StateId,RM.RegionId,DM.DistrictId,AM.AreaId,0,1,CASE WHEN T.IsActive='TRUE' THEN 1 ELSE 0 END ,@LoggedInUserId,GETDATE() 
			FROM @tempVisitValidDetail T
			INNER JOIN StateMaster ST ON ST.StateName=T.StateName
			INNER JOIN RegionMaster RM ON RM.StateId= ST.StateId AND RM.RegionName=T.RegionName
			INNER JOIN DistrictMaster DM ON DM.RegionId=RM.RegionId AND DM.DistrictName=T.DistrictName
			INNER JOIN AreaMaster AM ON AM.DistrictId=DM.DistrictId AND AM.AreaName=T.AreaName
			Where IsValid = 1 and T.Id=@tblCnt

			SET @AddressId = SCOPE_IDENTITY();

			INSERT INTO VisitRemarks
			(
				VisitId, Remarks, IsDeleted, CreatedOn, CreatedBy
			)
			SELECT
				@Result, Remarks, 0, GETDATE(), @LoggedInUserId FROM @tempVisitValidDetail Where IsValid = 1 and Id=@tblCnt

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

