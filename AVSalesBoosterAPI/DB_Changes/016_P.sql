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
					On CreatorEM.EmployeeId = U.EmployeeId And U.EmployeeId Is Not Null
				Left Join CustomerDetails CreatorCD With(NoLock)
					On CreatorCD.CustomerId = U.CustomerId And U.CustomerId Is Not Null
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

Create Or ALTER PROCEDURE GetCustomerTypesForSelectList
	@IsActive BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		CustomerTypeId AS [Value],
		CustomerTypeName AS [Text]
	FROM CustomerTypeMaster WITH(NOLOCK)
	WHERE (@IsActive IS NULL OR IsActive = @IsActive)
END

GO

-- GetCustomersForSelectList 0, null
Create Or ALTER PROCEDURE GetCustomersForSelectList
	@CustomerTypeId BigInt = 0,
	@IsActive BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		CustomerId AS [Value],
		CompanyName AS [Text]
	FROM CustomerDetails WITH(NOLOCK)
	WHERE (@CustomerTypeId = 0 OR CustomerTypeId = @CustomerTypeId)
		And (@IsActive IS NULL OR IsActive = @IsActive)
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

			INSERT INTO Users(EmailId,MobileNo,Passwords,CustomerId,IsActive,TermsConditionsAccepted,CreatedBy,CreatedOn)
			SELECT @EmailId,@MobileNumber,@Password,@Result,@IsActive,1,@LoggedInUserId,GETDATE()
		
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

-- [dbo].[GetCustomerContactDetailsById] 6
ALTER PROCEDURE [dbo].[GetCustomerContactDetailsById]
	@CustomerId BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		CD.ContactId, CD.ContactName, CD.MobileNo, CD.EmailId,
		CD.RefPartyId, RM.PartyName, RM.PhoneNumber as RefPhoneNumber, RM.MobileNumber as RefMobileNumber,
		CD.IsActive
	FROM CustomerContactMapping CCM WITH(NOLOCK)
	INNER JOIN ContactDetails CD With(NoLock)
		ON CD.ContactId=CCM.ContactId
	Left Join ReferenceMaster RM WIth(NoLock)
		On RM.ReferenceId = CD.RefPartyId
	WHERE CustomerId = @CustomerId
END

GO

-- [dbo].[GetCustomerAddressDetailsById] 6
ALTER PROCEDURE [dbo].[GetCustomerAddressDetailsById]
	@CustomerId BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		AD.AddressId, Ad.[Address] as [Address], 
		Ad.StateId, SM.StateName, Ad.RegionId, RM.RegionName, 
		Ad.DistrictId,DM.DistrictName,AD.AreaId,AM.AreaName,AD.Pincode,
		AD.IsActive,AD.IsDefault,AD.NameForAddress,AD.MobileNo,AD.EmailId,
		Ad.AddressTypeId, ATM.AddressType
		FROM CustomerAddressMapping CAM WITH(NOLOCK)
	INNER JOIN AddressMaster AD ON CAM.AddressId =AD.AddressId
	Inner Join StateMaster SM With(NoLock)
		On SM.StateId = AD.StateId
	Inner Join RegionMaster RM With(NoLock)
		On RM.RegionId = AD.RegionId
	Inner Join DistrictMaster DM With(NoLock)
		On DM.DistrictId = AD.DistrictId
	Inner Join AreaMaster AM With(NoLock)
		On AM.AreaId = AD.AreaId
	Left Join AddressTypesMaster ATM With(NoLock)
		On ATM.Id = AD.AddressTypeId
	WHERE CustomerId = @CustomerId
END

GO

If Object_Id('StatusMaster') Is Null
Begin
	Create Table StatusMaster
	(
		StatusId	Int Primary Key,
		StatusName	VarChar(25) Not Null
	)
End

GO

If Not Exists(select * from StatusMaster where statusname in('New','In Progress','Closed'))
Begin
	Insert Into StatusMaster(StatusId, StatusName) Values(1, 'New'),(2, 'In Progress'),(3, 'Closed')
