using Helpers;
using Interfaces.Repositories;
using Interfaces.Services;
using Models;

namespace Services
{
    public class ProfileService : IProfileService
    {
        private IProfileRepository _profileRepository;
        private IFileManager _fileManager;
        public ProfileService(IProfileRepository profileRepository, IFileManager fileManager)
        {
            _profileRepository = profileRepository;
            _fileManager = fileManager;
        }

        public async Task<IEnumerable<RoleResponse>> GetRolesList(SearchRoleRequest request)
        {
            return await _profileRepository.GetRolesList(request);
        }

        public async Task<int> SaveRoleDetails(RoleRequest roleRequest)
        {
            return await _profileRepository.SaveRoleDetails(roleRequest);
        }

        public async Task<RoleResponse?> GetRoleDetailsById(long id)
        {
            return await _profileRepository.GetRoleDetailsById(id);
        }
        public async Task<IEnumerable<RoleDataValidationErrors>> ImportRolesDetails(List<ImportedRoleDetails> request)
        {
            return await _profileRepository.ImportRolesDetails(request);
        }

        public async Task<IEnumerable<RoleResponse>> GetReportingHierarchyRolesList(SearchRoleRequest request)
        {
            return await _profileRepository.GetReportingHierarchyRolesList(request);
        }

        public async Task<IEnumerable<ReportingToResponse>> GetReportingTosList(SearchReportingToRequest request)
        {
            return await _profileRepository.GetReportingTosList(request);
        }

        public async Task<int> SaveReportingToDetails(ReportingToRequest reportingToRequest)
        {
            return await _profileRepository.SaveReportingToDetails(reportingToRequest);
        }
        public async Task<ReportingToResponse?> GetReportingToDetailsById(long id)
        {
            return await _profileRepository.GetReportingToDetailsById(id);
        }
        public async Task<IEnumerable<ReportingToDataValidationErrors>> ImportReportingTosDetails(List<ImportedReportingToDetails> request)
        {
            return await _profileRepository.ImportReportingTosDetails(request);
        }

        public async Task<IEnumerable<EmployeeResponse>> GetEmployeesList(SearchEmployeeRequest request)
        {
            return await _profileRepository.GetEmployeesList(request);
        }

        public async Task<IEnumerable<EmployeeReportingToResponse>> GetEmployeesListByReportingTo(long employeeId)
        {
            return await _profileRepository.GetEmployeesListByReportingTo(employeeId);
        }

        public async Task<int> SaveEmployeeDetails(EmployeeRequest employeeRequest)
        {
            if (employeeRequest.ProfilePicture != null)
            {
                employeeRequest.FileOriginalName = employeeRequest.ProfilePicture.FileName;
                employeeRequest.ImageUpload = _fileManager.UploadProfilePicture(employeeRequest.ProfilePicture);
            }

            if (employeeRequest.AdharCard != null)
            {
                employeeRequest.AdharCardFileName = employeeRequest.AdharCard.FileName;
                employeeRequest.AdharCardSavedFileName = _fileManager.UploadEmpDocuments(employeeRequest.AdharCard);
            }

            if (employeeRequest.PanCard != null)
            {
                employeeRequest.PanCardFileName = employeeRequest.PanCard.FileName;
                employeeRequest.PanCardSavedFileName = _fileManager.UploadEmpDocuments(employeeRequest.PanCard);
            }

            return await _profileRepository.SaveEmployeeDetails(employeeRequest);
        }

        public async Task<int> UpdateEmpDetailsThroughApp(UpdateEmployeeDetailsRequest parameters)
        {
            return await _profileRepository.UpdateEmpDetailsThroughApp(parameters);
        }

        public async Task<EmployeeResponse?> GetEmployeeDetailsById(long id)
        {
            EmployeeResponse? response = await _profileRepository.GetEmployeeDetailsById(id);

            if (response != null && !string.IsNullOrEmpty(response.ImageUpload))
            {
                response.ProfilePicture = _fileManager.GetProfilePicture(response.ImageUpload);
            }

            if (response != null && !string.IsNullOrEmpty(response.AdharCardSavedFileName))
            {
                response.AdharCardPicture = _fileManager.GetEmpDocuments(response.AdharCardSavedFileName);
            }

            if (response != null && !string.IsNullOrEmpty(response.PanCardSavedFileName))
            {
                response.PanCardPicture = _fileManager.GetEmpDocuments(response.PanCardSavedFileName);
            }

            return response;
        }

