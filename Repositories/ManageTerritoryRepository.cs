﻿using Dapper;
using Helpers;
using Interfaces.Repositories;
using Microsoft.Extensions.Configuration;
using Models;

namespace Repositories
{
    public class ManageTerritoryRepository : BaseRepository,IManageTerritoryRepository
    {
        private IConfiguration _configuration;

        public ManageTerritoryRepository(IConfiguration configuration) : base(configuration)
        {
            _configuration = configuration;
        }
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
            string xmlStateData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlStateData", xmlStateData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<StateDataValidationErrors>("SaveImportStateDetails", queryParameters);
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
            queryParameters.Add("@RegionName", parameters.RegionName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<RegionResponse>("GetRegions", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveRegion(RegionRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@RegionId", parameters.RegionId);
            queryParameters.Add("@StateId", parameters.StateId);
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
            string xmlRegionData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlRegionData", xmlRegionData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<RegionDataValidationErrors>("SaveImportRegionDetails", queryParameters);
        }

        public async Task<IEnumerable<DistrictResponse>> GetDistrictsList(SearchDistrictRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@DistrictName", parameters.DistrictName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<DistrictResponse>("GetDistricts", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        public async Task<int> SaveDistrict(DistrictRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@DistrictId", parameters.DistrictId);
            queryParameters.Add("@RegionId", parameters.RegionId);
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
            string xmlDistrictData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlDistrictData", xmlDistrictData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<DistrictDataValidationErrors>("SaveImportDistrictDetails", queryParameters);
        }

        public async Task<IEnumerable<AreaResponse>> GetAreasList(SearchAreaRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@AreaName", parameters.AreaName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<AreaResponse>("GetAreas", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveArea(AreaRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@AreaId", parameters.AreaId);
            queryParameters.Add("@DistrictId", parameters.DistrictId);
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
            string xmlAreaData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlAreaData", xmlAreaData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<AreaDataValidationErrors>("SaveImportAreaDetails", queryParameters);
        }
    }
}