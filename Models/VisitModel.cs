using Microsoft.AspNetCore.Http;
using Models.Constants;
using Newtonsoft.Json;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Xml.Serialization;

namespace Models
{
    public class VisitsRequest
    {
        public long VisitId { get; set; }

        //[Range(1, long.MaxValue, ErrorMessage = ValidationConstants.EmployeeNameRequied_Msg)]
        public long EmployeeId { get; set; }

        public DateTime VisitDate { get; set; }

        public bool HasVisited { get; set; }

        public long CustomerTypeId { get; set; }

        //[Range(1, long.MaxValue, ErrorMessage = ValidationConstants.CustomerNameRequired_Msg)]
        public long CustomerId { get; set; }


        //[Range(1, long.MaxValue, ErrorMessage = "Contact is required")]
        public long ContactId { get; set; }


        //[Range(1, long.MaxValue, ErrorMessage = ValidationConstants.StateRequied_Dropdown_Msg)]
        public long StateId { get; set; }

        //[Range(1, long.MaxValue, ErrorMessage = ValidationConstants.ReportingToRequied_Dropdown_Msg)]
        public long RegionId { get; set; }

        //[Range(1, long.MaxValue, ErrorMessage = ValidationConstants.DistrictRequied_Dropdown_Msg)]
        public long DistrictId { get; set; }

        //[Range(1, long.MaxValue, ErrorMessage = ValidationConstants.AreaRequied_Dropdown_Msg)]
        public long AreaId { get; set; }

        public long AddressId { get; set; }
        //[Required(ErrorMessage = ValidationConstants.AddressRequied_Msg)]
        //[MaxLength(ValidationConstants.Address_MaxLength, ErrorMessage = ValidationConstants.Address_MaxLength_Msg)]
        public string Address { get; set; }

        //public string ContactPerson { get; set; }

        //public string ContactNumber { get; set; }

        //[Required(ErrorMessage = ValidationConstants.EmailIdRequied_Msg)]
        //[RegularExpression(ValidationConstants.EmailRegExp, ErrorMessage = ValidationConstants.EmailRegExp_Msg)]
        //[MaxLength(ValidationConstants.Email_MaxLength, ErrorMessage = ValidationConstants.Email_MaxLength_Msg)]
        //public string EmailId { get; set; }

        public DateTime? NextActionDate { get; set; }

        public List<VisitRemarks> Remarks { get; set; }

        public bool IsActive { get; set; }

        //[Range(1, long.MaxValue, ErrorMessage = ValidationConstants.VisitStatus_Required_Msg)]
        public int VisitStatusId { get; set; }

        public int VisitTypeId { get; set; }

        //[JsonIgnore]
        //public IFormFile[] VisitPhotos { get; set; }

        public List<VisitPhotosRequest> VisitPhotosList { get;set; }

        public bool IsToCreateNewVisit { get; set; }

        [JsonIgnore]
        public long? BaseVisitId { get; set; }

        //public int[] IdOfFilesToBeDelete { get; set; }
    }

    public class SearchVisitRequest
    {
        //public string VisitNo { get; set; }
        public long? EmployeeId { get; set; }
        public long? CustomerId { get; set; }
        //public string EmployeeName { get; set; }
        //public string CustomerType { get; set; }
        //public string CustomerName { get; set; }
        //public string ContactPersonName { get; set; }
        //public string ContactPersonNumber { get; set; }
        //public string AreaName { get; set; }
        //public string Address { get; set; }

        [DefaultValue("")]
        public string SearchValue { get; set; }
        public DateTime? FromVisitDate { get; set; }
        public DateTime? ToVisitDate { get; set; }
        public int? VisitStatusId { get; set; }
        public Nullable<bool> IsActive { get; set; }

        [DefaultValue("All")]
        public string FilterType { get; set; }
        public PaginationParameters pagination { get; set; }
    }

    public class VisitsResponse
    {
        public long VisitId { get; set; }
        public string VisitNo { get; set; }
        public long EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public string EmployeeRole { get; set; }
        public DateTime? VisitDate { get; set; }
        public long CustomerId { get; set; }
        public long CustomerTypeId { get; set; }
        public long StateId { get; set; }
        public string StateName { get; set; }
        public long RegionId { get; set; }
        public string RegionName { get; set; }
        public long DistrictId { get; set; }
        public string DistrictName { get; set; }
        public long AreaId { get; set; }
        public string AreaName { get; set; }
        public long AddressId { get; set; }
        public string Address { get; set; }
        public string Pincode { get; set; }
        public long ContactId { get; set; }
        public string ContactPerson { get; set; }
        public string ContactNumber { get; set; }
        public DateTime? NextActionDate { get; set; }
        public bool IsActive { get; set; }
        public int VisitStatusId { get; set; }
        public string StatusName { get; set; }
        public int VisitTypeId { get; set; }
        public string VisitTypeName { get; set; }
        public string CustomerName { get; set; }
        public string CustomerTypeName { get; set; }
        public string CreatorName { get; set; }
        public long CreatedBy { get; set; }
        public DateTime CreatedOn { get; set; }

        [NotMapped]
        public List<VisitRemarks> Remarks { get; set; }
        [NotMapped]
        public List<VisitPhotosResponse> VisitPhotosList { get; set; }
    }
    
    public class VisitRemarks
    {
        public long VisitRemarkId { get; set; }