        public async Task<int> SaveEmployeeState(EmployeeState_Request request)
        {
            return await _profileRepository.SaveEmployeeState(request);
        }

        public async Task<IEnumerable<EmployeeState_Response>> GetEmployeeStateByEmployeeId(long EmployeeId, long StateId)
        {
            return await _profileRepository.GetEmployeeStateByEmployeeId(EmployeeId, StateId);
        }

        public async Task<int> SaveEmployeeRegion(EmployeeRegion_Request request)
        {
            return await _profileRepository.SaveEmployeeRegion(request);
        }
        public async Task<IEnumerable<EmployeeRegion_Response>> GetEmployeeRegionByEmployeeId(long EmployeeId, long RegionId)
        {
            return await _profileRepository.GetEmployeeRegionByEmployeeId(EmployeeId, RegionId);
        }

        public async Task<IEnumerable<EmployeeDataValidationErrors>> ImportEmployeesDetails(List<ImportedEmployeeDetails> request)
        {
            return await _profileRepository.ImportEmployeesDetails(request);
        }

        public async Task<UsersLoginSessionData?> ValidateUserLoginByEmail(LoginByMobileNoRequestModel parameters)
        {
            return await _profileRepository.ValidateUserLoginByEmail(parameters);
        }

        public async Task SaveUserLoginHistory(UserLoginHistorySaveParameters parameters)
        {
            await _profileRepository.SaveUserLoginHistory(parameters);
        }

        public async Task SaveExpirePreviousToken(long UserId)
        {
            await _profileRepository.SaveExpirePreviousToken(UserId);
        }

        public async Task<UsersLoginSessionData?> GetProfileDetailsByToken(string token)
        {
            return await _profileRepository.GetProfileDetailsByToken(token);
        }

        public async Task<PunchInOutHistoryModel?> SubmitPunchInOut(PunchInOutRequestModel parameters)
        {
            return await _profileRepository.SubmitPunchInOut(parameters);
        }

        public async Task<IEnumerable<PunchInOutHistoryModel>> GetPunchHistoryList(PunchHistoryRequestModel parameters)
        {
            return await _profileRepository.GetPunchHistoryList(parameters);
        }

        /*Role Permission*/
        public async Task<IEnumerable<ModuleMaster_Response>> GetModuleMasterList(SearchModuleMasterRequest parameters)
        {
            return await _profileRepository.GetModuleMasterList(parameters);
        }

        public async Task<IEnumerable<RoleMaster_Permission_Response>> GetRoleMaster_PermissionList(SearchRoleMaster_PermissionRequest request)
        {
            return await _profileRepository.GetRoleMaster_PermissionList(request);
        }

        public async Task<int> SaveRoleMaster_PermissionDetails(RoleMaster_Permission_Request parameters)
        {
            return await _profileRepository.SaveRoleMaster_PermissionDetails(parameters);
        }

        public async Task<IEnumerable<RoleMaster_Employee_Permission_Response>> GetRoleMaster_Employee_PermissionList(SearchRoleMaster_Employee_PermissionRequest request)
        {
            return await _profileRepository.GetRoleMaster_Employee_PermissionList(request);
        }

        public async Task<IEnumerable<RoleMasterEmployeePermissionList>> GetRoleMaster_Employee_PermissionById(long employeeId)
        {
            return await _profileRepository.GetRoleMaster_Employee_PermissionById(employeeId);
        }

        public async Task<int> SaveRoleMaster_Employee_PermissionDetails(RoleMaster_Employee_Permission_Request parameters)
        {
            return await _profileRepository.SaveRoleMaster_Employee_PermissionDetails(parameters);
        }

        public async Task<int> SaveFCMToken(FCMTokenModel parameters)
        {
            return await _profileRepository.SaveFCMToken(parameters);
        }
        public async Task<int> SaveFCMPushNotification(FCMPushNotificationModel parameters)
        {
            return await _profileRepository.SaveFCMPushNotification(parameters);
        }

        public async Task<tblUserModel?> GetUserDetails(int userId)
        {
            return await _profileRepository.GetUserDetails(userId);
        }
    }
}
