using Models;

namespace Interfaces.Services
{
    public interface ILeaveService
    {
        Task<IEnumerable<LeaveResponse>> GetLeavesList(SearchLeaveRequest request);
        Task<int> SaveLeaveDetails(LeaveRequest leaveRequest);
        Task<int> UpdateLeaveStatus(UpdateLeaveStatusRequest parameters);
        Task<LeaveResponse?> GetLeaveDetailsById(long id);
        Task<IEnumerable<LeaveApproveRejectHistory_Response>> GetLeaveApproveRejectHistoryList(LeaveApproveRejectHistory_Search parameters);
    }
}
