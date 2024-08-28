using Microsoft.AspNetCore.Http;
using Models.Constants;
using Newtonsoft.Json;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Xml.Serialization;

namespace Models
{
    public class CustomerRequest
    {
        public long CustomerId { get; set; }

        [Required(ErrorMessage = ValidationConstants.CompanyNameRequied_Msg)]
        [RegularExpression(ValidationConstants.CompanyNameRegExp, ErrorMessage = ValidationConstants.CompanyNameRegExp_Msg)]
        [MaxLength(ValidationConstants.CompanyName_MaxLength, ErrorMessage = ValidationConstants.CompanyName_MaxLength_Msg)]
        public string CompanyName { get; set; }

        //[RegularExpression(ValidationConstants.PhoneNumberRegExp, ErrorMessage = ValidationConstants.LandlineNumberRegExp_Msg)]
        [MaxLength(ValidationConstants.PhoneNumber_MaxLength, ErrorMessage = ValidationConstants.LandlineNumber_MaxLength_Msg)]
        public string LandlineNo { get; set; }

        //[Required(ErrorMessage = ValidationConstants.MobileNumberRequied_Msg)]
        //[RegularExpression(ValidationConstants.MobileNumberRegExp, ErrorMessage = ValidationConstants.MobileNumberRegExp_Msg)]
        [MaxLength(ValidationConstants.MobileNumber_MaxLength, ErrorMessage = ValidationConstants.MobileNumber_MaxLength_Msg)]
        public string MobileNumber { get; set; }

        //[Required(ErrorMessage = ValidationConstants.EmailIdRequied_Msg)]
        //[RegularExpression(ValidationConstants.EmailRegExp, ErrorMessage = ValidationConstants.EmailRegExp_Msg)]
        [MaxLength(ValidationConstants.Email_MaxLength, ErrorMessage = ValidationConstants.Email_MaxLength_Msg)]
        public string EmailId { get; set; }

        //[Range(1, long.MaxValue, ErrorMessage = ValidationConstants.CompanyTypeRequied_Msg)]
        //[Range(1, long.MaxValue)]
        public long CustomerTypeId { get; set; }

        public string SpecialRemarks { get; set; }

        //[Range(1, long.MaxValue, ErrorMessage = ValidationConstants.RoleRequied_Dropdown_Msg)]
        [Range(1, long.MaxValue)]
        public long EmployeeRoleId { get; set; }

        [Range(1, long.MaxValue)]
        public long EmployeeId { get; set; }

        public string RefPartyName { get; set; }

        public bool IsActive { get; set; }

        //[RegularExpression(ValidationConstants.ImageOrPdfFileRegExp, ErrorMessage = ValidationConstants.ImageOrPdfFileRegExp_Msg)]
        public  string GstFileName { get; set; }
        public string GstSavedFileName { get; set; }
        public IFormFile GstFile { get; set; }

        //[RegularExpression(ValidationConstants.ImageOrPdfFileRegExp, ErrorMessage = ValidationConstants.ImageOrPdfFileRegExp_Msg)]
        public string PanCardFileName { get; set; }
        public string PanCardSavedFileName { get; set; }
        public IFormFile Pancard { get; set; }

        public List<ContactDetail> ContactDetails { get; set; }
        public List<AddressDetail> AddressDetails { get; set; }
    }

    public class SearchCustomerRequest
    {
        public PaginationParameters pagination { get; set; }
        public long? CustomerTypeId { get; set; }
        public long? EmployeeId { get; set; }
        //public string CompanyName { get; set; }
        //public string EmployeeName { get; set; }

        [DefaultValue("")]
        public string SearchValue { get; set; }
        public Nullable<bool> IsActive { get; set; }

        [DefaultValue("All")]
        public string FilterType { get; set; }
    }

