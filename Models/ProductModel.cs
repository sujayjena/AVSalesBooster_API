using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.FileProviders;
using Models.Constants;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace Models
{
    public class ProductRequest
    {
        public long ProductId { get; set; }

        [Required(ErrorMessage = ValidationConstants.ProductNameRequied_Msg)]
        [RegularExpression(ValidationConstants.ProductNameRegExp, ErrorMessage = ValidationConstants.ProductNameRegExp_Msg)]
        [MaxLength(ValidationConstants.ProductName_MaxLength, ErrorMessage = ValidationConstants.ProductName_MaxLength_Msg)]
        public string ProductName { get; set; }
        public bool IsActive { get; set; }
    }

    public class ImportedProductDetails
    {
        public string ProductName { get; set; }
        public string IsActive { get; set; }
    }

    public class ImportRequest
    {
        //[RegularExpression(ValidationConstants.ExcelFileRegExp, ErrorMessage = ValidationConstants.ExcelFileRegExp_Msg)]
        public IFormFile FileUpload { get; set; }
    }

    public class SearchProductRequest
    {
        public PaginationParameters pagination { get; set; }
        public string ProductName { get; set; }
        public Nullable<bool> IsActive { get; set; }
    }

    public class ProductResponse  
    {
        public long ProductId { get; set; }
        public string ProductName { get; set; }
        public bool IsActive { get; set; }

        [JsonIgnore]
        public string ValidationMessage { get; set; }
    }

    public class ProductDataValidationErrors
    {
        public string ProductName { get; set; }
        public string IsActive { get; set; }
        public string ValidationMessage { get; set; }
    }
}
