-- GetProfileDetailsByToken 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJJZCI6IlFyaTMzNzZFRnBqeEpkQkJhdUdaTGc9PSIsIkVtYWlsSWQiOiJhZG1pbkB0ZXN0LmNvbSIsIk1vYmlsZU5vIjoiMTExMTExMTExMSIsIkVtcGxveWVlQ29kZSI6IkVNUDAwMSIsIk5hbWUiOiJBZG1pbiBFbXBsb3llZSIsIlJvbGVOYW1lIjoiQWRtaW5pc3RyYXRvciIsIm5iZiI6MTY4OTQzMTYyOCwiZXhwIjoxNjg5NDMyNTI4LCJpYXQiOjE2ODk0MzE2Mjh9.t2ZqlTLYilg9TGIaUkvJkwoUgWVfTnYAST64R0uAbc8'
Alter Procedure GetProfileDetailsByToken
	@Token VarChar(500)
As
Begin
	Set NoCount On;

	Update UsersLoginHistory
	Set LastAccessOn	= GetDate(),
		TokenExpireOn	= (Case When RememberMe = 1 Then DateAdd(day, 1, GetDate()) Else DateAdd(mi, 60, GetDate()) End)
	Where UserToken = @Token;

	Select
		U.UserId,
		U.EmailId,
		U.MobileNo,
		U.EmployeeId,
		U.IsActive,
		EM.EmployeeName,
		EM.EmployeeCode,
		EM.RoleId,
		RM.RoleName
		--,CD.CompanyName,
		--CD.CustomerTypeId,
		--CTM.CustomerTypeName
	From UsersLoginHistory LH With(NoLock)
	Inner Join Users U With(NoLock)
		On U.UserId = LH.UserId
	Left Join EmployeeMaster EM With(NoLock)
		On EM.EmployeeId = U.EmployeeId
	--Left Join CustomerDetails CD With(NoLock)
	--	On CD.CustomerId = U.CustomerId
	Left Join RoleMaster RM With(NoLock)
		On RM.RoleId = EM.RoleId
	--Left Join CustomerTypeMaster CTM With(NoLock)
	--	On CTM.CustomerTypeId = CD.CustomerTypeId
	Where LH.UserToken = @Token And IsLoggedIn = 1 And LoggedOutOn Is Null
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Column_Name='CustomerId' And Table_Name='Users')
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
	    KCU.TABLE_NAME = 'Users' AND
	    KCU.COLUMN_NAME = 'CustomerId'
		
	IF @ConstraintName IS NOT NULL
		EXEC('Alter Table Users drop  CONSTRAINT ' + @ConstraintName)

	Alter Table Users
	Drop Column CustomerId
End

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Column_Name='TermsConditionsAccepted' And Table_Name='Users')
Begin
	Alter Table Users
	Drop Column TermsConditionsAccepted
End

GO

-- ValidateUserLoginByEmail @Email = 'admin@test.com', @Password='test'
-- ValidateUserLoginByEmail @Email = 'testcustomer@test.com', @Password='test'
CREATE Or Alter Procedure ValidateUserLoginByEmail
	@Email VarChar(100),
	@Password VarChar(200)
As
Begin
	SET NOCOUNT ON;

	Select
		U.UserId,
		U.EmailId,
		U.MobileNo,
		U.EmployeeId,
		U.IsActive,
		EM.EmployeeName,
		EM.EmployeeCode,
		EM.RoleId,
		RM.RoleName
	From Users U With(NoLock)
	Left Join EmployeeMaster EM With(NoLock)
		On EM.EmployeeId = U.EmployeeId
	Left Join RoleMaster RM With(NoLock)
		On RM.RoleId = EM.RoleId
	Where U.EmailId = @Email
		And U.Passwords = @Password COLLATE Latin1_General_BIN
