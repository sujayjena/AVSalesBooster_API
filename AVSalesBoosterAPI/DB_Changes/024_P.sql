If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='EmployeeMaster' And Column_Name='EmailId')
Begin
	Alter Table EmployeeMaster
	Alter Column EmailId VarChar(200) Null
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='Users' And Column_Name='EmailId')
Begin
	Alter Table Users
	Alter Column EmailId VarChar(200) Null
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='EmployeeMaster' And Column_Name='AdharCardFileName')
Begin
	Alter Table EmployeeMaster
	Add AdharCardFileName VarChar(200)
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='EmployeeMaster' And Column_Name='AdharCardSavedFileName')
Begin
	Alter Table EmployeeMaster
	Add AdharCardSavedFileName VarChar(200)
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='EmployeeMaster' And Column_Name='PanCardFileName')
Begin
	Alter Table EmployeeMaster
	Add PanCardFileName VarChar(200)
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='EmployeeMaster' And Column_Name='PanCardSavedFileName')
Begin
	Alter Table EmployeeMaster
	Add PanCardSavedFileName VarChar(200)
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='EmployeeMaster' And Column_Name='EmployeeCode')
Begin
	Alter Table EmployeeMaster
	Alter Column EmployeeCode VarChar(20)
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='EmployeeMaster' And Column_Name='MobileNumber')
Begin
	Alter Table EmployeeMaster
	Alter Column MobileNumber VarChar(20) Not Null
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='EmployeeMaster' And Column_Name='RoleId')
Begin
	Alter Table EmployeeMaster
	Alter Column RoleId BigInt Not Null

	Alter Table EmployeeMaster
	Add Foreign Key (RoleId) References RoleMaster(RoleId)
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='EmployeeMaster' And Column_Name='ReportingTo')
Begin
	Update EmployeeMaster Set ReportingTo=1 Where ReportingTo Is Null

	Alter Table EmployeeMaster
	Alter Column ReportingTo BigInt Not Null

	Alter Table EmployeeMaster
	Add Foreign Key (ReportingTo) References EmployeeMaster(EmployeeId)
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='EmployeeMaster' And Column_Name='DateOfBirth')
Begin
	Update EmployeeMaster Set DateOfBirth = DateAdd(Year,-20, getdate()) Where DateOfBirth Is Null

	Alter Table EmployeeMaster
	Alter Column DateOfBirth DateTime Not Null
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='EmployeeMaster' And Column_Name='DateOfJoining')
Begin
	Update EmployeeMaster Set DateOfJoining = DateAdd(Day,-1, getdate()) Where DateOfJoining Is Null

	Alter Table EmployeeMaster
	Alter Column DateOfJoining DateTime Not Null
End

GO

