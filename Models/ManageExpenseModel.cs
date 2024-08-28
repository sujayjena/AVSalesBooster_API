using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class ExpenseTypeRequest
    {
        public long ExpenseTypeId { get; set; }

        [DefaultValue("")]
        public string ExpenseTypeName { get; set; }
        public bool IsActive { get; set; }
    }

    public class ExpenseTypeResponse : CreationDetails
    {
        public long ExpenseTypeId { get; set; }
        public string ExpenseTypeName { get; set; }
        public dynamic IsActive { get; set; }

    }
    public class SearchExpenseTypeRequest
    {
        public PaginationParameters pagination { get; set; }

        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;
        public bool? IsActive { get; set; }
    }

    public class Expense_Search
    {
        public int? EmployeeId { get; set; }

        [DefaultValue("All")]
        public string FilterType { get; set; }

        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;
        public bool? IsActive { get; set; }

        public PaginationParameters pagination { get; set; }

    }

    public class Expense_Request
    {
        public Expense_Request()
        {
            ExpenseDetails = new List<ExpenseDetails_Request>();
        }

        public int Id { get; set; }

        [DefaultValue("")]
        public string ExpenseNumber { get; set; }
        public bool? WithoutVisit { get; set; }
        public int? VisitId { get; set; }
        public bool? IsActive { get; set; }
        public List<ExpenseDetails_Request> ExpenseDetails { get; set; }
    }

    public class Expense_Response
    {
        public Expense_Response()
        {
            ExpenseDetails = new List<ExpenseDetails_Response>();
        }

        public int? Id { get; set; }
        public string ExpenseNumber { get; set; }
        public bool WithoutVisit { get; set; }
        public int? VisitId { get; set; }
        public string VisitNo { get; set; }
        public bool IsActive { get; set; }
        public string CreatorName { get; set; }
        public long CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; }

        public List<ExpenseDetails_Response> ExpenseDetails { get; set; }
    }

    public class Expense_ApproveNReject
    {
        public int Id { get; set; }
        public int ExpenseId { get; set; }
        public int StatusId { get; set; }

        [DefaultValue("")]
        public string Remarks { get; set; }
    }


    public class ExpenseDetails_Search
    {
        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;
        public bool? IsActive { get; set; }
        public int? ExpenseId { get; set; }
        public int? StatusId { get; set; }
        public PaginationParameters pagination { get; set; }

    }

    public class ExpenseDetails_Request
    {
        public int? Id { get; set; }

        public int? ExpenseId { get; set; }

        public DateTime? ExpenseDate { get; set; }

        public int? ExpenseTypeId { get; set; }

        [DefaultValue("")]
        public string ExpenseDescription { get; set; }

        public decimal? ExpenseAmount { get; set; }

        [DefaultValue("")]
        public string ExpenseImageFileName { get; set; }

        [DefaultValue("")]
        public string ExpenseImageOriginalFileName { get; set; }

        [DefaultValue("")]
        public string ExpenseImageFile_Base64 { get; set; }

        public int? StatusId { get; set; }
    }

    public class ExpenseDetails_Response
    {
        public int Id { get; set; }
        public int? ExpenseId { get; set; }
        public string ExpenseNumber { get; set; }
        public DateTime? ExpenseDate { get; set; }
        public int? ExpenseTypeId { get; set; }
        public string ExpenseTypeName { get; set; }
        public string ExpenseDescription { get; set; }
        public decimal? ExpenseAmount { get; set; }
        public string ExpenseImageFileName { get; set; }
        public string ExpenseImageOriginalFileName { get; set; }
        public string ExpenseImageFileURL { get; set; }
        public int? StatusId { get; set; }
        public string StatusName { get; set; }
        public string Remarks { get; set; }
        public string CreatorName { get; set; }
        public long CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
    }

    public class ExpenseDetailsApproveRejectHistory_Search
    {
        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;
        public int? ExpenseDetailsId { get; set; }
        public PaginationParameters pagination { get; set; }

    }

    public class ExpenseDetailsApproveRejectHistory_Response
    {
        public int Id { get; set; }
        public int ExpenseDetailsId { get; set; }
        public string? Remarks { get; set; }
        public string? ApproveOrReject { get; set; }
        public string? CreatorName { get; set; }
        public long CreatedBy { get; set; }
        public DateTime? CreatedOn { get; set; }
    }
}
