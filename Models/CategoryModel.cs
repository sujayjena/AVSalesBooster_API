using Models.Constants;
using System.ComponentModel.DataAnnotations;

namespace Models
{
    public class CategoryRequest
    {
        public long CategoryId { get; set; }

        [Required(ErrorMessage = ValidationConstants.CategoryNameRequied_Msg)]
        [RegularExpression(ValidationConstants.CategoryNameRegExp, ErrorMessage = ValidationConstants.CategoryNameRegExp_Msg)]
        [MaxLength(ValidationConstants.CategoryName_MaxLength, ErrorMessage = ValidationConstants.CategoryName_MaxLength_Msg)]
        public string CategoryName { get; set; }
        public bool IsActive { get; set; }
    }

    public class CategoryResponse : CreationDetails
    {
        public long CategoryId { get; set; }
        public string CategoryName { get; set; }
        public bool IsActive { get; set; }
    }

    public class SearchCategoryRequest
    {
        public PaginationParameters pagination { get; set; }
        public string CategoryName { get; set; }
        public Nullable<bool> IsActive { get; set; }

    }
    public class CategoryDataValidationErrors
    {
        public string CategoryName { get; set; }
        public string IsActive { get; set; }
        public string ValidationMessage { get; set; }
    }
    public class ImportedCategoryDetails
    {
        public string CategoryName { get; set; }
        public string IsActive { get; set; }
    }
}
