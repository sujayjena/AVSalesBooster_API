using Interfaces.Services;
using Microsoft.AspNetCore.Mvc;
using Models;
using Models.Constants;
using Models.Enums;
using Nancy;
using OfficeOpenXml;
using OfficeOpenXml.Style;
using Services;
using System.Globalization;
using System.Text.RegularExpressions;

namespace AVSalesBoosterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ManageDesignController : CustomBaseController
    {
        private ResponseModel _response;
        private IManageDesignService _manageDesignService;

        public ManageDesignController(IManageDesignService manageDesignService)
        {
            _manageDesignService = manageDesignService;

            _response = new ResponseModel();
            _response.IsSuccess = true;
        }

        #region Design API
        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveDesignDetails([FromForm]DesignRequest parameter)
        {
            int result;
            List<ResponseModel> lstImageValidations = new List<ResponseModel>();
            Regex regex = new Regex(ValidationConstants.ImageFileRegExp);

            if (parameter.DesignImages != null)
            {
                foreach (var img in parameter.DesignImages)
                {
                    if (!regex.IsMatch(img.FileName))
                    {
                        lstImageValidations.Add(new ResponseModel()
                        {
                            Data = img.FileName
                        });
                    }
                }

                _response.IsSuccess = false;

                if (lstImageValidations.Count > 0)
                {
                    _response.Message = ErrorConstants.ValidationFailureError;
                    _response.Data = new { InvalidFilesOrFileNames = lstImageValidations.Select(v => v.Data).ToList() };

                    return _response;
                }
            }

            result = await _manageDesignService.SaveDesignDetails(parameter);

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Design is already exists for selected Size, Series and Design Name";
            }
            else if (result == (int)SaveEnums.CodeExists)
            {
                _response.Message = "Design Code is already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.IsSuccess = true;
                if (parameter.DesignId > 0)
                {
                    _response.Message = "Record updated successfully";
                }
                else
                {
                    _response.Message = "Design details saved successfully";
                }
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetDesignesList(SearchDesignRequest request)
        {
            IEnumerable<DesignResponse> lstDesigns = await _manageDesignService.GetDesignesList(request);
            _response.Data = lstDesigns.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpGet]
        public async Task<ResponseModel> GetDesignDetails(long id)
        {
            DesignResponse? customer;

            if (id <= 0)
            {
                _response.IsSuccess = false;
                _response.Message = ValidationConstants.Id_Required_Msg;
            }
            else
            {
                customer = await _manageDesignService.GetDesignDetailsById(id);
                _response.Data = customer;
            }

            return _response;
        }
        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ImportDesignsData([FromQuery] ImportRequest request)
        {
            _response.IsSuccess = false;
            List<string[]> data = new List<string[]>();
            ExcelWorksheets currentSheet;
            ExcelWorksheet workSheet;
            List<ImportedDesignDetails> lstImportedDesignDetails = new List<ImportedDesignDetails>();
            IEnumerable<DesignDataValidationErrors> lstDesignsFailedToImport;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
            int noOfCol, noOfRow;

            if (request.FileUpload == null || request.FileUpload.Length == 0)
            {
                _response.Message = "Please upload an excel file to import Design data";
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

                if (!string.Equals(workSheet.Cells[1, 1].Value.ToString(), "ProductName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 2].Value.ToString(), "BrandName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 3].Value.ToString(), "SizeName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 4].Value.ToString(), "CategoryName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 5].Value.ToString(), "SeriesName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 6].Value.ToString(), "DesignTypeName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 7].Value.ToString(), "BaseDesignName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 8].Value.ToString(), "DesignName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 9].Value.ToString(), "DesignCode", StringComparison.OrdinalIgnoreCase) ||
                   !string.Equals(workSheet.Cells[1, 10].Value.ToString(), "IsActive", StringComparison.OrdinalIgnoreCase))
                {
                    _response.IsSuccess = false;
                    _response.Message = "Please upload a valid excel file. Please Download Format file for reference";
                    return _response;
                }

                for (int rowIterator = 2; rowIterator <= noOfRow; rowIterator++)
                {
                    lstImportedDesignDetails.Add(new ImportedDesignDetails()
                    {
                        ProductName = workSheet.Cells[rowIterator, 1].Value?.ToString(),
                        BrandName = workSheet.Cells[rowIterator, 2].Value?.ToString(),
                        SizeName = workSheet.Cells[rowIterator, 3].Value?.ToString(),
                        CategoryName = workSheet.Cells[rowIterator, 4].Value?.ToString(),
                        SeriesName = workSheet.Cells[rowIterator, 5].Value?.ToString(),
                        DesignTypeName = workSheet.Cells[rowIterator, 6].Value?.ToString(),
                        BaseDesignName = workSheet.Cells[rowIterator, 7].Value?.ToString(),
                        DesignName = workSheet.Cells[rowIterator, 8].Value?.ToString(),
                        DesignCode = workSheet.Cells[rowIterator, 9].Value?.ToString(),
                        IsActive = workSheet.Cells[rowIterator, 10].Value?.ToString()
                    });
                }
            }

            if (lstImportedDesignDetails.Count == 0)
            {
                _response.Message = "File does not contains any record(s)";
                return _response;
            }

            lstDesignsFailedToImport = await _manageDesignService.ImportDesignsDetails(lstImportedDesignDetails);

            _response.IsSuccess = true;
            _response.Message = "Designs list imported successfully";

            #region Generate Excel file for Invalid Data
            if (lstDesignsFailedToImport.ToList().Count > 0)
            {
                _response.Message = "Uploaded file contains invalid records, please check downloaded file for more details";
                _response.Data = GenerateInvalidDesignDataFile(lstDesignsFailedToImport);

            }
            #endregion

            return _response;
        }

        private byte[] GenerateInvalidDesignDataFile(IEnumerable<DesignDataValidationErrors> lstDesignsFailedToImport)
        {
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;

            using (MemoryStream msInvalidDataFile = new MemoryStream())
            {
                using (ExcelPackage excelInvalidData = new ExcelPackage())
                {
                    WorkSheet1 = excelInvalidData.Workbook.Worksheets.Add("Invalid_Design_Records");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "ProductName";
                    WorkSheet1.Cells[1, 2].Value = "BrandName";
                    WorkSheet1.Cells[1, 3].Value = "SizeName";
                    WorkSheet1.Cells[1, 4].Value = "CategoryName";
                    WorkSheet1.Cells[1, 5].Value = "SeriesName";
                    WorkSheet1.Cells[1, 6].Value = "DesignTypeName";
                    WorkSheet1.Cells[1, 7].Value = "BaseDesignName";
                    WorkSheet1.Cells[1, 8].Value = "DesignName";
                    WorkSheet1.Cells[1, 9].Value = "DesignCode";
                    WorkSheet1.Cells[1, 10].Value = "IsActive";
                    WorkSheet1.Cells[1, 11].Value = "ValidationMessage";

                    recordIndex = 2;

                    foreach (DesignDataValidationErrors record in lstDesignsFailedToImport)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = record.ProductName;
                        WorkSheet1.Cells[recordIndex, 2].Value = record.BrandName;
                        WorkSheet1.Cells[recordIndex, 3].Value = record.SizeName;
                        WorkSheet1.Cells[recordIndex, 4].Value = record.CategoryName;
                        WorkSheet1.Cells[recordIndex, 5].Value = record.SeriesName;
                        WorkSheet1.Cells[recordIndex, 6].Value = record.DesignTypeName;
                        WorkSheet1.Cells[recordIndex, 7].Value = record.BaseDesignName;
                        WorkSheet1.Cells[recordIndex, 8].Value = record.DesignName;
                        WorkSheet1.Cells[recordIndex, 9].Value = record.DesignCode;
                        WorkSheet1.Cells[recordIndex, 10].Value = record.IsActive;
                        WorkSheet1.Cells[recordIndex, 11].Value = record.ValidationMessage;

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
                    WorkSheet1.Column(9).AutoFit();
                    WorkSheet1.Column(10).AutoFit();
                    WorkSheet1.Column(11).AutoFit();


                    excelInvalidData.SaveAs(msInvalidDataFile);
                    msInvalidDataFile.Position = 0;
                    result = msInvalidDataFile.ToArray();
                }
            }

            return result;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ExportDesignData()
        {
            _response.IsSuccess = false;
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

            var request = new SearchDesignRequest();
            request.pagination = new PaginationParameters();

            IEnumerable<DesignResponse> lstDesignObj = await _manageDesignService.GetDesignesList(request);

            using (MemoryStream msExportDataFile = new MemoryStream())
            {
                using (ExcelPackage excelExportData = new ExcelPackage())
                {
                    WorkSheet1 = excelExportData.Workbook.Worksheets.Add("Design");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "Collection";
                    WorkSheet1.Cells[1, 2].Value = "Size";
                    WorkSheet1.Cells[1, 3].Value = "Series";
                    WorkSheet1.Cells[1, 4].Value = "DesignName";
                    WorkSheet1.Cells[1, 5].Value = "Status";

                    WorkSheet1.Cells[1, 6].Value = "CreatedBy";
                    WorkSheet1.Cells[1, 7].Value = "CreatedDate";

                    recordIndex = 2;

                    foreach (var items in lstDesignObj)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = items.CollectionName;
                        WorkSheet1.Cells[recordIndex, 2].Value = items.SizeName;
                        WorkSheet1.Cells[recordIndex, 3].Value = items.SeriesName;
                        WorkSheet1.Cells[recordIndex, 4].Value = items.BaseDesignName;
                        WorkSheet1.Cells[recordIndex, 5].Value = items.IsActive == true ? "Active" : "Inactive";

                        WorkSheet1.Cells[recordIndex, 6].Value = items.CreatorName;
                        WorkSheet1.Cells[recordIndex, 7].Style.Numberformat.Format = DateTimeFormatInfo.CurrentInfo.ShortDatePattern;
                        WorkSheet1.Cells[recordIndex, 7].Value = items.CreatedOn;

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
                _response.Message = "Design Master list Exported successfully";
            }

            return _response;
        }
        #endregion
    }
}
