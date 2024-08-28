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
    public class ManageActivitiesRepository : BaseRepository, IManageActivitiesRepository
    {
        private IConfiguration _configuration;

        public ManageActivitiesRepository(IConfiguration configuration) : base(configuration)
        {
            _configuration = configuration;
        }

        #region Single Activity
        public async Task<int> SaveSingleActivities(SingleActivities_Request parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", parameters.Id);
            queryParameters.Add("@ActivityName", parameters.ActivityName);
            queryParameters.Add("@PriorityId", parameters.PriorityId);
            queryParameters.Add("@ActivityStatusId", parameters.ActivityStatusId);
            queryParameters.Add("@EmployeeId", parameters.EmployeeId);
            queryParameters.Add("@StartDate", parameters.StartDate);
            queryParameters.Add("@EndDate", parameters.EndDate);
            queryParameters.Add("@DocumentFileName", parameters.DocumentFileName);
            queryParameters.Add("@DocumentSavedFileName", parameters.DocumentSavedFileName);
            queryParameters.Add("@ActivityTypeId", parameters.ActivityTypeId);
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveSingleActivities", queryParameters);
        }
        public async Task<IEnumerable<SingleActivities_Response>> GetSingleActivitiesList(SingleActivities_Search parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@EmployeeId", parameters.EmployeeId);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@ValueForSearch", parameters.ValueForSearch.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<SingleActivities_Response>("GetSingleActivitiesList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<SingleActivities_Response?> GetSingleActivitiesDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);

            return (await ListByStoredProcedure<SingleActivities_Response>("GetSingleActivitiesDetailsById", queryParameters)).FirstOrDefault();
        }

        public async Task<int> SaveSingleActivitiesRemarks(SingleActivitiesRemarks_Request parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", parameters.Id);
            queryParameters.Add("@SingleActivitiesId", parameters.SingleActivitiesId);
            queryParameters.Add("@Remarks", parameters.Remarks);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveSingleActivitiesRemarks", queryParameters);
        }

        public async Task<IEnumerable<SingleActivitiesRemarks_Response>> GetSingleActivitiesRemarksList(SingleActivitiesRemarks_Search parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@SingleActivitiesId", parameters.SingleActivitiesId);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@ValueForSearch", parameters.ValueForSearch.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<SingleActivitiesRemarks_Response>("GetSingleActivitiesRemarksList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        #endregion
    }
}
