using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class FCMPushNotificationModel
    {
        public int? UserId { get; set; }
        public int? ActivityId { get; set; }
        public string RequestJson { get; set; }
        public string BaseAddress { get; set; }
        public string ResponseJson { get; set; }
        public bool? IsSent { get; set; }
    }
}
