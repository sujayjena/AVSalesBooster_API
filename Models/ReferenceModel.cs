using Models.Constants;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace Models
{
    public class ReferenceRequest
    {
        public long ReferenceId { get; set; }

        [JsonIgnore]
        public string UniqueNumber { get; set; }

        [Required(ErrorMessage = ValidationConstants.ReferencePartyRequied_Msg)]
        [RegularExpression(ValidationConstants.ReferencePartyRegExp, ErrorMessage = ValidationConstants.ReferencePartyRegExp_Msg)]
        [MaxLength(ValidationConstants.ReferenceParty_MaxLength, ErrorMessage = ValidationConstants.ReferenceParty_MaxLength_Msg)]
        public string ReferenceParty { get; set; }
        [Required(ErrorMessage = ValidationConstants.AddressRequied_Msg)]
        [MaxLength(ValidationConstants.Address_MaxLength, ErrorMessage = ValidationConstants.Address_MaxLength_Msg)]
        public string Address { get; set; }
        [Range(1, long.MaxValue, ErrorMessage = ValidationConstants.StateRequied_Dropdown_Msg)]
        public long StateId { get; set; }
        [Range(1, long.MaxValue, ErrorMessage = ValidationConstants.ReportingToRequied_Dropdown_Msg)]
        public long RegionId { get; set; }
        [Range(1, long.MaxValue, ErrorMessage = ValidationConstants.DistrictRequied_Dropdown_Msg)]
        public long DistrictId { get; set; }
        [Range(1, long.MaxValue, ErrorMessage = ValidationConstants.AreaRequied_Dropdown_Msg)]
        public long AreaId { get; set; }
        [Required(ErrorMessage = ValidationConstants.PincodeRequied_Msg)]
        [RegularExpression(ValidationConstants.PincodeExp, ErrorMessage = ValidationConstants.Pincode_Validation_Msg)]
        [MaxLength(ValidationConstants.Pincode_MaxLength, ErrorMessage = ValidationConstants.Pincode_MaxLength_Msg)]
        [MinLength(ValidationConstants.Pincode_MinLength, ErrorMessage = ValidationConstants.Pincode_MinLength_Msg)]
        public string Pincode { get; set; }

        [Required(ErrorMessage = ValidationConstants.PhoneNumberRequied_Msg)]
        [RegularExpression(ValidationConstants.PhoneNumberRegExp, ErrorMessage = ValidationConstants.PhoneNumberRegExp_Msg)]
        [MaxLength(ValidationConstants.PhoneNumber_MaxLength, ErrorMessage = ValidationConstants.PhoneNumber_MaxLength_Msg)]
        public string PhoneNumber { get; set; }
        [Required(ErrorMessage = ValidationConstants.MobileNumberRequied_Msg)]
        [RegularExpression(ValidationConstants.MobileNumberRegExp, ErrorMessage = ValidationConstants.MobileNumberRegExp_Msg)]
        [MaxLength(ValidationConstants.MobileNumber_MaxLength, ErrorMessage = ValidationConstants.MobileNumber_MaxLength_Msg)]
        public string MobileNumber { get; set; }
        [Required(ErrorMessage = ValidationConstants.GSTNumberRequired_Msg)]
        [RegularExpression(ValidationConstants.GSTNumberRegExp, ErrorMessage = ValidationConstants.GSTNumberRegExp_Msg)]
        [MaxLength(ValidationConstants.GSTNumber_MaxLength, ErrorMessage = ValidationConstants.GST_MaxLength_Msg)]
        public string GSTNumber { get; set; }
        [Required(ErrorMessage = ValidationConstants.PANNumberRequired_Msg)]
        [RegularExpression(ValidationConstants.PANNumberRegExp, ErrorMessage = ValidationConstants.PANNumberRegExp_Msg)]
        [MaxLength(ValidationConstants.PANNumber_MaxLength, ErrorMessage = ValidationConstants.PANNumber_MaxLength_Msg)]
        public string PanNumber { get; set; }
        [Required(ErrorMessage = ValidationConstants.EmailIdRequied_Msg)]
        [RegularExpression(ValidationConstants.EmailRegExp, ErrorMessage = ValidationConstants.EmailRegExp_Msg)]
        [MaxLength(ValidationConstants.Email_MaxLength, ErrorMessage = ValidationConstants.Email_MaxLength_Msg)]
        public string EmailId { get; set; }
        public bool IsActive { get; set; }
    }

    public class SearchReferenceRequest
    {
        public PaginationParameters pagination { get; set; }
        public string ReferenceParty { get; set; }
        public Nullable<bool> IsActive { get; set; }
    }

    public class ReferenceResponse : CreationDetails
    {
        public long ReferenceId { get; set; }
        public string UniqueNumber { get; set; }
        public string ReferenceParty { get; set; }
        public string Address { get; set; }
        public long StateId { get; set; }
        public string StateName { get; set; }
        public long RegionId { get; set; }
        public string RegionName { get; set; }
        public long DistrictId { get; set; }
        public string DistrictName { get; set; }
        public long AreaId { get; set; }
        public string AreaName { get; set; }
        public string Pincode { get; set; }
        public string PhoneNumber { get; set; }
        public string MobileNumber { get; set; }
        public string GSTNumber { get; set; }
        public string PanNumber { get; set; }
        public string EmailId { get; set; }
        public bool IsActive { get; set; }
    }

    public class ImportedReferenceDetails
    {
        public string ReferenceParty { get; set; }
        public string Address { get; set; }
        public string StateName { get; set; }
        public string RegionName { get; set; }
        public string DistrictName { get; set; }
        public string AreaName { get; set; }
        public string Pincode { get; set; }
        public string PhoneNumber { get; set; }
        public string MobileNumber { get; set; }
        public string GSTNumber { get; set; }
        public string PanNumber { get; set; }
        public string EmailId { get; set; }
        public string IsActive { get; set; }
    }

    public class ReferenceDataValidationErrors
    {
        public string ReferenceParty { get; set; }
        public string Address { get; set; }
        public string StateName { get; set; }
        public string RegionName { get; set; }
        public string DistrictName { get; set; }
        public string AreaName { get; set; }
        public string Pincode { get; set; }
        public string PhoneNumber { get; set; }
        public string MobileNumber { get; set; }
        public string GSTNumber { get; set; }
        public string PanNumber { get; set; }
        public string EmailId { get; set; }
        public string IsActive { get; set; }
        public string ValidationMessage { get; set; }
    }
}
