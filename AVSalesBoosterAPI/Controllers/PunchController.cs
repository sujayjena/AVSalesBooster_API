using Helpers;
using Interfaces.Services;
using Microsoft.AspNetCore.Mvc;
using Models;
using OfficeOpenXml.Style;
using OfficeOpenXml;
using Services;
using System.Globalization;

namespace AVSalesBoosterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PunchController : CustomBaseController
    {
        private ResponseModel _response;
        private IProfileService _profileService;

        public PunchController(IProfileService profileService)
        {
            _profileService = profileService;

            _response = new ResponseModel();
            _response.IsSuccess = true;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> PunchIn(PunchInOutRequestModel parameters)
        {
            parameters.PunchType = "IN";
            PunchInOutHistoryModel? punchInOut = await _profileService.SubmitPunchInOut(parameters);

            if (punchInOut != null)
            {
                _response.Message = "Your Punch-in is done successfully";
                _response.Data = new 
                {
                    PunchInOut = punchInOut.PunchInOut
                };
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> PunchOut(PunchInOutRequestModel parameters)
        {
            parameters.PunchType = "OUT";
            PunchInOutHistoryModel? punchInOut = await _profileService.SubmitPunchInOut(parameters);

            if (punchInOut != null)
            {
                _response.Message = "Your Punch-out is done successfully";
                _response.Data = new
                {
                    PunchInOut = punchInOut.PunchInOut,
                };
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetPunchHistoryList(PunchHistoryRequestModel parameters)
        {
            IEnumerable<PunchInOutHistoryModel> punchHistory = await _profileService.GetPunchHistoryList(parameters);
            _response.Data = punchHistory.ToList();
            _response.Total = parameters.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ExportAttendanceData()
        {
            _response.IsSuccess = false;
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

            var request = new PunchHistoryRequestModel();
            request.pagination = new PaginationParameters();

            IEnumerable<PunchInOutHistoryModel> lstAttendanceObj = await _profileService.GetPunchHistoryList(request);

            using (MemoryStream msExportDataFile = new MemoryStream())
            {
                using (ExcelPackage excelExportData = new ExcelPackage())
                {
                    WorkSheet1 = excelExportData.Workbook.Worksheets.Add("Attendance");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "Employee Name";
                    WorkSheet1.Cells[1, 2].Value = "Date Time";
                    WorkSheet1.Cells[1, 3].Value = "Visit Status";
                    WorkSheet1.Cells[1, 4].Value = "Latitude";
                    WorkSheet1.Cells[1, 5].Value = "Longitude";
                    WorkSheet1.Cells[1, 6].Value = "Battery Status";
                    WorkSheet1.Cells[1, 7].Value = "Address";

                    recordIndex = 2;

                    foreach (var items in lstAttendanceObj)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = items.EmployeeName;
                        WorkSheet1.Cells[recordIndex, 2].Style.Numberformat.Format = DateTimeFormatInfo.CurrentInfo.ShortDatePattern;
                        WorkSheet1.Cells[recordIndex, 2].Value = items.PunchInOut;
                        WorkSheet1.Cells[recordIndex, 3].Value = items.PunchType;
                        WorkSheet1.Cells[recordIndex, 4].Value = items.Latitude;
                        WorkSheet1.Cells[recordIndex, 5].Value = items.Longitude;
                        WorkSheet1.Cells[recordIndex, 6].Value = items.BatteryStatus;
                        WorkSheet1.Cells[recordIndex, 7].Value = items.Address;
                       
                        recordIndex += 1;
                    }

                    WorkSheet1.Column(1).AutoFit();
                    WorkSheet1.Column(2).AutoFit();
                    WorkSheet1.Column(3).AutoFit();
                    WorkSheet1.Column(4).AutoFit();
                    WorkSheet1.Column(5).AutoFit();
                    WorkSheet1.Column(6).AutoFit();
                    WorkSheet1.Column(7).AutoFit();

                    excelExportData.SaveAs(msExportDataFile);
                    msExportDataFile.Position = 0;
                    result = msExportDataFile.ToArray();
                }
            }

            if (result != null)
            {
                _response.Data = result;
                _response.IsSuccess = true;
                _response.Message = "Attendance list Exported successfully";
            }

            return _response;
        }
    }
}
