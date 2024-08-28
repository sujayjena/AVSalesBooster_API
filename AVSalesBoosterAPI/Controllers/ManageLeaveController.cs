using Interfaces.Services;
using Microsoft.AspNetCore.Mvc;
using Models;
using Models.Constants;
using Models.Enums;
using OfficeOpenXml;
using OfficeOpenXml.Style;
using Services;
using System.Globalization;

namespace AVSalesBoosterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ManageLeaveController : CustomBaseController
    {
        private ResponseModel _response;
        private ILeaveService _leaveService;

        public ManageLeaveController(ILeaveService leaveService)
        {
            _leaveService = leaveService;

            _response = new ResponseModel();
            _response.IsSuccess = true;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetLeavesList(SearchLeaveRequest request)
        {
            IEnumerable<LeaveResponse> lstRoles = await _leaveService.GetLeavesList(request);
            _response.Data = lstRoles.ToList();
            _response.Total = request.pagination.Total;

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveLeaveDetails(LeaveRequest parameter)
        {
            if (parameter.LeaveId == 0)
                parameter.LeaveStatusId = (int)LeaveStatusMaster.Pending;

            int result = await _leaveService.SaveLeaveDetails(parameter);
            _response.IsSuccess = false;

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Leave is already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.IsSuccess = true;
                _response.Message = "Leave details saved sucessfully";
            }
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> UpdateLeaveStatus(UpdateLeaveStatusRequest parameter)
        {
            long result = await _leaveService.UpdateLeaveStatus(parameter);

            if (result == (int)SaveEnums.NoResult)
            {
                _response.IsSuccess = false;
                _response.Message = "Leave record not found to update status";
            }
            else if (result > 0)
            {
                _response.IsSuccess = true;
                _response.Message = "Leave status updated sucessfully";
            }
            
            return _response;
        }

        [Route("[action]")]
        [HttpGet]
        public async Task<ResponseModel> GetLeaveDetails(long id)
        {
            LeaveResponse? leave;

            if (id <= 0)
            {
                _response.IsSuccess = false;
                _response.Message = ValidationConstants.Id_Required_Msg;
            }
            else
            {
                leave = await _leaveService.GetLeaveDetailsById(id);
                _response.Data = leave;
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ExportLeaveData()
        {
            _response.IsSuccess = false;
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

            var request = new SearchLeaveRequest();
            request.pagination = new PaginationParameters();

            IEnumerable<LeaveResponse> lstLeaveObj = await _leaveService.GetLeavesList(request);

            using (MemoryStream msExportDataFile = new MemoryStream())
            {
                using (ExcelPackage excelExportData = new ExcelPackage())
                {
                    WorkSheet1 = excelExportData.Workbook.Worksheets.Add("Leave");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "StartDate";
                    WorkSheet1.Cells[1, 2].Value = "EndDate";
                    WorkSheet1.Cells[1, 3].Value = "LeaveType";
                    WorkSheet1.Cells[1, 4].Value = "Remark";
                    WorkSheet1.Cells[1, 5].Value = "Status";
                    WorkSheet1.Cells[1, 6].Value = "EmployeeName";

                    WorkSheet1.Cells[1, 7].Value = "CreatedBy";
                    WorkSheet1.Cells[1, 8].Value = "CreatedDate";

                    recordIndex = 2;

                    foreach (var items in lstLeaveObj)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Style.Numberformat.Format = DateTimeFormatInfo.CurrentInfo.ShortDatePattern;
                        WorkSheet1.Cells[recordIndex, 1].Value = items.StartDate;
                        WorkSheet1.Cells[recordIndex, 2].Style.Numberformat.Format = DateTimeFormatInfo.CurrentInfo.ShortDatePattern;
                        WorkSheet1.Cells[recordIndex, 2].Value = items.EndDate;
                        WorkSheet1.Cells[recordIndex, 3].Value = items.LeaveTypeName;
                        WorkSheet1.Cells[recordIndex, 4].Value = items.Remark;
                        WorkSheet1.Cells[recordIndex, 5].Value = items.IsActive == true ? "Active" : "Inactive";
                        WorkSheet1.Cells[recordIndex, 6].Value = items.EmployeeName;

                        WorkSheet1.Cells[recordIndex, 7].Value = items.CreatorName;
                        WorkSheet1.Cells[recordIndex, 8].Style.Numberformat.Format = DateTimeFormatInfo.CurrentInfo.ShortDatePattern;
                        WorkSheet1.Cells[recordIndex, 8].Value = items.CreatedOn;

                        recordIndex += 1;
                    }

                    WorkSheet1.Column(1).AutoFit();
                    WorkSheet1.Column(2).AutoFit();
                    WorkSheet1.Column(3).AutoFit();
                    WorkSheet1.Column(4).AutoFit();
                    WorkSheet1.Column(5).AutoFit();
                    WorkSheet1.Column(6).AutoFit();
                    WorkSheet1.Column(7).AutoFit();
                    WorkSheet1.Column(8).AutoFit();

                    excelExportData.SaveAs(msExportDataFile);
                    msExportDataFile.Position = 0;
                    result = msExportDataFile.ToArray();
                }
            }

            if (result != null)
            {
                _response.Data = result;
                _response.IsSuccess = true;
                _response.Message = "Leave list Exported successfully";
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetLeaveApproveRejectHistoryList(LeaveApproveRejectHistory_Search parameters)
        {
            var objList = await _leaveService.GetLeaveApproveRejectHistoryList(parameters);
            _response.Data = objList.ToList();
            _response.Total = parameters.pagination.Total;
            return _response;
        }
    }
}
