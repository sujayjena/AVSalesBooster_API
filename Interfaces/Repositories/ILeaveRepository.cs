using Models;

namespace Interfaces.Repositories
{
    public interface ILeaveRepository
    {
        Task<IEnumerable<LeaveResponse>> GetLeavesList(SearchLeaveRequest request);
        Task<int> SaveLeaveDetails(LeaveRequest parameters);
        Task<int> UpdateLeaveStatus(UpdateLeaveStatusRequest parameters);
        Task<LeaveResponse?> GetLeaveDetailsById(long id);
        Task<IEnumerable<LeaveApproveRejectHistory_Response>> GetLeaveApproveRejectHistoryList(LeaveApproveRejectHistory_Search parameters);

    }
}
