using Helpers;
using Interfaces.Repositories;
using Interfaces.Services;
using Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Services
{
    public class NotificationService : INotificationService
    {
        private INotificationRepository _notificationRepository;

        public NotificationService(INotificationRepository notificationRepository)
        {
            _notificationRepository = notificationRepository;
        }
        public async Task<IEnumerable<NotificationResponse>> GetNotificationList(SearchNotificationRequest request)
        {
            return await _notificationRepository.GetNotificationList(request);
        }
        public async Task<IEnumerable<NotificationResponse>> GetNotificationListById(long employeeId)
        {
            return await _notificationRepository.GetNotificationListById(employeeId);
        }
    }
}
