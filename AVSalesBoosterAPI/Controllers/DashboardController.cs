using Interfaces.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Models;
using Services;

namespace AVSalesBoosterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DashboardController : CustomBaseController
    {
        private ResponseModel _response;
        private IDashboardService _dashboardService;

        public DashboardController(IDashboardService dashboardService)
        {
            _dashboardService = dashboardService;

            _response = new ResponseModel();
            _response.IsSuccess = true;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetVisitCustomerCountList(SearchVisitCountListRequest request)
        {
            IEnumerable<VisitCustomerCountListResponse> lstVisitCount = await _dashboardService.GetVisitCustomerCountList(request);
            _response.Data = lstVisitCount.ToList();
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetDayWiseVisitCountList(SearchVisitCountListRequest request)
        {
            IEnumerable<DayWiseVisitCountListResponse> lstVisitCount = await _dashboardService.GetDayWiseVisitCountList(request);
            _response.Data = lstVisitCount.ToList();
            return _response;
        }
    }
}