/*
	Version : 1.0
	Created Date : 03 JULY 2023
	Execution : EXEC [dbo].[SaveEmployeeDetails] 
	Description : Insert Employee Detail from EmployeeMaster
*/
Alter Procedure SaveEmployeeDetails
(
	@EmployeeId BIGINT,
	@EmployeeName VARCHAR(100),
	@EmployeeCode VARCHAR(100),
	@EmailId VARCHAR(100),
	@MobileNumber VARCHAR(20),
	@RoleId BIGINT,
	@ReportingTo BIGINT,
	@Address VARCHAR(500),
	@StateId BIGINT,
	@RegionId BIGINT,
	@DistrictId BIGINT,
	@AreaId BIGINT,
	@Pincode VARCHAR(15),
	@DateOfBirth Datetime,
	@DateOfJoining Datetime,
	@EmergencyContactNumber VARCHAR(20),
	@BloodGroupId Int,
	@IsWebUser BIT,
	@IsMobileUser BIT,
	@IsActive BIT,
	@FileOriginalName VARCHAR(2000),
	@ImageUpload VARCHAR(2000),
	@AdharCardFileName VarChar(200),
	@AdharCardSavedFileName VarChar(200),
	@PanCardFileName VarChar(200),
	@PanCardSavedFileName VarChar(200),
	@LoggedInUserId BIGINT,
	@Password VARCHAR(250)
)
AS
BEGIN
	Set NoCount On;

	Declare @Result BIGINT=0;
	Declare @AddressId BIGINT=0;
	Declare @IsEmpCodeExists BIGINT=-5;
	Declare @IsNameExists BIGINT=-2;
	Declare @NoRecordExists BIGINT=-1;

	If (
		(@EmployeeId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM EmployeeMaster WITH(NOLOCK) 
				WHERE EmployeeName=@EmployeeName
			)
		)
		OR
		(@EmployeeId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM EmployeeMaster WITH(NOLOCK) 
				WHERE EmployeeName=@EmployeeName and EmployeeId<>@EmployeeId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	Else If (
		@EmployeeId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM EmployeeMaster WITH(NOLOCK) 
				WHERE EmployeeCode=@EmployeeCode
			)
		)
	BEGIN
		SET @Result = @IsEmpCodeExists;
	END
	ELSE
	BEGIN
		IF @EmployeeId=0
		BEGIN
			Insert Into EmployeeMaster
			(
				EmployeeName,EmployeeCode,EmailId,MobileNumber,RoleId,ReportingTo,DateOfBirth,DateOfJoining,EmergencyContactNumber,BloodGroup,
				IsWebUser,IsMobileUser,IsActive,FileOriginalName,ImageUpload,
				AdharCardFileName,AdharCardSavedFileName,PanCardFileName,PanCardSavedFileName,
				CreatedBy,CreatedOn
			)
			Values
			(
				@EmployeeName,@EmployeeCode,@EmailId ,@MobileNumber,@RoleId,@ReportingTo,@DateOfBirth,@DateOfJoining,@EmergencyContactNumber,@BloodGroupId,
				@IsWebUser,@IsMobileUser,@IsActive,@FileOriginalName,@ImageUpload,
				@AdharCardFileName,@AdharCardSavedFileName,@PanCardFileName,@PanCardSavedFileName,
				@LoggedInUserId,GETDATE()
			)

			SET @Result = SCOPE_IDENTITY();
			
			-- Insert Into Address 
			Insert Into AddressMaster
			(
				[Address],StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn
			)
			Values
			(
				@Address,@StateId,@RegionId,@DistrictId,@AreaId,@Pincode,1,@IsActive,@LoggedInUserId,GETDATE()
			)

			SET @AddressId = SCOPE_IDENTITY();

			INSERT INTO EmployeeAddressMapping
			(
				EmployeeId,AddressId
			)
			Values
			(
				@Result,@AddressId
			)

			Insert Into Users
			(
				EmailId,MobileNo,Passwords,EmployeeId,IsActive,CreatedBy,CreatedOn
			)
			Select @EmailId,@MobileNumber,@Password,@Result,@IsActive,@LoggedInUserId,GETDATE()
		END
		ELSE IF @EmployeeId> 0 and EXISTS(SELECT TOP 1 1 FROM EmployeeMaster WHERE EmployeeId=@EmployeeId)
		BEGIN
			UPDATE EmployeeMaster
			SET EmployeeName=@EmployeeName,
				--EmployeeCode=@EmployeeCode,
				EmailId=@EmailId,
				MobileNumber=@MobileNumber,
				RoleId=@RoleId,
				ReportingTo=@ReportingTo,
				DateOfBirth=@DateOfBirth,
				DateOfJoining=@DateOfJoining,
				EmergencyContactNumber=@EmergencyContactNumber,
				BloodGroup=@BloodGroupId,
				IsWebUser=@IsWebUser,
				IsMobileUser=@IsMobileUser,
				IsActive=@IsActive,
				FileOriginalName=@FileOriginalName,
				ImageUpload=@ImageUpload,
				AdharCardFileName=@AdharCardFileName,
				AdharCardSavedFileName=@AdharCardSavedFileName,
				PanCardFileName=@PanCardFileName,
				PanCardSavedFileName=@PanCardSavedFileName,
				ModifiedBy=@LoggedInUserId, 
				ModifiedOn=GETDATE()
			WHERE EmployeeId = @EmployeeId

			Update AD
			Set [Address]=@Address,
				StateId=@StateId,
				RegionId=@RegionId,
				DistrictId=@DistrictId,
				AreaId=@AreaId,
				Pincode=@Pincode,
				ModifiedBy=@LoggedInUserId,
				ModifiedOn=GETDATE()
			From EmployeeAddressMapping EAM
			Inner Join AddressMaster AD
				On AD.AddressId=EAM.AddressId
			Where EAM.EmployeeId = @EmployeeId
			
			Update Users
			Set EmailId=@EmailId,
				MobileNo=@MobileNumber,
				ModifiedBy=@LoggedInUserId,
				ModifiedOn=GETDATE()
			Where EmployeeId = @EmployeeId

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

-- GetReportingToEmployeeForSelectList 1,1
Create Or Alter Procedure GetReportingToEmployeeForSelectList
	@RoleId		BigInt,
	@RegionId	BigInt
