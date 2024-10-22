using Dapper;
using Helpers;
using Interfaces.Repositories;
using Microsoft.Extensions.Configuration;
using Models;

namespace Repositories
{
    public class ProfileRepository : BaseRepository, IProfileRepository
    {
        private IConfiguration _configuration;

        public ProfileRepository(IConfiguration configuration) : base(configuration)
        {
            _configuration = configuration;
        }

        public async Task<IEnumerable<RoleResponse>> GetRolesList(SearchRoleRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@RoleName", parameters.RoleName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<RoleResponse>("GetRoles", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveRoleDetails(RoleRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@RoleId", parameters.RoleId);
            queryParameters.Add("@RoleName", parameters.RoleName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveRoleDetails", queryParameters);
        }

        public async Task<RoleResponse?> GetRoleDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<RoleResponse>("GetRoleDetailsById", queryParameters)).FirstOrDefault();
        }
        public async Task<IEnumerable<RoleDataValidationErrors>> ImportRolesDetails(List<ImportedRoleDetails> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlRoleData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlRoleData", xmlRoleData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<RoleDataValidationErrors>("SaveImportRoleDetails", queryParameters);
        }
        public async Task<IEnumerable<RoleResponse>> GetReportingHierarchyRolesList(SearchRoleRequest parameters)
        {
            return await ListByStoredProcedure<RoleResponse>("GetReportingHierarchyRoles");
        }

        public async Task<IEnumerable<ReportingToResponse>> GetReportingTosList(SearchReportingToRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            //queryParameters.Add("@ReportingTo", parameters.ReportingTo);
            queryParameters.Add("@ValueForSearch", parameters.ValueForSearch);
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<ReportingToResponse>("GetReportingTos", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveReportingToDetails(ReportingToRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", parameters.Id);
            queryParameters.Add("@RoleId", parameters.RoleId);
            queryParameters.Add("@ReportingTo", parameters.ReportingTo);
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveReportingToDetails", queryParameters);
        }

        public async Task<ReportingToResponse?> GetReportingToDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<ReportingToResponse>("GetReportingToDetailsById", queryParameters)).FirstOrDefault();
        }
        public async Task<IEnumerable<ReportingToDataValidationErrors>> ImportReportingTosDetails(List<ImportedReportingToDetails> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlReportingToData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlReportingToData", xmlReportingToData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<ReportingToDataValidationErrors>("SaveImportReportingToDetails", queryParameters);
        }
        public async Task<IEnumerable<EmployeeResponse>> GetEmployeesList(SearchEmployeeRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@ValueForSearch", parameters.ValueForSearch);
            queryParameters.Add("@StateId", parameters.StateId.SanitizeValue());
            queryParameters.Add("@RegionId", parameters.RegionId.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<EmployeeResponse>("GetEmployees", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<IEnumerable<EmployeeReportingToResponse>> GetEmployeesListByReportingTo(long employeeId)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@employeeId", employeeId);

            return await ListByStoredProcedure<EmployeeReportingToResponse>("GetEmployeesListByReportingTo", queryParameters);
        }

        public async Task<int> SaveEmployeeDetails(EmployeeRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@EmployeeId", parameters.EmployeeId);
            queryParameters.Add("@EmployeeName", parameters.EmployeeName.SanitizeValue());
            queryParameters.Add("@EmployeeCode", parameters.EmployeeCode.SanitizeValue());
            queryParameters.Add("@EmailId", parameters.EmailId.SanitizeValue());
            queryParameters.Add("@MobileNumber", parameters.MobileNumber.SanitizeValue());
            queryParameters.Add("@RoleId", parameters.RoleId);
            queryParameters.Add("@ReportingTo", parameters.ReportingTo);
            queryParameters.Add("@Address", parameters.Address.SanitizeValue());
            queryParameters.Add("@StateId", parameters.StateId);
            queryParameters.Add("@RegionId", parameters.RegionId);
            queryParameters.Add("@DistrictId", parameters.DistrictId);
            queryParameters.Add("@AreaId", parameters.AreaId);
            queryParameters.Add("@Pincode", parameters.Pincode.SanitizeValue());
            //queryParameters.Add("@DateOfBirth", parameters.DateOfBirth.SanitizeValue());
            queryParameters.Add("@DateOfBirth", parameters.DateOfBirth);
            //queryParameters.Add("@DateOfJoining", parameters.DateOfJoining.SanitizeValue());
            queryParameters.Add("@DateOfJoining", parameters.DateOfJoining);
            queryParameters.Add("@EmergencyContactNumber", parameters.EmergencyContactNumber.SanitizeValue());
            queryParameters.Add("@BloodGroupId", parameters.BloodGroupId.SanitizeValue());
            queryParameters.Add("@IsWebUser", parameters.IsWebUser);
            queryParameters.Add("@IsMobileUser", parameters.IsMobileUser);
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@FileOriginalName", parameters.FileOriginalName.SanitizeValue());
            queryParameters.Add("@ImageUpload", parameters.ImageUpload.SanitizeValue());
            queryParameters.Add("@AdharCardFileName", parameters.AdharCardFileName.SanitizeValue());
            queryParameters.Add("@AdharCardSavedFileName", parameters.AdharCardSavedFileName.SanitizeValue());
            queryParameters.Add("@PanCardFileName", parameters.PanCardFileName.SanitizeValue());
            queryParameters.Add("@PanCardSavedFileName", parameters.PanCardSavedFileName.SanitizeValue());
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            if (!string.IsNullOrEmpty(parameters.InitialPassword))
            {
                queryParameters.Add("@Password", EncryptDecryptHelper.EncryptString(parameters.InitialPassword));
            }
            else
            {
                queryParameters.Add("@Password", parameters.InitialPassword);
            }

            queryParameters.Add("@MobileUniqueId", parameters.MobileUniqueId.SanitizeValue());
            return await SaveByStoredProcedure<int>("SaveEmployeeDetails", queryParameters);
        }

        public async Task<int> UpdateEmpDetailsThroughApp(UpdateEmployeeDetailsRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@EmployeeId", parameters.EmployeeId);
            queryParameters.Add("@MobileNumber", parameters.MobileNumber.SanitizeValue());
            queryParameters.Add("@AddressId", parameters.AddressId);
            queryParameters.Add("@Address", parameters.Address.SanitizeValue());
            queryParameters.Add("@StateId", parameters.StateId);
            queryParameters.Add("@RegionId", parameters.RegionId);
            queryParameters.Add("@DistrictId", parameters.DistrictId);
            queryParameters.Add("@AreaId", parameters.AreaId);
            queryParameters.Add("@Pincode", parameters.Pincode.SanitizeValue());
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("UpdateEmpDetailsThroughApp", queryParameters);
        }

        public async Task<EmployeeResponse?> GetEmployeeDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<EmployeeResponse>("GetEmployeeDetailsById", queryParameters)).FirstOrDefault();
        }

        public async Task<int> SaveEmployeeState(EmployeeState_Request parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Action", parameters.Action);
            queryParameters.Add("@EmployeeId", parameters.EmployeeId);
            queryParameters.Add("@StateId", parameters.StateId);
            queryParameters.Add("@UserId", SessionManager.LoggedInUserId);

            return await SaveByStoredProcedure<int>("SaveEmployeeState", queryParameters);
        }

        public async Task<IEnumerable<EmployeeState_Response>> GetEmployeeStateByEmployeeId(long EmployeeId, long StateId)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@EmployeeId", EmployeeId);
            queryParameters.Add("@StateId", StateId);
            queryParameters.Add("@UserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<EmployeeState_Response>("GetEmployeeStateByEmployeeId", queryParameters);

            return result;
        }

        public async Task<int> SaveEmployeeRegion(EmployeeRegion_Request parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Action", parameters.Action);
            queryParameters.Add("@EmployeeId", parameters.EmployeeId);
            queryParameters.Add("@RegionId", parameters.RegionId);
            queryParameters.Add("@UserId", SessionManager.LoggedInUserId);

            return await SaveByStoredProcedure<int>("SaveEmployeeRegion", queryParameters);
        }

        public async Task<IEnumerable<EmployeeRegion_Response>> GetEmployeeRegionByEmployeeId(long EmployeeId, long RegionId)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@EmployeeId", EmployeeId);
            queryParameters.Add("@RegionId", RegionId);
            queryParameters.Add("@UserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<EmployeeRegion_Response>("GetEmployeeRegionByEmployeeId", queryParameters);

            return result;
        }


        public async Task<IEnumerable<EmployeeDataValidationErrors>> ImportEmployeesDetails(List<ImportedEmployeeDetails> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlEmployeeData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlEmployeeData", xmlEmployeeData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<EmployeeDataValidationErrors>("SaveImportEmployeeDetails", queryParameters);
        }

        public async Task<UsersLoginSessionData?> ValidateUserLoginByEmail(LoginByMobileNoRequestModel parameters)
        {
            IEnumerable<UsersLoginSessionData> lstResponse;
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Username", parameters.MobileNo.SanitizeValue());
            queryParameters.Add("@Password", parameters.Password.SanitizeValue());
            queryParameters.Add("@MobileUniqueId", parameters.MobileUniqueId.SanitizeValue());

            lstResponse = await ListByStoredProcedure<UsersLoginSessionData>("ValidateUserLoginByUsername", queryParameters);
            return lstResponse.FirstOrDefault();
        }

        public async Task SaveUserLoginHistory(UserLoginHistorySaveParameters parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@UserId", parameters.UserId);
            queryParameters.Add("@UserToken", parameters.UserToken.SanitizeValue());
            queryParameters.Add("@TokenExpireOn", parameters.TokenExpireOn);
            queryParameters.Add("@DeviceName", parameters.DeviceName.SanitizeValue());
            queryParameters.Add("@IPAddress", parameters.IPAddress.SanitizeValue());
            queryParameters.Add("@RememberMe", parameters.RememberMe);
            queryParameters.Add("@IsLoggedIn", parameters.IsLoggedIn);

            await ExecuteNonQuery("SaveUserLoginHistory", queryParameters);
        }

        public async Task SaveExpirePreviousToken(long UserId)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@UserId", UserId);

            await ExecuteNonQuery("SaveExpirePreviousToken", queryParameters);
        }

        public async Task<UsersLoginSessionData?> GetProfileDetailsByToken(string token)
        {
            IEnumerable<UsersLoginSessionData> lstResponse;
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Token", token);
            lstResponse = await ListByStoredProcedure<UsersLoginSessionData>("GetProfileDetailsByToken", queryParameters);

            return lstResponse.FirstOrDefault();
        }

        public async Task<PunchInOutHistoryModel?> SubmitPunchInOut(PunchInOutRequestModel parameters)
        {
            IEnumerable<PunchInOutHistoryModel> lstResponse;
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@UserId", SessionManager.LoggedInUserId);
            queryParameters.Add("@Latitude", parameters.Latitude.SanitizeValue());
            queryParameters.Add("@Longitude", parameters.Longitude.SanitizeValue());
            queryParameters.Add("@BatteryStatus", parameters.BatteryStatus.SanitizeValue());
            queryParameters.Add("@CurrentAddress", parameters.CurrentAddress.SanitizeValue());
            queryParameters.Add("@PunchType", parameters.PunchType);

            lstResponse = await ListByStoredProcedure<PunchInOutHistoryModel>("SavePunchInOut", queryParameters);

            return lstResponse.FirstOrDefault();
        }

        public async Task<IEnumerable<PunchInOutHistoryModel>> GetPunchHistoryList(PunchHistoryRequestModel parameters)
        {
            IEnumerable<PunchInOutHistoryModel> lstResponse;
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@UserId", SessionManager.LoggedInUserId);
            //queryParameters.Add("@EmplyeeName", parameters.EmplyeeName.SanitizeValue());
            queryParameters.Add("@SearchValue", parameters.SearchValue.SanitizeValue());
            queryParameters.Add("@FromPunchInTime", parameters.FromPunchInDate);
            queryParameters.Add("@ToPunchInTime", parameters.ToPunchInDate);
            queryParameters.Add("@StateId", parameters.StateId.SanitizeValue());
            queryParameters.Add("@RegionId", parameters.RegionId.SanitizeValue());

            lstResponse = await ListByStoredProcedure<PunchInOutHistoryModel>("GetPunchHistoryRecords", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return lstResponse;
        }

        public async Task<IEnumerable<ModuleMaster_Response>> GetModuleMasterList(SearchModuleMasterRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@ModuleName", parameters.ModuleName.SanitizeValue());
            queryParameters.Add("@AppType", parameters.AppType.SanitizeValue());
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            return await ListByStoredProcedure<ModuleMaster_Response>("GetModuleMasterList", queryParameters);
        }

        public async Task<IEnumerable<RoleMaster_Permission_Response>> GetRoleMaster_PermissionList(SearchRoleMaster_PermissionRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@RoleId", parameters.RoleId);
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<RoleMaster_Permission_Response>("GetRoleMaster_PermissionList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        public async Task<int> SaveRoleMaster_PermissionDetails(RoleMaster_Permission_Request parameters)
        {
            int result = 0;
            foreach (var item in parameters.ModuleList)
            {
                DynamicParameters queryParameters = new DynamicParameters();
                queryParameters.Add("@RolePermissionId", parameters.RolePermissionId);
                queryParameters.Add("@RoleId", parameters.RoleId);
                queryParameters.Add("@ModuleId", item.ModuleId);
                queryParameters.Add("@AppType", parameters.AppType);
                queryParameters.Add("@View", item.View);
                queryParameters.Add("@Add", item.Add);
                queryParameters.Add("@Edit", item.Edit);
                queryParameters.Add("@EmployeeId", 0);
                queryParameters.Add("@IsActive", parameters.IsActive);
                queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

                result = await SaveByStoredProcedure<int>("SaveRoleMaster_PermissionDetails", queryParameters);
            }
            return result;
        }

        public async Task<IEnumerable<RoleMaster_Employee_Permission_Response>> GetRoleMaster_Employee_PermissionList(SearchRoleMaster_Employee_PermissionRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@EmployeeId", parameters.EmployeeId);
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<RoleMaster_Employee_Permission_Response>("GetRoleMaster_EmployeePermissionList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        public async Task<IEnumerable<RoleMasterEmployeePermissionList>> GetRoleMaster_Employee_PermissionById(long employeeid)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Employeeid", employeeid);
            queryParameters.Add("@PageNo", 0);
            queryParameters.Add("@PageSize", 0);
            queryParameters.Add("@Total", 0, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", "");
            queryParameters.Add("@OrderBy", "");
            queryParameters.Add("@IsActive", 1);
            return (await ListByStoredProcedure<RoleMasterEmployeePermissionList>("GetRoleMaster_EmployeePermissionList", queryParameters));
        }

        public async Task<int> SaveRoleMaster_Employee_PermissionDetails(RoleMaster_Employee_Permission_Request parameters)
        {
            int result = 0;
            foreach (var item in parameters.ModuleList)
            {
                DynamicParameters queryParameters = new DynamicParameters();
                queryParameters.Add("@RolePermissionId", parameters.RolePermissionId);
                queryParameters.Add("@RoleId", parameters.RoleId);
                queryParameters.Add("@ModuleId", item.ModuleId);
                queryParameters.Add("@AppType", parameters.AppType);
                queryParameters.Add("@View", item.View);
                queryParameters.Add("@Add", item.Add);
                queryParameters.Add("@Edit", item.Edit);
                queryParameters.Add("@EmployeeId", parameters.EmployeeId);
                queryParameters.Add("@IsActive", parameters.IsActive);
                queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

                result = await SaveByStoredProcedure<int>("SaveRoleMaster_PermissionDetails", queryParameters);
            }
            return result;
        }
    }
}