    public class CustomerResponse
    {
        public long CustomerId { get; set; }
        public string CompanyName { get; set; }
        public string LandlineNo { get; set; }
        public string MobileNumber { get; set; }
        public string EmailId { get; set; }
        public long CustomerTypeId { get; set; }
        public string CustomerTypeName { get; set; }
        public string SpecialRemarks { get; set; }
        public long EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public long RoleId { get; set; }
        public string EmployeeRole { get; set; }
        public string Address { get; set; }
        public string StateName { get; set; }
        public string RegionName { get; set; }
        public string DistrictName { get; set; }
        public string AreaName { get; set; }
        public string RefPartyName { get; set; }

        public string GstFileName { get; set; }
        public string GstSavedFileName { get; set; }
        public byte[] GstFile { get; set; }
        public string GstFileUrl { get; set; }
        public string PanCardFileName { get; set; }
        public string PanCardSavedFileName { get; set; }
        public byte[] PanCard { get; set; }
        public string PanCardFileUrl { get; set; }

        public bool IsActive { get; set; }
        public string CreatorName { get; set; }
        public long CreatedBy { get; set; }
        public DateTime CreatedOn { get; set; }
    }

    public class CustomerDetailsResponse
    {
        public CustomerResponse customerDetails { get; set; }
        public List<ContactDetail> contactDetails { get; set; }
        public List<AddressDetail> addressDetails { get; set; }
    }

    public class ContactDetail : CreationDetails
    {
        public long ContactId { get; set; }

        //[MaxLength(ValidationConstants.ContactName_MaxLength, ErrorMessage = ValidationConstants.ContactName_MaxLength_Msg)]
        public string ContactName { get; set; }

        //[Required(ErrorMessage = ValidationConstants.MobileNumberRequied_Msg)]
        //[RegularExpression(ValidationConstants.MobileNumberRegExp, ErrorMessage = ValidationConstants.MobileNumberRegExp_Msg)]
        [MaxLength(ValidationConstants.MobileNumber_MaxLength, ErrorMessage = ValidationConstants.MobileNumber_MaxLength_Msg)]
        public string MobileNo { get; set; }

        //[Required(ErrorMessage = ValidationConstants.EmailIdRequied_Msg)]
        //[RegularExpression(ValidationConstants.EmailRegExp, ErrorMessage = ValidationConstants.EmailRegExp_Msg)]
        [MaxLength(ValidationConstants.Email_MaxLength, ErrorMessage = ValidationConstants.Email_MaxLength_Msg)]
        public string EmailId { get; set; }

        //[Required(ErrorMessage = ValidationConstants.RefPartyNameRequired_Msg)]
        //[RegularExpression(ValidationConstants.CompanyNameRegExp, ErrorMessage = ValidationConstants.RefPartyNameRegExp_Msg)]
        [MaxLength(ValidationConstants.ReferenceParty_MaxLength, ErrorMessage = ValidationConstants.RefPartyName_MaxLength_Msg)]
        public string RefPartyName { get; set; }

        //[RegularExpression(ValidationConstants.ImageOrPdfFileRegExp, ErrorMessage = ValidationConstants.ImageOrPdfFileRegExp_Msg)]
        public string PanCardFileName { get; set; }
        public string PanCardSavedFileName { get; set; }

        [XmlIgnore]
        public IFormFile Pancard { get; set; }
        public string PanCardFileURL { get; set; }

        //[RegularExpression(ValidationConstants.ImageOrPdfFileRegExp, ErrorMessage = ValidationConstants.ImageOrPdfFileRegExp_Msg)]
        public string AdharCardFileName { get; set; }
        public string AdharCardSavedFileName { get; set; }

        [XmlIgnore]
        public IFormFile AdharCard { get; set; }

        public string AdharCardFileURL { get; set; }
        
        public bool IsActive { get; set; }
        public bool IsDefault { get; set; }
        public string PartyName { get; set; }
        public string RefPhoneNumber { get; set; }
        public string RefMobileNumber { get; set; }
        public string ModifierName { get; set; }
        public long? ModifiedBy { get; set; }
        public DateTime? ModifiedOn { get; set; }
    }

