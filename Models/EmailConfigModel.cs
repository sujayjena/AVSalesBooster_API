using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class EmailConfig_Search  
    {
        [DefaultValue("")]
        public string SearchText { get; set; } = null;

        [DefaultValue(null)]
        public bool? IsActive { get; set; }

        public PaginationParameters pagination { get; set; }
    }

    public class EmailConfig_Request 
    {
        public int Id { get; set; }
        public string SmtpServerName { get; set; }
        public string SmtpServer { get; set; }
        public string SmtpUsername { get; set; }
        public string SmtpPassword { get; set; }
        public bool? SmtpUseDefaultCredentials { get; set; }
        public bool? SmtpEnableSSL { get; set; }
        public int? SmtpPort { get; set; }
        public int? SmtpTimeout { get; set; }
        public string FromAddress { get; set; }
        public string EmailSenderName { get; set; }
        public string EmailSenderCompanyLogo { get; set; }
        public bool? IsActive { get; set; }
    }

    public class EmailConfig_Response 
    {
        public int Id { get; set; }
        public string SmtpServerName { get; set; }
        public string SmtpServer { get; set; }
        public string SmtpUsername { get; set; }
        public string SmtpPassword { get; set; }
        public bool? SmtpUseDefaultCredentials { get; set; }
        public bool? SmtpEnableSSL { get; set; }
        public int? SmtpPort { get; set; }
        public int? SmtpTimeout { get; set; }
        public string FromAddress { get; set; }
        public string EmailSenderName { get; set; }
        public string EmailSenderCompanyLogo { get; set; }
        public bool? IsActive { get; set; }

        public string CreatorName { get; set; }
        public long CreatedBy { get; set; }
        public DateTime? CreatedDate { get; set; }

        public string ModifierName { get; set; }
        public long ModifiedBy { get; set; }

        [DefaultValue(null)]
        public DateTime? ModifiedDate { get; set; }
    }


    public class EmailNotification_Request 
    {
        public int Id { get; set; }
        public string Module { get; set; }
        public string Subject { get; set; }
        public string SendTo { get; set; }
        public string Content { get; set; }
        public string EmailTo { get; set; }
        public string RefValue1 { get; set; }
        public string RefValue2 { get; set; }

        [Required]
        [DefaultValue(false)]
        public bool IsSent { get; set; }
    }

    public class EmailNotification_Response
    {
        public int Id { get; set; }
        public string Module { get; set; }
        public string Subject { get; set; }
        public string SendTo { get; set; }
        public string Content { get; set; }
        public string EmailTo { get; set; }
        public string RefValue1 { get; set; }
        public string RefValue2 { get; set; }

        [DefaultValue(false)]
        public bool IsSent { get; set; }

        public string CreatorName { get; set; }
        public long CreatedBy { get; set; }
        public DateTime? CreatedDate { get; set; }

        public string ModifierName { get; set; }
        public long ModifiedBy { get; set; }

        [DefaultValue(null)]
        public DateTime? ModifiedDate { get; set; }
    }
}
