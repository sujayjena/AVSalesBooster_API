using Models.Constants;
using System.ComponentModel.DataAnnotations;

namespace Models
{
    public class SaveCollectionRequestModel
    {
        public int CollectionId { get; set; }

        [Required(ErrorMessage = ValidationConstants.CollectionName_Required_Msg)]
        [RegularExpression(ValidationConstants.CollectionName_RegExp, ErrorMessage = ValidationConstants.CollectionName_RegExp_Msg)]
        [MaxLength(ValidationConstants.CollectionName_MaxLength, ErrorMessage = ValidationConstants.CollectionName_MaxLength_Msg)]
        public string CollectionName { get; set; }

        [Required(ErrorMessage = ValidationConstants.CollectionNameId_Required_Msg)]
        [RegularExpression(ValidationConstants.CollectionName_RegExp, ErrorMessage = ValidationConstants.CollectionNameId_RegExp_Msg)]
        [MaxLength(ValidationConstants.CollectionName_MaxLength, ErrorMessage = ValidationConstants.CollectionNameId_MaxLength_Msg)]
        public string CollectionNameId { get; set; }

        public bool IsActive { get; set; }
    }

    public class SearchCollectionRequestModel
    {
        public PaginationParameters pagination { get; set; }

        [MaxLength(ValidationConstants.CollectionName_MaxLength, ErrorMessage = ValidationConstants.CollectionName_MaxLength_Msg)]
        public string CollectionName { get; set; }

        public bool? IsActive { get; set; }
    }

    public class CollectionResponseModel : CreationDetails
    {
        public int CollectionId { get; set; }
        public string CollectionName { get; set; }
        public string CollectionNameId { get; set; }
        public bool IsActive { get; set; }
    }
    public class CollectionDataValidationErrors
    {
        public string CollectionName { get; set; }
        public string IsActive { get; set; }
        public string ValidationMessage { get; set; }
    }
    public class ImportedCollection
    {
        public string CollectionName { get; set; }
        public string IsActive { get; set; }
    }
}
