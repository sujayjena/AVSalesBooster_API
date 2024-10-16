Alter Procedure [dbo].[SaveUserLoginHistory]
	@UserId			BigInt,
	@UserToken		VarChar(2000),
	@TokenExpireOn	DateTime,
	@DeviceName		VarChar(500),
	@IPAddress		VarChar(30),
	@RememberMe		Bit,
	@IsLoggedIn		Bit
As
Begin
	SET NOCOUNT ON;

	-- To auto logout user sessions whose expiry date exceeded current date
	Update UsersLoginHistory
	Set IsLoggedIn = 0,
		LoggedOutOn = GETDATE(),
		IsAutoLogout = 1
	Where UserId = @UserId
		And IPAddress = @IPAddress
		And DeviceName = @DeviceName
		And IsLoggedIn = 1
		And LoggedOutOn Is Null
		And GETDATE() > TokenExpireOn

	-- Login
	If @IsLoggedIn = 1
	Begin
		If Not Exists
		(
			Select Top 1 1 From UsersLoginHistory With(NoLock)
			Where UserId = @UserId
				And UserToken = @UserToken
				And IPAddress = @IPAddress
				And DeviceName = @DeviceName
				And IsLoggedIn = 1
				And LoggedOutOn Is Null
		)
		Begin
			Insert Into UsersLoginHistory
			(
				UserId, LoggedInOn, IsLoggedIn, UserToken, LastAccessOn, TokenExpireOn, DeviceName, IPAddress, RememberMe
			)
			Values
			(
				@UserId, GETDATE(), @IsLoggedIn, @UserToken, GETDATE(), @TokenExpireOn, @DeviceName, @IPAddress, @RememberMe
			)
		End
		Else
		Begin
			Update UsersLoginHistory
			Set LastAccessOn = GETDATE(),
				TokenExpireOn = @TokenExpireOn
			Where UserId = @UserId
				And UserToken = @UserToken
				And IPAddress = @IPAddress
				And DeviceName = @DeviceName
		End
	End
	-- Logout
	Else
	Begin
		Update UsersLoginHistory
		Set LastAccessOn = GETDATE(),
			IsLoggedIn = 0,
			LoggedOutOn = GETDATE(),
			IsAutoLogout = 0
		Where UserId = @UserId
			And UserToken = @UserToken
			And IPAddress = @IPAddress
			And DeviceName = @DeviceName
	End
End

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetCustomerTypes]
Description : Get CustomerType from CustomTypeMaster
EXEC [dbo].[GetCustomerTypes]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@CustomerTypeName='',
	@IsActive=NULL
