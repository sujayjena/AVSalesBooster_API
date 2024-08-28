using Microsoft.Extensions.Hosting;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Net;

namespace Models
{
    public class PunchInOutRequestModel
    {
        [NotMapped]
        public string PunchType { get; set; }
        public string Latitude { get; set; }
        public string Longitude { get; set; }
        public string BatteryStatus { get; set; }
        public string CurrentAddress { get; set; }
    }

    public class PunchHistoryRequestModel
    {
        public PaginationParameters pagination { get; set; }
        //public string EmployeeName { get; set; }

        [DefaultValue("")]
        public string SearchValue { get; set; }
        public DateTime? FromPunchInDate { get; set; }
        public DateTime? ToPunchInDate { get; set; }
    }

    public class PunchInOutHistoryModel
    {
        public long PunchId { get; set; }
        public long UserId { get; set; }
        public long EmployeeId { get; set; }
        public string EmployeeName { get; set; }

        public string PunchInOut { get; set; }
        public string PunchType { get; set; }
        public string Latitude { get; set; }
        public string Longitude { get; set; }
        public string BatteryStatus { get; set; }
        public string Address { get; set; }
        public string Remark { get; set; }
        public long CreatedBy { get; set; }
        public DateTime? CreatedOn { get; set; }
    }
}
