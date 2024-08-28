using Dapper;
using Helpers;
using Interfaces.Repositories;
using Microsoft.Extensions.Configuration;
using Models;

namespace Repositories
{
    public class LeaveRepository : BaseRepository, ILeaveRepository
    {
        private IConfiguration _configuration;

        public LeaveRepository(IConfiguration configuration) : base(configuration)
        {
            _configuration = configuration;
        }

        public async Task<IEnumerable<LeaveResponse>> GetLeavesList(SearchLeaveRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            //queryParameters.Add("@EmployeeName", parameters.EmployeeName.SanitizeValue());
            //queryParameters.Add("@LeaveType", parameters.LeaveType.SanitizeValue());
            //queryParameters.Add("@LeaveReason", parameters.LeaveReason.SanitizeValue());
            queryParameters.Add("@SearchValue", parameters.SearchValue.SanitizeValue());
            queryParameters.Add("@LeaveStatusId", parameters.LeaveStatusId.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@FilterType", parameters.FilterType.SanitizeValue());
            queryParameters.Add("@EmployeeId", parameters.EmployeeId.SanitizeValue());
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<LeaveResponse>("GetLeaves", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        public async Task<int> SaveLeaveDetails(LeaveRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@LeaveId", parameters.LeaveId);
            queryParameters.Add("@StartDate", parameters.StartDate.SanitizeValue());
            queryParameters.Add("@EndDate", parameters.EndDate.SanitizeValue());
            queryParameters.Add("@LeaveTypeId", parameters.LeaveTypeId);
            queryParameters.Add("@EmployeeId", parameters.EmployeeId);
            queryParameters.Add("@Remark", parameters.Remark.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            queryParameters.Add("@StatusId", parameters.LeaveStatusId);
            return await SaveByStoredProcedure<int>("SaveLeaveDetails", queryParameters);
        }

        public async Task<int> UpdateLeaveStatus(UpdateLeaveStatusRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@LeaveId", parameters.LeaveId);
            queryParameters.Add("@LeaveStatusId", parameters.LeaveStatusId);
            queryParameters.Add("@Reason", parameters.Reason.SanitizeValue());
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("UpdateLeaveStatus", queryParameters);
        }

        public async Task<LeaveResponse?> GetLeaveDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<LeaveResponse>("GetLeaveDetailsById", queryParameters)).FirstOrDefault();
        }

        public async Task<IEnumerable<LeaveApproveRejectHistory_Response>> GetLeaveApproveRejectHistoryList(LeaveApproveRejectHistory_Search parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@LeaveId", parameters.LeaveId);
            queryParameters.Add("@ValueForSearch", parameters.ValueForSearch.SanitizeValue());
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@UserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<LeaveApproveRejectHistory_Response>("GetLeaveApproveRejectHistoryList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
    }
}
