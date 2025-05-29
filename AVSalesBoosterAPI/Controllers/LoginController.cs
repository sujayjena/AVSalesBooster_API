using AVSalesBoosterAPI.CustomAttributes;
using Helpers;
using Interfaces.Services;
using Microsoft.AspNetCore.Mvc;
using Models;
using Models.Constants;
using Services;

namespace AVSalesBoosterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LoginController : ControllerBase
    {
        private ResponseModel _response;
        private IProfileService _profileService;
        private IJwtUtilsService _jwt;
        private INotificationService _notificationService;
        private IFCMPushNotification _fcmPushNotification;

        FCMPushNotification _fCMPushNotification;

        public LoginController(IProfileService profileService, IJwtUtilsService jwt, INotificationService notificationService, IFCMPushNotification fcmPushNotification)
        {
            _profileService = profileService;
            _jwt = jwt;
            _notificationService = notificationService;
            _fcmPushNotification = fcmPushNotification;

            _response = new ResponseModel();
            _response.IsSuccess = true;
        }

        [HttpPost]
        [Route("[action]")]
        public async Task<ResponseModel> MobileAppLogin(MobileAppLoginRequestModel parameters)
        {
            LoginByMobileNoRequestModel loginParameters = new LoginByMobileNoRequestModel();
            loginParameters.MobileNo = parameters.MobileNo;
            loginParameters.Password = parameters.Password;
            loginParameters.MobileUniqueId = parameters.MobileUniqueId;
            loginParameters.Remember = parameters.Remember;
            loginParameters.IsWebOrMobileUser = parameters.IsWebOrMobileUser;

            //_response.Data = await Login(loginParameters);

            var vLoginObj = new ResponseModel();
            vLoginObj.Data = await Login(loginParameters);

            return vLoginObj;
        }

        [HttpPost]
        [Route("[action]")]
        public async Task<ResponseModel> Login(LoginByMobileNoRequestModel parameters)
        {
            (string, DateTime) tokenResponse;
            SessionDataEmployee employeeSessionData;
            SessionDataCustomer customerSessionData;
            UsersLoginSessionData? loginResponse;
            UserLoginHistorySaveParameters loginHistoryParameters;

            parameters.Password = EncryptDecryptHelper.EncryptString(parameters.Password);

            loginResponse = await _profileService.ValidateUserLoginByEmail(parameters);

            if (loginResponse != null)
            {
                if (loginResponse.IsActive == true && (loginResponse.IsWebUser == true && parameters.IsWebOrMobileUser == "W" || loginResponse.IsMobileUser == true && parameters.IsWebOrMobileUser == "M"))
                {
                    await _profileService.SaveExpirePreviousToken(loginResponse.UserId);

                    tokenResponse = _jwt.GenerateJwtToken(loginResponse);

                    if (loginResponse.EmployeeId != null)
                    {
                        string strStateIdList = string.Empty;
                        string strRegionIdList = string.Empty;

                        var vRoleList = await _profileService.GetRoleMaster_Employee_PermissionById(Convert.ToInt64(loginResponse.EmployeeId));
                        var vUserNotificationList = await _notificationService.GetNotificationListById(Convert.ToInt64(loginResponse.EmployeeId));

                        var vEmployeeStateDetail = await _profileService.GetEmployeeStateByEmployeeId(EmployeeId: Convert.ToInt32(loginResponse.EmployeeId), StateId: 0);
                        if (vEmployeeStateDetail.ToList().Count > 0)
                        {
                            strStateIdList = string.Join(",", vEmployeeStateDetail.ToList().OrderBy(x => x.StateId).Select(x => x.StateId));
                        }

                        var vEmployeeRegionDetail = await _profileService.GetEmployeeRegionByEmployeeId(EmployeeId: Convert.ToInt32(loginResponse.EmployeeId), RegionId: 0);
                        if (vEmployeeRegionDetail.ToList().Count > 0)
                        {
                            strRegionIdList = string.Join(",", vEmployeeRegionDetail.ToList().OrderBy(x => x.RegionId).Select(x => x.RegionId));
                        }

                        employeeSessionData = new SessionDataEmployee
                        {
                            EmployeeId = loginResponse.EmployeeId,
                            EmployeeCode = loginResponse.EmployeeCode,
                            Name = loginResponse.EmployeeName,
                            RoleId = loginResponse.RoleId,
                            EmailId = loginResponse.EmailId,
                            MobileNo = loginResponse.MobileNo,
                            RoleName = loginResponse.RoleName,
                            StateId = strStateIdList,
                            RegionId = strRegionIdList,
                            Token = tokenResponse.Item1,
                            UserRoleList = vRoleList.ToList(),
                            UserNotificationList = vUserNotificationList.ToList()
                        };

                        _response.Data = employeeSessionData;
                    }
                    else if (loginResponse.CustomerId != null)
                    {
                        customerSessionData = new SessionDataCustomer
                        {
                            Name = loginResponse.CompanyName,
                            EmailId = loginResponse.EmailId,
                            MobileNo = loginResponse.MobileNo,
                            CustomerTypeName = loginResponse.CustomerTypeName,
                            Token = tokenResponse.Item1
                        };

                        _response.Data = customerSessionData;
                    }

                    //Login History
                    loginHistoryParameters = new UserLoginHistorySaveParameters
                    {
                        UserId = loginResponse.UserId,
                        UserToken = tokenResponse.Item1,
                        IsLoggedIn = true,
                        IPAddress = HttpContext.Connection.RemoteIpAddress?.ToString(),
                        DeviceName = HttpContext.Request.Headers["User-Agent"],
                        TokenExpireOn = tokenResponse.Item2,
                        RememberMe = parameters.Remember
                    };

                    await _profileService.SaveUserLoginHistory(loginHistoryParameters);

                    _response.Message = MessageConstants.LoginSuccessful;
                }
                else
                {
                    _response.IsSuccess = false;
                    _response.Message = ErrorConstants.InactiveProfileError;
                }
            }
            else
            {
                _response.IsSuccess = false;
                _response.Message = "Invalid credential, please try again with correct credential";
            }

            return _response;
        }

        [HttpPost]
        [Route("[action]")]
        [CustomAuthorize]
        public async Task<ResponseModel> Logout()
        {
            string token = HttpContext.Request.Headers["Authorization"].FirstOrDefault()?.Split(" ").Last().SanitizeValue()!;
            //UsersLoginSessionData? sessionData = (UsersLoginSessionData?)HttpContext.Items["SessionData"]!;

            UserLoginHistorySaveParameters logoutParameters = new UserLoginHistorySaveParameters
            {
                UserId = SessionManager.LoggedInUserId,
                UserToken = token,
                IsLoggedIn = false, //To Logout set IsLoggedIn = false
                IPAddress = HttpContext.Connection.RemoteIpAddress?.ToString(),
                DeviceName = HttpContext.Request.Headers["User-Agent"],
                TokenExpireOn = DateTime.Now,
                RememberMe = false
            };

            await _profileService.SaveUserLoginHistory(logoutParameters);

            _response.Message = MessageConstants.LogoutSuccessful;

            return _response;
        }

        [HttpPost]
        [Route("[action]")]
        public async Task<ResponseModel> SaveFCMToken(FCMTokenModel parameters)
        {
            var fcmParameters = new FCMTokenModel()
            {
                UserId = parameters.UserId,
                FCMTokenId = parameters.FCMTokenId
            };

            await _profileService.SaveFCMToken(fcmParameters);

            _response.Message = "Update sucessfully";

            return _response;
        }

        [HttpPost]
        [Route("[action]")]
        public async Task<ResponseModel> SendFCMNotification(FCMNotificationModel parameters)
        {
            bool result;
            result = await _fcmPushNotification.SendNotification(parameters);
            if (result)
            {
                _response.IsSuccess = true;
                _response.Message = "Notification sent sucessfully";
            }
            else
            {
                _response.IsSuccess = false;
                _response.Message = "Failed to send notification";
            }

            return _response;
        }

        //[HttpPost]
        //[Route("[action]")]
        //public async Task<ResponseModel> GetOTPForCustomerLogin(LoginOTPRequestModel parameters)
        //{
        //    _response.IsSuccess = true;
        //    _response.Message = MessageConstants.OTPSentSuccessful;

        //    return _response;
        //}

        //[HttpPost]
        //[Route("[action]")]
        //public async Task<ResponseModel> GetOTPForEmployeeLogin(LoginOTPRequestModel parameters)
        //{
        //    _response.IsSuccess = true;
        //    _response.Message = MessageConstants.OTPSentSuccessful;

        //    return _response;
        //}

        //[HttpPost]
        //[Route("[action]")]
        //public async Task<ResponseModel> LoginByMobileOTP(LoginByOTPRequestModel parameters)
        //{
        //    _response.IsSuccess = true;
        //    _response.Message = MessageConstants.LoginSuccessful;

        //    return _response;
        //}
    }
}
