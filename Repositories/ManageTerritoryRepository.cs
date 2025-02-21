using Dapper;
using Helpers;
using Interfaces.Repositories;
using Microsoft.Extensions.Configuration;
using Models;
using System.Xml.Linq;

namespace Repositories
{
    public class ManageTerritoryRepository : BaseRepository,IManageTerritoryRepository
    {
        private IConfiguration _configuration;

        public ManageTerritoryRepository(IConfiguration configuration) : base(configuration)
        {
            _configuration = configuration;
        }

        #region Country

        public async Task<IEnumerable<CountryResponse>> GetCountryList(SearchCountryRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@CountryName", parameters.CountryName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<CountryResponse>("GetCountry", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveCountry(CountryRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@CountryId", parameters.CountryId);
            queryParameters.Add("@CountryName", parameters.CountryName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveCountryDetails", queryParameters);
        }
        public async Task<CountryResponse?> GetCountryDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<CountryResponse>("GetCountryDetailsById", queryParameters)).FirstOrDefault();
        }

        #endregion

        public async Task<IEnumerable<StateResponse>> GetStatesList(SearchStateRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@StateName", parameters.StateName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<StateResponse>("GetStates", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveState(StateRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@StateId", parameters.StateId);
            queryParameters.Add("@StateName", parameters.StateName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveStateDetails", queryParameters);
        }
        public async Task<IEnumerable<StateDataValidationErrors>> ImportStatesDetails(List<ImportedStateDetails> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string XmlData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlData", XmlData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<StateDataValidationErrors>("ImportStatesDetails", queryParameters);
        }
        public async Task<StateResponse?> GetStateDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<StateResponse>("GetStateDetailsById", queryParameters)).FirstOrDefault();
        }

        public async Task<IEnumerable<RegionResponse>> GetRegionsList(SearchRegionRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@ValueForSearch", parameters.ValueForSearch);
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<RegionResponse>("GetRegions", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveRegion(RegionRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@RegionId", parameters.RegionId);
            queryParameters.Add("@RegionName", parameters.RegionName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveRegionDetails", queryParameters);
        }
        public async Task<RegionResponse?> GetRegionDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<RegionResponse>("GetRegionDetailsById", queryParameters)).FirstOrDefault();
        }

        public async Task<IEnumerable<RegionDataValidationErrors>> ImportRegionsDetails(List<ImportedRegionDetails> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlData", xmlData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<RegionDataValidationErrors>("ImportRegionsDetails", queryParameters);
        }

        public async Task<IEnumerable<DistrictResponse>> GetDistrictsList(SearchDistrictRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@ValueForSearch", parameters.ValueForSearch);
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<DistrictResponse>("GetDistricts", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        public async Task<int> SaveDistrict(DistrictRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@DistrictId", parameters.DistrictId);
            queryParameters.Add("@DistrictName", parameters.DistrictName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveDistrictDetails", queryParameters);
        }

        public async Task<DistrictResponse?> GetDistrictDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<DistrictResponse>("GetDistrictDetailsById", queryParameters)).FirstOrDefault();
        }
        public async Task<IEnumerable<DistrictDataValidationErrors>> ImportDistrictsDetails(List<ImportedDistrictDetails> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlData", xmlData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<DistrictDataValidationErrors>("ImportDistrictsDetails", queryParameters);
        }

        public async Task<IEnumerable<AreaResponse>> GetAreasList(SearchAreaRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@ValueForSearch", parameters.ValueForSearch);
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<AreaResponse>("GetAreas", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveArea(AreaRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@AreaId", parameters.AreaId);
            queryParameters.Add("@AreaName", parameters.AreaName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveAreaDetails", queryParameters);
        }

        public async Task<AreaResponse?> GetAreaDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<AreaResponse>("GetAreaDetailsById", queryParameters)).FirstOrDefault();
        }
        public async Task<IEnumerable<AreaDataValidationErrors>> ImportAreasDetails(List<ImportedAreaDetails> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlData", xmlData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<AreaDataValidationErrors>("ImportAreasDetails", queryParameters);
        }

        public async Task<IEnumerable<TerritoryResponse>> GetTerritoryList(SearchTerritoryRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@ValueForSearch", parameters.ValueForSearch);
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<TerritoryResponse>("GetTerritory", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveTerritory(TerritoryRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@CountryId", parameters.CountryId);
            queryParameters.Add("@StateId", parameters.StateId);
            queryParameters.Add("@DistrictId", parameters.DistrictId);
            queryParameters.Add("@AreaId", parameters.AreaId);
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveTerritory", queryParameters);
        }

        public async Task<TerritoryResponse?> GetTerritoryById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<TerritoryResponse>("GetTerritoryById", queryParameters)).FirstOrDefault();
        }

        public async Task<IEnumerable<Territories_Country_State_Dist_Area_Response>> GetTerritories_Country_State_Dist_Area_List_ById(Territories_Country_State_Dist_Area_Search parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@CountryId", parameters.CountryId);
            queryParameters.Add("@StateId", parameters.StateId);
            queryParameters.Add("@DistId", parameters.DistrictId);
            queryParameters.Add("@VillageId", parameters.AreaId);

            var result = await ListByStoredProcedure<Territories_Country_State_Dist_Area_Response>("GetTerritories_Country_State_Dist_Area_List_ById", queryParameters);

            return result;
        }

        public async Task<IEnumerable<RegionMappingResponse>> GetRegionMappingList(SearchRegionMappingRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@ValueForSearch", parameters.ValueForSearch);
            queryParameters.Add("@RegionId", parameters.RegionId);
            queryParameters.Add("@StateId", parameters.StateId);
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<RegionMappingResponse>("GetRegionMapping", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveRegionMapping(RegionMappingRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", parameters.Id);
            queryParameters.Add("@RegionId", parameters.RegionId);
            queryParameters.Add("@StateId", parameters.StateId);
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveRegionMapping", queryParameters);
        }

        public async Task<RegionMappingResponse?> GetRegionMappingById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<RegionMappingResponse>("GetRegionMappingById", queryParameters)).FirstOrDefault();
        }

    }
}