As
Begin
	Set NoCount On;

	SELECT
		EM.EmployeeId AS [Value], EM.EmployeeName AS [Text]
	From EmployeeMaster EM With(NoLock)
	Left Join EmployeeAddressMapping EAM With(NoLock)
		On EAM.EmployeeId = EM.EmployeeId
	Left Join AddressMaster AM With(NoLock)
		On AM.AddressId = EAM.AddressId
	Where EM.RoleId = @RoleId And AM.RegionId = @RegionId
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='ContactDetails' And Column_Name='RefPartyId')
Begin
	DECLARE @ConstraintName nvarchar(200)
	
	SELECT 
	    @ConstraintName = KCU.CONSTRAINT_NAME
	FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS AS RC 
	INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KCU
	    ON KCU.CONSTRAINT_CATALOG = RC.CONSTRAINT_CATALOG  
	    AND KCU.CONSTRAINT_SCHEMA = RC.CONSTRAINT_SCHEMA 
	    AND KCU.CONSTRAINT_NAME = RC.CONSTRAINT_NAME
	WHERE
	    KCU.TABLE_NAME = 'ContactDetails' AND
	    KCU.COLUMN_NAME = 'RefPartyId'

	IF @ConstraintName IS NOT NULL
		EXEC('Alter Table ContactDetails drop  CONSTRAINT ' + @ConstraintName)

	Alter Table ContactDetails
	Drop Column RefPartyId
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='ContactDetails' And Column_Name='RefPartyName')
Begin
	Alter Table ContactDetails
	Add RefPartyName VarChar(100)
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='ContactDetails' And Column_Name='RefPartyName')
Begin
	Update ContactDetails Set RefPartyName=''

	Alter Table ContactDetails
	Alter Column RefPartyName VarChar(100) Not Null
End

GO

/*
EXEC SaveCustomerDetails 0,'XYZ Company Ltd.','123456000','1020304505','test@gmail.com',1,'test',1,1,
'<ArrayOfContactDetail xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <ContactDetail>
    <ContactId>0</ContactId>
    <ContactName>Akshay One</ContactName>
    <MobileNo>111111111</MobileNo>
    <EmailId>Akshay@gmail.com</EmailId>
    <RefPartyName>1</RefPartyName>
    <IsActive>true</IsActive>
  </ContactDetail>
  <ContactDetail>
    <ContactId>0</ContactId>
    <ContactName>Mehul One</ContactName>
    <MobileNo>22222222</MobileNo>
    <EmailId>MEhul@gmail.com</EmailId>
    <RefPartyName>2</RefPartyName>
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
</ArrayOfAddressDetail>',1,'adsdj2342'
*/

