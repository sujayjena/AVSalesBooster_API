using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class tblUserModel
    {
        public long UserId { get; set; }
        public string EmailId { get; set; }
        public string MobileNo { get; set; }
        public long? EmployeeId { get; set; }
        public bool IsActive { get; set; }
        public string FCMTokenId { get; set; }
    }
}