End

GO

-- GetStatusMasterList
Create Or Alter Procedure GetStatusMasterList
As
Begin
	SET NOCOUNT ON;

	Select 
		StatusId As [Value],
		StatusName As [Text]
	From StatusMaster
End

GO

If Not Exists(Select Top 1 1 From Information_Schema.Columns Where Table_Name = 'VisitMaster' And Column_Name='VisitStatusId')
Begin
	Alter Table VisitMaster
	Add VisitStatusId Int;
End

GO

Update VisitMaster Set VisitStatusId=1;

GO

Alter Table VisitMaster
Alter Column VisitStatusId Int Not Null

GO

/*
	Version : 1.0
	Created Date : 03 JULY 2023
	Execution : EXEC [dbo].[SaveVisitDetails] 
	Description : Insert Visit Detail from VisitMaster
*/
ALTER PROCEDURE [dbo].[SaveVisitDetails]
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
	@ContactPerson VARCHAR(100),
	@ContactNumber VARCHAR(20),
	@EmailId VARCHAR(100),
	@NextActionDate Datetime,
	@Latitude DECIMAL(9,6),
	@Longitude DECIMAL(9,6),
	@IsActive BIT,
	@VisitStatusId INT,
	@XmlRemarks XML,
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
			Insert into VisitMaster
			(
				EmployeeId,VisitDate,CustomerId,CustomerTypeId,ContactPerson,ContactNumber,EmailId,NextActionDate,
				Latitude,Longitude,IsActive,VisitStatusId,CreatedBy,CreatedOn
			)
			VALUES
			(
				@EmployeeId,@VisitDate,@CustomerId,@CustomerTypeId,@ContactPerson,@ContactNumber,@EmailId,@NextActionDate,
				@Latitude,@Longitude,@IsActive,@VisitStatusId,@LoggedInUserId,GETDATE()
			)

			SET @Result = SCOPE_IDENTITY();
			
			-- Insert Into Address 
			INSERT INTO AddressMaster
			(
				Address,StateId,RegionId,DistrictId,AreaId,Pincode,IsDefault,IsActive,CreatedBy,CreatedOn
			)
			Values
			(
				@Address,@StateId,@RegionId,@DistrictId,@AreaId,0,0,@IsActive,@LoggedInUserId,GETDATE()
			)

			SET @AddressId = SCOPE_IDENTITY();

			INSERT INTO VisitAddressMapping
			(
				VisitId,AddressId
			)
			Values
			(
				@Result, @AddressId
			)
		END
		ELSE IF(@VisitId> 0 and EXISTS(SELECT TOP 1 1 FROM VisitMaster WHERE VisitId=@VisitId))
		BEGIN
			UPDATE VisitMaster
			SET EmployeeId=@EmployeeId,VisitDate=@VisitDate,CustomerId=@CustomerId,
				CustomerTypeId=@CustomerTypeId,ContactPerson=@ContactPerson,
				ContactNumber=@ContactNumber,EmailId=@EmailId,NextActionDate=@NextActionDate,
				Latitude=@Latitude,Longitude=@Longitude,
				IsActive=@IsActive,VisitStatusId=@VisitStatusId,
				ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE VisitId = @VisitId
			
			UPDATE AD
			SET Address=@Address,StateId=@StateId,RegionId=@RegionId,DistrictId=@DistrictId,
				AreaId=@AreaId,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			FROM VisitAddressMapping vam
			INNER JOIN AddressMaster AD
				ON AD.AddressId=vam.AddressId
			WHERE vam.VisitId = @VisitId
			
			SET @Result = @VisitId;
		END
		ELSE
		BEGIN
			SET @Result=@NoRecordExists
		END

		-- Start: To add update visit remarks
		IF @Result > 0 -- @Result is Visit ID here
		Begin
			DECLARE @TempVisitRemarks TABLE
			(
				VisitId BIGINT,
				VisitRemarkId BIGINT NOT NULL,
				Remarks VARCHAR(2000) NOT NULL
			);

			INSERT INTO @TempVisitRemarks
			(
				VisitId, VisitRemarkId, Remarks
			)
			SELECT
				VisitId = @Result,
				VisitRemarkId = T.Item.value('VisitRemarkId[1]', 'BIGINT'),
				Remarks = T.Item.value('Remarks[1]', 'varchar(2000)')
			FROM @XmlRemarks.nodes('/ArrayOfVisitRemarks/VisitRemarks') AS T(Item)

			-- To Insert new records with VisitRemarkId = 0
			INSERT INTO VisitRemarks
			(
				VisitId, Remarks, IsDeleted, CreatedOn, CreatedBy
			)
			SELECT
				@Result, Remarks, 0, GETDATE(), @LoggedInUserId
			FROM @TempVisitRemarks
			WHERE VisitRemarkId = 0

			-- To update existing records
			UPDATE vr
			SET vr.Remarks = tvr.Remarks,
				vr.ModifiedOn = GETDATE(),
				vr.ModifiedBy = @LoggedInUserId
			FROM VisitRemarks vr WITH(NOLOCK)
			INNER JOIN @TempVisitRemarks tvr
				ON tvr.VisitRemarkId = vr.VisitRemarkId
			WHERE vr.VisitId = @Result AND tvr.VisitRemarkId <> 0

			-- To delete removed remarks
			UPDATE vr
			SET vr.IsDeleted = 1,
				vr.ModifiedOn = GETDATE(),
				vr.ModifiedBy = @LoggedInUserId
			FROM @TempVisitRemarks tvr
			LEFT JOIN VisitRemarks vr WITH(NOLOCK)
				ON tvr.VisitRemarkId = vr.VisitRemarkId
			WHERE vr.VisitId = @Result AND vr.VisitRemarkId IS NULL

			--SELECT * FROM VisitRemarks
		END
		-- End: To add update visit remarks
	END
	
	SELECT @Result as Result