ALTER PROCEDURE [dbo].[SaveCustomerDetails]
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
	@LoggedInUserId BIGINT,
	@Password VARCHAR(250)
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
		ContactId		BIGINT ,
		ContactName		VARCHAR(100),
		MobileNo		VARCHAR(15),
		EmailId			VARCHAR(100),
		RefPartyName	VARCHAR(100),
		IsActive		BIT
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
		NameForAddress	VARCHAR(100),
		MobileNo		VARCHAR(15),
		EmailId			VARCHAR(100),
		AddressTypeId   BIGINT
	)

	INSERT INTO @tempContactDetail
	(
		ContactId,ContactName,MobileNo,EmailId,RefPartyName,IsActive
	)
	SELECT
		ContactId		= T.Item.value('ContactId[1]', 'BIGINT'),
		ContactName		= T.Item.value('ContactName[1]', 'varchar(50)'),
		MobileNo		= T.Item.value('MobileNo[1]', 'varchar(15)'),
		EmailId			= T.Item.value('EmailId[1]', 'varchar(100)'),
		RefPartyName	= T.Item.value('RefPartyName[1]', 'varchar(100)'),
		IsActive		= T.Item.value('IsActive[1]', 'BIT')
	FROM @XmlContactData.nodes('/ArrayOfContactDetail/ContactDetail') AS T(Item)
	
	INSERT INTO @tempAddressDetail
	(
		AddressId,[Address],StateId,RegionId,DistrictId,AreaId,Pincode,IsActive,IsDefault,NameForAddress,MobileNo,EmailId,AddressTypeId
	)
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
	FROM @xmlAddressData.nodes('/ArrayOfAddressDetail/AddressDetail') AS T(Item)
	
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
			Insert into CustomerDetails
			(
				CompanyName,LandlineNo,MobileNo,EmailId,CustomerTypeId,SpecialRemarks,EmployeeId,
				IsActive,CreatedBy,CreatedOn
			)
			Values
			(
				@CompanyName,@LandlineNo ,@MobileNumber,@EmailId,@CustomerTypeId,@SpecialRemarks,@EmployeeRoleId,@IsActive,@LoggedInUserId,GETDATE()
			)

			SET @Result = SCOPE_IDENTITY();
			
			DECLARE @tempAdd TABLE
			(
				AddId BIGINT
			)

			-- Insert Into Address 
			INSERT INTO AddressMaster
			(
				[Address],StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn,NameForAddress,MobileNo,EmailId,AddressTypeId
			)
			OUTPUT inserted.AddressId
			into @tempAdd
			SELECT
				[Address],StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,@LoggedInUserId,GETDATE(),NameForAddress,MobileNo,EmailId,AddressTypeId
			FROM @tempAddressDetail

			INSERT INTO CustomerAddressMapping
			(
				CustomerId,AddressId
			)
			Select
				@Result,AddId
			from @tempAdd

			DECLARE @tempContact TABLE
			(
				ContId BIGINT
			)

			Insert Into ContactDetails
			(
				ContactName,MobileNo,EmailId,RefPartyName,IsActive,CreatedBy,CreatedOn
			)
			OUTPUT inserted.ContactId
			Into @tempContact
			Select
				ContactName,MobileNo,EmailId,RefPartyName,IsActive,@LoggedInUserId,GETDATE()
			From @tempContactDetail

			Insert Into CustomerContactMapping
			(
				CustomerId,ContactId
			)
			Select
				@Result,ContId
			From @tempContact

			------ Commented as User of Customer not required to create
			--INSERT INTO Users(EmailId,MobileNo,Passwords,CustomerId,IsActive,TermsConditionsAccepted,CreatedBy,CreatedOn)
			--SELECT @EmailId,@MobileNumber,@Password,@Result,@IsActive,1,@LoggedInUserId,GETDATE()
		END
		ELSE IF(@CustomerId> 0 and EXISTS(SELECT TOP 1 1 FROM CustomerDetails WHERE EmployeeId=@CustomerId))
		BEGIN
			UPDATE CustomerDetails
			SET CompanyName=@CompanyName,
				LandlineNo=@LandlineNo,
				MobileNo=@MobileNumber,
				EmailId=@EmailId,
				CustomerTypeId=@CustomerTypeId,
				SpecialRemarks=@SpecialRemarks,
				EmployeeId=@EmployeeRoleId,
				IsActive=@IsActive,
				ModifiedBy=@LoggedInUserId,
				ModifiedOn=GETDATE()
			WHERE CustomerId=@CustomerId

			UPDATE AD
			SET [Address]=temp.[Address],
				StateId=temp.StateId,
				RegionId=temp.RegionId,
				DistrictId=temp.DistrictId,
				AreaId=temp.AreaId,
				Pincode=temp.Pincode,
				IsDefault=temp.IsDefault,
				IsActive=temp.IsActive,
				NameForAddress=temp.NameForAddress,
				MobileNo=temp.MobileNo,
				EmailId=temp.EmailId,
				AddressTypeId=temp.AddressTypeId,
				ModifiedBy=@LoggedInUserId,
				ModifiedOn=GETDATE()
			FROM CustomerAddressMapping EAM
			INNER JOIN AddressMaster AD
				ON AD.AddressId=EAM.AddressId
			INNER JOIN @tempAddressDetail temp
				ON temp.AddressId=AD.AddressId
			WHERE EAM.CustomerId=@CustomerId

			UPDATE CD
			SET ContactName=tempd.ContactName,
				MobileNo=tempd.MobileNo,
				EmailId=tempd.EmailId,
				CD.RefPartyName=tempd.RefPartyName,
				IsActive=tempd.IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			FROM CustomerContactMapping EAM
			INNER JOIN ContactDetails CD
				ON CD.ContactId=EAM.ContactId
			INNER JOIN @tempContactDetail tempd
				ON tempd.ContactId=CD.ContactId
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

-- GetCustomerContactDetailsById 7
Alter Procedure GetCustomerContactDetailsById
	@CustomerId BIGINT
AS
BEGIN
	Set NoCount On;

	Select
		CD.ContactId, CD.ContactName, CD.MobileNo, CD.EmailId,
		CD.RefPartyName, 
		--RM.PartyName, RM.PhoneNumber as RefPhoneNumber, RM.MobileNumber as RefMobileNumber,
		'' as PartyName, '' as RefPhoneNumber, '' as RefMobileNumber,
		CD.IsActive,
		CreatorEM.EmployeeName As CreatorName,
		CD.CreatedBy,
		CD.CreatedOn,
		ModifierEmp.EmployeeName As ModifierName,
		CD.ModifiedBy,
		CD.ModifiedOn
	From CustomerContactMapping CCM With(NoLock)
	INNER JOIN ContactDetails CD With(NoLock)
		On CD.ContactId=CCM.ContactId
	Inner Join Users U With(NoLock)
		On U.UserId = CD.CreatedBy
	Left Join EmployeeMaster CreatorEM With(NoLock)
		On CreatorEM.EmployeeId = U.EmployeeId And U.EmployeeId Is Not Null
	Left Join Users Modifier With(NoLock)
		On Modifier.UserId = CD.ModifiedBy
	Left Join EmployeeMaster ModifierEmp With(NoLock)
		On ModifierEmp.EmployeeId = Modifier.EmployeeId And Modifier.EmployeeId Is Not Null
	--Left Join ReferenceMaster RM WIth(NoLock)
	--	On RM.ReferenceId = CD.RefPartyId
	WHERE CCM.CustomerId = @CustomerId
END

GO

