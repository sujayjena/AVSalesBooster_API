using Models.Constants;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class RegionRequest
    {
        public long RegionId { get; set; }
        public long StateId { get; set; }

        [Required(ErrorMessage = ValidationConstants.RegionNameRequied_Msg)]
        [RegularExpression(ValidationConstants.RegionNameRegExp, ErrorMessage = ValidationConstants.RegionNameRegExp_Msg)]
        [MaxLength(ValidationConstants.RegionName_MaxLength, ErrorMessage = ValidationConstants.RegionName_MaxLength_Msg)]
        public string RegionName { get; set; }
        public bool IsActive { get; set; }
    }

    public class SearchRegionRequest
    {
        public PaginationParameters pagination { get; set; }
        public string RegionName { get; set; }
        public Nullable<bool> IsActive { get; set; }
    }

    public class RegionResponse : CreationDetails
    {
        public long RegionId { get; set; }
        public long StateId { get; set; }
        public string StateName { get; set; }
        public string RegionName { get; set; }
        public bool IsActive { get; set; }
    }

    public class ImportedRegionDetails
    {
        public string RegionName { get; set; }
        public string StateName { get; set; }
        public string IsActive { get; set; }
    }
    public class RegionDataValidationErrors
    {
        public string RegionName { get; set; }
        public string StateName { get; set; }
        public string IsActive { get; set; }
        public string ValidationMessage { get; set; }
    }

}
