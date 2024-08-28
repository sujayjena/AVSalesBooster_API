using Helpers;
using Interfaces.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Models;
using Models.Constants;
using Models.Enums;
using Services;

namespace AVSalesBoosterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ServiceDetailsController : CustomBaseController
    {
        private ResponseModel _response;
        private IServiceDetailsService _serviceDetailsService;

        public ServiceDetailsController(IServiceDetailsService serviceDetailsService)
        {
            _serviceDetailsService = serviceDetailsService;

            _response = new ResponseModel();
            _response.IsSuccess = true;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveServiceDetails(ServiceDetailsRequest parameter)
        {
            int result = await _serviceDetailsService.SaveServiceDetails(parameter);
            _response.IsSuccess = false;

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Record is already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.IsSuccess = true;
                _response.Message = "Record saved sucessfully";
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetServiceDetailsList(SearchServiceDetailsRequest request)
        {
            IEnumerable<ServiceDetailsResponse> list = await _serviceDetailsService.GetServiceDetailsList(request);

            _response.Data = list.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpGet]
        public async Task<ResponseModel> GetServiceDetailsById(long id)
        {
            if (id <= 0)
            {
                _response.IsSuccess = false;
                _response.Message = ValidationConstants.Id_Required_Msg;
            }
            else
            {
                var list = await _serviceDetailsService.GetServiceDetailsById(id);

                _response.Data = list;
            }

            return _response;
        }
    }
}