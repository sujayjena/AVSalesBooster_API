using Dapper;
using Helpers;
using Interfaces.Repositories;
using Microsoft.Extensions.Configuration;
using Models;

namespace Repositories
{
    public class ManageDesignRepository : BaseRepository, IManageDesignRepository
    {
        private IConfiguration _configuration;

        public ManageDesignRepository(IConfiguration configuration) : base(configuration)
        {
            _configuration = configuration;
        }

        public async Task<IEnumerable<DesignResponse>> GetDesignesList(SearchDesignRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            //queryParameters.Add("@DesignName", parameters.DesignName.SanitizeValue());
            queryParameters.Add("@SearchValue", parameters.SearchValue.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<DesignResponse>("GetDesignes", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        public async Task<DesignResponse?> GetDesignDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<DesignResponse>("GetDesignDetailsById", queryParameters)).FirstOrDefault();
        }

        public async Task<IEnumerable<DesignMasterImages?>> GetDesignImagesList(long designId)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@DesignId", designId);
            return await ListByStoredProcedure<DesignMasterImages>("GetDesignImagesList", queryParameters);
        }

        public async Task<int> SaveDesignDetails(DesignRequest parameters, List<DesignMasterImages> lstDesignImages)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlDesignImageData = ConvertListToXml(lstDesignImages);

            queryParameters.Add("@DesignId", parameters.DesignId);
            queryParameters.Add("@CollectionId", parameters.CollectionId);
            queryParameters.Add("@CollectionNameId", parameters.CollectionNameId);
            queryParameters.Add("@CategoryId", parameters.CategoryId);
            queryParameters.Add("@DesignCode", parameters.DesignCode.SanitizeValue());
            queryParameters.Add("@SizeId", parameters.SizeId);
            queryParameters.Add("@SeriesId", parameters.SeriesId);
            queryParameters.Add("@BaseDesignId", parameters.BaseDesignId);
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@XmlDesignImagesData", xmlDesignImageData);
            queryParameters.Add("@DesignImagesIdToDelete", parameters.DesignImagesIdToDelete != null ? string.Join(',', parameters.DesignImagesIdToDelete) : "");
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            return await SaveByStoredProcedure<int>("SaveDesignDetails", queryParameters);
        }

        public async Task<IEnumerable<DesignDataValidationErrors>> ImportDesignsDetails(List<ImportedDesignDetails> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlDesignData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlDesignData", xmlDesignData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<DesignDataValidationErrors>("SaveImportDesignDetails", queryParameters);
        }
    }
}
