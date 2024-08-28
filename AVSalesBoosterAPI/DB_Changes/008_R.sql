If OBJECT_ID('Users') Is NullBegin	Create Table Users	(		UserId BigInt Primary Key Identity(1,1),		EmailId VarChar(100) Not Null,		MobileNo VarChar(15) Not Null,		Passwords VarChar(200) Not Null,		EmployeeId BigInt References EmployeeMaster(EmployeeId),		CustomerId BigInt References CustomerDetails(CustomerId),		IsActive Bit Not Null,		TermsConditionsAccepted Bit,		CreatedBy BIGINT NOT NULL,		CreatedOn DATETIME NOT NULL,		ModifiedBy BIGINT,		ModifiedOn DATETIME	)EndGO If exists(select top 1 1 From INFORMATION_SCHEMA.COLUMNS Where TABLE_NAME='EmployeeAddressMapping' 
	And COLUMN_NAME In('NameForAddress','MobileNo','EmailId','AddressTypeId'))
 begin
	ALTER TABLE EmployeeAddressMapping
	DROP COLUMN NameForAddress,MobileNo,EmailId,AddressTypeId 
 end

 GO

 If Not Exists(Select Top 1 1 From INFORMATION_SCHEMA.COLUMNS Where TABLE_NAME='AddressMaster' And 
 COLUMN_NAME In('NameForAddress','MobileNo','EmailId','AddressTypeId'))
 Begin
	ALTER TABLE AddressMaster
	ADD NameForAddress VARCHAR(100),MobileNo VARCHAR(15),EmailId VARCHAR(100),AddressTypeId BIGINT
 End

 GO

 If OBJECT_ID('CompanyDetails') Is Not Null
Begin
	Drop Table CompanyDetails
End

GO

If OBJECT_ID('CustomerContactMapping') Is Not Null
Begin
	Drop Table CustomerContactMapping
End

GO

If OBJECT_ID('CustomerDetails') Is Null
Begin

	CREATE TABLE CustomerDetails
	(
		CustomerId BIGINT IDENTITY(1,1) PRIMARY KEY,
		CompanyName VARCHAR(100) NOT NULL,
		LandlineNo VARCHAR(15),
		MobileNo VARCHAR(15),
		EmailId VARCHAR(100),
		CustomerTypeId BIGINT,
		SpecialRemarks VARCHAR(250),
		EmployeeId  BIGINT FOREIGN KEY REFERENCES EmployeeMaster(EmployeeId),
		IsActive BIT NOT NULL,
		CreatedBy BIGINT NOT NULL,
		CreatedOn DATETIME NOT NULL,
		ModifiedBy BIGINT,
		ModifiedOn DATETIME
	)
END

GO

If OBJECT_ID('ContactDetails') Is Not Null
Begin
	Drop Table ContactDetails
End

GO

If OBJECT_ID('ContactDetails') Is Null
Begin

	CREATE TABLE ContactDetails
	(
		ContactId BIGINT IDENTITY(1,1) PRIMARY KEY,
		ContactName VARCHAR(100) NOT NULL,
		MobileNo VARCHAR(15),
		EmailId VARCHAR(100),
		RefPartyId  BIGINT FOREIGN KEY REFERENCES ReferenceMaster(ReferenceId),
		IsActive BIT NOT NULL,
		CreatedBy BIGINT NOT NULL,
		CreatedOn DATETIME NOT NULL,
		ModifiedBy BIGINT,
		ModifiedOn DATETIME
	)
END

GO

CREATE TABLE CustomerContactMapping
(
CompanyContactId BIGINT IDENTITY(1,1) PRIMARY KEY,
CustomerId BIGINT FOREIGN KEY REFERENCES CustomerDetails(CustomerId), 
ContactId  BIGINT FOREIGN KEY REFERENCES ContactDetails(ContactId)
)

GO

If OBJECT_ID('CustomerAddressMapping') Is Not Null
Begin
	Drop Table CustomerAddressMapping
End

GO

CREATE TABLE CustomerAddressMapping
(
CustomerAddressId BIGINT IDENTITY(1,1) PRIMARY KEY,
CustomerId BIGINT FOREIGN KEY REFERENCES CustomerDetails(CustomerId), 
AddressId  BIGINT FOREIGN KEY REFERENCES AddressMaster(AddressId)
)

GO

Drop Procedure If Exists SaveCustomerDetails

GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[SaveCustomerDetails] 
Description : Insert Customer Detail from CustomerDetails

EXEC SaveCustomerDetails 0,'Vishal and Co','123456789','1020304050','vishu@gmail.com',1,'test',1,1,
'<ArrayOfContactDetail xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <ContactDetail>
    <ContactId>0</ContactId>
    <ContactName>Akshay</ContactName>
    <MobileNo>111111111</MobileNo>
    <EmailId>Akshay@gmail.com</EmailId>
    <RefPartyId>1</RefPartyId>
    <IsActive>true</IsActive>
  </ContactDetail>
  <ContactDetail>
    <ContactId>0</ContactId>
    <ContactName>Mehul</ContactName>
    <MobileNo>22222222</MobileNo>
    <EmailId>MEhul@gmail.com</EmailId>
    <RefPartyId>2</RefPartyId>
    <IsActive>true</IsActive>
  </ContactDetail>
</ArrayOfContactDetail>',
'<ArrayOfAddressDetail xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <AddressDetail>
    <AddressId>0</AddressId>
    <Address>Jesar Road</Address>
    <StateId>1</StateId>
    <RegionId>1</RegionId>
    <DistrictId>1</DistrictId>
    <AreaId>1</AreaId>
    <Pincode>16158703113</Pincode>
    <IsActive>true</IsActive>
    <IsDefault>true</IsDefault>
    <NameForAddress>Akshay Vinu</NameForAddress>
    <MobileNo>5555555</MobileNo>
    <EmailId>Vinu@gmail.com</EmailId>
    <AddressTypeId>1</AddressTypeId>
  </AddressDetail>
  <AddressDetail>
    <AddressId>0</AddressId>
    <Address>Fatak Road</Address>
    <StateId>1</StateId>
    <RegionId>1</RegionId>
    <DistrictId>1</DistrictId>
    <AreaId>1</AreaId>
    <Pincode>22222222222</Pincode>
    <IsActive>true</IsActive>
    <IsDefault>true</IsDefault>
    <NameForAddress>Mehul Rasik</NameForAddress>
    <MobileNo>5555555</MobileNo>
    <EmailId>Rasik@gmail.com</EmailId>
    <AddressTypeId>1</AddressTypeId>
  </AddressDetail>
