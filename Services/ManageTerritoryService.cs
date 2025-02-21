using Interfaces.Repositories;
using Interfaces.Services;
using Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Services
{
    public class ManageTerritoryService : IManageTerritoryService
    {
        private IManageTerritoryRepository _manageTerritorRepository;

        public ManageTerritoryService(IManageTerritoryRepository manageTerritorRepository)
        {
            _manageTerritorRepository = manageTerritorRepository;
        }

        #region Country
        public async Task<IEnumerable<CountryResponse>> GetCountryList(SearchCountryRequest request)
        {
            return await _manageTerritorRepository.GetCountryList(request);
        }
        public async Task<int> SaveCountry(CountryRequest request)
        {
            return await _manageTerritorRepository.SaveCountry(request);
        }
        public async Task<CountryResponse?> GetCountryDetailsById(long id)
        {
            return await _manageTerritorRepository.GetCountryDetailsById(id);
        }
        #endregion

        #region State
        public async Task<IEnumerable<StateResponse>> GetStatesList(SearchStateRequest request)
        {
            return await _manageTerritorRepository.GetStatesList(request);
        }
        public async Task<int> SaveState(StateRequest stateRequest)
        {
            return await _manageTerritorRepository.SaveState(stateRequest);
        }
        public async Task<IEnumerable<StateDataValidationErrors>> ImportStatesDetails(List<ImportedStateDetails> request)
        {
            return await _manageTerritorRepository.ImportStatesDetails(request);
        }
        public async Task<StateResponse?> GetStateDetailsById(long id)
        {
            return await _manageTerritorRepository.GetStateDetailsById(id);
        }
        #endregion

        #region Region
        public async Task<IEnumerable<RegionResponse>> GetRegionsList(SearchRegionRequest request)
        {
            return await _manageTerritorRepository.GetRegionsList(request);
        }
        public async Task<int> SaveRegion(RegionRequest regionRequest)
        {
            return await _manageTerritorRepository.SaveRegion(regionRequest);
        }
        public async Task<RegionResponse?> GetRegionDetailsById(long id)
        {
            return await _manageTerritorRepository.GetRegionDetailsById(id);
        }
        public async Task<IEnumerable<RegionDataValidationErrors>> ImportRegionsDetails(List<ImportedRegionDetails> request)
        {
            return await _manageTerritorRepository.ImportRegionsDetails(request);
        }
        #endregion

        #region District
        public async Task<IEnumerable<DistrictResponse>> GetDistrictsList(SearchDistrictRequest request)
        {
            return await _manageTerritorRepository.GetDistrictsList(request);
        }
        public async Task<int> SaveDistrict(DistrictRequest districtRequest)
        {
            return await _manageTerritorRepository.SaveDistrict(districtRequest);
        }
        public async Task<DistrictResponse?> GetDistrictDetailsById(long id)
        {
            return await _manageTerritorRepository.GetDistrictDetailsById(id);
        }
        public async Task<IEnumerable<DistrictDataValidationErrors>> ImportDistrictsDetails(List<ImportedDistrictDetails> request)
        {
            return await _manageTerritorRepository.ImportDistrictsDetails(request);
        }
        #endregion

        #region Area
        public async Task<IEnumerable<AreaResponse>> GetAreasList(SearchAreaRequest request)
        {
            return await _manageTerritorRepository.GetAreasList(request);
        }
        public async Task<int> SaveArea(AreaRequest areaRequest)
        {
            return await _manageTerritorRepository.SaveArea(areaRequest);
        }
        public async Task<AreaResponse?> GetAreaDetailsById(long id)
        {
            return await _manageTerritorRepository.GetAreaDetailsById(id);
        }
        public async Task<IEnumerable<AreaDataValidationErrors>> ImportAreasDetails(List<ImportedAreaDetails> request)
        {
            return await _manageTerritorRepository.ImportAreasDetails(request);
        }
        #endregion

        #region Territory
        public async Task<IEnumerable<TerritoryResponse>> GetTerritoryList(SearchTerritoryRequest request)
        {
            return await _manageTerritorRepository.GetTerritoryList(request);
        }
        public async Task<int> SaveTerritory(TerritoryRequest territoryRequest)
        {
            return await _manageTerritorRepository.SaveTerritory(territoryRequest);
        }
        public async Task<TerritoryResponse?> GetTerritoryById(long id)
        {
            return await _manageTerritorRepository.GetTerritoryById(id);
        }
        public async Task<IEnumerable<Territories_Country_State_Dist_Area_Response>> GetTerritories_Country_State_Dist_Area_List_ById(Territories_Country_State_Dist_Area_Search parameters)
        {
            return await _manageTerritorRepository.GetTerritories_Country_State_Dist_Area_List_ById(parameters);
        }
        #endregion

        #region Region Mapping
        public async Task<IEnumerable<RegionMappingResponse>> GetRegionMappingList(SearchRegionMappingRequest request)
        {
            return await _manageTerritorRepository.GetRegionMappingList(request);
        }
        public async Task<int> SaveRegionMapping(RegionMappingRequest request)
        {
            return await _manageTerritorRepository.SaveRegionMapping(request);
        }
        public async Task<RegionMappingResponse?> GetRegionMappingById(long id)
        {
            return await _manageTerritorRepository.GetRegionMappingById(id);
        }
       
        #endregion
    }
}
