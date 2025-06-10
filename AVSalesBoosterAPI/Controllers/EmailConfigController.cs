using Interfaces.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Models;
using Models.Enums;
using Nancy;
using Services;

namespace AVSalesBoosterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class EmailConfigController //: CustomBaseController
    {
        private ResponseModel _response;
        private IEmailConfigService _emailConfigService;

        public EmailConfigController(IEmailConfigService emailConfigService)
        {
            _emailConfigService = emailConfigService;

            _response = new ResponseModel();
            _response.IsSuccess = true;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveEmailConfig(EmailConfig_Request parameters)
        {
            int result = await _emailConfigService.SaveEmailConfig(parameters);

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Record already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.Message = "Record details saved successfully";
            }

            _response.Id = result;
            return _response;
        }


        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetEmailConfigList(EmailConfig_Search parameters)
        {
            IEnumerable<EmailConfig_Response> lstRoles = await _emailConfigService.GetEmailConfigList(parameters);
            _response.Data = lstRoles.ToList();
            _response.Total = parameters.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetEmailConfigById(int Id)
        {
            if (Id <= 0)
            {
                _response.Message = "Id is required";
            }
            else
            {
                var vResultObj = await _emailConfigService.GetEmailConfigById(Id);
                _response.Data = vResultObj;
            }
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveEmailNotification(EmailNotification_Request parameters)
        {
            int result = await _emailConfigService.SaveEmailNotification(parameters);

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Record already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.Message = "Record details saved successfully";
            }

            _response.Id = result;
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetEmailNotificationById(int Id)
        {
            if (Id <= 0)
            {
                _response.Message = "Id is required";
            }
            else
            {
                var vResultObj = await _emailConfigService.GetEmailNotificationById(Id);
                _response.Data = vResultObj;
            }
            return _response;
        }
    }
}
