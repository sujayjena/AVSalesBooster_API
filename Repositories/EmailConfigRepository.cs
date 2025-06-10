using Dapper;
using Helpers;
using Interfaces.Repositories;
using Microsoft.Extensions.Configuration;
using Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repositories
{
    public class EmailConfigRepository : BaseRepository, IEmailConfigRepository
    {
        private IConfiguration _configuration;

        public EmailConfigRepository(IConfiguration configuration) : base(configuration)
        {
            _configuration = configuration;
        }

        public async Task<int> SaveEmailConfig(EmailConfig_Request parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@Id", parameters.Id);
            queryParameters.Add("@SmtpServerName", parameters.SmtpServerName);
            queryParameters.Add("@SmtpServer", parameters.SmtpServer);
            queryParameters.Add("@SmtpUsername", parameters.SmtpUsername);
            queryParameters.Add("@SmtpPassword", parameters.SmtpPassword);
            queryParameters.Add("@SmtpUseDefaultCredentials", parameters.SmtpUseDefaultCredentials);
            queryParameters.Add("@SmtpEnableSSL", parameters.SmtpEnableSSL);
            queryParameters.Add("@SmtpTimeout", parameters.SmtpTimeout);
            queryParameters.Add("@FromAddress", parameters.FromAddress);
            queryParameters.Add("@EmailSenderName", parameters.EmailSenderName);
            queryParameters.Add("@EmailSenderCompanyLogo", parameters.EmailSenderCompanyLogo);
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@UserId", SessionManager.LoggedInUserId);

            return await SaveByStoredProcedure<int>("SaveEmailConfig", queryParameters);
        }

        public async Task<IEnumerable<EmailConfig_Response>> GetEmailConfigList(EmailConfig_Search parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@SearchText", parameters.SearchText.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@UserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<EmailConfig_Response>("GetEmailConfigList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");


            return result;
        }

        public async Task<EmailConfig_Response?> GetEmailConfigById(int Id)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@Id", Id);

            return (await ListByStoredProcedure<EmailConfig_Response>("GetEmailConfigById", queryParameters)).FirstOrDefault();
        }

        public async Task<int> SaveEmailNotification(EmailNotification_Request parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@Id", parameters.Id);
            queryParameters.Add("@Module", parameters.Module);
            queryParameters.Add("@Subject", parameters.Subject);
            queryParameters.Add("@SendTo", parameters.SendTo);
            queryParameters.Add("@Content", parameters.Content);
            queryParameters.Add("@EmailTo", parameters.EmailTo);
            queryParameters.Add("@RefValue1", parameters.RefValue1);
            queryParameters.Add("@RefValue2", parameters.RefValue2);
            queryParameters.Add("@IsSent", parameters.IsSent);
            queryParameters.Add("@UserId", SessionManager.LoggedInUserId);

            return await SaveByStoredProcedure<int>("SaveEmailNotification", queryParameters);
        }

        public async Task<EmailNotification_Response?> GetEmailNotificationById(int Id)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@Id", Id);

            return (await ListByStoredProcedure<EmailNotification_Response>("GetEmailNotificationById", queryParameters)).FirstOrDefault();
        }
    }
}
