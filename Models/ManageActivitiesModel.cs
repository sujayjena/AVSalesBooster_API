using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace Models
{
    #region Single Activity

    public class SingleActivities_Search
    {
        public int? EmployeeId { get; set; }

        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;
        public bool? IsActive { get; set; }

        public PaginationParameters pagination { get; set; }

    }

    public class SingleActivities_Request
    {
        public SingleActivities_Request()
        {
            SingleActivitiesRemarks = new List<SingleActivitiesRemarks_Request>();
        }

        public int Id { get; set; }

        [DefaultValue("")]
        public string ActivityName { get; set; }
        public long? PriorityId { get; set; }
        public long? ActivityStatusId { get; set; }
        public long? EmployeeId { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }

        [DefaultValue("")]
        public string DocumentFileName { get; set; }

        [JsonIgnore]
        public string DocumentSavedFileName { get; set; }

        [DefaultValue("")]
        public string DocumentFile_Base64 { get; set; }

        public long? ActivityTypeId { get; set; }
        public bool? IsActive { get; set; }
        public List<SingleActivitiesRemarks_Request> SingleActivitiesRemarks { get; set; }
    }

    public class SingleActivities_Response
    {
        public SingleActivities_Response()
        {
            SingleActivitiesRemarks = new List<SingleActivitiesRemarks_Response>();
        }

        public int Id { get; set; }

        [DefaultValue("")]
        public string ActivityName { get; set; }
        public string SLAStatus { get; set; }
        public long? PriorityId { get; set; }
        public string? PriorityName { get; set; }
        public long? ActivityStatusId { get; set; }
        public string? ActivityStatusName { get; set; }
        public long? EmployeeId { get; set; }
        public string? EmployeeName { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string DocumentFileName { get; set; }
        public string DocumentSavedFileName { get; set; }
        public string DocumentFileURL { get; set; }
        public long? ActivityTypeId { get; set; }
        public string? ActivityTypeName { get; set; }
        public bool? IsActive { get; set; }
        public string CreatorName { get; set; }
        public long CreatedBy { get; set; }
        public DateTime CreatedOn { get; set; }
        public string ModifierName { get; set; }
        public long ModifiedBy { get; set; }
        public DateTime ModifiedOn { get; set; }

        public List<SingleActivitiesRemarks_Response> SingleActivitiesRemarks { get; set; }
    }

    public class SingleActivitiesRemarks_Request
    {
        public int? Id { get; set; }
        public int? SingleActivitiesId { get; set; }

        [DefaultValue("")]
        public string Remarks { get; set; }
    }

    public class SingleActivitiesRemarks_Search
    {
        public int? SingleActivitiesId { get; set; }

        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;
        public bool? IsActive { get; set; }

        public PaginationParameters pagination { get; set; }

    }

    public class SingleActivitiesRemarks_Response
    {
        public int Id { get; set; }
        public int? SingleActivitiesId { get; set; }
        public string Remarks { get; set; }
        public string CreatorName { get; set; }
        public long CreatedBy { get; set; }
        public DateTime CreatedOn { get; set; }
        public string ModifierName { get; set; }
        public long ModifiedBy { get; set; }
        public DateTime ModifiedOn { get; set; }
    }
    #endregion

    #region Multiple Activity

    public class ActivityTemplate_Search
    {
        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;
        public bool? IsActive { get; set; }

        public PaginationParameters pagination { get; set; }

    }

    public class ActivityTemplate_Request
    {
        public int Id { get; set; }

        [DefaultValue("")]
        public string ActivityTemplateName { get; set; }
        public long? ActivityStatusId { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public bool? IsActive { get; set; }
    }

    public class ActivityTemplate_Response
    {
        public int Id { get; set; }

        [DefaultValue("")]
        public string ActivityTemplateName { get; set; }
        public long? ActivityStatusId { get; set; }
        public string? ActivityStatusName { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public bool? IsActive { get; set; }
        public string CreatorName { get; set; }
        public long CreatedBy { get; set; }
        public DateTime CreatedOn { get; set; }
        public string ModifierName { get; set; }
        public long ModifiedBy { get; set; }
        public DateTime ModifiedOn { get; set; }
    }

    public class MultipleActivities_Search
    {
        public int? EmployeeId { get; set; }

        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;
        public bool? IsActive { get; set; }

        public PaginationParameters pagination { get; set; }

    }

    public class MultipleActivities_Request
    {
        public MultipleActivities_Request()
        {
            MultipleActivitiesRemarks = new List<MultipleActivitiesRemarks_Request>();
        }

        public int Id { get; set; }

        [DefaultValue("")]
        public string ActivityName { get; set; }
        public long? ActivityTemplateId { get; set; }
        public long? PriorityId { get; set; }
        public long? ActivityStatusId { get; set; }
        public long? EmployeeId { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }

        [DefaultValue("")]
        public string DocumentFileName { get; set; }

        [JsonIgnore]
        public string DocumentSavedFileName { get; set; }

        [DefaultValue("")]
        public string DocumentFile_Base64 { get; set; }

        public long? ActivityTypeId { get; set; }
        public bool? IsActive { get; set; }
        public List<MultipleActivitiesRemarks_Request> MultipleActivitiesRemarks { get; set; }
    }

    public class MultipleActivities_Response
    {
        public MultipleActivities_Response()
        {
            MultipleActivitiesRemarks = new List<MultipleActivitiesRemarks_Response>();
        }

        public int Id { get; set; }

        [DefaultValue("")]
        public string ActivityName { get; set; }
        public long? ActivityTemplateId { get; set; }
        public string ActivityTemplateName { get; set; }
        public string SLAStatus { get; set; }
        public long? PriorityId { get; set; }
        public string? PriorityName { get; set; }
        public long? ActivityStatusId { get; set; }
        public string? ActivityStatusName { get; set; }
        public long? EmployeeId { get; set; }
        public string? EmployeeName { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string DocumentFileName { get; set; }
        public string DocumentSavedFileName { get; set; }
        public string DocumentFileURL { get; set; }
        public long? ActivityTypeId { get; set; }
        public string? ActivityTypeName { get; set; }
        public bool? IsActive { get; set; }
        public string CreatorName { get; set; }
        public long CreatedBy { get; set; }
        public DateTime CreatedOn { get; set; }
        public string ModifierName { get; set; }
        public long ModifiedBy { get; set; }
        public DateTime ModifiedOn { get; set; }

        public List<MultipleActivitiesRemarks_Response> MultipleActivitiesRemarks { get; set; }
    }

    public class MultipleActivitiesRemarks_Request
    {
        public int? Id { get; set; }
        public int? MultipleActivitiesId { get; set; }

        [DefaultValue("")]
        public string Remarks { get; set; }
    }

    public class MultipleActivitiesRemarks_Search
    {
        public int? MultipleActivitiesId { get; set; }

        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;
        public bool? IsActive { get; set; }

        public PaginationParameters pagination { get; set; }

    }

    public class MultipleActivitiesRemarks_Response
    {
        public int Id { get; set; }
        public int? MultipleActivitiesId { get; set; }
        public string Remarks { get; set; }
        public string CreatorName { get; set; }
        public long CreatedBy { get; set; }
        public DateTime CreatedOn { get; set; }
        public string ModifierName { get; set; }
        public long ModifiedBy { get; set; }
        public DateTime ModifiedOn { get; set; }
    }

    #endregion
}
