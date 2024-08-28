Alter Table EmployeeMaster
Alter Column ReportingTo BigInt NULL

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
  </ContactDetail>
  <ContactDetail>
    <ContactId>0</ContactId>
    <ContactName>Mehul</ContactName>
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
		ContactId		BigInt,
		ContactName		VarChar(100),
		MobileNo		VarChar(15),
		EmailId			VarChar(100),
		RefPartyName	VarChar(100),
		IsActive		Bit
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
		ContactId,ContactName,MobileNo,EmailId,RefPartyName,IsActive
	)
	Select
		ContactId		= T.Item.value('ContactId[1]', 'BIGINT'),
		ContactName		= T.Item.value('ContactName[1]', 'varchar(50)'),
		MobileNo		= T.Item.value('MobileNo[1]', 'varchar(15)'),
		EmailId			= T.Item.value('EmailId[1]', 'varchar(100)'),
		RefPartyName	= T.Item.value('RefPartyName[1]', 'varchar(100)'),
		IsActive		= T.Item.value('IsActive[1]', 'BIT')
	From @XmlContactData.nodes('/ArrayOfContactDetail/ContactDetail') As T(Item)
	
	Insert Into @tempAddressDetail
	(
		AddressId,[Address],StateId,RegionId,DistrictId,AreaId,Pincode,IsActive,IsDefault,NameForAddress,MobileNo,EmailId,AddressTypeId
	)
	Select
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
			From @tempAdd

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
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='PunchInOutHistory' And Column_Name='InLatitude')
Begin
	Alter Table PunchInOutHistory
	Add InLatitude VarChar(20)
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='PunchInOutHistory' And Column_Name='InLongitude')
Begin
	Alter Table PunchInOutHistory
	Add InLongitude VarChar(20)
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='PunchInOutHistory' And Column_Name='InBatteryStatus')
Begin
	Alter Table PunchInOutHistory
	Add InBatteryStatus VarChar(20)
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='PunchInOutHistory' And Column_Name='InCurrentAddress')
Begin
	Alter Table PunchInOutHistory
	Add InCurrentAddress VarChar(200)
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='PunchInOutHistory' And Column_Name='OutLatitude')
Begin
	Alter Table PunchInOutHistory
	Add OutLatitude VarChar(20)
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='PunchInOutHistory' And Column_Name='OutLongitude')
Begin
	Alter Table PunchInOutHistory
	Add OutLongitude VarChar(20)
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='PunchInOutHistory' And Column_Name='OutBatteryStatus')
Begin
	Alter Table PunchInOutHistory
	Add OutBatteryStatus VarChar(20)
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='PunchInOutHistory' And Column_Name='OutCurrentAddress')
Begin
	Alter Table PunchInOutHistory
	Add OutCurrentAddress VarChar(200)
End

GO

-- SavePunchInOut @UserId=1
Alter Procedure SavePunchInOut
	@UserId			BigInt,
	@Latitude		VarChar(20),
	@Longitude		VarChar(20),
	@BatteryStatus	VarChar(20),
	@CurrentAddress	VarChar(200)
As
Begin
	Set NoCount On;

	Declare @PunchId	BigInt = 0;
	Declare @PunchInOn	DateTime = NULL;
	Declare @PunchOutOn	DateTime = NULL;
	Declare @Message	VarChar(1000) = '';

	-- To get latest Punch History record of the User
	Select
		@PunchId = IsNull(Max(PunchId),0)
	From PunchInOutHistory With(NoLock)
	Where UserId = @UserId And (PunchInOn Is Null Or PunchOutOn Is Null)

	-- To get Punch In and Punch Out Datetime based on latest Punch Id of User
	Select
		@PunchInOn = PunchInOn,
		@PunchOutOn = PunchOutOn
	From PunchInOutHistory With(NoLock)
	Where PunchId = @PunchId

	-- To insert new Punch history record if not Punched-in
	If @PunchId = 0 Or @PunchInOn Is Null
	Begin
		Insert Into PunchInOutHistory
		(
			UserId,PunchInOn,InLatitude,InLongitude,InBatteryStatus,InCurrentAddress
		)
		Values
		(
			@UserId, GetDate(), @Latitude,@Longitude,@BatteryStatus,@CurrentAddress
		)

		Set @PunchId = SCOPE_IDENTITY();
	End
	-- To update existing Punch History record if already Punched-in (To do Punchout)
	Else If @PunchId > 0 And @PunchInOn Is Not Null And @PunchOutOn Is Null
	Begin
		Update PunchInOutHistory
		Set PunchOutOn		= GetDate()
			,ActiveTimeInMin = DateDiff(minute, PunchInOn, GetDate())
			,OutLatitude=@Latitude
			,OutLongitude=@Longitude
			,OutBatteryStatus=@BatteryStatus
			,OutCurrentAddress=@CurrentAddress
			,ModifiedBy		= @UserId
			,ModifiedOn		= GetDate()
		Where PunchId = @PunchId
			And UserId = @UserId
	End

	Select
		PunchId			
		,UserId			
		,PunchInOn		
		,PunchOutOn		
		,ActiveTimeInMin
		,InLatitude
		,InLongitude
		,InBatteryStatus
		,InCurrentAddress
		,OutLatitude
		,OutLongitude
		,OutBatteryStatus
		,OutCurrentAddress
		,Remark
		,ModifiedBy		
		,ModifiedOn		
	From PunchInOutHistory
	Where PunchId = @PunchId
End

GO

-- GetPunchHistoryRecords @UserId=1
Create Or Alter Procedure GetPunchHistoryRecords
	@UserId BigInt,
	@FromPunchInTime DateTime = NULL,
	@ToPunchInTime DateTime = null
As
Begin
	Set NoCount On;

	Select
		PH.PunchId			
		,PH.UserId
		,EM.EmployeeId
		,EM.EmployeeName
		,PH.PunchInOn		
		,PH.PunchOutOn		
		,PH.ActiveTimeInMin
		,PH.InLatitude
		,PH.InLongitude
		,PH.InBatteryStatus
		,PH.InCurrentAddress
		,PH.OutLatitude
		,PH.OutLongitude
		,PH.OutBatteryStatus
		,PH.OutCurrentAddress
		,PH.Remark
		,PH.ModifiedBy		
		,PH.ModifiedOn
	From PunchInOutHistory PH With(NoLock)
	Inner Join Users U With(NoLock)
		On U.UserId = PH.UserId
	Inner Join EmployeeMaster EM With(NoLock)
		On EM.EmployeeId = U.EmployeeId
	Where PH.UserId = @UserId
		And (@FromPunchInTime Is Null Or Cast(PH.PunchInOn As Date) >= @FromPunchInTime)
		And (@ToPunchInTime Is Null Or Cast(PH.PunchInOn As Date) <= @ToPunchInTime)
	Order By PH.PunchInOn Desc, PunchOutOn
End

GO
