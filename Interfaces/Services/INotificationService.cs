using Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Interfaces.Services
{
    public interface INotificationService
    {
        Task<IEnumerable<NotificationResponse>> GetNotificationList(SearchNotificationRequest request);
        Task<IEnumerable<NotificationResponse>> GetNotificationListById(long employeeId);
    }
}
