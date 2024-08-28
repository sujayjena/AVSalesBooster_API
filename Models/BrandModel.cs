using Models.Constants;
using System.ComponentModel.DataAnnotations;

namespace Models
{
    public class BrandRequest
    {
        public long BrandId { get; set; }

        [Required(ErrorMessage = ValidationConstants.ProductNameRequied_Msg)]
        [RegularExpression(ValidationConstants.ProductNameRegExp, ErrorMessage = ValidationConstants.ProductNameRegExp_Msg)]
        [MaxLength(ValidationConstants.ProductName_MaxLength, ErrorMessage = ValidationConstants.ProductName_MaxLength_Msg)]
        public string BrandName { get; set; }
        public bool IsActive { get; set; }
    }

    public class BrandResponse
    {
        public long BrandId { get; set; }
        public string BrandName { get; set; }
        public bool IsActive { get; set; }
    }
    public class BrandResponseObj
    {
        public long Total { get; set; }
        public List<BrandResponse> Results { get; set; }
    }

    public class ImportedBrandDetails
    {
        public string BrandName { get; set; }
        public string IsActive { get; set; }
    }

    public class BrandDataValidationErrors
    {
        public string BrandName { get; set; }
        public string IsActive { get; set; }
        public string ValidationMessage { get; set; }
    }

    public class SearchBrandRequest
    {
        public string BrandName { get; set; }
        public Nullable<bool> IsActive { get; set; }

        public PaginationParameters pagination { get; set; }
    }
}
