using Models.Constants;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class DesignTypeRequest
    {
        public long DesignTypeId { get; set; }

        [Required(ErrorMessage = ValidationConstants.DesignTypeNameRequied_Msg)]
        [RegularExpression(ValidationConstants.DesignTypeNameRegExp, ErrorMessage = ValidationConstants.DesignTypeNameRegExp_Msg)]
        [MaxLength(ValidationConstants.DesignTypeName_MaxLength, ErrorMessage = ValidationConstants.DesignTypeName_MaxLength_Msg)]
        public string DesignTypeName { get; set; }
        public bool IsActive { get; set; }
    }

    public class DesignTypeResponse
    {
        public long DesignTypeId { get; set; }
        public string DesignTypeName { get; set; }
        public bool IsActive { get; set; }
    }
    public class SearchDesignTypeRequest
    {
        public PaginationParameters pagination { get; set; }
        public string DesignTypeName { get; set; }
        public Nullable<bool> IsActive { get; set; }
    }
    public class DesignTypeDataValidationErrors
    {
        public string DesignTypeName { get; set; }
        public string IsActive { get; set; }
        public string ValidationMessage { get; set; }
    }
    public class ImportedDesignTypeDetails
    {
        public string DesignTypeName { get; set; }
        public string IsActive { get; set; }
    }
}
