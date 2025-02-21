using Models;

namespace Interfaces.Repositories
{
    public interface IManageTerritoryRepository
    {
        #region Country
        Task<IEnumerable<CountryResponse>> GetCountryList(SearchCountryRequest request);
        Task<int> SaveCountry(CountryRequest request);
        Task<CountryResponse?> GetCountryDetailsById(long id);

        #endregion

        #region State
        Task<IEnumerable<StateResponse>> GetStatesList(SearchStateRequest request);
        Task<int> SaveState(StateRequest stateRequest);
        Task<IEnumerable<StateDataValidationErrors>> ImportStatesDetails(List<ImportedStateDetails> parameters);
        Task<StateResponse?> GetStateDetailsById(long id);
        #endregion

        #region Region
        Task<IEnumerable<RegionResponse>> GetRegionsList(SearchRegionRequest request);
        Task<int> SaveRegion(RegionRequest regionRequest);
        Task<RegionResponse?> GetRegionDetailsById(long id);
        Task<IEnumerable<RegionDataValidationErrors>> ImportRegionsDetails(List<ImportedRegionDetails> parameters);
        #endregion

        #region District
        Task<IEnumerable<DistrictResponse>> GetDistrictsList(SearchDistrictRequest request);
        Task<int> SaveDistrict(DistrictRequest districtRequest);
        Task<DistrictResponse?> GetDistrictDetailsById(long id);
        Task<IEnumerable<DistrictDataValidationErrors>> ImportDistrictsDetails(List<ImportedDistrictDetails> parameters);

        #endregion

        #region Area
        Task<IEnumerable<AreaResponse>> GetAreasList(SearchAreaRequest request);
        Task<int> SaveArea(AreaRequest areaRequest);
        Task<AreaResponse?> GetAreaDetailsById(long id);
        Task<IEnumerable<AreaDataValidationErrors>> ImportAreasDetails(List<ImportedAreaDetails> parameters);


        #endregion

        #region Territory
        Task<IEnumerable<TerritoryResponse>> GetTerritoryList(SearchTerritoryRequest request);
        Task<int> SaveTerritory(TerritoryRequest territoryRequest);
        Task<TerritoryResponse?> GetTerritoryById(long id);
        Task<IEnumerable<Territories_Country_State_Dist_Area_Response>> GetTerritories_Country_State_Dist_Area_List_ById(Territories_Country_State_Dist_Area_Search parameters);

        #endregion

        #region Region Mapping
        Task<IEnumerable<RegionMappingResponse>> GetRegionMappingList(SearchRegionMappingRequest request);
        Task<int> SaveRegionMapping(RegionMappingRequest request);
        Task<RegionMappingResponse?> GetRegionMappingById(long id);
        #endregion
    }
}