*/
Alter Procedure [dbo].[GetCustomerTypes]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@CustomerTypeName VARCHAR(100)=null,
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
	SET @CustomerTypeName = ISNULL(@CustomerTypeName,'');

	IF @SortBy <> ''
	BEGIN
		SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
	END
	ELSE 
	BEGIN
		SET @OrderByQuery='ORDER by CustomerTypeId DESC ';
	END

	SET @STR = N'SELECT
					CTM.CustomerTypeId, CTM.CustomerTypeName, CTM.IsActive,
					CreatorEM.EmployeeName As CreatorName,
					CTM.CreatedBy,
					CTM.CreatedOn
				FROM CustomerTypeMaster CTM WITH(NOLOCK)
				Inner Join Users U With(NoLock)
					On U.UserId = CTM.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId
						And U.EmployeeId Is Not Null
				WHERE (@CustomerTypeName='''' OR CTM.CustomerTypeName like ''%''+@CustomerTypeName+''%'')
					and (@IsActive IS NULL OR CTM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	--PRINT @STR;

	exec sp_executesql @STR,
						N'@CustomerTypeName VARCHAR(100),@IsActive BIT',
						@CustomerTypeName,@IsActive
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetLeaveTypes]
Description : Get LeaveType from LeaveTypeMaster
EXEC [dbo].[GetLeaveTypes]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@LeaveTypeName='',
	@IsActive=NULL
*/
Alter Procedure [dbo].[GetLeaveTypes]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@LeaveTypeName VARCHAR(100)=null,
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
	SET @LeaveTypeName = ISNULL(@LeaveTypeName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by LeaveTypeId DESC ';
		END


	SET @STR = N'SELECT
					LTM.LeaveTypeId, LTM.LeaveTypeName, LTM.IsActive,
					CreatorEM.EmployeeName As CreatorName,
					LTM.CreatedBy,
					LTM.CreatedOn
				FROM LeaveTypeMaster LTM WITH(NOLOCK)
				Inner Join Users U With(NoLock)
					On U.UserId = LTM.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId
						And U.EmployeeId Is Not Null
				WHERE (@LeaveTypeName='''' OR LTM.LeaveTypeName like ''%''+@LeaveTypeName+''%'')
					and (@IsActive IS NULL OR LTM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	--PRINT @STR;

	exec sp_executesql @STR,
						N'@LeaveTypeName VARCHAR(100),@IsActive BIT',
						@LeaveTypeName,@IsActive
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetRoles]
Description : Get Role from RoleMaster
EXEC [dbo].[GetRoles]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@RoleName='',
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetRoles]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@RoleName VARCHAR(100)=null,
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
	SET @RoleName = ISNULL(@RoleName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by RoleId DESC ';
		END


	SET @STR = N'SELECT
					RM.RoleId, RM.RoleName, RM.IsActive,
					CreatorEM.EmployeeName As CreatorName,
					RM.CreatedBy,
					RM.CreatedOn
				FROM RoleMaster RM WITH(NOLOCK)
				Inner Join Users U With(NoLock)
					On U.UserId = RM.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId
						And U.EmployeeId Is Not Null
				WHERE (@RoleName='''' OR RM.RoleName like ''%''+@RoleName+''%'')
					and (@IsActive IS NULL OR RM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	--PRINT @STR;

	exec sp_executesql @STR,
						N'@RoleName VARCHAR(100),@IsActive BIT',
						@RoleName,@IsActive
END

GO

/*
	EXEC [dbo].[GetReferences]  @PageSize=10,
		@PageNo=1,
		@SortBy='',
		@OrderBy='',
		@ReferenceParty='',
		@IsActive=null
*/
ALTER PROCEDURE [dbo].[GetReferences]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@ReferenceParty VARCHAR(100)=null,
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
	SET @ReferenceParty = ISNULL(@ReferenceParty,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by ReferenceId DESC ';
		END


SET @STR = N'SELECT
				RM.ReferenceId,RM.UniqueNumber,RM.PartyName as ReferenceParty ,
				AD.Address,AD.StateId,AD.RegionId,AD.DistrictId,AD.AreaId,AD.Pincode,RM.PhoneNumber,RM.MobileNumber,
				SM.StateName,RGM.RegionName,DM.DistrictName,ARM.AreaName,
				RM.GSTNumber,RM.PanNumber,RM.EmailId,RM.IsActive,
					CreatorEM.EmployeeName As CreatorName,
					RM.CreatedBy,
					RM.CreatedOn
			FROM ReferenceMaster RM WITH(NOLOCK)
			INNER JOIN ReferenceAddressMapping RAM WITH(NOLOCK) ON RAM.ReferenceId = RM.ReferenceId
			INNER JOIN AddressMaster AD WITH(NOLOCK) ON Ad.AddressId=RAM.AddressId
			INNER JOIN StateMaster SM WITH(NOLOCK) ON SM.StateId=AD.StateId
			INNER JOIN RegionMaster RGM WITH(NOLOCK) ON RGM.RegionId=AD.RegionId
			INNER JOIN DistrictMaster DM WITH(NOLOCK) ON DM.DistrictId=AD.DistrictId
			INNER JOIN AreaMaster ARM WITH(NOLOCK) ON ARM.AreaId=AD.AreaId
			Inner Join Users U With(NoLock)
					On U.UserId = RM.CreatedBy
			Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId
						And U.EmployeeId Is Not Null
			WHERE (@ReferenceParty='''' OR RM.PartyName like ''%''+@ReferenceParty+''%'')
				and (@IsActive IS NULL OR RM.IsActive=@IsActive)
    '+@OrderByQuery+' '+@PaginationQuery+'	'

	--PRINT @STR;

	exec sp_executesql @STR,
						N'@ReferenceParty VARCHAR(100),@IsActive BIT',
						@ReferenceParty,@IsActive
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
		CD.IsActive,
		Case 
			When CreatorEM.EmployeeName Is Not Null 
				Then CreatorEM.EmployeeName
			Else CreatorCD.CompanyName
		End As CreatorName,
		CD.CreatedBy,
		CD.CreatedOn
	FROM CustomerDetails CD WITH(NOLOCK)
	Inner Join Users U With(NoLock)
		On U.UserId = CD.CreatedBy
	Left Join EmployeeMaster CreatorEM With(NoLock)
		On CreatorEM.EmployeeId = U.EmployeeId
			And U.EmployeeId Is Not Null
	Left Join CustomerDetails CreatorCD With(NoLock)
		On CreatorCD.CustomerId = U.CustomerId
			And U.CustomerId Is Not Null
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

	INSERT INTO @tempContactDetail
	(
		ContactId,ContactName,MobileNo,EmailId,RefPartyId,IsActive
	)
	SELECT
		ContactId = T.Item.value('ContactId[1]', 'BIGINT'),
		ContactName = T.Item.value('ContactName[1]', 'varchar(50)'),
		MobileNo = T.Item.value('MobileNo[1]', 'varchar(15)'),
		EmailId =  T.Item.value('EmailId[1]', 'varchar(100)'),
		RefPartyId = T.Item.value('RefPartyId[1]', 'BIGINT'),
		IsActive = T.Item.value('IsActive[1]', 'BIT')
		FROM
	@XmlContactData.nodes('/ArrayOfContactDetail/ContactDetail') AS T(Item)

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

			INSERT INTO Users(EmailId,MobileNo,Passwords,CustomerId,IsActive,TermsConditionsAccepted,CreatedBy,CreatedOn)
			SELECT @EmailId,@MobileNumber,@Password,@Result,@IsActive,1,@LoggedInUserId,GETDATE()
		
		END
		ELSE IF(@CustomerId> 0 and EXISTS(SELECT TOP 1 1 FROM CustomerDetails WHERE CustomerId=@CustomerId))
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

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='StatusMaster' And Column_Name='StatusCode')
Begin
	Alter Table StatusMaster
	Add StatusCode VarChar(2)
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='StatusMaster' And Column_Name='Notes')
Begin
	Alter Table StatusMaster
	Add Notes VarChar(20)
