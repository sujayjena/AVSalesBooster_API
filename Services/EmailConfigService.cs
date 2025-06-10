using Interfaces.Repositories;
using Interfaces.Services;
using Models;
using Nancy;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Services
{
    public class EmailConfigService : IEmailConfigService
    {
        private IEmailConfigRepository _emailConfigRepository;

        public EmailConfigService(IEmailConfigRepository EmailConfigRepository)
        {
            _emailConfigRepository = EmailConfigRepository;
        }

        public async Task<int> SaveEmailConfig(EmailConfig_Request parameters)
        {
            return await _emailConfigRepository.SaveEmailConfig(parameters);
        }

        public async Task<EmailConfig_Response?> GetEmailConfigById(int Id)
        {
            return await _emailConfigRepository.GetEmailConfigById(Id);
        }

        public async Task<IEnumerable<EmailConfig_Response>> GetEmailConfigList(EmailConfig_Search parameters)
        {
            return await _emailConfigRepository.GetEmailConfigList(parameters);
        }

        public async Task<int> SaveEmailNotification(EmailNotification_Request parameters)
        {
            return await _emailConfigRepository.SaveEmailNotification(parameters);
        }
        public async Task<EmailNotification_Response?> GetEmailNotificationById(int Id)
        {
            return await _emailConfigRepository.GetEmailNotificationById(Id);
        }
    }
}
