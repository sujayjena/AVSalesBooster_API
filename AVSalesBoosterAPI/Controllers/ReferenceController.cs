using Interfaces.Services;
using Microsoft.AspNetCore.Mvc;
using Models;
using Models.Constants;
using Models.Enums;
using OfficeOpenXml;
using OfficeOpenXml.Style;
/*
Reference module is not required that's why commented public access specifier and Route and ApiController attribute
*/
namespace AVSalesBoosterAPI.Controllers
{
    //[Route("api/[controller]")]
    //[ApiController]
    /*public*/ class ReferenceController : CustomBaseController
    {
        private ResponseModel _response;
        private IReferenceService _referenceService;

        public ReferenceController(IReferenceService referenceService)
        {
            _referenceService = referenceService;

            _response = new ResponseModel();
            _response.IsSuccess = true;
        }

        #region Reference API
        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetReferencesList(SearchReferenceRequest request)
        {
            IEnumerable<ReferenceResponse> lstReferences = await _referenceService.GetReferencesList(request);
            _response.Data = lstReferences.ToList();
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveReferenceDetails(ReferenceRequest parameter)
        {
            int result = await _referenceService.SaveReferenceDetails(parameter);
            _response.IsSuccess = false;

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Reference Name is already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.IsSuccess = true;
                _response.Message = "Reference details saved sucessfully";
            }

            return _response;
        }

        [Route("[action]")]
        [HttpGet]
        public async Task<ResponseModel> GetReferenceDetails(long id)
        {
            ReferenceResponse? reference;

            if (id <= 0)
            {
                _response.IsSuccess = false;
                _response.Message = ValidationConstants.Id_Required_Msg;
            }
            else
            {
                reference = await _referenceService.GetReferenceDetailsById(id);
                _response.Data = reference;
            }

            return _response;
        }
        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ImportReferencesData([FromQuery] ImportRequest request)
        {
            _response.IsSuccess = false;
            List<string[]> data = new List<string[]>();
            ExcelWorksheets currentSheet;
            ExcelWorksheet workSheet;
            List<ImportedReferenceDetails> lstImportedReferenceDetails = new List<ImportedReferenceDetails>();
            IEnumerable<ReferenceDataValidationErrors> lstReferencesFailedToImport;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
            int noOfCol, noOfRow;

            if (request.FileUpload == null || request.FileUpload.Length == 0)
            {
                _response.Message = "Please upload an excel file to import Reference data";
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

                if (!string.Equals(workSheet.Cells[1, 1].Value.ToString(), "ReferenceParty", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 2].Value.ToString(), "Address", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 3].Value.ToString(), "StateName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 4].Value.ToString(), "RegionName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 5].Value.ToString(), "DistrictName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 6].Value.ToString(), "AreaName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 7].Value.ToString(), "Pincode", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 8].Value.ToString(), "PhoneNumber", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 9].Value.ToString(), "MobileNumber", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 10].Value.ToString(), "GSTNumber", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 11].Value.ToString(), "PanNumber", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 12].Value.ToString(), "EmailId", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 13].Value.ToString(), "IsActive", StringComparison.OrdinalIgnoreCase))
                {
                    _response.IsSuccess = false;
                    _response.Message = "Please upload a valid excel file. Please Download Format file for reference";
                    return _response;
                }

                for (int rowIterator = 2; rowIterator <= noOfRow; rowIterator++)
                {
                    lstImportedReferenceDetails.Add(new ImportedReferenceDetails()
                    {
                        ReferenceParty = workSheet.Cells[rowIterator, 1].Value?.ToString(),
                        Address = workSheet.Cells[rowIterator, 2].Value?.ToString(),
                        StateName = workSheet.Cells[rowIterator, 3].Value?.ToString(),
                        RegionName = workSheet.Cells[rowIterator, 4].Value?.ToString(),
                        DistrictName = workSheet.Cells[rowIterator, 5].Value?.ToString(),
                        AreaName = workSheet.Cells[rowIterator, 6].Value?.ToString(),
                        Pincode = workSheet.Cells[rowIterator, 7].Value?.ToString(),
                        PhoneNumber = workSheet.Cells[rowIterator, 8].Value?.ToString(),
                        MobileNumber = workSheet.Cells[rowIterator, 9].Value?.ToString(),
                        GSTNumber = workSheet.Cells[rowIterator, 10].Value?.ToString(),
                        PanNumber = workSheet.Cells[rowIterator, 11].Value?.ToString(),
                        EmailId = workSheet.Cells[rowIterator, 12].Value?.ToString(),
                        IsActive = workSheet.Cells[rowIterator, 13].Value?.ToString()
                    });
                }
            }

            if (lstImportedReferenceDetails.Count == 0)
            {
                _response.Message = "File does not contains any record(s)";
                return _response;
            }

            lstReferencesFailedToImport = await _referenceService.ImportReferencesDetails(lstImportedReferenceDetails);

            _response.IsSuccess = true;
            _response.Message = "References list imported successfully";

            #region Generate Excel file for Invalid Data
            if (lstReferencesFailedToImport.ToList().Count > 0)
            {
                _response.Message = "Uploaded file contains invalid records, please check downloaded file for more details";
                _response.Data = GenerateInvalidReferenceDataFile(lstReferencesFailedToImport);

            }
            #endregion

            return _response;
        }


        private byte[] GenerateInvalidReferenceDataFile(IEnumerable<ReferenceDataValidationErrors> lstReferencesFailedToImport)
        {
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;

            using (MemoryStream msInvalidDataFile = new MemoryStream())
            {
                using (ExcelPackage excelInvalidData = new ExcelPackage())
                {
                    WorkSheet1 = excelInvalidData.Workbook.Worksheets.Add("Invalid_Reference_Records");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "ReferenceParty";
                    WorkSheet1.Cells[1, 2].Value = "Address";
                    WorkSheet1.Cells[1, 3].Value = "StateName";
                    WorkSheet1.Cells[1, 4].Value = "RegionName";
                    WorkSheet1.Cells[1, 5].Value = "DistrictName";
                    WorkSheet1.Cells[1, 6].Value = "AreaName";
                    WorkSheet1.Cells[1, 7].Value = "Pincode";
                    WorkSheet1.Cells[1, 8].Value = "PhoneNumber";
                    WorkSheet1.Cells[1, 9].Value = "MobileNumber";
                    WorkSheet1.Cells[1, 10].Value = "GSTNumber";
                    WorkSheet1.Cells[1, 11].Value = "PanNumber";
                    WorkSheet1.Cells[1, 12].Value = "EmailId"; 
                    WorkSheet1.Cells[1, 13].Value = "IsActive";
                    WorkSheet1.Cells[1, 14].Value = "ValidationMessage";

                    recordIndex = 2;

                    foreach (ReferenceDataValidationErrors record in lstReferencesFailedToImport)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = record.ReferenceParty;
                        WorkSheet1.Cells[recordIndex, 2].Value = record.Address;
                        WorkSheet1.Cells[recordIndex, 3].Value = record.StateName;
                        WorkSheet1.Cells[recordIndex, 4].Value = record.RegionName;
                        WorkSheet1.Cells[recordIndex, 5].Value = record.DistrictName;
                        WorkSheet1.Cells[recordIndex, 6].Value = record.AreaName;
                        WorkSheet1.Cells[recordIndex, 7].Value = record.Pincode;
                        WorkSheet1.Cells[recordIndex, 8].Value = record.PhoneNumber;
                        WorkSheet1.Cells[recordIndex, 9].Value = record.MobileNumber;
                        WorkSheet1.Cells[recordIndex, 10].Value = record.GSTNumber;
                        WorkSheet1.Cells[recordIndex, 11].Value = record.PanNumber;
                        WorkSheet1.Cells[recordIndex, 12].Value = record.EmailId;
                        WorkSheet1.Cells[recordIndex, 13].Value = record.IsActive;
                        WorkSheet1.Cells[recordIndex, 14].Value = record.ValidationMessage;

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

                    excelInvalidData.SaveAs(msInvalidDataFile);
                    msInvalidDataFile.Position = 0;
                    result = msInvalidDataFile.ToArray();
                }
            }

            return result;
        }
        #endregion
    }
}