End

GO

Update StatusMaster Set StatusCode='C', Notes='Common Status'

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name='StatusMaster' And Column_Name='StatusCode')
Begin
	Alter Table StatusMaster
	Alter Column StatusCode VarChar(2) Not Null
End

GO

If Not Exists(Select * From StatusMaster Where StatusCode='L')
Begin
	Insert Into StatusMaster(StatusId,StatusName,StatusCode,Notes)
	Values(4,'Pending', 'L', 'For Leave Status'),(5,'Approved', 'L', 'For Leave Status'),(6,'Rejected', 'L', 'For Leave Status')
End

GO

-- GetStatusMasterList 'C'
ALTER Procedure [dbo].[GetStatusMasterList]
	@StatusCode VarChar(2)
As
Begin
	SET NOCOUNT ON;

	Select 
		StatusId As [Value],
		StatusName As [Text]
	From StatusMaster
	Where StatusCode = @StatusCode
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Column_Name='StatusId' And Table_Name='LeaveMaster')
Begin
	Alter Table LeaveMaster
	Add StatusId Int References StatusMaster(StatusId)
End

GO

Update LeaveMaster Set StatusId=4

GO

If Exists(Select Top 1 1 From Information_Schema.Columns Where Column_Name='StatusId' And Table_Name='LeaveMaster')
Begin
	Alter Table LeaveMaster
	Alter Column StatusId Int Not Null
