using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace Models
{
    public class SearchNotificationRequest
    {
        public DateTime? NotificationDate { get; set; }
        //public long? EmployeeId { get; set; }
        //public string EmployeeName { get; set; }
        //public long? VisitId { get; set; }
        public PaginationParameters pagination { get; set; }
    }

    public class NotificationResponse : CreationDetails
    {
        public long NotificationId { get; set; }
        public DateTime? NotificationDate { get; set; }
        public long EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public long VisitId { get; set; }
        public DateTime? NextActionDate { get; set; }
        public string VisitStatus { get; set; }
        public string Message { get; set; }
    }
}