        //[MaxLength(ValidationConstants.Remark_MaxLength, ErrorMessage = ValidationConstants.Remark_MaxLength_Msg)]
        public string Remarks { get; set; }
    }

    public class VisitDetailsResponse
    {
        public long VisitId { get; set; }
        public string VisitNo { get; set; }
        public DateTime? VisitDate { get; set; }
        public long? EmployeeRoleId { get; set; }
        public string RoleName { get; set; }
        public long CustomerId { get; set; }
        public long? EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public string EmailId { get; set; }
        public long? CustomerTypeId { get; set; }
        public string CustomerName { get; set; }
        public string CustomerTypeName { get; set; }
        public long StateId { get; set; }
        public string StateName { get; set; }
        public long RegionId { get; set; }
        public string RegionName { get; set; }
        public long DistrictId { get; set; }
        public string DistrictName { get; set; }
        public long AreaId { get; set; }
        public string AreaName { get; set; }
        public DateTime? NextActionDate { get; set; }
        public long AddressId { get; set; }
        public string Address { get; set; }
        public bool IsActive { get; set; }
        public int VisitStatusId { get; set; }
        public string StatusName { get; set; }

        public int ContactId { get; set; }
        public string ContactPerson { get; set; }
        public string ContactNumber { get; set; }

        public int VisitTypeId { get; set; }
        public string VisitTypeName { get; set; }

        public DateTime CreatedOn { get; set; }
        public DateTime? ModifiedOn { get; set; }
        public List<VisitRemarks> Remarks { get; set; }
        public List<VisitPhotosResponse> VisitPhotosList { get; set; }
    }

    public class ImportedVisitDetails
    {
        public DateTime? VisitDate { get; set; }
        public string RoleName { get; set; }
        public string EmployeeName { get; set; }
        public string CustomerTypeName { get; set; }
        public string CustomerName { get; set; }
        public string StateName { get; set; }
        public string RegionName { get; set; }
        public string DistrictName { get; set; }
        public string AreaName { get; set; }
        public string ContactPerson { get; set; }
        public string ContactNumber { get; set; }
        public string EmailId { get; set; }
        public DateTime? NextActionDate { get; set; }
        public decimal? Latitude { get; set; }
        public decimal? Longitude { get; set; }
        public string Address { get; set; }
        public string Remarks { get; set; }

        //public List<VisitRemarks> Remarks { get; set; }
        public string IsActive { get; set; }
    }

    public class VisitDataValidationErrors
    {
        public DateTime? VisitDate { get; set; }
        public string EmployeeName { get; set; }
        public long? CustomerTypeName { get; set; }
        public string CustomerName { get; set; }
        public string StateName { get; set; }
        public string RegionName { get; set; }
        public string DistrictName { get; set; }
        public string AreaName { get; set; }
        public string ContactPerson { get; set; }
        public string ContactNumber { get; set; }
        public string EmailId { get; set; }
        public DateTime? NextActionDate { get; set; }
        public decimal? Latitude { get; set; }
        public decimal? Longitude { get; set; }
        public string Address { get; set; }
        //public List<VisitRemarks> Remarks { get; set; }
        public string Remarks { get; set; }
        public string IsActive { get; set; }
        public string ValidationMessage { get; set; }
    }

    public class VisitPhotosRequest
    {
        public long VisitPhotoId { get; set; }

        //[Required(ErrorMessage = ValidationConstants.Latitude_Required_Msg)]
        //[MaxLength(ValidationConstants.Latitude_MaxLength, ErrorMessage = ValidationConstants.Latitude_MaxLength_Msg)]
        public string Latitude { get; set; }

        //[Required(ErrorMessage = ValidationConstants.Longitude_Required_Msg)]
        //[MaxLength(ValidationConstants.Longitude_MaxLength, ErrorMessage = ValidationConstants.Longitude_MaxLength_Msg)]
        public string Longitude { get; set; }

        //[Required(ErrorMessage = ValidationConstants.VisitAddress_Required_Msg)]
        //[MaxLength(ValidationConstants.Address_MaxLength, ErrorMessage = ValidationConstants.VisitAddress_MaxLength_Msg)]
        public string VisitAddress { get; set; }

        //[Required(ErrorMessage = "Visit Date Time value is required")]
        public DateTime? VisitDateTime { get; set; }

        //[RegularExpression(ValidationConstants.ImageFileRegExp, ErrorMessage = ValidationConstants.ImageFileRegExp_Msg)]
        public string UploadedFileName { get; set; }

        public string SavedFileName { get; set; }

        [JsonIgnore, XmlIgnore]
        public IFormFile Photo { get; set; }
    }

    public class VisitPhotosResponse : VisitPhotosRequest
    {
        //public byte[] FileContent { get; set; }
        public string FileContent { get; set; }
    }

    public class SearchVisitLogHistoryRequest
    {
        public int? VisitId { get; set; }
        public PaginationParameters pagination { get; set; }
    }

    public class VisitLogHistoryResponse
    {
        public long VisitLogHistoryId { get; set; }
        public long VisitId { get; set; }
        public string VisitNo { get; set; }
        public long VisitTypeId { get; set; }
        public string VisitTypeName { get; set; }
        public long VisitStatusId { get; set; }
        public string StatusName { get; set; }
        public string Remarks { get; set; }
        public DateTime? NextActionDate { get; set; }
        public string CreatorName { get; set; }
        public long CreatedBy { get; set; }
        public DateTime CreatedOn { get; set; }
    }
}