END

GO

/*
	Version : 1.0
	Created Date : 03 JULY 2023
	Execution : EXEC [dbo].[GetVisits]
	Description : Get Visit Detail from GetVisits
	EXEC [dbo].[GetVisits]  
		@PageSize=10,
	    @PageNo=1,
	    @SortBy='',
	    @OrderBy='',
		@ContactPerson='',
		@CustomerType='',
		@CustomerName='',
		@ContactPersonName = '',
		@ContactPersonNumber = '',
		@AreaName = '',
		@FromDate = null,
		@ToDate = null,
		@VisitStatusId = 1,
		@IsActive=NULL
*/
ALTER PROCEDURE [dbo].[GetVisits]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@ContactPerson VARCHAR(100) = '',
	@CustomerType VARCHAR(50) = '',
	@CustomerName VARCHAR(50) = '',
	@ContactPersonName VARCHAR(50) = '',
	@ContactPersonNumber VARCHAR(20) = '',
	@AreaName VARCHAR(20) = '',
	@FromDate Date = null,
	@ToDate Date = null,
	@VisitStatusId Int = 0,
	@IsActive BIT = null
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
	SET @ContactPerson = ISNULL(@ContactPerson,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by VisitId DESC ';
		END


	SET @STR = N'SELECT
					EM.VisitId,EM.EmployeeId,EM.VisitDate,EM.CustomerId,EM.CustomerTypeId,EM.ContactPerson,EM.ContactNumber,
					EM.EmailId,EM.NextActionDate,EM.Latitude,EM.Longitude,
					/*VR.Remarks,*/
					EM.IsActive,
					AD.Address,AD.StateId,AD.RegionId,AD.DistrictId,AD.AreaId,
					SM.StateName,RGM.RegionName,DM.DistrictName,ARM.AreaName,
					AD.Pincode,EM.VisitStatusId,StsM.StatusName, CD.CompanyName as CustomerName,
					CTM.CustomerTypeName
				FROM VisitMaster EM WITH(NOLOCK)
				Inner Join StatusMaster StsM WIth(NoLock)
					On StsM.StatusId = EM.VisitStatusId
				INNER JOIN VisitAddressMapping VAM WITH(NOLOCK)
					ON VAM.VisitId=EM.VisitId
				INNER JOIN AddressMaster AD WITH(NOLOCK)
					ON AD.AddressId=VAM.AddressId
				INNER JOIN StateMaster SM WITH(NOLOCK)
					ON SM.StateId=AD.StateId
				INNER JOIN RegionMaster RGM WITH(NOLOCK)
					ON RGM.RegionId=AD.RegionId
				INNER JOIN DistrictMaster DM WITH(NOLOCK)
					ON DM.DistrictId=AD.DistrictId
				INNER JOIN AreaMaster ARM WITH(NOLOCK)
					ON ARM.AreaId=AD.AreaId
				/*LEFT JOIN VisitRemarks vr WITH(NOLOCK)
					ON vr.VisitId = EM.VisitId*/
				Left Join CustomerDetails CD WITH(NOLOCK)
					On CD.CustomerId = EM.CustomerId
				Left Join CustomerTypeMaster CTM With(NoLock)
					On CTM.CustomerTypeId = EM.CustomerTypeId
				WHERE (@ContactPerson='''' OR EM.ContactPerson like ''%''+@ContactPerson+''%'')
					and (@IsActive IS NULL OR EM.IsActive=@IsActive)
					And (@VisitStatusId = 0 OR EM.VisitStatusId = @VisitStatusId)
					And (@CustomerType = '''' Or CTM.CustomerTypeName like ''%''+ @CustomerType +''%'')
					And (@CustomerName = '''' Or CD.CompanyName like ''%''+@CustomerName+''%'')
					And (@ContactPersonName = '''' Or EM.ContactPerson like ''%''+@ContactPersonName+''%'')
					And (@ContactPersonNumber = '''' Or EM.ContactNumber like ''%''+@ContactPersonNumber+''%'')
					And (@AreaName = '''' Or ARM.AreaName like ''%''+@AreaName+''%'')
					And (@FromDate Is Null Or EM.VisitDate >= @FromDate)
					And (@ToDate Is Null Or EM.VisitDate <= @ToDate)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	--PRINT @STR;

	exec sp_executesql @STR,
			N'@ContactPerson VARCHAR(100),@IsActive BIT,@VisitStatusId Int,@CustomerType VARCHAR(50), @CustomerName VARCHAR(50),
				@ContactPersonName VARCHAR(50), @ContactPersonNumber VARCHAR(20),@AreaName VARCHAR(20),
				@FromDate Date, @ToDate Date',
			@ContactPerson,@IsActive,@VisitStatusId,@CustomerType,@CustomerName,
			@ContactPersonName, @ContactPersonNumber,@AreaName,@FromDate, @ToDate
END

GO

-- GetVisitDetailsById 2
ALTER PROCEDURE [dbo].[GetVisitDetailsById]
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		vm.VisitId,
		vm.VisitDate,
		em.RoleId AS EmployeeRoleId,
		rm.RoleName,
		vm.CustomerId,
		em.EmployeeId,
		em.EmployeeName,
		EM.EmailId,
		ctm.CustomerTypeId,
		cd.CompanyName AS CustomerName,
		CTM.CustomerTypeName,
		sm.StateId,
		sm.StateName,
		region.RegionId,
		region.RegionName,
		dm.DistrictId,
		dm.DistrictName,
		am.AreaId,
		area.AreaName,
		vm.ContactPerson,
		vm.ContactNumber,
		vm.NextActionDate,
		vm.Latitude,
		vm.Longitude,
		am.[Address],
		--vr.Remarks
		vm.IsActive,
		vm.VisitStatusId,
		StsM.StatusName,
		vm.CreatedOn,
		vm.ModifiedOn
	FROM VisitMaster vm WITH(NOLOCK)
	Inner Join StatusMaster StsM WIth(NoLock)
		On StsM.StatusId = VM.VisitStatusId
	INNER JOIN VisitAddressMapping vam WITH(NOLOCK)
		ON vam.VisitId = vm.VisitId
	INNER JOIN AddressMaster am WITH(NOLOCK)
		ON am.AddressId = vam.AddressId
	INNER JOIN StateMaster sm WITH(NOLOCK)
		ON sm.StateId = am.StateId
	INNER JOIN RegionMaster region WITH(NOLOCK)
		ON region.RegionId = am.RegionId
	INNER JOIN DistrictMaster dm WITH(NOLOCK)
		ON dm.DistrictId = am.DistrictId
	INNER JOIN AreaMaster area WITH(NOLOCK)
		ON area.AreaId = am.AreaId
	--INNER JOIN Users creator WITH(NOLOCK)
	--	ON creator.UserId = vm.CreatedBy
	--LEFT JOIN Users modifier WITH(NOLOCK)
	--	ON modifier.UserId = vm.ModifiedBy
	LEFT JOIN EmployeeMaster em WITH(NOLOCK)
		ON em.EmployeeId = vm.EmployeeId
	LEFT JOIN RoleMaster rm WITH(NOLOCK)
		ON rm.RoleId = em.RoleId
	LEFT JOIN CustomerDetails cd WITH(NOLOCK)
		ON cd.CustomerId = vm.CustomerId
	LEFT JOIN CustomerTypeMaster ctm WITH(NOLOCK)
		ON ctm.CustomerTypeId = cd.CustomerTypeId
	--LEFT JOIN VisitRemarks vr WITH(NOLOCK)
	--	ON vr.VisitId = vm.VisitId
	WHERE vm.VisitId = @Id
END

GO

Create Or ALTER PROCEDURE [dbo].[GetStatesForSelectList]
	@IsActive BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT StateId AS [Value], StateName AS [Text]
	FROM StateMaster WITH(NOLOCK)
	WHERE @IsActive IS NULL OR IsActive = @IsActive
END

GO

Create Or ALTER PROCEDURE [dbo].[GetDistrictsForSelectList]
	@RegionId BIGINT,
	@IsActive BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DistrictId AS [Value], DistrictName AS [Text]
	FROM DistrictMaster WITH(NOLOCK)
	WHERE RegionId = @RegionId AND
		(@IsActive IS NULL OR IsActive = @IsActive)
END

GO

Create Or ALTER PROCEDURE [dbo].[GetAreasForSelectList]
	@DistrictId BIGINT,
	@IsActive BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		AreaId AS [Value],
		AreaName AS [Text]
	FROM AreaMaster WITH(NOLOCK)
	WHERE DistrictId = @DistrictId AND
		(@IsActive IS NULL OR IsActive = @IsActive)
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[GetDistricts]
Description : Get District from DistrictMaster
EXEC [dbo].[GetDistricts]  
	@PageSize=10,
    @PageNo=1,
    @SortBy='',
    @OrderBy='',
	@DistrictName='',
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetDistricts]
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
					ST.StateId,ST.StateName
				FROM DistrictMaster D WITH(NOLOCK)
				INNER JOIN RegionMaster RM  WITH(NOLOCK)
					ON RM.RegionId=D.RegionId
				INNER JOIN StateMaster ST  WITH(NOLOCK)
					ON ST.StateId=RM.StateId
				WHERE (@DistrictName='''' OR DistrictName like ''%''+@DistrictName+''%'')
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
					AM.DistrictId,D.DistrictName
				FROM AreaMaster AM WITH(NOLOCK)
				INNER JOIN DistrictMaster D WITH(NOLOCK)
					ON D.DistrictId=AM.DistrictId
				INNER JOIN RegionMaster RM  WITH(NOLOCK)
					ON RM.RegionId = D.RegionId
				INNER JOIN StateMaster ST  WITH(NOLOCK)
					ON ST.StateId=RM.StateId
				WHERE (@AreaName='''' OR AM.AreaName like ''%''+@AreaName+''%'')
					and (@IsActive IS NULL OR AM.IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	--PRINT @STR;

	exec sp_executesql @STR,
						N'@AreaName VARCHAR(100),@IsActive BIT',
						@AreaName,@IsActive
END

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
					LeaveId,StartDate,EndDate,EmployeeName,LM.LeaveTypeId,
					LTM.LeaveTypeName,Remark,Reason,LM.IsActive,
					LM.CreatedOn
				FROM LeaveMaster LM WITH(NOLOCK)
				LEFT JOIN LeaveTypeMaster LTM WITH(NOLOCK)
					ON LTM.LeaveTypeId=LM.LeaveTypeId
				WHERE (@EmployeeName='''' OR EmployeeName like ''%''+@EmployeeName+''%'')
					And (@IsActive IS NULL OR LM.IsActive=@IsActive)
					And (@LeaveTypeId = 0 OR LM.LeaveTypeId = @LeaveTypeId)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	--PRINT @STR;

	exec sp_executesql @STR,
						N'@EmployeeName VARCHAR(100),@IsActive BIT,@LeaveTypeId BigInt',
						@EmployeeName,@IsActive,@LeaveTypeId
END

GO

/*
Version : 1.0
Created Date : 03 JULY 2023
Execution : EXEC [dbo].[SaveReportingToDetails] '0','ReportingTo 1',1
Description : Insert ReportingTo from ReportingToMaster
*/
ALTER PROCEDURE [dbo].[SaveReportingToDetails]
(
	@Id BIGINT,
	@RoleId BIGINT,
	@ReportingTo BIGINT,
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
		(@Id=0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM ReportingToMaster WITH(NOLOCK) 
				WHERE  ReportingTo=@ReportingTo And RoleId = @RoleId
			)
		)
		OR
		(@Id>0 AND 
			EXISTS
			(
				SELECT TOP 1 1 
				FROM ReportingToMaster WITH(NOLOCK) 
				WHERE ReportingTo=@ReportingTo And RoleId = @RoleId and Id<>@Id
			)
		))
	BEGIN
		SET @Result=@IsNameExists;
	END
	ELSE
	BEGIN
		IF (@Id=0)
		BEGIN
			Insert into ReportingToMaster(RoleId,ReportingTo, IsActive,CreatedBy,CreatedOn)
			Values(@RoleId,@ReportingTo, @IsActive,@LoggedInUserId,GETDATE())
			SET @Result = SCOPE_IDENTITY();
		END
		ELSE IF(@Id> 0 and EXISTS(SELECT TOP 1 1 FROM ReportingToMaster WHERE Id=@Id))
		BEGIN
			UPDATE ReportingToMaster
			SET RoleId=@RoleId,ReportingTo=@ReportingTo,IsActive=@IsActive,ModifiedBy=@LoggedInUserId, ModifiedOn=GETDATE()
			WHERE Id=@Id
			SET @Result = @Id;
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
					Case 
						When CreatorEM.EmployeeName Is Not Null 
							Then CreatorEM.EmployeeName
						Else CreatorCD.CompanyName
					End As CreatorName,
					RTM.CreatedBy,
					RTM.CreatedOn,
					ReportTo.RoleName as ReportingToName
				FROM ReportingToMaster RTM WITH(NOLOCK)
				Inner Join Users U With(NoLock)
					On U.UserId = RTM.CreatedBy
				Left Join EmployeeMaster CreatorEM With(NoLock)
					On CreatorEM.EmployeeId = U.EmployeeId And U.EmployeeId Is Not Null
				Left Join CustomerDetails CreatorCD With(NoLock)
					On CreatorCD.CustomerId = U.CustomerId And U.CustomerId Is Not Null
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