End

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

			----Commented below as User of Customers will not be created
			--INSERT INTO Users(EmailId,MobileNo,Passwords,CustomerId,IsActive,CreatedBy,CreatedOn)
			--SELECT @EmailId,@MobileNumber,@Password,@Result,@IsActive,@LoggedInUserId,GETDATE()
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

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetCustomers]
Description : Get Customer Detail from CustomerDetails
EXEC [dbo].[GetCustomers]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@CustomerTypeId = 0,
	@CompanyName='',
	@IsActive=null
*/

ALTER PROCEDURE [dbo].[GetCustomers]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@CustomerTypeId bigint = 0,
	@CompanyName VARCHAR(100)=null,
	@IsActive BIT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @STR NVARCHAR(MAX);
	DECLARE @Offset INT, @RowCount INT;
	DECLARE @OrderSortByConcate VARCHAR(100);
	DECLARE @OrderByQuery VARCHAR(1000)='';
	DECLARE @PaginationQuery VARCHAR(100)='';

	IF @PageSize > 0
	BEGIN
		SET @Offset = (@PageNo - 1) * @PageSize;
		SET @RowCount = @PageSize * @PageNo;
		SET @PaginationQuery='OFFSET '+CAST(@Offset as VARCHAR(5))+'  ROWS
								 FETCH NEXT '+CAST(@RowCount as VARCHAR(5))+' ROWS ONLY';
	END
	
	SET @OrderSortByConcate= @SortBy + ' ' + @OrderBy;
	SET @CompanyName = ISNULL(@CompanyName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by CustomerId DESC ';
		END


	SET @STR = N'SELECT
					CD.CustomerId,CD.CompanyName,CD.LandlineNo,CD.MobileNo as MobileNumber,CD.EmailId,
					CD.CustomerTypeId,CTM.CustomerTypeName as CustomerTypeName,CD.SpecialRemarks,
					CD.EmployeeId,EM.EmployeeName as EmployeeName,CD.IsActive,
					CreatorEM.EmployeeName As CreatorName,
					CD.CreatedBy,
					CD.CreatedOn
				FROM CustomerDetails CD WITH(NOLOCK)
				Inner Join Users U With(NoLock)
					On U.UserId = CD.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId And U.EmployeeId Is Not Null
				LEFT JOIN CustomerTypeMaster CTM  WITH(NOLOCK)
					ON CTM.CustomerTypeId = CD.CustomerTypeId
				LEFT JOIN EmployeeMaster EM WITH(NOLOCK)
					ON EM.EmployeeId = CD.EmployeeId
				WHERE (@CustomerTypeId = 0 OR CD.CustomerTypeId = @CustomerTypeId)
					and (@CompanyName='''' OR CD.CompanyName like ''%''+@CompanyName+''%'')
					and (@IsActive IS NULL OR CD.IsActive=@IsActive)
			' + @OrderByQuery+' '+@PaginationQuery+'	'

	------PRINT @STR;
	exec sp_executesql @STR,
						N'@CompanyName VARCHAR(100), @IsActive BIT, @CustomerTypeId bigint',
						@CompanyName, @IsActive, @CustomerTypeId
END

GO

ALTER PROCEDURE [dbo].[GetCustomerDetailsById]
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		CD.CustomerId,CD.CompanyName,CD.LandlineNo,CD.MobileNo as MobileNumber,CD.EmailId,
		CD.CustomerTypeId,CTM.CustomerTypeName as CustomerTypeName,CD.SpecialRemarks,CD.EmployeeId,
		EM.EmployeeName as EmployeeName,
		CreatorEM.EmployeeName As CreatorName,
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
	WHERE CD.CustomerId = @Id
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[SaveCustomerDetails] 
Description : Insert Customer Detail from CustomerDetails

EXEC SaveCustomerDetails 0,'Test Company Ltd.','123456789','1020304050','vishu@gmail.com',1,'test',1,1,
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
			SELECT ContactName,MobileNo,EmailId,Case When RefPartyId = 0 Then NULL Else RefPartyId End,IsActive,@LoggedInUserId,GETDATE() FROM @tempContactDetail

			INSERT into CustomerContactMapping(CustomerId,ContactId)
			Select @Result,ContId from @tempContact

			------ Commented as User of Customer not required to create
			--INSERT INTO Users(EmailId,MobileNo,Passwords,CustomerId,IsActive,TermsConditionsAccepted,CreatedBy,CreatedOn)
			--SELECT @EmailId,@MobileNumber,@Password,@Result,@IsActive,1,@LoggedInUserId,GETDATE()
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
				EmailId=tempd.EmailId,
				RefPartyId=Case When tempd.RefPartyId = 0 Then Null Else tempd.RefPartyId End,
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

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetReportingTos]
Description : Get ReportingTo from ReportingToMaster
EXEC [dbo].[GetReportingTos]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@ReportingTo=0,
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetReportingTos]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@ReportingTo VARCHAR(100)=null,
	@IsActive BIT
)
AS
BEGIN

 SET NOCOUNT ON;

	DECLARE @STR NVARCHAR(MAX)

	DECLARE @Offset INT, @RowCount INT;
	DECLARE @OrderSortByConcate VARCHAR(100);
	DECLARE @OrderByQuery VARCHAR(1000)='';
	DECLARE @PaginationQuery VARCHAR(100)='';

	if @PageSize>0
	BEGIN
		SET @Offset = (@PageNo - 1) * @PageSize;
		SET @RowCount = @PageSize * @PageNo;
		SET @PaginationQuery='OFFSET '+CAST(@Offset as VARCHAR(5))+'  ROWS
								 FETCH NEXT '+CAST(@RowCount as VARCHAR(5))+' ROWS ONLY';
	END
	
	SET @OrderSortByConcate= @SortBy + ' ' + @OrderBy;
	SET @ReportingTo = ISNULL(@ReportingTo,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by Id DESC ';
		END

	SET @STR = N'SELECT
					RTM.Id,RTM.RoleId,RM.RoleName,RTM.ReportingTo,RTM.IsActive,
					CreatorEM.EmployeeName As CreatorName,
					RTM.CreatedBy,
					RTM.CreatedOn,
					ReportTo.RoleName as ReportingToName
				FROM ReportingToMaster RTM WITH(NOLOCK)
				Inner Join Users U With(NoLock)
					On U.UserId = RTM.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId And U.EmployeeId Is Not Null
				LEFT JOIN RoleMaster RM WITH(NOLOCK)
					ON RM.RoleId=RTM.RoleId
				LEFT JOIN RoleMaster ReportTo WITH(NOLOCK)
					ON RTM.ReportingTo=ReportTo.RoleId
				WHERE (@ReportingTo=0 OR RTM.ReportingTo =@ReportingTo)
					and (@IsActive IS NULL OR RTM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	-- PRINT @STR;

	exec sp_executesql @STR,
						N'@ReportingTo VARCHAR(100),@IsActive BIT',
						@ReportingTo,@IsActive
END

GO

/*
	Exec GetCollectionsList
		@PageNo			= 1,
		@PageSize		= 10,
		@SortBy			= 'CollectionId',
		@OrderBy		= '',
		@CollectionName	= '',
		@IsActive		= 1
*/
ALTER   Procedure [dbo].[GetCollectionsList]
	@PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@CollectionName VARCHAR(100) = '',
	@IsActive BIT = null
As
Begin
	Set NoCount On;

	DECLARE @stringQuery	NVARCHAR(MAX);
	DECLARE @Offset		INT, 
			@RowCount	INT;

	DECLARE @OrderByQuery VARCHAR(1000) = '';
	DECLARE @PaginationQuery VARCHAR(100) = '';

	If @PageNo > 0 And @PageSize > 0
	Begin
		SET @Offset = (@PageNo - 1) * @PageSize;
		SET @RowCount = @PageSize * @PageNo;
		SET @PaginationQuery='OFFSET '+CAST(@Offset as VARCHAR(5))+'  ROWS
								 FETCH NEXT '+CAST(@RowCount as VARCHAR(5))+' ROWS ONLY';
	End

	If @SortBy <> '' And @OrderBy <> ''
	Begin
		Set @OrderByQuery=' Order By '+@SortBy+' '+@OrderBy+' ';
	End
	Else 
	Begin
		Set @OrderByQuery=' Order By CollectionId DESC ';
	End
	
	SET @stringQuery = N'Select
					CM.CollectionId,
					CM.CollectionName,
					CM.IsActive,
					CreatorEM.EmployeeName As CreatorName,
					CM.CreatedBy,
					CM.CreatedOn
				From CollectionMaster CM With(NoLock)
				Inner Join Users U With(NoLock)
					On U.UserId = CM.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId
						And U.EmployeeId Is Not Null
				WHERE (@CollectionName='''' OR CM.CollectionName Like ''%''+@CollectionName+''%'')
					And (@IsActive IS NULL OR CM.IsActive = @IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	Exec sp_executesql @stringQuery,
			N'@CollectionName VARCHAR(100), @IsActive BIT',
			@CollectionName, @IsActive
End

GO

/*
	Version : 1.0
	Created Date : 03 JULY 2023
	Execution : EXEC [dbo].[GetStates]
	Description : Get State from StateMaster
	EXEC [dbo].[GetStates]  
		@PageSize=10,
		@PageNo=1,
		@SortBy='',
		@OrderBy='',
		@StateName='',
		@IsActive=NULL
*/

Alter Procedure GetStates
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@StateName VARCHAR(100)=null,
	@IsActive BIT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @STR NVARCHAR(MAX);
	DECLARE @Offset INT, @RowCount INT;
	DECLARE @OrderSortByConcate VARCHAR(100);
	DECLARE @OrderByQuery VARCHAR(1000)='';
	DECLARE @PaginationQuery VARCHAR(100)='';

	If @PageSize > 0
	BEGIN
		SET @Offset = (@PageNo - 1) * @PageSize;
		SET @RowCount = @PageSize * @PageNo;
		SET @PaginationQuery='OFFSET '+CAST(@Offset as VARCHAR(5))+'  ROWS
								 FETCH NEXT '+CAST(@RowCount as VARCHAR(5))+' ROWS ONLY';
	END
	
	SET @OrderSortByConcate= @SortBy + ' ' + @OrderBy;
	SET @StateName = ISNULL(@StateName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by StateId DESC ';
		END

	SET @STR = N'Select
					SM.StateId, SM.StateName, SM.IsActive,
					CreatorEM.EmployeeName As CreatorName,
					SM.CreatedBy,
					SM.CreatedOn
				From StateMaster SM WITH(NOLOCK)
				Inner Join Users U With(NoLock)
					On U.UserId = SM.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId And U.EmployeeId Is Not Null
				Where (@StateName='''' OR SM.StateName like ''%''+@StateName+''%'')
					And (@IsActive IS NULL OR SM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	-- PRINT @STR;

	Exec sp_executesql @STR,
						N'@StateName VARCHAR(100),@IsActive BIT',
						@StateName,@IsActive
END

GO

/*
	Version : 1.0
	Created Date : 03 JULY 2023
	Execution : EXEC [dbo].[GetRegions]
	Description : Get Region from RegionMaster
	EXEC [dbo].[GetRegions]  
		@PageSize=10,
		@PageNo=1,
		@SortBy='',
		@OrderBy='',
		@RegionName='',
		@IsActive=NULL
*/
Alter Procedure GetRegions
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@RegionName VARCHAR(100)=null,
	@IsActive BIT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @STR NVARCHAR(MAX);
	DECLARE @Offset INT, @RowCount INT;
	DECLARE @OrderSortByConcate VARCHAR(100);
	DECLARE @OrderByQuery VARCHAR(1000)='';
	DECLARE @PaginationQuery VARCHAR(100)='';

	IF @PageSize>0
	BEGIN
		SET @Offset = (@PageNo - 1) * @PageSize;
		SET @RowCount = @PageSize * @PageNo;
		SET @PaginationQuery='OFFSET '+CAST(@Offset as VARCHAR(5))+'  ROWS
								 FETCH NEXT '+CAST(@RowCount as VARCHAR(5))+' ROWS ONLY';
	END
	
	SET @OrderSortByConcate= @SortBy + ' ' + @OrderBy;
	SET @RegionName = ISNULL(@RegionName,'');

	IF @SortBy <> ''
	BEGIN
		SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
	END
	ELSE
	BEGIN
		SET @OrderByQuery='ORDER by RegionId DESC ';
	END
	
	SET @STR = N'SELECT
					R.RegionId, R.StateId, M.StateName, R.RegionName, R.IsActive,
					CreatorEM.EmployeeName As CreatorName,
					R.CreatedBy,
					R.CreatedOn
				From RegionMaster R WITH(NOLOCK)
				Inner Join StateMaster M WITH(NOLOCK)
					ON M.StateId=R.StateId
				Inner Join Users U With(NoLock)
					On U.UserId = R.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId And U.EmployeeId Is Not Null
				Where (@RegionName='''' OR R.RegionName like ''%''+@RegionName+''%'')
					and (@IsActive IS NULL OR R.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	-- PRINT @STR;

	exec sp_executesql @STR,
						N'@RegionName VARCHAR(100),@IsActive BIT',
						@RegionName,@IsActive
END

GO

/*
	Version : 1.0
	Created Date : 03 JULY 2023
	Execution : EXEC [dbo].[GetDistricts]
	Description : Get District from DistrictMaster
	Exec [dbo].[GetDistricts]  
		@PageSize=10,
	    @PageNo=1,
	    @SortBy='',
	    @OrderBy='',
		@DistrictName='',
		@IsActive=NULL
*/
Alter Procedure GetDistricts
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@DistrictName VARCHAR(100)=null,
	@IsActive BIT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @STR NVARCHAR(MAX)='';

	DECLARE @Offset INT, @RowCount INT;
	DECLARE @OrderSortByConcate VARCHAR(100);
	DECLARE @OrderByQuery VARCHAR(1000)='';
	DECLARE @PaginationQuery VARCHAR(100)='';

	if @PageSize>0
	BEGIN
		SET @Offset = (@PageNo - 1) * @PageSize;
		SET @RowCount = @PageSize * @PageNo;
		SET @PaginationQuery='OFFSET '+CAST(@Offset as VARCHAR(5))+'  ROWS
								 FETCH NEXT '+CAST(@RowCount as VARCHAR(5))+' ROWS ONLY';
	END
	
	SET @OrderSortByConcate= @SortBy + ' ' + @OrderBy;
	SET @DistrictName = ISNULL(@DistrictName,'');

	IF @SortBy <> ''
	BEGIN
		SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
	END
	ELSE
	BEGIN
		SET @OrderByQuery='ORDER by RegionId DESC ';
	END

	SET @STR = N'SELECT
					D.DistrictId,D.DistrictName,D.IsActive,
					D.RegionId,RM.RegionName,
					ST.StateId,ST.StateName,
					CreatorEM.EmployeeName As CreatorName,
					D.CreatedBy,
					D.CreatedOn
				FROM DistrictMaster D WITH(NOLOCK)
				INNER JOIN RegionMaster RM  WITH(NOLOCK)
					ON RM.RegionId=D.RegionId
				INNER JOIN StateMaster ST  WITH(NOLOCK)
					ON ST.StateId=RM.StateId
				Inner Join Users U With(NoLock)
					On U.UserId = D.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId And U.EmployeeId Is Not Null
				WHERE (@DistrictName='''' OR D.DistrictName like ''%''+@DistrictName+''%'')
					And (@IsActive IS NULL OR D.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	------PRINT @STR;

	exec sp_executesql @STR,
						N'@DistrictName VARCHAR(100),@IsActive BIT',
						@DistrictName,@IsActive
END

GO

/*
	Version : 1.0
	Created Date : 03 JULY 2023
	Execution : EXEC [dbo].[GetAreas]
	Description : Get Area from AreaMaster
	EXEC [dbo].[GetAreas]  
		@PageSize=10,
	    @PageNo=1,
	    @SortBy='',
	    @OrderBy='',
		@AreaName='',
		@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetAreas]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@AreaName VARCHAR(100)=null,
	@IsActive BIT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @STR NVARCHAR(MAX);
	DECLARE @Offset INT, @RowCount INT;
	DECLARE @OrderSortByConcate VARCHAR(100);
	DECLARE @OrderByQuery VARCHAR(1000)='';
	DECLARE @PaginationQuery VARCHAR(100)='';

	if @PageSize>0
	BEGIN
		SET @Offset = (@PageNo - 1) * @PageSize;
		SET @RowCount = @PageSize * @PageNo;
		SET @PaginationQuery='OFFSET '+CAST(@Offset as VARCHAR(5))+'  ROWS
								 FETCH NEXT '+CAST(@RowCount as VARCHAR(5))+' ROWS ONLY';
	END
	
	SET @OrderSortByConcate= @SortBy + ' ' + @OrderBy;
	SET @AreaName = ISNULL(@AreaName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by AreaId DESC ';
		END
		

	SET @STR = N'SELECT
					AM.AreaId,AM.AreaName,AM.IsActive,ST.StateId,ST.StateName, RM.RegionId,RM.RegionName, 
					AM.DistrictId,D.DistrictName,
					CreatorEM.EmployeeName As CreatorName,
					AM.CreatedBy,
					AM.CreatedOn
				FROM AreaMaster AM WITH(NOLOCK)
				INNER JOIN DistrictMaster D WITH(NOLOCK)
					ON D.DistrictId=AM.DistrictId
				INNER JOIN RegionMaster RM  WITH(NOLOCK)
					ON RM.RegionId = D.RegionId
				INNER JOIN StateMaster ST  WITH(NOLOCK)
					ON ST.StateId=RM.StateId
				Inner Join Users U With(NoLock)
					On U.UserId = AM.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId And U.EmployeeId Is Not Null
				WHERE (@AreaName='''' OR AM.AreaName like ''%''+@AreaName+''%'')
					and (@IsActive IS NULL OR AM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	--PRINT @STR;

	exec sp_executesql @STR,
						N'@AreaName VARCHAR(100),@IsActive BIT',
						@AreaName,@IsActive
END

GO

-- ValidateUserLoginByEmail @Email = 'admin@test.com', @Password='Y+ZeQ74DLebrzzB+ogmTLg=='
-- ValidateUserLoginByEmail @Email = 'admin@test.com', @Password='test'
Alter Procedure [dbo].[ValidateUserLoginByEmail]
	@Email VarChar(100),
	@Password VarChar(200)
As
Begin
	SET NOCOUNT ON;

	Select
		U.UserId,
		U.EmailId,
		U.MobileNo,
		U.EmployeeId,
		--U.CustomerId,
		U.IsActive,
		EM.EmployeeName,
		EM.EmployeeCode,
		EM.RoleId,
		RM.RoleName
		--,CD.CompanyName,
		--CD.CustomerTypeId,
		--CTM.CustomerTypeName
	From Users U With(NoLock)
	Left Join EmployeeMaster EM With(NoLock)
		On EM.EmployeeId = U.EmployeeId
	Left Join RoleMaster RM With(NoLock)
		On RM.RoleId = EM.RoleId
	--Left Join CustomerDetails CD With(NoLock)
	--	On CD.CustomerId = U.CustomerId
	--Left Join CustomerTypeMaster CTM With(NoLock)
		--On CTM.CustomerTypeId = CD.CustomerTypeId
	Where U.EmailId = @Email
		And U.Passwords = @Password COLLATE Latin1_General_BIN
End

GO

/*
	Version : 1.0
	Created Date : 03 JULY 2023
	Execution : EXEC [dbo].[GetCustomers]
	Description : Get Customer Detail from CustomerDetails
	EXEC [dbo].[GetCustomers]  
		@PageSize=10,
	    @PageNo=1,
	    @SortBy='',
	    @OrderBy='',
		@CustomerTypeId = 0,
		@CompanyName='',
		@IsActive=null
*/
Alter Procedure GetCustomers
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@CustomerTypeId bigint = 0,
	@CompanyName VARCHAR(100)=null,
	@IsActive BIT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @STR NVARCHAR(MAX);
	DECLARE @Offset INT, @RowCount INT;
	DECLARE @OrderSortByConcate VARCHAR(100);
	DECLARE @OrderByQuery VARCHAR(1000)='';
	DECLARE @PaginationQuery VARCHAR(100)='';

	IF @PageSize > 0
	BEGIN
		SET @Offset = (@PageNo - 1) * @PageSize;
		SET @RowCount = @PageSize * @PageNo;
		SET @PaginationQuery='OFFSET '+CAST(@Offset as VARCHAR(5))+'  ROWS
								 FETCH NEXT '+CAST(@RowCount as VARCHAR(5))+' ROWS ONLY';
	END
	
	SET @OrderSortByConcate= @SortBy + ' ' + @OrderBy;
	SET @CompanyName = ISNULL(@CompanyName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by CustomerId DESC ';
		END


	SET @STR = N'Select
					CD.CustomerId,CD.CompanyName,CD.LandlineNo,CD.MobileNo as MobileNumber,CD.EmailId,
					CD.CustomerTypeId,CTM.CustomerTypeName as CustomerTypeName,CD.SpecialRemarks,
					CD.EmployeeId,
					EM.EmployeeName as EmployeeName,
					RM.RoleName as EmployeeRole,
					Addr.[Address],
					SM.StateName,
					Region.RegionName,
					DM.DistrictName,
					AM.AreaName,
					CD.IsActive,
					CreatorEM.EmployeeName As CreatorName,
					CD.CreatedBy,
					CD.CreatedOn
				From CustomerDetails CD WITH(NOLOCK)
				Inner Join Users U With(NoLock)
					On U.UserId = CD.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId And U.EmployeeId Is Not Null
				Left Join CustomerTypeMaster CTM  WITH(NOLOCK)
					ON CTM.CustomerTypeId = CD.CustomerTypeId
				Left Join EmployeeMaster EM WITH(NOLOCK)
					ON EM.EmployeeId = CD.EmployeeId
				Left Join RoleMaster RM With(NoLock)
					On RM.RoleId = EM.RoleId
				Left Join CustomerAddressMapping CAM With(NoLock)
					On CAM.CustomerId = CD.CustomerId
				Left Join AddressMaster Addr With(NoLock)
					On Addr.AddressId = CAM.AddressId
				Left Join StateMaster SM With(NoLock)
					On SM.StateId = Addr.StateId
				Left Join RegionMaster Region With(NoLock)
					On Region.RegionId = Addr.RegionId
				Left Join DistrictMaster DM With(NoLock)
					On DM.DistrictId = Addr.DistrictId
				Left Join AreaMaster AM With(NoLock)
					On AM.AreaId = Addr.AreaId
				Where Addr.IsDefault = 1 And Addr.IsActive=1 And (@CustomerTypeId = 0 OR CD.CustomerTypeId = @CustomerTypeId)
					And (@CompanyName='''' OR CD.CompanyName like ''%''+@CompanyName+''%'')
					And (@IsActive IS NULL OR CD.IsActive=@IsActive)
			' + @OrderByQuery+' '+@PaginationQuery+'	'

	------PRINT @STR;
	exec sp_executesql @STR,
						N'@CompanyName VARCHAR(100), @IsActive BIT, @CustomerTypeId bigint',
						@CompanyName, @IsActive, @CustomerTypeId
END

GO

-- GetCustomerContactDetailsById 6
Alter Procedure GetCustomerContactDetailsById
	@CustomerId BIGINT
AS
BEGIN
	Set NoCount On;

	Select
		CD.ContactId, CD.ContactName, CD.MobileNo, CD.EmailId,
		CD.RefPartyId, RM.PartyName, RM.PhoneNumber as RefPhoneNumber, RM.MobileNumber as RefMobileNumber,
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
	Left Join ReferenceMaster RM WIth(NoLock)
		On RM.ReferenceId = CD.RefPartyId
	WHERE CCM.CustomerId = @CustomerId
END

GO
