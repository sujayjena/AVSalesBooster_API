using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace Models
{
    public class VisitCustomerCountListResponse
    {
        public long VisitForDayCount { get; set; }
        public long VisitFollowUpCount { get; set; }
        public long VisitFollowUpCount_DataChart { get; set; }
        public long TodayFollowUpCount { get; set; }
        public long TotalCustomer { get; set; }
        public long TotalCustomerVisit_DataChart { get; set; }
        public long TotalNewVisitTillDateCount { get; set; }
        public long TotalClosedVisitCount { get; set; }
        public long TotalOnCallVisitCount { get; set; }
        public long TotalOnLocationVisitCount { get; set; }
    }
    public class SearchVisitCountListRequest
    {
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
        public long EmployeeId { get; set; }

        [DefaultValue("All")]
        public string FilterType { get; set; }
    }
    public class DayWiseVisitCountListResponse
    {
        public DateTime? VisitDate { get; set; }
        public long VisitCount { get; set; }
    }
}
