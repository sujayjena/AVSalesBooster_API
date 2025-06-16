using Helpers;
using Interfaces.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Models;
using Models.Constants;
using Models.Enums;
using OfficeOpenXml.Style;
using OfficeOpenXml;
using Services;
using System.Globalization;

namespace AVSalesBoosterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ServiceDetailsController : CustomBaseController
    {
        private ResponseModel _response;
        private IServiceDetailsService _serviceDetailsService;
        private readonly IFileManager _fileManager;

        public ServiceDetailsController(IServiceDetailsService serviceDetailsService, IFileManager fileManager)
        {
            _serviceDetailsService = serviceDetailsService;
            _fileManager = fileManager;

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
                _response.Message = "Record saved successfully";
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

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> DownloadServiceDetailsTemplate()
        {
            byte[]? formatFile = await Task.Run(() => _fileManager.GetFormatFileFromPath("Template_ServiceDetails.xlsx"));

            if (formatFile != null)
            {
                _response.Data = formatFile;
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ImportServiceDetailsData([FromQuery] ImportRequest request)
        {
            _response.IsSuccess = false;
            List<string[]> data = new List<string[]>();
            ExcelWorksheets currentSheet;
            ExcelWorksheet workSheet;
            List<ImportedServiceDetails> lstImported = new List<ImportedServiceDetails>();
            IEnumerable<ServiceDetailsDataValidationErrors> lstFailedToImport;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
            int noOfCol, noOfRow;

            if (request.FileUpload == null || request.FileUpload.Length == 0)
            {
                _response.Message = "Please upload an excel file to import Role data";
                return _response;
            }

            using (MemoryStream stream = new MemoryStream())
            {
                request.FileUpload.CopyTo(stream);
                using ExcelPackage package = new ExcelPackage(stream);
                currentSheet = package.Workbook.Worksheets;
                workSheet = currentSheet.First();
                noOfCol = workSheet.Dimension.End.Column;
                noOfRow = workSheet.Dimension.End.Row;

                if (!string.Equals(workSheet.Cells[1, 1].Value.ToString(), "ServiceName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 2].Value.ToString(), "ServiceDesc", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 3].Value.ToString(), "YoutubeLink", StringComparison.OrdinalIgnoreCase) ||
                   !string.Equals(workSheet.Cells[1, 4].Value.ToString(), "IsActive", StringComparison.OrdinalIgnoreCase))
                {
                    _response.IsSuccess = false;
                    _response.Message = "Please upload a valid excel file. Please Download Format file for reference";
                    return _response;
                }

                for (int rowIterator = 2; rowIterator <= noOfRow; rowIterator++)
                {
                    lstImported.Add(new ImportedServiceDetails()
                    {
                        ServiceName = workSheet.Cells[rowIterator, 1].Value?.ToString(),
                        ServiceDesc = workSheet.Cells[rowIterator, 2].Value?.ToString(),
                        YoutubeLink = workSheet.Cells[rowIterator, 3].Value?.ToString(),
                        IsActive = workSheet.Cells[rowIterator, 4].Value?.ToString()
                    });
                }
            }

            if (lstImported.Count == 0)
            {
                _response.Message = "File does not contains any record(s)";
                return _response;
            }

            lstFailedToImport = await _serviceDetailsService.ImportServiceDetails(lstImported);

            _response.IsSuccess = true;
            _response.Message = "Record imported successfully";

            #region Generate Excel file for Invalid Data
            if (lstFailedToImport.ToList().Count > 0)
            {
                _response.Message = "Uploaded file contains invalid records, please check downloaded file for more details";
                _response.Data = GenerateInvalidServiceDetailsDataFile(lstFailedToImport);

            }
            #endregion

            return _response;
        }

        private byte[] GenerateInvalidServiceDetailsDataFile(IEnumerable<ServiceDetailsDataValidationErrors> lstFailedToImport)
        {
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;

            using (MemoryStream msInvalidDataFile = new MemoryStream())
            {
                using (ExcelPackage excelInvalidData = new ExcelPackage())
                {
                    WorkSheet1 = excelInvalidData.Workbook.Worksheets.Add("Invalid_ServiceDetails_Records");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "ServiceName";
                    WorkSheet1.Cells[1, 2].Value = "ServiceDesc";
                    WorkSheet1.Cells[1, 3].Value = "YoutubeLink";
                    WorkSheet1.Cells[1, 4].Value = "IsActive";
                    WorkSheet1.Cells[1, 5].Value = "ValidationMessage";

                    recordIndex = 2;

                    foreach (ServiceDetailsDataValidationErrors record in lstFailedToImport)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = record.ServiceName;
                        WorkSheet1.Cells[recordIndex, 2].Value = record.ServiceDesc;
                        WorkSheet1.Cells[recordIndex, 3].Value = record.YoutubeLink;
                        WorkSheet1.Cells[recordIndex, 4].Value = record.IsActive;
                        WorkSheet1.Cells[recordIndex, 5].Value = record.ValidationMessage;

                        recordIndex += 1;
                    }

                    WorkSheet1.Column(1).AutoFit();
                    WorkSheet1.Column(2).AutoFit();
                    WorkSheet1.Column(3).AutoFit();
                    WorkSheet1.Column(4).AutoFit();
                    WorkSheet1.Column(5).AutoFit();

                    excelInvalidData.SaveAs(msInvalidDataFile);
                    msInvalidDataFile.Position = 0;
                    result = msInvalidDataFile.ToArray();
                }
            }

            return result;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ExportServiceDetailsData()
        {
            _response.IsSuccess = false;
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

            var request = new SearchServiceDetailsRequest();
            request.pagination = new PaginationParameters();

            IEnumerable<ServiceDetailsResponse> lstObj = await _serviceDetailsService.GetServiceDetailsList(request);

            using (MemoryStream msExportDataFile = new MemoryStream())
            {
                using (ExcelPackage excelExportData = new ExcelPackage())
                {
                    WorkSheet1 = excelExportData.Workbook.Worksheets.Add("ServiceDetails");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "Service Name";
                    WorkSheet1.Cells[1, 2].Value = "Service Desc";
                    WorkSheet1.Cells[1, 3].Value = "Youtube Link";
                    WorkSheet1.Cells[1, 4].Value = "Status";

                    WorkSheet1.Cells[1, 5].Value = "CreatedBy";
                    WorkSheet1.Cells[1, 6].Value = "CreatedDate";

                    recordIndex = 2;

                    foreach (var items in lstObj)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = items.ServiceName;
                        WorkSheet1.Cells[recordIndex, 2].Value = items.ServiceDesc;
                        WorkSheet1.Cells[recordIndex, 3].Value = items.YoutubeLink;
                        WorkSheet1.Cells[recordIndex, 4].Value = items.IsActive == true ? "Active" : "Inactive";

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
                _response.Message = "Record Exported successfully";
            }

            return _response;
        }
    }
}