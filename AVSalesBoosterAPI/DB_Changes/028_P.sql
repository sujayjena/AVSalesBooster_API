If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='CustomerDetails' And Column_Name='GstFileName')
Begin
	Alter Table CustomerDetails
	Add GstFileName VarChar(200) NULL
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='CustomerDetails' And Column_Name='GstSavedFileName')
Begin
	Alter Table CustomerDetails
	Add GstSavedFileName VarChar(200) NULL
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='CustomerDetails' And Column_Name='PanCardFileName')
Begin
	Alter Table CustomerDetails
	Add PanCardFileName VarChar(200) NULL
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='CustomerDetails' And Column_Name='PanCardSavedFileName')
Begin
	Alter Table CustomerDetails
	Add PanCardSavedFileName VarChar(200) NULL
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='CustomerDetails' And Column_Name='RefPartyName')
Begin
	Alter Table ContactDetails
	Alter Column RefPartyName VarChar(100) Null
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='ContactDetails' And Column_Name='PanCardFileName')
Begin
	Alter Table ContactDetails
	Add PanCardFileName VarChar(200) NULL
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='ContactDetails' And Column_Name='IsDefault')
Begin
	Alter Table ContactDetails
	Add IsDefault Bit NULL
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='ContactDetails' And Column_Name='PanCardSavedFileName')
Begin
	Alter Table ContactDetails
	Add PanCardSavedFileName VarChar(200) NULL
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='ContactDetails' And Column_Name='AdharCardFileName')
Begin
	Alter Table ContactDetails
	Add AdharCardFileName VarChar(200) NULL
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='ContactDetails' And Column_Name='AdharCardSavedFileName')
Begin
	Alter Table ContactDetails
	Add AdharCardSavedFileName VarChar(200) NULL
End

GO

