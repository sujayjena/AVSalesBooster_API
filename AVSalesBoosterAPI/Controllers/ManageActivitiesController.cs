using Helpers;
using Interfaces.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Models;
using Models.Constants;
using Models.Enums;
using Services;

namespace AVSalesBoosterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ManageActivitiesController : CustomBaseController
    {
        private ResponseModel _response;
        private IManageActivitiesService _manageActivitiesService;
        private IFileManager _fileManager;

        public ManageActivitiesController(IManageActivitiesService manageActivitiesService, IFileManager fileManager)
        {
            _manageActivitiesService = manageActivitiesService;
            _fileManager = fileManager;

            _response = new ResponseModel();
            _response.IsSuccess = true;
        }

        #region Single Activity Status API

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveSingleActivities(SingleActivities_Request request)
        {
            //Image Upload
            if (!string.IsNullOrWhiteSpace(request.DocumentFile_Base64))
            {
                var vUploadFile = _fileManager.UploadDocumentsBase64ToFile(request.DocumentFile_Base64, "\\Uploads\\Activity\\", request.DocumentFileName);

                if (!string.IsNullOrWhiteSpace(vUploadFile))
                {
                    request.DocumentSavedFileName = vUploadFile;
                }
            }

            int result = await _manageActivitiesService.SaveSingleActivities(request);
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
                _response.Message = "Record details saved sucessfully";

                //Add / Update Remarks Details
                if (result > 0)
                {
                    foreach (var item in request.SingleActivitiesRemarks)
                    {
                        var vSingleActivitiesRemarks_Request = new SingleActivitiesRemarks_Request()
                        {
                            Id = item.Id,
                            SingleActivitiesId = result,
                            Remarks = item.Remarks
                        };

                        int resultExpenseDetails = await _manageActivitiesService.SaveSingleActivitiesRemarks(vSingleActivitiesRemarks_Request);
                    }
                }
            }
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetSingleActivitiesList(SingleActivities_Search request)
        {
            IEnumerable<SingleActivities_Response> lstSingleActivitiess = await _manageActivitiesService.GetSingleActivitiesList(request);
            _response.Data = lstSingleActivitiess.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetSingleActivitiesDetailsById(long id)
        {
            if (id <= 0)
            {
                _response.IsSuccess = false;
                _response.Message = ValidationConstants.Id_Required_Msg;
            }
            else
            {
                var vResultObj = await _manageActivitiesService.GetSingleActivitiesDetailsById(id);
                if (vResultObj != null)
                {
                    var serachObj = new SingleActivitiesRemarks_Search();
                    serachObj.SingleActivitiesId = vResultObj.Id;
                    serachObj.pagination = new PaginationParameters();

                    var vSingleActivitiesRemarksListObj = await _manageActivitiesService.GetSingleActivitiesRemarksList(serachObj);
                    vResultObj.SingleActivitiesRemarks = vSingleActivitiesRemarksListObj.ToList();
                }
                _response.Data = vResultObj;
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveSingleActivitiesRemarks(SingleActivitiesRemarks_Request request)
        {
            int result = await _manageActivitiesService.SaveSingleActivitiesRemarks(request);
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
                _response.Message = "Record details saved sucessfully";
            }
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetSingleActivitiesRemarksList(SingleActivitiesRemarks_Search request)
        {
            IEnumerable<SingleActivitiesRemarks_Response> lstSingleActivitiess = await _manageActivitiesService.GetSingleActivitiesRemarksList(request);
            _response.Data = lstSingleActivitiess.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }
        #endregion
    }
}
