using Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Interfaces.Repositories
{
    public interface IEmailConfigRepository
    {
        Task<int> SaveEmailConfig(EmailConfig_Request parameters);

        Task<IEnumerable<EmailConfig_Response>> GetEmailConfigList(EmailConfig_Search parameters);

        Task<EmailConfig_Response?> GetEmailConfigById(int Id);

        Task<int> SaveEmailNotification(EmailNotification_Request parameters);

        Task<EmailNotification_Response?> GetEmailNotificationById(int Id);
    }
}
