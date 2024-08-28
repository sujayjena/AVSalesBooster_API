using Dapper;
using Helpers;
using Interfaces.Repositories;
using Microsoft.Extensions.Configuration;
using Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repositories
{
    public class NotificationRepository : BaseRepository, INotificationRepository
    {
        public NotificationRepository(IConfiguration configuration) : base(configuration)
        {
            //_configuration = configuration;
        }
        public async Task<IEnumerable<NotificationResponse>> GetNotificationList(SearchNotificationRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@NotificationDate", parameters.NotificationDate);
            //queryParameters.Add("@EmployeeId", parameters.EmployeeId);
            //queryParameters.Add("@EmployeeName", parameters.EmployeeName);
            //queryParameters.Add("@VisitId", parameters.VisitId);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<NotificationResponse>("GetNotificationList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<IEnumerable<NotificationResponse>> GetNotificationListById(long employeeId)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@NotificationDate", DateTime.Now);
            queryParameters.Add("@LoggedInUserId", employeeId);

            return await ListByStoredProcedure<NotificationResponse>("GetNotificationListById", queryParameters);
        }
    }
}