    public class AddressDetail
    {
        public long AddressId { get; set; }

        //[Required(ErrorMessage = ValidationConstants.AddressRequied_Msg)]
        //[MaxLength(ValidationConstants.Address_MaxLength, ErrorMessage = ValidationConstants.Address_MaxLength_Msg)]
        public string Address { get; set; }

        //[Range(1, long.MaxValue, ErrorMessage = ValidationConstants.StateRequied_Dropdown_Msg)]
        public long StateId { get; set; }
        public string StateName { get; set; }

        //[Range(1, long.MaxValue, ErrorMessage = ValidationConstants.ReportingToRequied_Dropdown_Msg)]
        public long RegionId { get; set; }
        public string RegionName { get; set; }

        //[Range(1, long.MaxValue, ErrorMessage = ValidationConstants.DistrictRequied_Dropdown_Msg)]
        public long DistrictId { get; set; }
        public string DistrictName { get; set; }

        //[Range(1, long.MaxValue, ErrorMessage = ValidationConstants.AreaRequied_Dropdown_Msg)]
        public long AreaId { get; set; }
        public string AreaName { get; set; }

        //[Required(ErrorMessage = ValidationConstants.PincodeRequied_Msg)]
        //[RegularExpression(ValidationConstants.PincodeExp, ErrorMessage = ValidationConstants.Pincode_Validation_Msg)]
        //[MaxLength(ValidationConstants.Pincode_MaxLength, ErrorMessage = ValidationConstants.Pincode_MaxLength_Msg)]
        //[MinLength(ValidationConstants.Pincode_MinLength, ErrorMessage = ValidationConstants.Pincode_MinLength_Msg)]
        public string Pincode { get; set; }

        public bool IsActive { get; set; }
        public bool IsDefault { get; set; }
        public string NameForAddress { get; set; }

        //[Required(ErrorMessage = ValidationConstants.MobileNumberRequied_Msg)]
        //[RegularExpression(ValidationConstants.MobileNumberRegExp, ErrorMessage = ValidationConstants.MobileNumberRegExp_Msg)]
        //[MaxLength(ValidationConstants.MobileNumber_MaxLength, ErrorMessage = ValidationConstants.MobileNumber_MaxLength_Msg)]
        public string MobileNo { get; set; }

        //[Required(ErrorMessage = ValidationConstants.EmailIdRequied_Msg)]
        //[RegularExpression(ValidationConstants.EmailRegExp, ErrorMessage = ValidationConstants.EmailRegExp_Msg)]
        //[MaxLength(ValidationConstants.Email_MaxLength, ErrorMessage = ValidationConstants.Email_MaxLength_Msg)]
        public string EmailId { get; set; }

