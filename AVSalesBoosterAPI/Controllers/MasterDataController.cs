using Interfaces.Services;
using Microsoft.AspNetCore.Mvc;
using Models;
using Models.Constants;

namespace AVSalesBoosterAPI.Controllers
{
    public class MasterDataController : CustomBaseController
    {
        private ResponseModel _response;
        private IAdminService _adminService;

        public MasterDataController(IAdminService adminService)
        {
            _adminService = adminService;

            _response = new ResponseModel();
            _response.IsSuccess = true;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetStatesForSelectList(StatesSelectListRequestModel parameters)
        {
            IEnumerable<SelectListResponse> lstResponse = await _adminService.GetStatesForSelectList(parameters);
            _response.Data = lstResponse.ToList();
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetRegionForSelectList( RegionSelectListRequestModel parameters)
        {
            IEnumerable<SelectListResponse> lstResponse = await _adminService.GetRegionForSelectList(parameters);
            _response.Data = lstResponse.ToList();
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetDistrictForSelectList(DistrictSelectListRequestModel parameters)
        {
            IEnumerable<SelectListResponse> lstResponse = await _adminService.GetDistrictForSelectList(parameters);
            _response.Data = lstResponse.ToList();
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetAreaForSelectList(AreaSelectListRequestModel parameters)
        {
            IEnumerable<SelectListResponse> lstResponse = await _adminService.GetAreaForSelectList(parameters);
            _response.Data = lstResponse.ToList();
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetCustomerTypesForSelectList(CommonSelectListRequestModel parameters)
        {
            IEnumerable<SelectListResponse> lstResponse = await _adminService.GetCustomerTypesForSelectList(parameters);
            _response.Data = lstResponse.ToList();
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetCustomersForSelectList(CustomerSelectListRequestModel parameters)
        {
            IEnumerable<SelectListResponse> lstResponse = await _adminService.GetCustomersForSelectList(parameters);
            _response.Data = lstResponse.ToList();
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetStatusMasterForSelectList()
        {
            IEnumerable<SelectListResponse> lstResponse = await _adminService.GetStatusMasterForSelectList(StatusTypeCode.Common);
            _response.Data = lstResponse.ToList();
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetLeaveStatusListForSelectList()
        {
            IEnumerable<SelectListResponse> lstResponse = await _adminService.GetStatusMasterForSelectList(StatusTypeCode.LeaveTypes);
            _response.Data = lstResponse.ToList();
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetReportingToEmpListForSelectList(ReportingToEmpListParameters parameters)
        {
            IEnumerable<SelectListResponse> lstResponse = await _adminService.GetReportingToEmployeeForSelectList(parameters);
            _response.Data = lstResponse.ToList();
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetCustomerContactsListForFields(CustomerContactsListRequest parameters)
        {
            IEnumerable<CustomerContactsListForFields> lstResponse = await _adminService.GetCustomerContactsListForFields(parameters);
            _response.Data = lstResponse.ToList();
            return _response;
        }
    }
}
