using Interfaces.Services;
using Microsoft.AspNetCore.Http;
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
    public class NotificationController : ControllerBase
    {
        private ResponseModel _response;
        private INotificationService _notificationService;

        public NotificationController(INotificationService notificationService)
        {
            _notificationService = notificationService;

            _response = new ResponseModel();
            _response.IsSuccess = true;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetNotificationList(SearchNotificationRequest request)
        {
            IEnumerable<NotificationResponse> lstNotification = await _notificationService.GetNotificationList(request);
            _response.Data = lstNotification.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetNotificationListById(long employeeId)
        {
            IEnumerable<NotificationResponse> lstNotification = await _notificationService.GetNotificationListById(employeeId);
            _response.Data = lstNotification.ToList();
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ExportNotificationData()
        {
            _response.IsSuccess = false;
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

            var request = new SearchNotificationRequest();
            request.pagination = new PaginationParameters();

            IEnumerable<NotificationResponse> lstNotificationObj = await _notificationService.GetNotificationList(request);

            using (MemoryStream msExportDataFile = new MemoryStream())
            {
                using (ExcelPackage excelExportData = new ExcelPackage())
                {
                    WorkSheet1 = excelExportData.Workbook.Worksheets.Add("Notification");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "NotificationDate";
                    WorkSheet1.Cells[1, 2].Value = "Notification";
                    WorkSheet1.Cells[1, 3].Value = "Status";
                    WorkSheet1.Cells[1, 4].Value = "NextActionDate";

                    WorkSheet1.Cells[1, 5].Value = "CreatedBy";
                    WorkSheet1.Cells[1, 6].Value = "CreatedDate";

                    recordIndex = 2;

                    foreach (var items in lstNotificationObj)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = items.NotificationDate;
                        WorkSheet1.Cells[recordIndex, 1].Style.Numberformat.Format = DateTimeFormatInfo.CurrentInfo.ShortDatePattern;
                        WorkSheet1.Cells[recordIndex, 2].Value = items.Message;
                        WorkSheet1.Cells[recordIndex, 3].Value = items.VisitStatus;
                        WorkSheet1.Cells[recordIndex, 4].Value = items.NextActionDate;
                        WorkSheet1.Cells[recordIndex, 4].Style.Numberformat.Format = DateTimeFormatInfo.CurrentInfo.ShortDatePattern;

                        WorkSheet1.Cells[recordIndex, 5].Value = items.CreatorName;
                        WorkSheet1.Cells[recordIndex, 6].Style.Numberformat.Format = DateTimeFormatInfo.CurrentInfo.ShortDatePattern;
                        WorkSheet1.Cells[recordIndex, 6].Value = items.CreatedOn;

                        recordIndex += 1;
                    }

                    WorkSheet1.Column(1).AutoFit();
                    WorkSheet1.Column(2).AutoFit();
                    WorkSheet1.Column(3).AutoFit();
                    WorkSheet1.Column(4).AutoFit();
                    WorkSheet1.Column(5).AutoFit();
                    WorkSheet1.Column(6).AutoFit();

                    excelExportData.SaveAs(msExportDataFile);
                    msExportDataFile.Position = 0;
                    result = msExportDataFile.ToArray();
                }
            }

            if (result != null)
            {
                _response.Data = result;
                _response.IsSuccess = true;
                _response.Message = "Notification list Exported successfully";
            }

            return _response;
        }
    }
}