        //[Range(1, long.MaxValue, ErrorMessage = ValidationConstants.AddressTypeRequied_Dropdown_Msg)]
        public long? AddressTypeId { get; set; }
        public string AddressType { get; set; } 
    }
    public class CustomerDataValidationErrors
    {
        public string CompanyName { get; set; }
        public string LandlineNo { get; set; }
        public string MobileNumber { get; set; }
        public string EmailId { get; set; }
        public string CustomerTypeName { get; set; }
        public string SpecialRemarks { get; set; }
        public string EmployeeName { get; set; }
        public string ContactName { get; set; }
        public string MobileNo { get; set; }
        public string EmailAddress { get; set; }
        public string RefPartyName { get; set; }
        public string Address { get; set; }
        public string StateName { get; set; }
        public string RegionName { get; set; }
        public string DistrictName { get; set; }
        public string AreaName { get; set; }
        public string Pincode { get; set; }
        public string NameForAddress { get; set; }
        public string BuyerMobileNo { get; set; }
        public string BuyerEmailId { get; set; }
        public string AddressTypeName { get; set; }
        public string IsActive { get; set; }
        public string ValidationMessage { get; set; }
    }
    public class ImportedCustomerDetails
    {
        public string CompanyName { get; set; }
        public string LandlineNo { get; set; }
        public string MobileNumber { get; set; }
        public string EmailId { get; set; }
        public string CustomerTypeName { get; set; }
        public string SpecialRemarks { get; set; }
        public string EmployeeName { get; set; }
        public string ContactName { get; set; }
        public string MobileNo { get; set; }
        public string EmailAddress { get; set; }
        public string RefPartyName { get; set; }
        public string Address { get; set; }
        public string StateName { get; set; }
        public string RegionName { get; set; }
        public string DistrictName { get; set; }
        public string AreaName { get; set; }
        public string Pincode { get; set; }
        public string NameForAddress { get; set; }
        public string BuyerMobileNo { get; set; }
        public string BuyerEmailId { get; set; }
        public string AddressTypeName { get; set; }
        public string IsActive { get; set; }
    }

    public class ContactSaveRequestParameters
    {
        public long ContactId { get; set; }

        [Range(1,long.MaxValue, ErrorMessage = "Customer Id is required")]
        public long CustomerId { get; set; }

        //[Required(ErrorMessage = "Contact Name is required")]
        [MaxLength(ValidationConstants.ContactName_MaxLength, ErrorMessage = ValidationConstants.ContactName_MaxLength_Msg)]
        public string ContactName { get; set; }
        
        //[Required(ErrorMessage = ValidationConstants.MobileNumberRequied_Msg)]
        [RegularExpression(ValidationConstants.MobileNumberRegExp, ErrorMessage = ValidationConstants.MobileNumberRegExp_Msg)]
        [MaxLength(ValidationConstants.MobileNumber_MaxLength, ErrorMessage = ValidationConstants.MobileNumber_MaxLength_Msg)]
        public string MobileNo { get; set; }
        
        //[Required(ErrorMessage = ValidationConstants.EmailIdRequied_Msg)]
        [RegularExpression(ValidationConstants.EmailRegExp, ErrorMessage = ValidationConstants.EmailRegExp_Msg)]
        [MaxLength(ValidationConstants.Email_MaxLength, ErrorMessage = ValidationConstants.Email_MaxLength_Msg)]
        public string EmailAddress { get; set; }
        public string RefPartyName { get; set; }

        [DefaultValue("")]
        public string PanCardSavedFileName { get; set; }

        [DefaultValue("")]
        public string  PanCardFileName { get; set; }

        [DefaultValue("")]
        public string PanCardFile_Base64 { get; set; }

        [DefaultValue("")]
        public string AdharCardSavedFileName { get; set; }

        [DefaultValue("")]
        public string AdharCardFileName { get; set; }

        [DefaultValue("")]
        public string AdharCardFile_Base64 { get; set; }

        public bool IsActive { get; set; }
        public bool IsDefault { get; set; }
    }

    public class AddressSaveRequestParameters
    {
        public long? AddressId { get; set; }
        public long? CustomerId { get; set; }
        public string? Address { get; set; }
        public string? AddressLineTwo { get; set; }
        public string? NameForAddress { get; set; }
        public string? MobileNo { get; set; }
        public string? EmailId { get; set; }
        public long? AddressTypeId { get; set; }
        public long? StateId { get; set; }
        public long? RegionId { get; set; }
        public long? DistrictId { get; set; }
        public long? AreaId { get; set; }
        public string? Pincode { get; set; }
        public bool IsActive { get; set; }
    }

    public class SearchContactAddressRequest
    {
        public PaginationParameters pagination { get; set; }
        public long? CustomerId { get; set; }

        [DefaultValue("")]
        public string SearchValue { get; set; }
        public Nullable<bool> IsActive { get; set; }
    }
}
