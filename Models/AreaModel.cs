using Models.Constants;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace Models
{
    public class AreaRequest
    {
        public long AreaId { get; set; }
        //public long DistrictId { get; set; }
        
        [Required(ErrorMessage = ValidationConstants.AreaNameRequied_Msg)]
        //[RegularExpression(ValidationConstants.AreaNameRegExp, ErrorMessage = ValidationConstants.AreaNameRegExp_Msg)]
        [MaxLength(ValidationConstants.AreaName_MaxLength, ErrorMessage = ValidationConstants.AreaName_MaxLength_Msg)]
        public string AreaName { get; set; }
        public bool IsActive { get; set; }

    }
    public class SearchAreaRequest
    {
        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;

        [DefaultValue(null)]
        public bool? IsActive { get; set; }

        public PaginationParameters pagination { get; set; }

    }

    public class AreaResponse : CreationDetails
    {
        public long AreaId { get; set; }
        public string AreaName { get; set; }
        public bool IsActive { get; set; }
        //public long StateId { get; set; }
        //public string StateName { get; set; }
        //public long RegionId { get; set; }
        //public string RegionName { get; set; }
        //public long DistrictId { get; set; }
        //public string DistrictName { get; set; }
    }
    public class ImportedAreaDetails
    {
        public string AreaName { get; set; }
        public string DistrictName { get; set; }
        public string RegionName { get; set; }
        public string StateName { get; set; }
        public string IsActive { get; set; }
    }
    public class AreaDataValidationErrors
    {
        public string AreaName { get; set; }
        public string DistrictName { get; set; }
        public string RegionName { get; set; }
        public string StateName { get; set; }
        public string IsActive { get; set; }
        public string ValidationMessage { get; set; }
    }
}