</ArrayOfAddressDetail>',1
*/
CREATE Or Alter Procedure[dbo].[SaveCustomerDetails]
(
	@CustomerId BIGINT,
	@CompanyName VARCHAR(100),
	@LandlineNo VARCHAR(15),
	@MobileNumber VARCHAR(15),
	@EmailId VARCHAR(100),
	@CustomerTypeId BIGINT,
	@SpecialRemarks VARCHAR(250),
	@EmployeeRoleId BIGINT,
	@IsActive BIT,
	@XmlContactData XML,
	@XmlAddressData XML,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	DECLARE @tempContactDetail TABLE
	(
		ContactId BIGINT ,
		ContactName VARCHAR(100),
		MobileNo VARCHAR(15),
		EmailId VARCHAR(100),
		RefPartyId  BIGINT ,
		IsActive BIT
	)

	DECLARE @tempAddressDetail TABLE
	(
		AddressId		BigInt,
		[Address]		VARCHAR(500),
		StateId			BIGINT,
		RegionId		BIGINT,
		DistrictId		BIGINT,
		AreaId			BIGINT,
		Pincode			VARCHAR(15),
		IsActive		BIT,
		IsDefault       BIT,
		NameForAddress VARCHAR(100),
		MobileNo		VARCHAR(15),
		EmailId			VARCHAR(100),
		AddressTypeId   BIGINT
	)

	INSERT INTO @tempContactDetail(ContactId,ContactName,MobileNo,EmailId,RefPartyId,IsActive)
	SELECT
		ContactId = T.Item.value('ContactId[1]', 'BIGINT'),
		ContactName = T.Item.value('ContactName[1]', 'varchar(50)'),
		MobileNo = T.Item.value('MobileNo[1]', 'varchar(15)'),
		EmailId =  T.Item.value('EmailId[1]', 'varchar(100)'),
		RefPartyId = T.Item.value('RefPartyId[1]', 'BIGINT'),
		IsActive = T.Item.value('IsActive[1]', 'BIT')
		FROM
	 @XmlContactData.nodes('/ArrayOfContactDetail/ContactDetail') AS T(Item)

	 INSERT INTO @tempAddressDetail(AddressId,[Address],StateId,RegionId,DistrictId,AreaId,Pincode,IsActive,IsDefault,NameForAddress,MobileNo,EmailId,AddressTypeId)
	 SELECT
		AddressId = T.Item.value('AddressId[1]', 'BIGINT'),
		Address = T.Item.value('Address[1]', 'varchar(500)'),
		StateId = T.Item.value('StateId[1]', 'BIGINT'),
		RegionId =  T.Item.value('RegionId[1]', 'BIGINT'),
		DistrictId = T.Item.value('DistrictId[1]', 'BIGINT'),
		AreaId = T.Item.value('AreaId[1]', 'BIGINT'),
		Pincode = T.Item.value('Pincode[1]', 'varchar(15)'),
		IsActive = T.Item.value('IsActive[1]', 'BIT'),
		IsDefault = T.Item.value('IsDefault[1]', 'BIT'),
		NameForAddress = T.Item.value('NameForAddress[1]', 'VARCHAR(100)'),
		MobileNo = T.Item.value('MobileNo[1]', 'VARCHAR(15)'),
		EmailId = T.Item.value('EmailId[1]', 'VARCHAR(100)'),
		AddressTypeId = T.Item.value('AddressTypeId[1]', 'BIGINT')
			FROM
			@xmlAddressData.nodes('/ArrayOfAddressDetail/AddressDetail') AS T(Item)

		
	If (
		(@CustomerId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM CustomerDetails WITH(NOLOCK) 
				WHERE  CompanyName=@CompanyName 
			)
		)
		OR
		(@CustomerId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM CustomerDetails WITH(NOLOCK) 
				WHERE  CompanyName=@CompanyName  and CustomerId<>@CustomerId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
	IF (@CustomerId=0)
		BEGIN
			Insert into CustomerDetails(CompanyName,LandlineNo,MobileNo,EmailId,CustomerTypeId,SpecialRemarks,EmployeeId,
						IsActive,CreatedBy,CreatedOn)
			Values(@CompanyName,@LandlineNo ,@MobileNumber,@EmailId,@CustomerTypeId,@SpecialRemarks,@EmployeeRoleId,@IsActive,@LoggedInUserId,GETDATE())

			SET @Result = SCOPE_IDENTITY();
			
			DECLARE @tempAdd TABLE
			(
				AddId BIGINT
			)

			-- Insert Into Address 
			INSERT INTO AddressMaster(Address,StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn,NameForAddress,MobileNo,EmailId,AddressTypeId)
			OUTPUT inserted.AddressId
			into @tempAdd
			SELECT Address,StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,@LoggedInUserId,GETDATE(),NameForAddress,MobileNo,EmailId,AddressTypeId
			FROM @tempAddressDetail

			INSERT INTO CustomerAddressMapping(CustomerId,AddressId)
			Select @Result,AddId from @tempAdd

			DECLARE @tempContact TABLE
			(
				ContId BIGINT
			)

			INSERT INTO ContactDetails(ContactName,MobileNo,EmailId,RefPartyId,IsActive,CreatedBy,CreatedOn)
			OUTPUT inserted.ContactId
			into @tempContact
			SELECT ContactName,MobileNo,EmailId,RefPartyId,IsActive,@LoggedInUserId,GETDATE() FROM @tempContactDetail

			INSERT into CustomerContactMapping(CustomerId,ContactId)
			Select @Result,ContId from @tempContact
		
		END
		ELSE IF(@CustomerId> 0 and EXISTS(SELECT TOP 1 1 FROM CustomerDetails WHERE EmployeeId=@CustomerId))
		BEGIN
			UPDATE CustomerDetails
			SET CompanyName=@CompanyName,LandlineNo=@LandlineNo,MobileNo=@MobileNumber,EmailId=@EmailId,CustomerTypeId=@CustomerTypeId,SpecialRemarks=@SpecialRemarks,EmployeeId=@EmployeeRoleId,
						IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE CustomerId=@CustomerId

			UPDATE AD
			SET Address=temp.Address,StateId=temp.StateId,RegionId=temp.RegionId,DistrictId=temp.DistrictId,AreaId=temp.AreaId,Pincode=temp.Pincode,
			IsDefault=temp.IsDefault,IsActive=temp.IsActive,
				NameForAddress=temp.NameForAddress,MobileNo=temp.MobileNo,EmailId=temp.EmailId,AddressTypeId=temp.AddressTypeId
				,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			 FROM CustomerAddressMapping EAM
			INNER JOIN AddressMaster AD ON AD.AddressId=EAM.AddressId
			INNER JOIN @tempAddressDetail temp ON temp.AddressId=AD.AddressId
			WHERE EAM.CustomerId=@CustomerId

			UPDATE CD
			SET ContactName=tempd.ContactName,MobileNo=tempd.MobileNo,
				EmailId=tempd.EmailId,RefPartyId=tempd.RefPartyId,
				IsActive=tempd.IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			 FROM CustomerContactMapping EAM
			INNER JOIN ContactDetails CD ON CD.ContactId=EAM.ContactId
			INNER JOIN @tempContactDetail tempd ON tempd.ContactId=CD.ContactId
			WHERE EAM.CustomerId=@CustomerId

			
			SET @Result = @CustomerId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result
END


GO
Drop Procedure If Exists GetCustomers;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetCustomers]
Description : Get Customer Detail from CustomerDetails
*/
CREATE Or Alter Procedure[dbo].[GetCustomers]
AS
BEGIN
	SELECT CD.CustomerId,CD.CompanyName,CD.LandlineNo,CD.MobileNo as MobileNumber,CD.EmailId,
	CD.CustomerTypeId,CD.SpecialRemarks,CD.EmployeeId,COD.ContactId,COD.ContactName,COD.MobileNo,COD.EmailId,
	COD.RefPartyId,AM.AddressId,AM.[Address],AM.StateId,AM.RegionId,AM.DistrictId,AM.AreaId,AM.Pincode,AM.IsActive
	FROM CustomerDetails CD WITH(NOLOCK)
	INNER JOIN CustomerContactMapping CCM  WITH(NOLOCK) ON CCM.CustomerId=CD.CustomerId
	INNER JOIN ContactDetails COD  WITH(NOLOCK) ON COD.ContactId=CCM.ContactId
	INNER JOIN CustomerAddressMapping CAM WITH(NOLOCK) ON CAM.CustomerId=CD.CustomerId
	--INNER JOIN  RM WITH(NOLOCK) ON RM.RoleId
	INNER JOIN AddressMaster AM WITH(NOLOCK) ON AM.AddressId=CAM.AddressId
END



GO
If OBJECT_ID('VisitAddressMapping') Is Not Null
Begin
	Drop Table VisitAddressMapping
End

GO

If OBJECT_ID('VisitMaster') Is Not Null
Begin
	Drop Table VisitMaster
End

GO

If OBJECT_ID('VisitMaster') Is Null
Begin

	CREATE TABLE VisitMaster
	(
		VisitId BIGINT IDENTITY(1,1) PRIMARY KEY,
		EmployeeId  BIGINT FOREIGN KEY REFERENCES EmployeeMaster(EmployeeId),
		VisitDate Datetime,
		CustomerId BIGINT FOREIGN KEY REFERENCES CustomerDetails(CustomerId),
		CustomerTypeId BIGINT FOREIGN KEY REFERENCES CustomerTypeMaster(CustomerTypeId),
		ContactPerson VARCHAR(100),
		ContactNumber VARCHAR(20),
		EmailId VARCHAR(100),
		NextActionDate DATETIME,
		LandlineNo VARCHAR(15),
		MobileNo VARCHAR(15),
		Latitude Decimal(9,6),
		Longitude Decimal(9,6),
		Remarks VARCHAR(250),
		IsActive BIT NOT NULL,
		CreatedBy BIGINT NOT NULL,
		CreatedOn DATETIME NOT NULL,
		ModifiedBy BIGINT,
		ModifiedOn DATETIME
	)
END

GO

CREATE TABLE VisitAddressMapping
(
VisitAddressId BIGINT IDENTITY(1,1) PRIMARY KEY,
VisitId BIGINT FOREIGN KEY REFERENCES VisitMaster(VisitId), 
AddressId  BIGINT FOREIGN KEY REFERENCES AddressMaster(AddressId)
)
GO

GO
Drop Procedure If Exists SaveVisitDetails;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[SaveVisitDetails] 
Description : Insert Visit Detail from VisitMaster
*/
CREATE Or Alter Procedure[dbo].[SaveVisitDetails]
(
	@VisitId BIGINT,
	@EmployeeId BIGINT,
	@VisitDate Datetime,
	@CustomerId BIGINT,
	@CustomerTypeId BIGINT,
	@StateId BIGINT,
	@RegionId BIGINT,
	@DistrictId BIGINT,
	@AreaId BIGINT,
	@Address VARCHAR(500),
	@Pincode VARCHAR(15),
	@ContactPerson VARCHAR(100),
	@ContactNumber VARCHAR(20),
	@EmailId VARCHAR(100),
	@NextActionDate Datetime,
	@LandlineNo VARCHAR(20),
	@MobileNumber VARCHAR(20),
	@Latitude DECIMAL(9,6),
	@Longitude DECIMAL(9,6),
	@Remarks VARCHAR(500),
	@IsActive BIT,
	@LoggedInUserId BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @AddressId BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	If (
		(@VisitId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM VisitMaster WITH(NOLOCK) 
				WHERE EmployeeId=@EmployeeId and VisitDate=@VisitDate and CustomerId=@CustomerId
			)
		)
		OR
		(@VisitId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM VisitMaster WITH(NOLOCK) 
				WHERE  EmployeeId=@EmployeeId and VisitDate=@VisitDate and CustomerId=@CustomerId and VisitId<>@VisitId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@VisitId=0)
		BEGIN
			Insert into VisitMaster(EmployeeId,VisitDate,CustomerId,CustomerTypeId,ContactPerson,ContactNumber,EmailId,NextActionDate,
									LandlineNo,MobileNo,Latitude,Longitude,Remarks,IsActive,CreatedBy,CreatedOn)
			Values(@EmployeeId,@VisitDate,@CustomerId,@CustomerTypeId,@ContactPerson,@ContactNumber,@EmailId,@NextActionDate,
									@LandlineNo,@MobileNumber,@Latitude,@Longitude,@Remarks,@IsActive,@LoggedInUserId,GETDATE())

			SET @Result = SCOPE_IDENTITY();
			
			-- Insert Into Address 
			INSERT INTO AddressMaster(Address,StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn)
			Values (@Address,@StateId,@RegionId,@DistrictId,@AreaId,@Pincode,0,@IsActive,@LoggedInUserId,GETDATE())

			SET @AddressId = SCOPE_IDENTITY();

			INSERT INTO VisitAddressMapping(VisitId,AddressId)
			Values (@Result,@AddressId)
		
		END
		ELSE IF(@VisitId> 0 and EXISTS(SELECT TOP 1 1 FROM VisitMaster WHERE VisitId=@VisitId))
		BEGIN
			UPDATE VisitMaster
			SET EmployeeId=@EmployeeId,VisitDate=@VisitDate,CustomerId=@CustomerId,CustomerTypeId=@CustomerTypeId,ContactPerson=@ContactPerson,
									ContactNumber=@ContactNumber,EmailId=@EmailId,NextActionDate=@NextActionDate,
									LandlineNo=@LandlineNo,MobileNo=@MobileNumber,Latitude=@Latitude,Longitude=@Longitude,Remarks=@Remarks,
						IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE VisitId=@VisitId

			UPDATE AD
			SET Address=@Address,StateId=@StateId,RegionId=@RegionId,DistrictId=@DistrictId,AreaId=@AreaId,Pincode=@Pincode
				,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			 FROM EmployeeAddressMapping EAM
			INNER JOIN AddressMaster AD ON AD.AddressId=EAM.AddressId
			WHERE EAM.EmployeeId=@EmployeeId

			
			SET @Result = @EmployeeId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result
END

GO
Drop Procedure If Exists GetVisits;
GO
/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetVisits]
Description : Get Visit Detail from GetVisits
*/
CREATE Or Alter Procedure[dbo].[GetVisits]
AS
BEGIN
	SELECT EM.VisitId,EM.EmployeeId,EM.VisitDate,EM.CustomerId,EM.CustomerTypeId,EM.ContactPerson,EM.ContactNumber,
		EM.EmailId,EM.NextActionDate,EM.LandlineNo,EM.MobileNo,EM.Latitude,EM.Longitude,EM.Remarks,
		   AD.Address,AD.StateId,AD.RegionId,AD.DistrictId,AD.AreaId,AD.Pincode,EM.IsActive
	FROM VisitMaster EM WITH(NOLOCK)
	INNER JOIN VisitAddressMapping EAM WITH(NOLOCK) ON EAM.VisitId = EM.VisitId
	INNER JOIN AddressMaster AD WITH(NOLOCK) ON Ad.AddressId=EAM.AddressId
END