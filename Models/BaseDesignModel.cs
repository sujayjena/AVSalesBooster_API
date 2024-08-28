using Models.Constants;
using System.ComponentModel.DataAnnotations;

namespace Models
{
    public class BaseDesignRequest
    {
        public long BaseDesignId { get; set; }

        [Required(ErrorMessage = ValidationConstants.BaseDesignNameRequied_Msg)]
        [RegularExpression(ValidationConstants.BaseDesignNameRegExp, ErrorMessage = ValidationConstants.BaseDesignNameRegExp_Msg)]
        [MaxLength(ValidationConstants.BaseDesignName_MaxLength, ErrorMessage = ValidationConstants.BaseDesignName_MaxLength_Msg)]
        public string BaseDesignName { get; set; }
        public bool IsActive { get; set; }
    }

    public class BaseDesignResponse: CreationDetails
    {
        public long BaseDesignId { get; set; }
        public string BaseDesignName { get; set; }
        public bool IsActive { get; set; }
    }

    public class SearchBaseDesignRequest
    {
        public PaginationParameters pagination { get; set; }
        public string BaseDesignName { get; set; }
        public Nullable<bool> IsActive { get; set; }

    }
    public class BaseDesignDataValidationErrors
    {
        public string BaseDesignName { get; set; }
        public string IsActive { get; set; }
        public string ValidationMessage { get; set; }
    }
    public class ImportedBaseDesignDetails
    {
        public string BaseDesignName { get; set; }
        public string IsActive { get; set; }
    }
}
