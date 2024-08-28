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
    public class IndustryRepository : BaseRepository, IIndustryRepository
    {
        //private IConfiguration _configuration;

        public IndustryRepository(IConfiguration configuration) : base(configuration)
        {
            //_configuration = configuration;
        }

        #region Industry
        public async Task<int> SaveIndustryDetails(IndustryRequest request)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@IndustryId", request.IndustryId);
            queryParameters.Add("@IndustryName", request.IndustryName);
            queryParameters.Add("@IsActive", request.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            return await SaveByStoredProcedure<int>("SaveIndustryDetails", queryParameters);
        }

        public async Task<IEnumerable<IndustryResponse>> GetIndustryList(SearchIndustryRequest request)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@PageSize", request.pagination.PageSize);
            queryParameters.Add("@PageNo", request.pagination.PageNo);
            queryParameters.Add("@Total", request.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", request.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", request.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@IndustryName", request.IndustryName.SanitizeValue());
            queryParameters.Add("@IsActive", request.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<IndustryResponse>("GetIndustryList", queryParameters);
            request.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        public async Task<IndustryResponse?> GetIndustryDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);

            return (await ListByStoredProcedure<IndustryResponse>("GetIndustryDetailsById", queryParameters)).FirstOrDefault();
        }

        #endregion

        #region Industry Solution
        public async Task<int> SaveIndustrySolutionDetails(IndustrySolutionRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@IndustrySolutionId", parameters.IndustrySolutionId);
            queryParameters.Add("@IndustryId", parameters.IndustryId);
            queryParameters.Add("@SolutionName", parameters.SolutionName);
            queryParameters.Add("@SolutionDesc", parameters.SolutionDesc);
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            return await SaveByStoredProcedure<int>("SaveIndustrySolutionDetails", queryParameters);
        }

        public async Task<IEnumerable<IndustrySolutionResponse>> GetIndustrySolutionList(SearchIndustrySolutionRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@SearchValue", parameters.SearchValue.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@IndustryId", parameters.IndustryId);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<IndustrySolutionResponse>("GetIndustrySolutionList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        public async Task<IndustrySolutionResponse?> GetIndustrySolutionDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);

            return (await ListByStoredProcedure<IndustrySolutionResponse>("GetIndustrySolutionDetailsById", queryParameters)).FirstOrDefault();
        }

        #endregion

        #region Solution Feature
        public async Task<int> SaveSolutionFeatureDetails(SolutionFeatureRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@SolutionFeatureId", parameters.SolutionFeatureId);
            queryParameters.Add("@IndustrySolutionId", parameters.IndustrySolutionId);
            queryParameters.Add("@FeatureFileName", parameters.FeatureFileName);
            queryParameters.Add("@FeatureSavedFileName", parameters.FeatureSavedFileName);
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            return await SaveByStoredProcedure<int>("SaveSolutionFeatureDetails", queryParameters);
        }

        public async Task<IEnumerable<SolutionFeatureResponse>> GetSolutionFeatureList(SearchSolutionFeature_Image_YoutubeUrl_Request parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@SearchValue", parameters.SearchValue.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@IndustrySolutionId", parameters.IndustrySolutionId);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<SolutionFeatureResponse>("GetSolutionFeatureList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        #endregion

        #region Solution Image
        public async Task<int> SaveSolutionImageDetails(SolutionImageRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@SolutionImageId", parameters.SolutionImageId);
            queryParameters.Add("@IndustrySolutionId", parameters.IndustrySolutionId);
            queryParameters.Add("@ImageFileName", parameters.ImageFileName);
            queryParameters.Add("@ImageSavedFileName", parameters.ImageSavedFileName);
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            return await SaveByStoredProcedure<int>("SaveSolutionImageDetails", queryParameters);
        }

        public async Task<IEnumerable<SolutionImageResponse>> GetSolutionImageList(SearchSolutionFeature_Image_YoutubeUrl_Request parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@SearchValue", parameters.SearchValue.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@IndustrySolutionId", parameters.IndustrySolutionId);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<SolutionImageResponse>("GetSolutionImageList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        #endregion

        #region Solution Youtube Url
        public async Task<int> SaveSolutionYoutubeUrlDetails(SolutionYoutubeUrlRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@SolutionYoutubeUrlId", parameters.SolutionYoutubeUrlId);
            queryParameters.Add("@IndustrySolutionId", parameters.IndustrySolutionId);
            queryParameters.Add("@YoutubeUrl", parameters.YoutubeUrl);
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            return await SaveByStoredProcedure<int>("SaveSolutionYoutubeUrlDetails", queryParameters);
        }

        public async Task<IEnumerable<SolutionYoutubeUrlResponse>> GetSolutionYoutubeUrlList(SearchSolutionFeature_Image_YoutubeUrl_Request parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@SearchValue", parameters.SearchValue.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@IndustrySolutionId", parameters.IndustrySolutionId);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<SolutionYoutubeUrlResponse>("GetSolutionYoutubeUrlList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        #endregion
    }
}
