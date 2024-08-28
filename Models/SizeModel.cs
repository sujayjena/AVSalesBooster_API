using Models.Constants;
using System.ComponentModel.DataAnnotations;

namespace Models
{
    public class SizeRequest
    {
        public long SizeId { get; set; }

        [Required(ErrorMessage = ValidationConstants.SizeNameRequied_Msg)]
        [RegularExpression(ValidationConstants.SizeNameRegExp, ErrorMessage = ValidationConstants.SizeNameRegExp_Msg)]
        [MaxLength(ValidationConstants.SizeName_MaxLength, ErrorMessage = ValidationConstants.SizeName_MaxLength_Msg)]
        public string SizeName { get; set; }
        public bool IsActive { get; set; }
    }

    public class SizeResponse : CreationDetails
    {
        public long SizeId { get; set; }
        public string SizeName { get; set; }
        public bool IsActive { get; set; }
    }

    public class SearchSizeRequest
    {
        public PaginationParameters pagination { get; set; }
        public string SizeName { get; set; }
        public Nullable<bool> IsActive { get; set; }
    }
    public class SizeDataValidationErrors
    {
        public string SizeName { get; set; }
        public string IsActive { get; set; }
        public string ValidationMessage { get; set; }
    }
    public class ImportedSizeDetails
    {
        public string SizeName { get; set; }
        public string IsActive { get; set; }
    }
}
