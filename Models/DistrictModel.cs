using Models.Constants;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class DistrictRequest
    {
        public long DistrictId { get; set; }
        //public long RegionId { get; set; }

        [Required(ErrorMessage = ValidationConstants.DistrictNameRequied_Msg)]
        //[RegularExpression(ValidationConstants.DistrictNameRegExp, ErrorMessage = ValidationConstants.DistrictNameRegExp_Msg)]
        [MaxLength(ValidationConstants.DistrictName_MaxLength, ErrorMessage = ValidationConstants.DistrictName_MaxLength_Msg)]
        public string DistrictName { get; set; }
        public bool IsActive { get; set; }
    }
    public class SearchDistrictRequest
    {
        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;

        [DefaultValue(null)]
        public bool? IsActive { get; set; }

        public PaginationParameters pagination { get; set; }
    }

    public class DistrictResponse : CreationDetails
    {
        public long DistrictId { get; set; }
        public string DistrictName { get; set; }
        public bool IsActive { get; set; }
        //public long RegionId { get; set; }
        //public string RegionName { get; set; }
        //public long StateId { get; set; }
        //public string StateName { get; set; }
    }
    public class ImportedDistrictDetails
    {
        public string DistrictName { get; set; }
        public string RegionName { get; set; }
        public string StateName { get; set; }
        public string IsActive { get; set; }
    }
    public class DistrictDataValidationErrors
    {
        public string DistrictName { get; set; }
        public string RegionName { get; set; }
        public string StateName { get; set; }
        public string IsActive { get; set; }
        public string ValidationMessage { get; set; }
    }
}