End

GO

/*
	Version : 1.0
	Created Date : 03 JULY 2023
	Execution : EXEC [dbo].[GetLeaves]
	Description : Get Leave from LeaveMaster
	EXEC [dbo].[GetLeaves]  
		@PageSize=10,
	    @PageNo=1,
	    @SortBy='',
	    @OrderBy='',
		@EmployeeName='',
		@LeaveTypeId = 0,
		@LeaveStatusId = 0,
		@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetLeaves]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@EmployeeName VARCHAR(100)=null,
	@LeaveTypeId BigInt = 0,
	@LeaveStatusId Int = 0,
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
	SET @EmployeeName = ISNULL(@EmployeeName,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by LeaveId DESC ';
		END
	
	SET @STR = N'SELECT
					LM.LeaveId,LM.StartDate,LM.EndDate,LM.EmployeeName,LM.LeaveTypeId,
					LTM.LeaveTypeName,Remark,Reason,LM.IsActive,LM.StatusId,SM.StatusName,
					CreatorEM.EmployeeName As CreatorName,
					LM.CreatedBy,
					LM.CreatedOn
				FROM LeaveMaster LM WITH(NOLOCK)
				Inner Join StatusMaster SM With(NoLock)
					On SM.StatusId = LM.StatusId
				Inner Join Users U With(NoLock)
					On U.UserId = LM.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId
						And U.EmployeeId Is Not Null
				LEFT JOIN LeaveTypeMaster LTM WITH(NOLOCK)
					ON LTM.LeaveTypeId=LM.LeaveTypeId
				WHERE (@EmployeeName='''' OR LM.EmployeeName like ''%''+@EmployeeName+''%'')
					And (@IsActive IS NULL OR LM.IsActive=@IsActive)
					And (@LeaveTypeId = 0 OR LM.LeaveTypeId = @LeaveTypeId)
					And (@LeaveStatusId = 0 OR LM.StatusId = @LeaveStatusId)
			'+@OrderByQuery+' '+@PaginationQuery+'	'
			
	--PRINT @STR;

	exec sp_executesql @STR,
						N'@EmployeeName VARCHAR(100),@IsActive BIT,@LeaveTypeId BigInt,@LeaveStatusId Int',
						@EmployeeName,@IsActive,@LeaveTypeId,@LeaveStatusId
END

GO

/*
	Version : 1.0
	Created Date : 03 JULY 2023
	Execution : EXEC [dbo].[SaveLeaveDetails] '0','Leave 1',1
	Description : Insert Leave from LeaveMaster
*/
ALTER PROCEDURE [dbo].[SaveLeaveDetails]
(
	@LeaveId BIGINT,
	@StartDate DATETIME,
	@EndDate DATETIME,
	@EmployeeName VARCHAR(100),
	@LeaveTypeId BIGINT,
	@Remark VARCHAR(100),
	@IsActive BIT,
	@LoggedInUserId BIGINT,
	@StatusId Int = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result BIGINT=0;
	DECLARE @IsNameExists BIGINT=-2;
	DECLARE @NoRecordExists BIGINT=-1;

	If (
		(@LeaveId=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM LeaveMaster WITH(NOLOCK) 
				WHERE StartDate=@StartDate and EndDate=@EndDate 
			)
		)
		OR
		(@LeaveId>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM LeaveMaster WITH(NOLOCK) 
				WHERE StartDate=@StartDate and EndDate=@EndDate and LeaveId<>@LeaveId
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@LeaveId=0)
		BEGIN
			Insert into LeaveMaster
			(
				StartDate,EndDate,EmployeeName,LeaveTypeId,Remark, IsActive,CreatedBy,CreatedOn,StatusId
			)
			Values
			(
				@StartDate,@EndDate,@EmployeeName,@LeaveTypeId,@Remark, @IsActive,@LoggedInUserId,GETDATE(),@StatusId
			)

			SET @Result = SCOPE_IDENTITY();
		END
		ELSE IF(@LeaveId> 0 and EXISTS(SELECT TOP 1 1 FROM LeaveMaster WHERE LeaveId=@LeaveId))
		BEGIN
			UPDATE LeaveMaster
			SET StartDate=@StartDate,
				EndDate=@EndDate,
				EmployeeName=@EmployeeName,
				LeaveTypeId=@LeaveTypeId,
				Remark=@Remark,
				IsActive=@IsActive,
				ModifiedBy=@LoggedInUserId, 
				ModifiedOn=GETDATE()
			WHERE LeaveId=@LeaveId
			SET @Result = @LeaveId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END
	END
	
	SELECT @Result as Result
END

GO

Alter Procedure [dbo].[GetLeaveDetailsById]
	@Id BIGINT
As
Begin
	SET NOCOUNT ON;
	
	SELECT
		LM.LeaveId,LM.StartDate,LM.EndDate,LM.EmployeeName,
		LM.LeaveTypeId,LTM.LeaveTypeName,Remark,Reason,LM.IsActive,
		LM.StatusId,SM.StatusName,
		CreatorEM.EmployeeName As CreatorName,
		LM.CreatedBy,
		LM.CreatedOn
	FROM LeaveMaster LM WITH(NOLOCK)
	Inner Join StatusMaster SM With(NoLock)
		On SM.StatusId = LM.StatusId
	Inner Join Users U With(NoLock)
		On U.UserId = LM.CreatedBy
	Left Join EmployeeMaster CreatorEM With(NoLock)
		On CreatorEM.EmployeeId = U.EmployeeId
			And U.EmployeeId Is Not Null
	LEFT JOIN LeaveTypeMaster LTM WITH(NOLOCK)
		ON LTM.LeaveTypeId=LM.LeaveTypeId
	WHERE LM.LeaveId = @Id
End

GO

If Object_Id('PunchInOutHistory') Is Null
Begin
	Create Table PunchInOutHistory
	(
		PunchId			BigInt Primary Key Identity(1,1),
		UserId			BigInt		Not Null References Users(UserId),
		PunchInOn		DateTime	Not Null,
		PunchOutOn		DateTime,
		ActiveTimeInMin	Int,
		Remark			VarChar(500),
		ModifiedBy		BigInt References Users(UserId),
		ModifiedOn		DateTime
	)
End

GO

-- SavePunchInOut 1
Create Or Alter Procedure SavePunchInOut
	@UserId BigInt
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
			UserId, PunchInOn
		)
		Values
		(
			@UserId, GetDate()
		)

		Set @PunchId = SCOPE_IDENTITY();
	End
	-- To update existing Punch History record if already Punched-in (To do Punchout)
	Else If @PunchId > 0 And @PunchInOn Is Not Null And @PunchOutOn Is Null
	Begin
		Update PunchInOutHistory
		Set PunchOutOn = GetDate(),
			ActiveTimeInMin = DateDiff(minute, PunchInOn, GetDate()),
			ModifiedBy = @UserId,
			ModifiedOn = GetDate()
		Where PunchId = @PunchId And UserId = @UserId
	End

	Select
		PunchId			
		,UserId			
		,PunchInOn		
		,PunchOutOn		
		,ActiveTimeInMin	
		,Remark			
		,ModifiedBy		
		,ModifiedOn		
	From PunchInOutHistory
	Where PunchId = @PunchId
End

GO
