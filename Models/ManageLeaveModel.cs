using Models.Constants;
using Newtonsoft.Json;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace Models
{
    public class LeaveTypeRequest
    {
        public long LeaveTypeId { get; set; }

        [Required(ErrorMessage = ValidationConstants.LeaveTypeNameRequied_Msg)]
        [RegularExpression(ValidationConstants.LeaveTypeNameRegExp, ErrorMessage = ValidationConstants.LeaveTypeNameRegExp_Msg)]
        [MaxLength(ValidationConstants.LeaveTypeName_MaxLength, ErrorMessage = ValidationConstants.LeaveTypeName_MaxLength_Msg)]
        public string LeaveTypeName { get; set; }
        public bool IsActive { get; set; }
    }

    public class LeaveTypeResponse : CreationDetails
    {
        public long LeaveTypeId { get; set; }
        public string LeaveTypeName { get; set; }
        public bool IsActive { get; set; }

    }

    public class LeaveRequest
    {
        public long LeaveId { get; set; }
        public DateTime StartDate { get; set; }

        public DateTime EndDate { get; set; }

        [Required(ErrorMessage = ValidationConstants.EmployeeNameRequied_Msg)]
        //[RegularExpression(ValidationConstants.EmployeeNameRegExp, ErrorMessage = ValidationConstants.EmployeeNameRegExp_Msg)]
        //[MaxLength(ValidationConstants.EmployeeName_MaxLength, ErrorMessage = ValidationConstants.EmployeeName_MaxLength_Msg)]
        public long EmployeeId { get; set; }

        [Range(1, long.MaxValue, ErrorMessage = ValidationConstants.LeaveRequied_Dropdown_Msg)]
        public long LeaveTypeId { get; set; }

        [Required(ErrorMessage = ValidationConstants.RemarkRequied_Msg)]
        [MaxLength(ValidationConstants.Remark_MaxLength, ErrorMessage = ValidationConstants.Remark_MaxLength_Msg)]
        public string Remark { get; set; }

        public bool IsActive { get; set; }

        [JsonIgnore]
        public int LeaveStatusId { get; set; }
    }

    public class UpdateLeaveStatusRequest
    {
        [Range(1, long.MaxValue, ErrorMessage = ValidationConstants.LeaveId_Required_Msg)]
        public long LeaveId { get; set; }

        [Range(1, long.MaxValue, ErrorMessage = ValidationConstants.LeaveStatus_Required_Msg)]
        public int LeaveStatusId { get; set; }

        [MaxLength(ValidationConstants.LeaveReason_MaxLength, ErrorMessage = ValidationConstants.LeaveReason_MaxLength_Msg)]
        public string Reason { get; set; }
    }

    public class LeaveResponse : CreationDetails
    {
        public long LeaveId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public long EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public long LeaveTypeId { get; set; }
        public string LeaveTypeName { get; set; }
        public string Remark { get; set; }
        public string Reason { get; set; }
        public bool IsActive { get; set; }
        public int StatusId { get; set; }
        public string StatusName { get; set; }
    }

    public class SearchLeaveTypeRequest
    {
        public PaginationParameters pagination { get; set; }
        public string LeaveTypeName { get; set; }
        public Nullable<bool> IsActive { get; set; }
    }
    public class LeaveTypeDataValidationErrors
    {
        public string LeaveTypeName { get; set; }
        public string IsActive { get; set; }
        public string ValidationMessage { get; set; }
    }
    public class ImportedLeaveTypeDetails
    {
        public string LeaveTypeName { get; set; }
        public string IsActive { get; set; }
    }

    public class SearchLeaveRequest
    {
        public PaginationParameters pagination { get; set; }

        [DefaultValue("")]
        public string SearchValue { get; set; }
        //public string EmployeeName { get; set; }
        public bool? IsActive { get; set; }
        //public string LeaveType { get; set; }
        //public string LeaveReason { get; set; }
        public int? LeaveStatusId { get; set; }

        [DefaultValue("")]
        public string StateId { get; set; }

        [DefaultValue("")]
        public string RegionId { get; set; }

        [DefaultValue("All")]
        public string FilterType { get; set; }

        public long? EmployeeId { get; set; }
    }

    //public bool ValidateDates()
    //{
    //    if (StartDate <= EndDate)
    //    {
    //        // Dates are not valid
    //        return false;
    //    }
    //    return true;
    //}
    public class LeaveApproveRejectHistory_Search
    {
        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;
        public int? LeaveId { get; set; }
        public PaginationParameters pagination { get; set; }

    }

    public class LeaveApproveRejectHistory_Response
    {
        public int Id { get; set; }
        public int LeaveId { get; set; }
        public string? Remarks { get; set; }
        public string? ApproveOrReject { get; set; }
        public string? CreatorName { get; set; }
        public long CreatedBy { get; set; }
        public DateTime? CreatedOn { get; set; }
    }
}
