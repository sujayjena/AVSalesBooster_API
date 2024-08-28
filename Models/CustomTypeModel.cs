using Models.Constants;
using System.ComponentModel.DataAnnotations;

namespace Models
{
    public class CustomerTypeRequest
    {
        public long CustomerTypeId { get; set; }

        [Required(ErrorMessage = ValidationConstants.CustomerTypeNameRequied_Msg)]
        [RegularExpression(ValidationConstants.CustomerTypeNameRegExp, ErrorMessage = ValidationConstants.CustomerTypeNameRegExp_Msg)]
        [MaxLength(ValidationConstants.CustomerTypeName_MaxLength, ErrorMessage = ValidationConstants.CustomerTypeName_MaxLength_Msg)]
        public string CustomerTypeName { get; set; }
        public bool IsActive { get; set; }
    }

    public class CustomerTypeResponse
    {
        public long CustomerTypeId { get; set; }
        public string CustomerTypeName { get; set; }
        public bool IsActive { get; set; }
        public string CreatorName { get; set; }
        public long CreatedBy { get; set; }
        public DateTime CreatedOn { get; set; }
    }

    public class SearchCustomerTypeRequest
    {
        public PaginationParameters pagination { get; set; }
        public string CustomerTypeName { get; set; }
        public Nullable<bool> IsActive { get; set; }
    }
    public class CustomerTypeDataValidationErrors
    {
        public string CustomerTypeName { get; set; }
        public string IsActive { get; set; }
        public string ValidationMessage { get; set; }
    }
    public class ImportedCustomerTypeDetails
    {
        public string CustomerTypeName { get; set; }
        public string IsActive { get; set; }
    }
}
