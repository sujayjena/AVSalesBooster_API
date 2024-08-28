using Models.Constants;
using System.ComponentModel.DataAnnotations;

namespace Models
{
    public class BloodGroupRequestModel
    {
        public int BloodGroupId { get; set; }

        [Required(ErrorMessage = ValidationConstants.BloodGroup_Required_Msg)]
        [RegularExpression(ValidationConstants.BloodGroup_RegExp, ErrorMessage = ValidationConstants.BloodGroup_RegExp_Msg)]
        [MaxLength(ValidationConstants.BloodGroup_MaxLength, ErrorMessage = ValidationConstants.BloodGroup_MaxLength_Msg)]
        public string BloodGroupName { get; set; }
        public bool IsActive { get; set; }
    }

    public class SearchBloodGroupRequestModel
    {
        public PaginationParameters pagination { get; set; }

        [MaxLength(ValidationConstants.BloodGroup_MaxLength, ErrorMessage = ValidationConstants.BloodGroup_MaxLength_Msg)]
        public string BloodGroup { get; set; }
        public bool? IsActive { get; set; }
    }

    public class BloodGroupResponseModel : CreationDetails
    {
        public int BloodGroupId { get; set; }
        public string BloodGroup { get; set; }
        public bool IsActive { get; set; }
    }
}
