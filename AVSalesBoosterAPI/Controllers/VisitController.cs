using Helpers;
using Interfaces.Services;
using Microsoft.AspNetCore.Mvc;
using Models;
using Models.Constants;
using Models.Enums;
using Nancy;
using OfficeOpenXml;
using OfficeOpenXml.Style;
using System.Collections.Generic;
using System.Globalization;
using System.Text.RegularExpressions;

namespace AVSalesBoosterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class VisitController : CustomBaseController
    {
        private ResponseModel _response;
        private IVisitService _visitsService;

        public VisitController(IVisitService visitsService)
        {
            _visitsService = visitsService;

            _response = new ResponseModel();
            _response.IsSuccess = true;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetVisitsList(SearchVisitRequest request)
        {
            var host = $"{this.Request.Scheme}://{this.Request.Host}{this.Request.PathBase}";
            IEnumerable<VisitsResponse> lstVisits = await _visitsService.GetVisitsList(request);

            var vlstVisits = new List<VisitsResponse>();
            foreach (var list in lstVisits)
            {
                vlstVisits.Add(new VisitsResponse
                {
                    VisitId = list.VisitId,
                    VisitNo = list.VisitNo,
                    EmployeeId = list.EmployeeId,
                    EmployeeName = list.EmployeeName,
                    EmployeeRole = list.EmployeeRole,
                    VisitDate = list.VisitDate,
                    CustomerId = list.CustomerId,
                    CustomerTypeId = list.CustomerTypeId,
                    StateId = list.StateId,
                    StateName = list.StateName,
                    RegionId = list.RegionId,
                    RegionName = list.RegionName,
                    DistrictId = list.DistrictId,
                    DistrictName = list.DistrictName,
                    AreaId = list.AreaId,
                    AreaName = list.AreaName,
                    AddressId = list.AddressId,
                    Address = list.Address,
                    Pincode = list.Pincode,
                    ContactId = list.ContactId,
                    ContactPerson = list.ContactPerson,
                    ContactNumber = list.ContactNumber,
                    NextActionDate = list.NextActionDate,
                    IsActive = list.IsActive,
                    VisitStatusId = list.VisitStatusId,
                    StatusName = list.StatusName,
                    CustomerName = list.CustomerName,
                    CustomerTypeName = list.CustomerTypeName,
                    VisitTypeId = list.VisitTypeId,
                    VisitTypeName = list.VisitTypeName,
                    CreatorName = list.CreatorName,
                    CreatedBy = list.CreatedBy,
                    CreatedOn = list.CreatedOn,
                    Remarks = (await _visitsService.GetVisitRemarks(list.VisitId)).ToList(),
                    VisitPhotosList = (await _visitsService.GetVisitPhotos(list.VisitId, host)).ToList()
                });
            }

            _response.Data = vlstVisits.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveVisitDetails([FromForm] VisitsRequest parameter)
        {
            Regex regex;
            int result;
            List<string> invalidFileNames = new List<string>();
            _response.IsSuccess = false;

            #region Validation Check

            //if ((parameter.VisitId == 0 && (parameter.VisitPhotosList.Count() == 0 || HttpContext.Request.Form.Files.Count() == 0))
            //    || (parameter.VisitId > 0 && parameter.VisitPhotosList.Count() == 0))
            //{
            //    _response.Message = "At least one visit photo is required to upload";
            //    return _response;
            //}
            //else if (parameter.VisitPhotosList.Count() > 5)
            //{
            //    _response.Message = "More than 5 visit photos are not allowed to upload";
            //    return _response;
            //}

            if (parameter.VisitPhotosList.Count() > 5)
            {
                _response.Message = "More than 5 visit photos are not allowed to upload";
                return _response;
            }

            //Manual File name validation checking as sometime Regex Engine Timeout error is occurring
            regex = new Regex(ValidationConstants.ImageFileRegExp);

            for (int pid = 0; pid < parameter.VisitPhotosList.Count(); pid++)
            {
                var tempPhoto = HttpContext.Request.Form.Files["VisitPhoto[" + pid + "]"];

                if (parameter.VisitPhotosList[pid].VisitPhotoId == 0 || tempPhoto?.FileName != parameter.VisitPhotosList[pid].UploadedFileName)
                    parameter.VisitPhotosList[pid].Photo = tempPhoto;

                if (tempPhoto != null && !regex.IsMatch(tempPhoto.FileName))
                {
                    invalidFileNames.Add(tempPhoto.FileName);
                }
            }

            if (invalidFileNames.Count > 0)
            {
                _response.Message = ValidationConstants.ImageFileRegExp_Msg;
                _response.Data = new[] { new { Field = "VisitPhotos", FileNames = invalidFileNames } };
                return _response;
            }
            #endregion

            #region Visit form Validation check
            _response = ModelStateHelper.GetValidationErrorsList(parameter);

            if (!_response.IsSuccess)
            {
                return _response;
            }
            #endregion
            //parameter.VisitPhotos = VisitPhotos;

            if (string.IsNullOrEmpty(parameter.Address))
            {
                parameter.Address = "N/A";
            }

            result = await _visitsService.SaveVisitDetails(parameter);
            _response.IsSuccess = false;

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Visit Name is already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.IsSuccess = true;
                if (parameter.VisitId > 0)
                {
                    _response.Message = "Record updated successfully";
                }
                else
                {
                    _response.Message = "Visit details saved successfully";
                }
            }

            return _response;
        }

        [Route("[action]")]
        [HttpGet]
        public async Task<ResponseModel> GetVisitDetails(long id)
        {
            var host = $"{this.Request.Scheme}://{this.Request.Host}{this.Request.PathBase}";
            VisitDetailsResponse? visit;

            if (id <= 0)
            {
                _response.IsSuccess = false;
                _response.Message = ValidationConstants.Id_Required_Msg;
            }
            else
            {
                visit = await _visitsService.GetVisitDetailsById(id);

                if (visit != null)
                {
                    visit.Remarks = (await _visitsService.GetVisitRemarks(id)).ToList();
                    visit.VisitPhotosList = (await _visitsService.GetVisitPhotos(id, host)).ToList();
                }

                _response.Data = visit;
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetVisitLogHistoryList(SearchVisitLogHistoryRequest request)
        {
            var host = $"{this.Request.Scheme}://{this.Request.Host}{this.Request.PathBase}";
            IEnumerable<VisitLogHistoryResponse> vlstVisits = await _visitsService.GetVisitLogHistoryList(request);

            _response.Data = vlstVisits.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ImportVisitsData([FromQuery] ImportRequest request)
        {
            _response.IsSuccess = false;
            List<string[]> data = new List<string[]>();
            ExcelWorksheets currentSheet;
            ExcelWorksheet workSheet;
            List<ImportedVisitDetails> lstImportedVisitDetails = new List<ImportedVisitDetails>();
            IEnumerable<VisitDataValidationErrors> lstVisitsFailedToImport;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
            int noOfCol, noOfRow;

            if (request.FileUpload == null || request.FileUpload.Length == 0)
            {
                _response.Message = "Please upload an excel file to import Visit data";
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

                if (!string.Equals(workSheet.Cells[1, 1].Value.ToString(), "VisitDate", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 2].Value.ToString(), "EmployeeName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 3].Value.ToString(), "CustomerTypeName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 4].Value.ToString(), "CustomerName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 5].Value.ToString(), "StateName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 6].Value.ToString(), "RegionName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 7].Value.ToString(), "DistrictName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 8].Value.ToString(), "AreaName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 9].Value.ToString(), "ContactPerson", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 10].Value.ToString(), "ContactNumber", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 11].Value.ToString(), "EmailId", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 12].Value.ToString(), "NextActionDate", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 13].Value.ToString(), "Latitude", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 14].Value.ToString(), "Longitude", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 15].Value.ToString(), "Address", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 16].Value.ToString(), "Remarks", StringComparison.OrdinalIgnoreCase) ||
                   !string.Equals(workSheet.Cells[1, 17].Value.ToString(), "IsActive", StringComparison.OrdinalIgnoreCase))
                {
                    _response.IsSuccess = false;
                    _response.Message = "Please upload a valid excel file. Please Download Format file for reference";
                    return _response;
                }
                var remarks = new List<VisitRemarks>();


                for (int rowIterator = 2; rowIterator <= noOfRow; rowIterator++)
                {
                    //remarks.Add(new VisitRemarks()
                    //{
                    //    Remarks = workSheet.Cells[rowIterator, 16].Value?.ToString()
                    //});

                    lstImportedVisitDetails.Add(new ImportedVisitDetails()
                    {
                        VisitDate = Convert.ToDateTime(workSheet.Cells[rowIterator, 1].Value),
                        EmployeeName = workSheet.Cells[rowIterator, 2].Value?.ToString(),
                        CustomerTypeName = workSheet.Cells[rowIterator, 3].Value?.ToString(),
                        CustomerName = workSheet.Cells[rowIterator, 4].Value?.ToString(),
                        StateName = workSheet.Cells[rowIterator, 5].Value?.ToString(),
                        RegionName = workSheet.Cells[rowIterator, 6].Value?.ToString(),
                        DistrictName = workSheet.Cells[rowIterator, 7].Value?.ToString(),
                        AreaName = workSheet.Cells[rowIterator, 8].Value?.ToString(),
                        ContactPerson = workSheet.Cells[rowIterator, 9].Value?.ToString(),
                        ContactNumber = workSheet.Cells[rowIterator, 10].Value?.ToString(),
                        EmailId = workSheet.Cells[rowIterator, 11].Value?.ToString(),
                        NextActionDate = Convert.ToDateTime(workSheet.Cells[rowIterator, 12].Value),
                        Latitude = Convert.ToDecimal(workSheet.Cells[rowIterator, 13].Value?.ToString()),
                        Longitude = Convert.ToDecimal(workSheet.Cells[rowIterator, 14].Value?.ToString()),
                        Address = workSheet.Cells[rowIterator, 15].Value?.ToString(),
                        Remarks = workSheet.Cells[rowIterator, 16].Value?.ToString(),
                        IsActive = workSheet.Cells[rowIterator, 17].Value?.ToString()
                    });
                }
            }

            if (lstImportedVisitDetails.Count == 0)
            {
                _response.Message = "File does not contains any record(s)";
                return _response;
            }

            lstVisitsFailedToImport = await _visitsService.ImportVisitsDetails(lstImportedVisitDetails);

            _response.IsSuccess = true;
            _response.Message = "Visits list imported successfully";

            #region Generate Excel file for Invalid Data
            if (lstVisitsFailedToImport.ToList().Count > 0)
            {
                _response.Message = "Uploaded file contains invalid records, please check downloaded file for more details";
                _response.Data = GenerateInvalidVisitDataFile(lstVisitsFailedToImport);

            }
            #endregion

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ExportVisitsData()
        {
            _response.IsSuccess = false;
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

            var request = new SearchVisitRequest();
            request.pagination = new PaginationParameters();

            IEnumerable<VisitsResponse> lstVisitsObj = await _visitsService.GetVisitsList(request);
            foreach (var list in lstVisitsObj)
            {
                var remarks = (await _visitsService.GetVisitRemarks(list.VisitId)).ToList();
                list.Remarks = remarks;
            }

            using (MemoryStream msExportDataFile = new MemoryStream())
            {
                using (ExcelPackage excelExportData = new ExcelPackage())
                {
                    WorkSheet1 = excelExportData.Workbook.Worksheets.Add("Visit");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "Visit No";
                    WorkSheet1.Cells[1, 2].Value = "Visit Type";
                    

                    WorkSheet1.Cells[1, 3].Value = "EmployeeName";
                    WorkSheet1.Cells[1, 4].Value = "EmployeeRole";
                    WorkSheet1.Cells[1, 5].Value = "CustomerName";
                    WorkSheet1.Cells[1, 6].Value = "CustomerType";
                    WorkSheet1.Cells[1, 7].Value = "VisitDate";

                    WorkSheet1.Cells[1, 8].Value = "NextActionDate";
                    WorkSheet1.Cells[1, 9].Value = "Status";
                    WorkSheet1.Cells[1, 10].Value = "CreatedBy";
                    WorkSheet1.Cells[1, 11].Value = "CreatedDate";

                    WorkSheet1.Cells[1, 12].Value = "ContactPerson";
                    WorkSheet1.Cells[1, 13].Value = "ContactNumber";
                    WorkSheet1.Cells[1, 14].Value = "Latitude";
                    WorkSheet1.Cells[1, 15].Value = "Longitude";
                    WorkSheet1.Cells[1, 16].Value = "Address";

                    WorkSheet1.Cells[1, 17].Value = "State";
                    WorkSheet1.Cells[1, 18].Value = "Reason";
                    WorkSheet1.Cells[1, 19].Value = "District";
                    WorkSheet1.Cells[1, 20].Value = "Area";

                    WorkSheet1.Cells[1, 21].Value = "Remarks";

                    recordIndex = 2;

                    foreach (var items in lstVisitsObj)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = items.VisitNo;
                        WorkSheet1.Cells[recordIndex, 2].Value = items.VisitTypeName;
                        

                        WorkSheet1.Cells[recordIndex, 3].Value = items.EmployeeName;
                        WorkSheet1.Cells[recordIndex, 4].Value = items.EmployeeRole;
                        WorkSheet1.Cells[recordIndex, 5].Value = items.CustomerName;
                        WorkSheet1.Cells[recordIndex, 6].Value = items.CustomerTypeName;
                        WorkSheet1.Cells[recordIndex, 7].Value = items.VisitDate.HasValue ? items.VisitDate.Value.ToString("dd/MM/yyyy hh:mm:ss tt") : string.Empty;

                        //WorkSheet1.Cells[recordIndex, 8].Style.Numberformat.Format = DateTimeFormatInfo.CurrentInfo.FullDateTimePattern;
                        WorkSheet1.Cells[recordIndex, 8].Value = items.NextActionDate.HasValue ? items.NextActionDate.Value.ToString("dd/MM/yyyy hh:mm:ss tt") : string.Empty;
                        WorkSheet1.Cells[recordIndex, 9].Value = items.StatusName;
                        WorkSheet1.Cells[recordIndex, 10].Value = items.CreatorName;
                        WorkSheet1.Cells[recordIndex, 11].Style.Numberformat.Format = DateTimeFormatInfo.CurrentInfo.ShortDatePattern;
                        WorkSheet1.Cells[recordIndex, 11].Value = items.CreatedOn;

                        WorkSheet1.Cells[recordIndex, 12].Value = items.ContactPerson;
                        WorkSheet1.Cells[recordIndex, 13].Value = items.ContactNumber;
                        WorkSheet1.Cells[recordIndex, 14].Value = items.ContactNumber;
                        WorkSheet1.Cells[recordIndex, 15].Value = items.ContactNumber;
                        WorkSheet1.Cells[recordIndex, 16].Value = items.Address;

                        WorkSheet1.Cells[recordIndex, 17].Value = items.StateName;
                        WorkSheet1.Cells[recordIndex, 18].Value = items.RegionName;
                        WorkSheet1.Cells[recordIndex, 19].Value = items.DistrictName;
                        WorkSheet1.Cells[recordIndex, 20].Value = items.AreaName;

                        if (items.Remarks.Count > 0)
                        {
                                WorkSheet1.Cells[recordIndex, 21].Value = items.Remarks.OrderByDescending(x=>x.VisitRemarkId).FirstOrDefault().Remarks;
                        }
                        else
                        {
                            WorkSheet1.Cells[recordIndex, 21].Value = "";
                        }

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
                    WorkSheet1.Column(12).AutoFit();
                    WorkSheet1.Column(13).AutoFit();
                    WorkSheet1.Column(14).AutoFit();
                    WorkSheet1.Column(15).AutoFit();
                    WorkSheet1.Column(16).AutoFit();
                    WorkSheet1.Column(17).AutoFit();
                    WorkSheet1.Column(18).AutoFit();
                    WorkSheet1.Column(19).AutoFit();
                    WorkSheet1.Column(20).AutoFit();
                    WorkSheet1.Column(21).AutoFit();

                    excelExportData.SaveAs(msExportDataFile);
                    msExportDataFile.Position = 0;
                    result = msExportDataFile.ToArray();
                }
            }

            if (result != null)
            {
                _response.Data = result;
                _response.IsSuccess = true;
                _response.Message = "Visits list Exported successfully";
            }

            return _response;
        }

        private byte[] GenerateInvalidVisitDataFile(IEnumerable<VisitDataValidationErrors> lstVisitsFailedToImport)
        {
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;

            using (MemoryStream msInvalidDataFile = new MemoryStream())
            {
                using (ExcelPackage excelInvalidData = new ExcelPackage())
                {
                    WorkSheet1 = excelInvalidData.Workbook.Worksheets.Add("Invalid_Visit_Records");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "VisitDate";
                    WorkSheet1.Cells[1, 2].Value = "EmployeeName";
                    WorkSheet1.Cells[1, 3].Value = "CustomerTypeName";
                    WorkSheet1.Cells[1, 4].Value = "CustomerName";
                    WorkSheet1.Cells[1, 5].Value = "StateName";
                    WorkSheet1.Cells[1, 6].Value = "RegionName";
                    WorkSheet1.Cells[1, 7].Value = "DistrictName";
                    WorkSheet1.Cells[1, 8].Value = "AreaName";
                    WorkSheet1.Cells[1, 9].Value = "ContactPerson";
                    WorkSheet1.Cells[1, 10].Value = "ContactNumber";
                    WorkSheet1.Cells[1, 11].Value = "EmailId";
                    WorkSheet1.Cells[1, 12].Value = "NextActionDate";
                    WorkSheet1.Cells[1, 13].Value = "Latitude";
                    WorkSheet1.Cells[1, 14].Value = "Longitude";
                    WorkSheet1.Cells[1, 15].Value = "Address";
                    WorkSheet1.Cells[1, 16].Value = "Remarks";
                    WorkSheet1.Cells[1, 17].Value = "IsActive";
                    WorkSheet1.Cells[1, 18].Value = "ValidationMessage";


                    recordIndex = 2;

                    foreach (VisitDataValidationErrors record in lstVisitsFailedToImport)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = record.VisitDate;
                        WorkSheet1.Cells[recordIndex, 2].Value = record.EmployeeName;
                        WorkSheet1.Cells[recordIndex, 3].Value = record.CustomerTypeName;
                        WorkSheet1.Cells[recordIndex, 4].Value = record.CustomerName;
                        WorkSheet1.Cells[recordIndex, 5].Value = record.StateName;
                        WorkSheet1.Cells[recordIndex, 6].Value = record.RegionName;
                        WorkSheet1.Cells[recordIndex, 7].Value = record.DistrictName;
                        WorkSheet1.Cells[recordIndex, 8].Value = record.AreaName;
                        WorkSheet1.Cells[recordIndex, 9].Value = record.ContactPerson;
                        WorkSheet1.Cells[recordIndex, 10].Value = record.ContactNumber;
                        WorkSheet1.Cells[recordIndex, 11].Value = record.EmailId;
                        WorkSheet1.Cells[recordIndex, 12].Value = record.NextActionDate;
                        WorkSheet1.Cells[recordIndex, 13].Value = record.Latitude;
                        WorkSheet1.Cells[recordIndex, 14].Value = record.Longitude;
                        WorkSheet1.Cells[recordIndex, 15].Value = record.Address;
                        WorkSheet1.Cells[recordIndex, 16].Value = record.Remarks;
                        WorkSheet1.Cells[recordIndex, 17].Value = record.IsActive;
                        WorkSheet1.Cells[recordIndex, 18].Value = record.ValidationMessage;

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
                    WorkSheet1.Column(12).AutoFit();
                    WorkSheet1.Column(13).AutoFit();
                    WorkSheet1.Column(14).AutoFit();
                    WorkSheet1.Column(15).AutoFit();
                    WorkSheet1.Column(16).AutoFit();
                    WorkSheet1.Column(17).AutoFit();
                    WorkSheet1.Column(18).AutoFit();


                    excelInvalidData.SaveAs(msInvalidDataFile);
                    msInvalidDataFile.Position = 0;
                    result = msInvalidDataFile.ToArray();
                }
            }

            return result;
        }

    }
}
