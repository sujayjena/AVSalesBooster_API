using Models.Constants;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class TerritoryRequest
    {
        public long Id { get; set; }
        public long CountryId { get; set; }
        public long StateId { get; set; }
        public long RegionId { get; set; }
        public long DistrictId { get; set; }
        public long AreaId { get; set; }
        public bool IsActive { get; set; }

    }
    public class SearchTerritoryRequest
    {
        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;

        [DefaultValue(null)]
        public bool? IsActive { get; set; }

        public PaginationParameters pagination { get; set; }
    }

    public class TerritoryResponse : CreationDetails
    {
        public long Id { get; set; }
        public long CountryId { get; set; }
        public string CountryName { get; set; }
        public long StateId { get; set; }
        public string StateName { get; set; }
        public long RegionId { get; set; }
        public string RegionName { get; set; }
        public long DistrictId { get; set; }
        public string DistrictName { get; set; }
        public long AreaId { get; set; }
        public string AreaName { get; set; }
        public bool IsActive { get; set; }
    }

    public class Territories_Country_State_Dist_Area_Search
    {
        public int? CountryId { get; set; }
        public int? StateId { get; set; }
        public int? RegionId { get; set; }
        public int? DistrictId { get; set; }
        public int? AreaId { get; set; }
    }

    public class Territories_Country_State_Dist_Area_Response
    {
        public int? Id { get; set; }

        public string? Value { get; set; }

        public string? Text { get; set; }
    }

    public class RegionMappingRequest
    {
        public long Id { get; set; }
        public long RegionId { get; set; }
        public long StateId { get; set; }
        public bool IsActive { get; set; }

    }

    public class RegionMapping
    {
        public RegionMapping()
        {
            RegionMappingList = new List<RegionMappingRequest>();
        }

        public List<RegionMappingRequest> RegionMappingList { get; set; }
    }

    public class SearchRegionMappingRequest
    {
        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;

        public long? RegionId { get; set; }
        public long? StateId { get; set; }

        [DefaultValue(null)]
        public bool? IsActive { get; set; }

        public PaginationParameters pagination { get; set; }
    }

    public class RegionMappingResponse : CreationDetails
    {
        public long Id { get; set; }
        public long RegionId { get; set; }
        public string RegionName { get; set; }
        public long StateId { get; set; }
        public string StateName { get; set; }
        public bool IsActive { get; set; }
    }
}
