If OBJECT_ID('Users') Is Null
Begin
	Create Table Users
	(
		UserId BigInt Primary Key Identity(1,1),
		EmailId VarChar(100) Not Null,
		MobileNo VarChar(15) Not Null,
		Passwords VarChar(200) Not Null,
		EmployeeId BigInt References EmployeeMaster(EmployeeId),
		CustomerId BigInt References CustomerDetails(CustomerId),
		IsActive Bit Not Null,
		TermsConditionsAccepted Bit,
		CreatedBy BIGINT NOT NULL,
		CreatedOn DATETIME NOT NULL,
		ModifiedBy BIGINT,
		ModifiedOn DATETIME
	)
End

GO

Drop Procedure If Exists ValidateUserLoginByEmail;

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
		U.CustomerId,
		U.IsActive,
		EM.EmployeeName,
		EM.EmployeeCode,
		EM.RoleId,
		RM.RoleName,
		CD.CompanyName,
		CD.CustomerTypeId,
		CTM.CustomerTypeName
	From Users U With(NoLock)
	Left Join EmployeeMaster EM With(NoLock)
		On EM.EmployeeId = U.EmployeeId
	Left Join RoleMaster RM With(NoLock)
		On RM.RoleId = EM.RoleId
	Left Join CustomerDetails CD With(NoLock)
		On CD.CustomerId = U.CustomerId
	Left Join CustomerTypeMaster CTM With(NoLock)
		On CTM.CustomerTypeId = CD.CustomerTypeId
	Where U.EmailId = @Email
		And U.Passwords = @Password COLLATE Latin1_General_BIN
End

GO

If OBJECT_ID('UsersLoginHistory') Is Null
Begin
	Create Table UsersLoginHistory
	(
		Id BigInt Primary Key Identity(1,1),
		UserId BigInt References Users(UserId) Not Null,
		LoggedInOn DateTime Not Null,
		IsLoggedIn Bit Not Null,
		UserToken VarChar(2000) Not Null,
		LastAccessOn DateTime Not Null,
		TokenExpireOn DateTime Not Null,
		LoggedOutOn DateTime,
		IsAutoLogout Bit,
		DeviceName VarChar(500),
		IPAddress VarChar(30),
		RememberMe Bit
	)
End

GO

Drop Procedure If Exists SaveUserLoginHistory;

GO

CREATE Or Alter ProcedureSaveUserLoginHistory
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
	Where UserId = @UserId And IPAddress = @IPAddress
		And IsLoggedIn = 1 And LoggedOutOn Is Null
		And GETDATE() > TokenExpireOn

	-- Login
	If @IsLoggedIn = 1
	Begin
		If Not Exists
		(
			Select Top 1 1 From UsersLoginHistory With(NoLock)
			Where UserId = @UserId And UserToken = @UserToken And IPAddress = @IPAddress
				And IsLoggedIn = 1 And LoggedOutOn Is Null
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
	End
End

GO

Drop Procedure If Exists GetProfileDetailsByToken;

GO

-- GetProfileDetailsByToken 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJJZCI6Iit6RWZ1eEdHUVZLMkZyc2NsUGZMTWc9PSIsIkVtYWlsSWQiOiJ0ZXN0Y3VzdG9tZXJAdGVzdC5jb20iLCJNb2JpbGVObyI6IjEyMzEyMzEyMzAiLCJOYW1lIjoiQ29tcGFueSBPbmUiLCJDdXN0b21lclR5cGVOYW1lIjoiQ3VzdG9tZXItUzEiLCJuYmYiOjE2ODk0MzQ3NTksImV4cCI6MTY4OTQzNTY1OSwiaWF0IjoxNjg5NDM0NzU5fQ.uFd4ZcrrloL40IpeuLT6z26w2B1wPBMbgxgCBhVUIBo'
CREATE Or Alter ProcedureGetProfileDetailsByToken
	@Token VarChar(500)
As
Begin
	Set NoCount On;

	Select
		U.UserId,
		U.EmailId,
		U.MobileNo,
		U.EmployeeId,
		U.CustomerId,
		U.IsActive,
		EM.EmployeeName,
		EM.EmployeeCode,
		EM.RoleId,
		RM.RoleName,
		CD.CompanyName,
		CD.CustomerTypeId,
		CTM.CustomerTypeName
	From UsersLoginHistory LH With(NoLock)
	Inner Join Users U With(NoLock)
		On U.UserId = LH.UserId
	Left Join EmployeeMaster EM With(NoLock)
		On EM.EmployeeId = U.EmployeeId
	Left Join CustomerDetails CD With(NoLock)
		On CD.CustomerId = U.CustomerId
	Left Join RoleMaster RM With(NoLock)
		On RM.RoleId = EM.RoleId
	Left Join CustomerTypeMaster CTM With(NoLock)
		On CTM.CustomerTypeId = CD.CustomerTypeId
	Where LH.UserToken = @Token And LH.IsLoggedIn = 1 And LH.LoggedOutOn Is Null
End