/*
EXEC SaveCustomerDetails 0,'Demo Company LLP','123456789','1020304050','vishu@gmail.com',1,'test',1,1,
'<ArrayOfContactDetail xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <ContactDetail>
    <ContactId>0</ContactId>
    <ContactName>Akshay</ContactName>
    <MobileNo>111111111</MobileNo>
    <EmailId>Akshay@gmail.com</EmailId>
    <RefPartyName>1</RefPartyName>
    <IsActive>true</IsActive>
	<IsDefault>false</IsDefault>
  </ContactDetail>
  <ContactDetail>
    <ContactId>0</ContactId>
    <ContactName>Mehul</ContactName>
    <MobileNo>22222222</MobileNo>
    <EmailId>MEhul@gmail.com</EmailId>
    <RefPartyName>2</RefPartyName>
    <IsActive>true</IsActive>
	<IsDefault>true</IsDefault>
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

Alter Procedure SaveCustomerDetails
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
	@GstFileName			VarChar(200),
	@GstSavedFileName		VarChar(200),
	@PanCardFileName		VarChar(200),
	@PanCardSavedFileName	VarChar(200),
	@XmlContactData XML,
	@XmlAddressData XML,
	@LoggedInUserId BIGINT,
	@Password VARCHAR(250)
)
As
Begin
	Set NoCount On;
	Declare @Result BIGINT=0;
	Declare @AddressId BIGINT=0;
	Declare @IsNameExists BIGINT=-2;
	Declare @NoRecordExists BIGINT=-1;

	Declare @tempContactDetail Table
	(
		ContactId				BigInt,
		ContactName				VarChar(100),
		MobileNo				VarChar(15),
		EmailId					VarChar(100),
		RefPartyName			VarChar(100),
		IsActive				Bit,
		IsDefault				Bit,
		PanCardFileName			VarChar(200),
		PanCardSavedFileName	VarChar(200),
		AdharCardFileName		VarChar(200),
		AdharCardSavedFileName	VarChar(200)
	)

	Declare @tempAddressDetail Table
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

	Insert Into @tempContactDetail
	(
		ContactId,ContactName,MobileNo,EmailId,RefPartyName,IsDefault,IsActive,PanCardFileName,PanCardSavedFileName,AdharCardFileName,AdharCardSavedFileName
	)
	Select
		ContactId				= T.Item.value('ContactId[1]', 'BIGINT'),
		ContactName				= T.Item.value('ContactName[1]', 'varchar(50)'),
		MobileNo				= T.Item.value('MobileNo[1]', 'varchar(15)'),
		EmailId					= T.Item.value('EmailId[1]', 'varchar(100)'),
		RefPartyName			= T.Item.value('RefPartyName[1]', 'varchar(100)'),
		IsDefault				= T.Item.value('IsDefault[1]', 'BIT'),
		IsActive				= T.Item.value('IsActive[1]', 'BIT'),
		PanCardFileName			= T.Item.value('PanCardFileName[1]','VarChar(200)'),
		PanCardSavedFileName	= T.Item.value('PanCardSavedFileName[1]','VarChar(200)'),
		AdharCardFileName		= T.Item.value('AdharCardFileName[1]','VarChar(200)'),
		AdharCardSavedFileName	= T.Item.value('AdharCardSavedFileName[1]','VarChar(200)')
	From @XmlContactData.nodes('/ArrayOfContactDetail/ContactDetail') As T(Item)
	
	Insert Into @tempAddressDetail
	(
		AddressId,[Address],StateId,RegionId,DistrictId,AreaId,Pincode,IsActive,IsDefault,NameForAddress,MobileNo,EmailId,AddressTypeId
	)
	Select
		AddressId = T.Item.value('AddressId[1]', 'BIGINT'),
		[Address] = T.Item.value('Address[1]', 'varchar(500)'),
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
	From @xmlAddressData.nodes('/ArrayOfAddressDetail/AddressDetail') As T(Item)
	
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
				GstFileName,GstSavedFileName,PanCardFileName,PanCardSavedFileName,IsActive,CreatedBy,CreatedOn
			)
			Values
			(
				@CompanyName,@LandlineNo ,@MobileNumber,@EmailId,@CustomerTypeId,@SpecialRemarks,@EmployeeRoleId,
				@GstFileName,@GstSavedFileName,@PanCardFileName,@PanCardSavedFileName,@IsActive,@LoggedInUserId,GETDATE()
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
			From @tempAdd

			DECLARE @tempContact TABLE
			(
				ContId BIGINT
			)

			Insert Into ContactDetails
			(
				ContactName,MobileNo,EmailId,RefPartyName,IsDefault,IsActive,PanCardFileName,PanCardSavedFileName,AdharCardFileName,AdharCardSavedFileName,
				CreatedBy,CreatedOn
			)
			OUTPUT inserted.ContactId
			Into @tempContact
			Select
				ContactName,MobileNo,EmailId,RefPartyName,IsDefault,IsActive,PanCardFileName,PanCardSavedFileName,AdharCardFileName,AdharCardSavedFileName,
				@LoggedInUserId,GETDATE()
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
		ELSE IF(@CustomerId> 0 and EXISTS(SELECT TOP 1 1 FROM CustomerDetails WHERE CustomerId=@CustomerId))
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
				GstFileName=@GstFileName,
				GstSavedFileName=@GstSavedFileName,
				PanCardFileName=@PanCardFileName,
				PanCardSavedFileName=@PanCardSavedFileName,
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
				IsDefault=tempd.IsDefault,
				IsActive=tempd.IsActive,
				PanCardFileName=tempd.PanCardFileName,
				PanCardSavedFileName=tempd.PanCardSavedFileName,
				AdharCardFileName=tempd.AdharCardFileName,
				AdharCardSavedFileName=tempd.AdharCardSavedFileName,
				ModifiedBy=@LoggedInUserId,
				ModifiedOn=GETDATE()
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
End

GO

-- GetCustomerDetailsById 10
Alter Procedure GetCustomerDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		CD.CustomerId,
		CD.CompanyName,
		CD.LandlineNo,
		CD.MobileNo as MobileNumber,
		CD.EmailId,
		CD.CustomerTypeId,
		CTM.CustomerTypeName as CustomerTypeName,
		CD.SpecialRemarks,
		CD.EmployeeId,
		EM.EmployeeName as EmployeeName,
		RM.RoleId,
		RM.RoleName As EmployeeRole,
		CreatorEM.EmployeeName As CreatorName,
		CD.GstFileName,
		CD.GstSavedFileName,
		CD.PanCardFileName,
		CD.PanCardSavedFileName,
		CD.IsActive,
		CD.CreatedBy,
		CD.CreatedOn
	FROM CustomerDetails CD WITH(NOLOCK)
	Inner Join Users U With(NoLock)
		On U.UserId = CD.CreatedBy
	Left Join EmployeeMaster CreatorEM With(NoLock)
		On CreatorEM.EmployeeId = U.EmployeeId
			And U.EmployeeId Is Not Null
	LEFT JOIN CustomerTypeMaster CTM  WITH(NOLOCK)
		ON CTM.CustomerTypeId = CD.CustomerTypeId
	LEFT JOIN EmployeeMaster EM WITH(NOLOCK)
		ON EM.EmployeeId=CD.EmployeeId
	Left Join RoleMaster RM With(NoLock)
		On RM.RoleId = EM.RoleId
	WHERE CD.CustomerId = @Id
END

GO

-- GetCustomerContactDetailsById 10
Alter Procedure GetCustomerContactDetailsById
	@CustomerId BIGINT
As
Begin
	Set NoCount On;

	Select
		CD.ContactId,
		CD.ContactName,
		CD.MobileNo,
		CD.EmailId,
		CD.RefPartyName, 
		--RM.PartyName, RM.PhoneNumber as RefPhoneNumber, RM.MobileNumber as RefMobileNumber,
		'' as PartyName,
		'' as RefPhoneNumber,
		'' as RefMobileNumber,
		CD.PanCardFileName,
		CD.PanCardSavedFileName,
		CD.AdharCardFileName,
		CD.AdharCardSavedFileName,
		CD.IsDefault,
		CD.IsActive,
		CreatorEM.EmployeeName As CreatorName,
		CD.CreatedBy,
		CD.CreatedOn,
		ModifierEmp.EmployeeName As ModifierName,
		CD.ModifiedBy,
		CD.ModifiedOn
	From CustomerContactMapping CCM With(NoLock)
	Inner Join ContactDetails CD With(NoLock)
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
	Where CCM.CustomerId = @CustomerId
End

GO

-- UpdateLeaveStatus 2,5,'Approved',1
Create Or Alter Procedure UpdateLeaveStatus
	@LeaveId		BigInt,
	@LeaveStatusId	Int,
	@Reason			VarChar(100),
	@LoggedInUserId	BigInt
As
Begin
	Set NoCount On;
	Declare @Result As BigInt = 0;

	If Exists(Select Top 1 1 From LeaveMaster With(NoLock) Where LeaveId = @LeaveId)
	Begin
		Update LeaveMaster
		Set StatusId	= @LeaveStatusId,
			Reason		= @Reason,
			ModifiedBy	= @LoggedInUserId,
			ModifiedOn	= GetDate()
		Where LeaveId	= @LeaveId

		Set @Result = @LeaveId
	End

	Select @Result As Result
End

GO
