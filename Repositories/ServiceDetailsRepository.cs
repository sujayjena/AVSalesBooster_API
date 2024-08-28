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
    public class ServiceDetailsRepository : BaseRepository, IServiceDetailsRepository
    {
        //private IConfiguration _configuration;

        public ServiceDetailsRepository(IConfiguration configuration) : base(configuration)
        {
            //_configuration = configuration;
        }

        public async Task<int> SaveServiceDetails(ServiceDetailsRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@ServiceId", parameters.ServiceId);
            queryParameters.Add("@ServiceName", parameters.ServiceName);
            queryParameters.Add("@ServiceDesc", parameters.ServiceDesc);
            queryParameters.Add("@YoutubeLink", parameters.YoutubeLink);
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            return await SaveByStoredProcedure<int>("SaveServiceDetails", queryParameters);
        }

        public async Task<IEnumerable<ServiceDetailsResponse>> GetServiceDetailsList(SearchServiceDetailsRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@SearchValue", parameters.SearchValue.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<ServiceDetailsResponse>("GetServiceDetailsList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        public async Task<ServiceDetailsResponse?> GetServiceDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);

            return (await ListByStoredProcedure<ServiceDetailsResponse>("GetServiceDetailsById", queryParameters)).FirstOrDefault();
        }
    }
}
