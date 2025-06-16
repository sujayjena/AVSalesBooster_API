using Helpers;
using Interfaces.Services;
using Microsoft.AspNetCore.Mvc;
using Models;
using Models.Constants;
using Models.Enums;
using OfficeOpenXml;
using OfficeOpenXml.Style;
using Services;
using System.Globalization;
using System.Reflection.Metadata;
using System.Security.Cryptography;
using System.Text.RegularExpressions;

namespace AVSalesBoosterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ProfileController : CustomBaseController
    {

        private ResponseModel _response;
        private IProfileService _profileService;
        private IFileManager _fileManager;

        public ProfileController(IProfileService profileService, IFileManager fileManager)
        {
            _profileService = profileService;

            _response = new ResponseModel();
            _response.IsSuccess = true;
            _fileManager = fileManager;
        }

        #region Role API

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetRolesList(SearchRoleRequest request)
        {
            IEnumerable<RoleResponse> lstRoles = await _profileService.GetRolesList(request);
            _response.Data = lstRoles.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveRoleDetails(RoleRequest parameter)
        {
            _response.IsSuccess = false;

            int result = await _profileService.SaveRoleDetails(parameter);

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Role Name is already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.IsSuccess = true;
                _response.Message = "Role details saved successfully";
            }
            return _response;
        }

        [Route("[action]")]
        [HttpGet]
        public async Task<ResponseModel> GetRoleDetails(long id)
        {
            RoleResponse? role;

            if (id <= 0)
            {
                _response.IsSuccess = false;
                _response.Message = ValidationConstants.Id_Required_Msg;
            }
            else
            {
                role = await _profileService.GetRoleDetailsById(id);
                _response.Data = role;
            }

            return _response;
        }
        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ImportRolesData([FromQuery] ImportRequest request)
        {
            _response.IsSuccess = false;
            List<string[]> data = new List<string[]>();
            ExcelWorksheets currentSheet;
            ExcelWorksheet workSheet;
            List<ImportedRoleDetails> lstImportedRoleDetails = new List<ImportedRoleDetails>();
            IEnumerable<RoleDataValidationErrors> lstRolesFailedToImport;
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

                if (!string.Equals(workSheet.Cells[1, 1].Value.ToString(), "RoleName", StringComparison.OrdinalIgnoreCase) ||
                   !string.Equals(workSheet.Cells[1, 2].Value.ToString(), "IsActive", StringComparison.OrdinalIgnoreCase))
                {
                    _response.IsSuccess = false;
                    _response.Message = "Please upload a valid excel file. Please Download Format file for reference";
                    return _response;
                }

                for (int rowIterator = 2; rowIterator <= noOfRow; rowIterator++)
                {
                    lstImportedRoleDetails.Add(new ImportedRoleDetails()
                    {
                        RoleName = workSheet.Cells[rowIterator, 1].Value?.ToString(),
                        IsActive = workSheet.Cells[rowIterator, 2].Value?.ToString()
                    });
                }
            }

            if (lstImportedRoleDetails.Count == 0)
            {
                _response.Message = "File does not contains any record(s)";
                return _response;
            }

            lstRolesFailedToImport = await _profileService.ImportRolesDetails(lstImportedRoleDetails);

            _response.IsSuccess = true;
            _response.Message = "Roles list imported successfully";

            #region Generate Excel file for Invalid Data
            if (lstRolesFailedToImport.ToList().Count > 0)
            {
                _response.Message = "Uploaded file contains invalid records, please check downloaded file for more details";
                _response.Data = GenerateInvalidRoleDataFile(lstRolesFailedToImport);

            }
            #endregion

            return _response;
        }

        private byte[] GenerateInvalidRoleDataFile(IEnumerable<RoleDataValidationErrors> lstRolesFailedToImport)
        {
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;

            using (MemoryStream msInvalidDataFile = new MemoryStream())
            {
                using (ExcelPackage excelInvalidData = new ExcelPackage())
                {
                    WorkSheet1 = excelInvalidData.Workbook.Worksheets.Add("Invalid_Role_Records");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "RoleName";
                    WorkSheet1.Cells[1, 2].Value = "IsActive";
                    WorkSheet1.Cells[1, 3].Value = "ValidationMessage";

                    recordIndex = 2;

                    foreach (RoleDataValidationErrors record in lstRolesFailedToImport)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = record.RoleName;
                        WorkSheet1.Cells[recordIndex, 2].Value = record.IsActive;
                        WorkSheet1.Cells[recordIndex, 3].Value = record.ValidationMessage;

                        recordIndex += 1;
                    }

                    WorkSheet1.Column(1).AutoFit();
                    WorkSheet1.Column(2).AutoFit();
                    WorkSheet1.Column(3).AutoFit();

                    excelInvalidData.SaveAs(msInvalidDataFile);
                    msInvalidDataFile.Position = 0;
                    result = msInvalidDataFile.ToArray();
                }
            }

            return result;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ExportRoleData()
        {
            _response.IsSuccess = false;
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

            var request = new SearchRoleRequest();
            request.pagination = new PaginationParameters();

            IEnumerable<RoleResponse> lstRoleObj = await _profileService.GetRolesList(request);

            using (MemoryStream msExportDataFile = new MemoryStream())
            {
                using (ExcelPackage excelExportData = new ExcelPackage())
                {
                    WorkSheet1 = excelExportData.Workbook.Worksheets.Add("Role");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "RoleName";
                    WorkSheet1.Cells[1, 2].Value = "Status";

                    WorkSheet1.Cells[1, 3].Value = "CreatedBy";
                    WorkSheet1.Cells[1, 4].Value = "CreatedDate";

                    recordIndex = 2;

                    foreach (var items in lstRoleObj)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = items.RoleName;
                        WorkSheet1.Cells[recordIndex, 2].Value = items.IsActive == true ? "Active" : "Inactive";

                        WorkSheet1.Cells[recordIndex, 3].Value = items.CreatorName;
                        WorkSheet1.Cells[recordIndex, 4].Style.Numberformat.Format = DateTimeFormatInfo.CurrentInfo.ShortDatePattern;
                        WorkSheet1.Cells[recordIndex, 4].Value = items.CreatedOn;

                        recordIndex += 1;
                    }

                    WorkSheet1.Column(1).AutoFit();
                    WorkSheet1.Column(2).AutoFit();
                    WorkSheet1.Column(3).AutoFit();
                    WorkSheet1.Column(4).AutoFit();

                    excelExportData.SaveAs(msExportDataFile);
                    msExportDataFile.Position = 0;
                    result = msExportDataFile.ToArray();
                }
            }

            if (result != null)
            {
                _response.Data = result;
                _response.IsSuccess = true;
                _response.Message = "Role list Exported successfully";
            }

            return _response;
        }

        #endregion

        #region Reporting To API

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetReportingHierarchyRolesList(SearchRoleRequest request)
        {
            IEnumerable<RoleResponse> lstRoles = await _profileService.GetReportingHierarchyRolesList(request);
            _response.Data = lstRoles.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetReportingTosList(SearchReportingToRequest request)
        {
            IEnumerable<ReportingToResponse> lstReportingToes = await _profileService.GetReportingTosList(request);
            _response.Data = lstReportingToes.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveReportingToDetails(ReportingToRequest parameter)
        {
            int result = await _profileService.SaveReportingToDetails(parameter);

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Roporting To is already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.Message = "Reporting To details saved successfully";
            }
            return _response;
        }

        [Route("[action]")]
        [HttpGet]
        public async Task<ResponseModel> GetReportingToDetails(long id)
        {
            ReportingToResponse? reportingTo;

            if (id <= 0)
            {
                _response.IsSuccess = false;
                _response.Message = ValidationConstants.Id_Required_Msg;
            }
            else
            {
                reportingTo = await _profileService.GetReportingToDetailsById(id);
                _response.Data = reportingTo;
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetReportingToListByEmployeeId(long employeeId)
        {
            IEnumerable<ReportingToListReponse> lstReportingToes = await _profileService.GetReportingToListByEmployeeId(employeeId);
            _response.Data = lstReportingToes.ToList();
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ImportReportingTosData([FromQuery] ImportRequest request)
        {
            _response.IsSuccess = false;
            List<string[]> data = new List<string[]>();
            ExcelWorksheets currentSheet;
            ExcelWorksheet workSheet;
            List<ImportedReportingToDetails> lstImportedReportingToDetails = new List<ImportedReportingToDetails>();
            IEnumerable<ReportingToDataValidationErrors> lstReportingTosFailedToImport;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
            int noOfCol, noOfRow;

            if (request.FileUpload == null || request.FileUpload.Length == 0)
            {
                _response.Message = "Please upload an excel file to import Reporting To data";
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

                if (!string.Equals(workSheet.Cells[1, 1].Value.ToString(), "RoleName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 2].Value.ToString(), "ReportingToName", StringComparison.OrdinalIgnoreCase) ||
                   !string.Equals(workSheet.Cells[1, 3].Value.ToString(), "IsActive", StringComparison.OrdinalIgnoreCase))
                {
                    _response.IsSuccess = false;
                    _response.Message = "Please upload a valid excel file. Please Download Format file for reference";
                    return _response;
                }

                for (int rowIterator = 2; rowIterator <= noOfRow; rowIterator++)
                {
                    lstImportedReportingToDetails.Add(new ImportedReportingToDetails()
                    {
                        RoleName = workSheet.Cells[rowIterator, 1].Value?.ToString(),
                        ReportingToName = workSheet.Cells[rowIterator, 2].Value?.ToString(),
                        IsActive = workSheet.Cells[rowIterator, 3].Value?.ToString()

                    });
                }
            }

            if (lstImportedReportingToDetails.Count == 0)
            {
                _response.Message = "File does not contains any record(s)";
                return _response;
            }

            lstReportingTosFailedToImport = await _profileService.ImportReportingTosDetails(lstImportedReportingToDetails);

            _response.IsSuccess = true;
            _response.Message = "Reporting Tos list imported successfully";

            #region Generate Excel file for Invalid Data
            if (lstReportingTosFailedToImport.ToList().Count > 0)
            {
                _response.Message = "Uploaded file contains invalid records, please check downloaded file for more details";
                _response.Data = GenerateInvalidReportingToDataFile(lstReportingTosFailedToImport);

            }
            #endregion

            return _response;
        }
        private byte[] GenerateInvalidReportingToDataFile(IEnumerable<ReportingToDataValidationErrors> lstReportingTosFailedToImport)
        {
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;

            using (MemoryStream msInvalidDataFile = new MemoryStream())
            {
                using (ExcelPackage excelInvalidData = new ExcelPackage())
                {
                    WorkSheet1 = excelInvalidData.Workbook.Worksheets.Add("Invalid_ReportingTo_Records");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "RoleName";
                    WorkSheet1.Cells[1, 2].Value = "ReportingToName";
                    WorkSheet1.Cells[1, 3].Value = "IsActive";
                    WorkSheet1.Cells[1, 4].Value = "ValidationMessage";

                    recordIndex = 2;

                    foreach (ReportingToDataValidationErrors record in lstReportingTosFailedToImport)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = record.RoleName;
                        WorkSheet1.Cells[recordIndex, 2].Value = record.ReportingToName;
                        WorkSheet1.Cells[recordIndex, 3].Value = record.IsActive;
                        WorkSheet1.Cells[recordIndex, 4].Value = record.ValidationMessage;

                        recordIndex += 1;
                    }

                    WorkSheet1.Column(1).AutoFit();
                    WorkSheet1.Column(2).AutoFit();
                    WorkSheet1.Column(3).AutoFit();
                    WorkSheet1.Column(4).AutoFit();

                    excelInvalidData.SaveAs(msInvalidDataFile);
                    msInvalidDataFile.Position = 0;
                    result = msInvalidDataFile.ToArray();
                }
            }

            return result;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ExportReportingHierarchyData()
        {
            _response.IsSuccess = false;
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

            var request = new SearchReportingToRequest();
            request.pagination = new PaginationParameters();

            IEnumerable<ReportingToResponse> lstReportingToObj = await _profileService.GetReportingTosList(request);

            using (MemoryStream msExportDataFile = new MemoryStream())
            {
                using (ExcelPackage excelExportData = new ExcelPackage())
                {
                    WorkSheet1 = excelExportData.Workbook.Worksheets.Add("ReportingHierarchy");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "RoleName";
                    WorkSheet1.Cells[1, 2].Value = "RoleHierarchy";
                    WorkSheet1.Cells[1, 3].Value = "Status";

                    WorkSheet1.Cells[1, 4].Value = "CreatedBy";
                    WorkSheet1.Cells[1, 5].Value = "CreatedDate";

                    recordIndex = 2;

                    foreach (var items in lstReportingToObj)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = items.RoleName;
                        WorkSheet1.Cells[recordIndex, 2].Value = items.ReportingToName;
                        WorkSheet1.Cells[recordIndex, 3].Value = items.IsActive == true ? "Active" : "Inactive";

                        WorkSheet1.Cells[recordIndex, 4].Value = items.CreatorName;
                        WorkSheet1.Cells[recordIndex, 5].Style.Numberformat.Format = DateTimeFormatInfo.CurrentInfo.ShortDatePattern;
                        WorkSheet1.Cells[recordIndex, 5].Value = items.CreatedOn;

                        recordIndex += 1;
                    }

                    WorkSheet1.Column(1).AutoFit();
                    WorkSheet1.Column(2).AutoFit();
                    WorkSheet1.Column(3).AutoFit();
                    WorkSheet1.Column(4).AutoFit();
                    WorkSheet1.Column(5).AutoFit();

                    excelExportData.SaveAs(msExportDataFile);
                    msExportDataFile.Position = 0;
                    result = msExportDataFile.ToArray();
                }
            }

            if (result != null)
            {
                _response.Data = result;
                _response.IsSuccess = true;
                _response.Message = "Reporting Hierarchy list Exported successfully";
            }

            return _response;
        }

        #endregion

        #region Employee To API

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetEmployeesList(SearchEmployeeRequest request)
        {
            var host = $"{this.Request.Scheme}://{this.Request.Host}{this.Request.PathBase}";

            IEnumerable<EmployeeResponse> lstEmployees = await _profileService.GetEmployeesList(request);

            foreach (var item in lstEmployees)
            {
                if (!string.IsNullOrWhiteSpace(item.ImageUpload))
                {
                    item.ProfilePictureUrl = host + _fileManager.GetProfilePictureFile(item.ImageUpload);
                }

                if (!string.IsNullOrWhiteSpace(item.AdharCardSavedFileName))
                {
                    item.AdharCardPictureUrl = host + _fileManager.GetEmpDocumentsFile(item.AdharCardSavedFileName);
                }

                if (!string.IsNullOrWhiteSpace(item.PanCardSavedFileName))
                {
                    item.PanCardPictureUrl = host + _fileManager.GetEmpDocumentsFile(item.PanCardSavedFileName);
                }
            }

            _response.Data = lstEmployees.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetEmployeesListByReportingTo(long employeeId)
        {
            IEnumerable<EmployeeReportingToResponse> lstEmployees = await _profileService.GetEmployeesListByReportingTo(employeeId);
            _response.Data = lstEmployees.ToList();
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveEmployeeDetails(IFormFile? ProfilePicture, IFormFile? AdharCard, IFormFile? PanCard)  //[FromQuery] ProfilePictureRequest profilePicture)
        {
            string jsonParameters;
            int result;
            EmployeeRequest parameter;
            Regex regex;
            Regex regex_imgPdf;

            #region Validation Check
            jsonParameters = Convert.ToString(HttpContext.Request.Query["parameter"]);

            if (string.IsNullOrEmpty(jsonParameters))
            {
                _response.IsSuccess = false;
                _response.Message = ValidationConstants.Parameters_Required_Msg;
                return _response;
            }

            //Manual File name validation checking as sometime Regex Engine Timeout error is occurring
            regex = new Regex(ValidationConstants.ImageFileRegExp);
            regex_imgPdf = new Regex(ValidationConstants.ImageOrPdfFileRegExp);

            if (ProfilePicture != null && !regex.IsMatch(ProfilePicture.FileName))
            {
                _response.IsSuccess = false;
                _response.Message = ErrorConstants.ValidationFailureError;
                _response.Data = new[] { new { Field = "ProfilePicture", ErrorMessage = ValidationConstants.ImageFileRegExp_Msg } };
                return _response;
            }

            if (AdharCard != null && !regex_imgPdf.IsMatch(AdharCard.FileName))
            {
                _response.IsSuccess = false;
                _response.Message = ErrorConstants.ValidationFailureError;
                _response.Data = new[] { new { Field = "AdharCard", ErrorMessage = ValidationConstants.ImageOrPdfFileRegExp_Msg } };
                return _response;
            }

            if (PanCard != null && !regex_imgPdf.IsMatch(PanCard.FileName))
            {
                _response.IsSuccess = false;
                _response.Message = ErrorConstants.ValidationFailureError;
                _response.Data = new[] { new { Field = "PanCard", ErrorMessage = ValidationConstants.ImageOrPdfFileRegExp_Msg } };
                return _response;
            }
            #endregion

            parameter = System.Text.Json.JsonSerializer.Deserialize<EmployeeRequest>(HttpContext.Request.Query["parameter"]!) ?? new EmployeeRequest();

            #region Employee Main form Validation check
            //Condition to ignore InitialPassword on Edit/Update Employee details, This will not update in table. Just initialized value to ignore validations.
            //if (parameter.EmployeeId > 0)
            //{
            //    parameter.InitialPassword = "Temp_Pwd";
            //}

            _response = ModelStateHelper.GetValidationErrorsList(parameter);

            if (!_response.IsSuccess)
            {
                return _response;
            }
            #endregion

            if (parameter.IsToDeleteProfilePic != true)
                parameter.ProfilePicture = ProfilePicture;

            if (parameter.IsToDeleteAdharCard != true)
                parameter.AdharCard = AdharCard;

            if (parameter.IsToDeletePanCard != true)
                parameter.PanCard = PanCard;

            //checking address is null or empty then update N/A
            if (string.IsNullOrEmpty(parameter.Address))
            {
                parameter.Address = "N/A";
            }

            result = await _profileService.SaveEmployeeDetails(parameter);

            _response.IsSuccess = false;

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Employee Name is already exists";
            }
            else if (result == (int)SaveEnums.CodeExists)
            {
                _response.Message = "Employee Code is already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.IsSuccess = true;
                _response.Message = "Employee details saved successfully";

                #region // Add/Update Employee State

                // Delete state of employee

                var vStateDELETEObj = new EmployeeState_Request()
                {
                    Action = "DELETE",
                    EmployeeId = result,
                    StateId = 0
                };
                int resultStateMappingDELETE = await _profileService.SaveEmployeeState(vStateDELETEObj);


                // Add new mapping of employee
                foreach (var vStateitem in parameter.StateList)
                {
                    var vStateMapObj = new EmployeeState_Request()
                    {
                        Action = "INSERT",
                        EmployeeId = result,
                        StateId = vStateitem.StateId
                    };

                    int resultBranchMapping = await _profileService.SaveEmployeeState(vStateMapObj);
                }

                #endregion

                #region // Add/Update Employee Region

                // Delete state of employee

                var vRegionDELETEObj = new EmployeeRegion_Request()
                {
                    Action = "DELETE",
                    EmployeeId = result,
                    RegionId = 0
                };
                int resultRegionMappingDELETE = await _profileService.SaveEmployeeRegion(vRegionDELETEObj);


                // Add new mapping of employee
                foreach (var vRegionitem in parameter.RegionList)
                {
                    var vRegionMapObj = new EmployeeRegion_Request()
                    {
                        Action = "INSERT",
                        EmployeeId = result,
                        RegionId = vRegionitem.RegionId
                    };

                    int resultRegionMapping = await _profileService.SaveEmployeeRegion(vRegionMapObj);
                }

                #endregion
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> UpdateEmpDetailsThroughApp(UpdateEmployeeDetailsRequest parameters)
        {
            int result = await _profileService.UpdateEmpDetailsThroughApp(parameters);
            _response.IsSuccess = false;

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists to update";
            }
            else if (result == (int)SaveEnums.MobileNoExists)
            {
                _response.Message = "Mobile No. is already in use";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.IsSuccess = true;
                _response.Message = "Employee details updated successfully";
            }

            return _response;
        }

        [Route("[action]")]
        [HttpGet]
        public async Task<ResponseModel> GetEmployeeDetails(long id)
        {
            EmployeeResponse? employee;

            if (id <= 0)
            {
                _response.IsSuccess = false;
                _response.Message = ValidationConstants.Id_Required_Msg;
            }
            else
            {
                employee = await _profileService.GetEmployeeDetailsById(id);

                if (employee != null)
                {
                    var statelistObj = await _profileService.GetEmployeeStateByEmployeeId(employee.EmployeeId, 0);
                    var regionlistObj = await _profileService.GetEmployeeRegionByEmployeeId(employee.EmployeeId, 0);

                    employee.StateList = statelistObj.ToList();
                    employee.RegionList = regionlistObj.ToList();
                }

                _response.Data = employee;
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ImportEmployeesData([FromQuery] ImportRequest request)
        {
            _response.IsSuccess = false;
            List<string[]> data = new List<string[]>();
            ExcelWorksheets currentSheet;
            ExcelWorksheet workSheet;
            List<ImportedEmployeeDetails> lstImportedEmployeeDetails = new List<ImportedEmployeeDetails>();
            IEnumerable<EmployeeDataValidationErrors> lstEmployeesFailedToImport;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
            int noOfCol, noOfRow;

            if (request.FileUpload == null || request.FileUpload.Length == 0)
            {
                _response.Message = "Please upload an excel file to import employee data";
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

                if (!string.Equals(workSheet.Cells[1, 1].Value.ToString(), "EmployeeName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 2].Value.ToString(), "EmployeeCode", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 3].Value.ToString(), "EmailId", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 4].Value.ToString(), "MobileNumber", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 5].Value.ToString(), "RoleName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 6].Value.ToString(), "ReportingToName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 7].Value.ToString(), "Address", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 8].Value.ToString(), "StateName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 9].Value.ToString(), "RegionName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 10].Value.ToString(), "DistrictName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 11].Value.ToString(), "AreaName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 12].Value.ToString(), "Pincode", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 19].Value.ToString(), "IsActive", StringComparison.OrdinalIgnoreCase))
                {
                    _response.IsSuccess = false;
                    _response.Message = "Please upload a valid excel file. Please Download Format file for reference";
                    return _response;
                }

                for (int rowIterator = 2; rowIterator <= noOfRow; rowIterator++)
                {
                    lstImportedEmployeeDetails.Add(new ImportedEmployeeDetails()
                    {
                        EmployeeName = workSheet.Cells[rowIterator, 1].Value?.ToString(),
                        EmployeeCode = workSheet.Cells[rowIterator, 2].Value?.ToString(),
                        EmailId = workSheet.Cells[rowIterator, 3].Value?.ToString(),
                        MobileNumber = workSheet.Cells[rowIterator, 4].Value?.ToString(),
                        RoleName = workSheet.Cells[rowIterator, 5].Value?.ToString(),
                        ReportingToName = workSheet.Cells[rowIterator, 6].Value?.ToString(),
                        Address = workSheet.Cells[rowIterator, 7].Value?.ToString(),
                        StateName = workSheet.Cells[rowIterator, 8].Value?.ToString(),
                        RegionName = workSheet.Cells[rowIterator, 9].Value?.ToString(),
                        DistrictName = workSheet.Cells[rowIterator, 10].Value?.ToString(),
                        AreaName = workSheet.Cells[rowIterator, 11].Value?.ToString(),
                        Pincode = workSheet.Cells[rowIterator, 12].Value?.ToString(),
                        DateOfBirth = Convert.ToDateTime(workSheet.Cells[rowIterator, 13].Value),
                        DateOfJoining = Convert.ToDateTime(workSheet.Cells[rowIterator, 14].Value),
                        EmergencyContactNumber = workSheet.Cells[rowIterator, 15].Value?.ToString(),
                        BloodGroup = workSheet.Cells[rowIterator, 16].Value?.ToString(),
                        IsWebUser = workSheet.Cells[rowIterator, 17].Value?.ToString(),
                        IsMobileUser = workSheet.Cells[rowIterator, 18].Value?.ToString(),
                        IsActive = workSheet.Cells[rowIterator, 19].Value?.ToString()
                    });
                }
            }

            if (lstImportedEmployeeDetails.Count == 0)
            {
                _response.Message = "File does not contains any record(s)";
                return _response;
            }

            lstEmployeesFailedToImport = await _profileService.ImportEmployeesDetails(lstImportedEmployeeDetails);

            _response.IsSuccess = true;
            _response.Message = "Employees list imported successfully";

            #region Generate Excel file for Invalid Data
            if (lstEmployeesFailedToImport.ToList().Count > 0)
            {
                _response.Message = "Uploaded file contains invalid records, please check downloaded file for more details";
                _response.Data = GenerateInvalidEmployeeDataFile(lstEmployeesFailedToImport);

            }
            #endregion

            return _response;
        }

        private byte[] GenerateInvalidEmployeeDataFile(IEnumerable<EmployeeDataValidationErrors> lstEmployeesFailedToImport)
        {
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;

            using (MemoryStream msInvalidDataFile = new MemoryStream())
            {
                using (ExcelPackage excelInvalidData = new ExcelPackage())
                {
                    WorkSheet1 = excelInvalidData.Workbook.Worksheets.Add("Invalid_Employee_Records");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;


                    WorkSheet1.Cells[1, 1].Value = "EmployeeName";
                    WorkSheet1.Cells[1, 2].Value = "EmployeeCode";
                    WorkSheet1.Cells[1, 3].Value = "EmailId";
                    WorkSheet1.Cells[1, 4].Value = "MobileNumber";
                    WorkSheet1.Cells[1, 5].Value = "RoleName";
                    WorkSheet1.Cells[1, 6].Value = "ReportingToName";
                    WorkSheet1.Cells[1, 7].Value = "Address";
                    WorkSheet1.Cells[1, 8].Value = "StateName";
                    WorkSheet1.Cells[1, 9].Value = "RegionName";
                    WorkSheet1.Cells[1, 10].Value = "DistrictName";
                    WorkSheet1.Cells[1, 11].Value = "AreaName";
                    WorkSheet1.Cells[1, 12].Value = "Pincode";
                    WorkSheet1.Cells[1, 13].Value = "DateOfBirth";
                    WorkSheet1.Cells[1, 14].Value = "DateOfJoining";
                    WorkSheet1.Cells[1, 15].Value = "EmergencyContactNumber";
                    WorkSheet1.Cells[1, 16].Value = "BloodGroup";
                    WorkSheet1.Cells[1, 17].Value = "IsWebUser";
                    WorkSheet1.Cells[1, 18].Value = "IsMobileUser";
                    WorkSheet1.Cells[1, 19].Value = "IsActive";
                    WorkSheet1.Cells[1, 20].Value = "ValidationMessage";

                    recordIndex = 2;

                    foreach (EmployeeDataValidationErrors record in lstEmployeesFailedToImport)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = record.EmployeeName;
                        WorkSheet1.Cells[recordIndex, 2].Value = record.EmployeeCode;
                        WorkSheet1.Cells[recordIndex, 3].Value = record.EmailId;
                        WorkSheet1.Cells[recordIndex, 4].Value = record.MobileNumber;
                        WorkSheet1.Cells[recordIndex, 5].Value = record.RoleName;
                        WorkSheet1.Cells[recordIndex, 6].Value = record.ReportingToName;
                        WorkSheet1.Cells[recordIndex, 7].Value = record.Address;
                        WorkSheet1.Cells[recordIndex, 8].Value = record.StateName;
                        WorkSheet1.Cells[recordIndex, 9].Value = record.RegionName;
                        WorkSheet1.Cells[recordIndex, 10].Value = record.DistrictName;
                        WorkSheet1.Cells[recordIndex, 11].Value = record.AreaName;
                        WorkSheet1.Cells[recordIndex, 12].Value = record.Pincode;
                        WorkSheet1.Cells[recordIndex, 13].Value = record.DateOfBirth;
                        WorkSheet1.Cells[recordIndex, 14].Value = record.DateOfJoining;
                        WorkSheet1.Cells[recordIndex, 15].Value = record.EmergencyContactNumber;
                        WorkSheet1.Cells[recordIndex, 16].Value = record.BloodGroup;
                        WorkSheet1.Cells[recordIndex, 17].Value = record.IsWebUser;
                        WorkSheet1.Cells[recordIndex, 18].Value = record.IsMobileUser;
                        WorkSheet1.Cells[recordIndex, 19].Value = record.IsActive;
                        WorkSheet1.Cells[recordIndex, 20].Value = record.ValidationMessage;

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

                    excelInvalidData.SaveAs(msInvalidDataFile);
                    msInvalidDataFile.Position = 0;
                    result = msInvalidDataFile.ToArray();
                }
            }

            return result;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ExportEmployeeData()
        {
            _response.IsSuccess = false;
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

            var request = new SearchEmployeeRequest();
            request.pagination = new PaginationParameters();

            IEnumerable<EmployeeResponse> lstEmployeeObj = await _profileService.GetEmployeesList(request);

            using (MemoryStream msExportDataFile = new MemoryStream())
            {
                using (ExcelPackage excelExportData = new ExcelPackage())
                {
                    WorkSheet1 = excelExportData.Workbook.Worksheets.Add("Employee");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "EmployeCode";
                    WorkSheet1.Cells[1, 2].Value = "EmployeeName";
                    WorkSheet1.Cells[1, 3].Value = "MobileUser";
                    WorkSheet1.Cells[1, 4].Value = "WebUser";
                    WorkSheet1.Cells[1, 5].Value = "EmailID";
                    WorkSheet1.Cells[1, 6].Value = "Role";
                    WorkSheet1.Cells[1, 7].Value = "ReportingTo";
                    WorkSheet1.Cells[1, 8].Value = "Status";

                    WorkSheet1.Cells[1, 9].Value = "CreatedBy";
                    WorkSheet1.Cells[1, 10].Value = "CreatedDate";

                    recordIndex = 2;

                    foreach (var items in lstEmployeeObj)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = items.EmployeeCode;
                        WorkSheet1.Cells[recordIndex, 2].Value = items.EmployeeName;
                        WorkSheet1.Cells[recordIndex, 3].Value = items.IsMobileUser == true ? "YES" : "NO";
                        WorkSheet1.Cells[recordIndex, 4].Value = items.IsWebUser == true ? "YES" : "NO";
                        WorkSheet1.Cells[recordIndex, 5].Value = items.EmailId;
                        WorkSheet1.Cells[recordIndex, 6].Value = items.RoleName;
                        WorkSheet1.Cells[recordIndex, 7].Value = items.ReportingToName;
                        WorkSheet1.Cells[recordIndex, 8].Value = items.IsActive == true ? "Active" : "Inactive";

                        WorkSheet1.Cells[recordIndex, 9].Value = items.CreatorName;
                        WorkSheet1.Cells[recordIndex, 10].Style.Numberformat.Format = DateTimeFormatInfo.CurrentInfo.ShortDatePattern;
                        WorkSheet1.Cells[recordIndex, 10].Value = items.CreatedOn;

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

                    excelExportData.SaveAs(msExportDataFile);
                    msExportDataFile.Position = 0;
                    result = msExportDataFile.ToArray();
                }
            }

            if (result != null)
            {
                _response.Data = result;
                _response.IsSuccess = true;
                _response.Message = "Employee list Exported successfully";
            }

            return _response;
        }

        #endregion

        #region Manage Access Role Permisson for Web & Employee

        //[Route("[action]")]
        //[HttpPost]
        //public async Task<ResponseModel> GetModuleMasterList(SearchModuleMasterRequest request)
        //{
        //    IEnumerable<ModuleMaster_Response> lstModuleMaster = await _profileService.GetModuleMasterList(request);
        //    _response.Data = lstModuleMaster.ToList();
        //    return _response;
        //}

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetRoleMaster_PermissionList(SearchRoleMaster_PermissionRequest request)
        {
            IEnumerable<RoleMaster_Permission_Response> lstModuleMaster = await _profileService.GetRoleMaster_PermissionList(request);
            _response.Data = lstModuleMaster.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveRoleMaster_PermissionDetails(RoleMaster_Permission_Request parameter)
        {
            int result = await _profileService.SaveRoleMaster_PermissionDetails(parameter);

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.Message = "Role Master Permission details saved successfully";
            }
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetRoleMaster_Employee_PermissionList(SearchRoleMaster_Employee_PermissionRequest request)
        {
            if (request.EmployeeId <= 0)
            {
                _response.Message = "EmployeeId is required";
            }
            else
            {
                IEnumerable<RoleMaster_Employee_Permission_Response> lstModuleMaster = await _profileService.GetRoleMaster_Employee_PermissionList(request);
                _response.Data = lstModuleMaster.ToList();
                _response.Total = request.pagination.Total;
            }
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetRoleMaster_Employee_PermissionById(long employeeid)
        {
            if (employeeid <= 0)
            {
                _response.Message = "EmployeeId is required";
            }
            else
            {
                IEnumerable<RoleMasterEmployeePermissionList> lstModuleMaster = await _profileService.GetRoleMaster_Employee_PermissionById(employeeid);
                _response.Data = lstModuleMaster.ToList();
            }
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveRoleMaster_Employee_PermissionDetails(RoleMaster_Employee_Permission_Request parameter)
        {
            if (parameter.EmployeeId <= 0)
            {
                _response.Message = "EmployeeId is required";
            }
            else
            {
                int result = await _profileService.SaveRoleMaster_Employee_PermissionDetails(parameter);

                if (result == (int)SaveEnums.NoRecordExists)
                {
                    _response.Message = "No record exists";
                }
                else if (result == (int)SaveEnums.NoResult)
                {
                    _response.Message = "Something went wrong, please try again";
                }
                else
                {
                    _response.Message = "Employee Role Master Permission details saved successfully";
                }
            }
            return _response;
        }

        #endregion
    }
}
