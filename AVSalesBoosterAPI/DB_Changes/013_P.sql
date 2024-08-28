IF OBJECT_ID('VisitRemarks') IS NULL
BEGIN
	CREATE TABLE VisitRemarks
	(
		VisitRemarkId BIGINT PRIMARY KEY IDENTITY(1,1),
		VisitId BIGINT NOT NULL REFERENCES VisitMaster(VisitId),
		Remarks VARCHAR(2000) NOT NULL,
		IsDeleted BIT NOT NULL,
		CreatedOn DATETIME NOT NULL,
		CreatedBy BIGINT NOT NULL,
		ModifiedOn DATETIME,
		ModifiedBy BIGINT
	)
END

GO

DROP PROCEDURE IF EXISTS GetVisitDetailsById

GO

CREATE Or Alter Procedure GetVisitDetailsById
	@Id BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		vm.VisitId,
		vm.VisitDate,
		em.RoleId AS EmployeeRoleId,
		rm.RoleName,
		em.EmployeeId,
		em.EmployeeName,
		ctm.CustomerTypeId,
		cd.CompanyName AS CustomerName,
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
		vm.CreatedOn,
		vm.ModifiedOn
	FROM VisitMaster vm WITH(NOLOCK)
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
	LEFT JOIN VisitRemarks vr WITH(NOLOCK)
		ON vr.VisitId = vm.VisitId
	WHERE vm.VisitId = @Id
END

GO

DROP PROCEDURE IF EXISTS GetVisitRemarksByVisitId

GO

-- GetVisitRemarksByVisitId 1
CREATE Or Alter ProcedureGetVisitRemarksByVisitId
	@VisitId BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		vr.VisitRemarkId
		,vr.Remarks
	FROM VisitRemarks vr WITH(NOLOCK)
	WHERE vr.VisitId = @VisitId AND vr.IsDeleted = 0
END

GO

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='VisitMaster' AND COLUMN_NAME='Remarks')
BEGIN
	ALTER TABLE VisitMaster
	DROP COLUMN Remarks
END

GO

DROP PROCEDURE IF EXISTS SaveVisitDetails;

GO

/*
	Version : 1.0
	Created Date : 03 JULY 2023
	Execution : EXEC [dbo].[SaveVisitDetails] 
	Description : Insert Visit Detail from VisitMaster
*/
CREATE Or Alter ProcedureSaveVisitDetails
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
				Latitude,Longitude,IsActive,CreatedBy,CreatedOn
			)
			VALUES
			(
				@EmployeeId,@VisitDate,@CustomerId,@CustomerTypeId,@ContactPerson,@ContactNumber,@EmailId,@NextActionDate,
				@Latitude,@Longitude,@IsActive,@LoggedInUserId,GETDATE()
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
				Latitude=@Latitude,Longitude=@Longitude,IsActive=@IsActive,
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
	@IsActive=NULL
*/

ALTER PROCEDURE [dbo].[GetVisits]
(
    @PageSize INT,
    @PageNo INT,
    @SortBy VARCHAR(50),
    @OrderBy VARCHAR(4),
	@ContactPerson VARCHAR(100)=null,
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
	SET @ContactPerson = ISNULL(@ContactPerson,'');

	IF @SortBy <> ''
		BEGIN
			SET @OrderByQuery='ORDER by '+@SortBy+' '+@OrderBy+' ';
		END
	ELSE 
		BEGIN
			SET @OrderByQuery='ORDER by VisitId DESC ';
		END


	SET @STR = N'SELECT EM.VisitId,EM.EmployeeId,EM.VisitDate,EM.CustomerId,EM.CustomerTypeId,EM.ContactPerson,EM.ContactNumber,
					EM.EmailId,EM.NextActionDate,EM.Latitude,EM.Longitude,EM.IsActive
					FROM VisitMaster EM WITH(NOLOCK)
				WHERE (@ContactPerson='''' OR ContactPerson like ''%''+@ContactPerson+''%'')
				and (@IsActive IS NULL OR IsActive=@IsActive)
			'+@OrderByQuery+' '+@PaginationQuery+'	'

	PRINT @STR;
	exec sp_executesql @STR,
						N'@ContactPerson VARCHAR(100),@IsActive BIT',
						@ContactPerson,@IsActive
END
