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
using System.Collections.Generic;
using System.Globalization;
using Microsoft.Extensions.Hosting;

namespace AVSalesBoosterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BroadCastController : CustomBaseController
    {
        private ResponseModel _response;
        private IBroadCastService _broadCastService;
        private IFileManager _fileManager;
        private IAdminService _adminService;

        public BroadCastController(IBroadCastService broadCastService, IFileManager fileManager, IAdminService adminService)
        {
            _broadCastService = broadCastService;
            _fileManager = fileManager;
            _adminService = adminService;

            _response = new ResponseModel();
            _response.IsSuccess = true;
        }

        #region Catalog API

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetCatalogDetailsList(SearchCatalogRequest request)
        {
            var host = $"{this.Request.Scheme}://{this.Request.Host}{this.Request.PathBase}";

            IEnumerable<CatalogResponse> lstCatalog = await _broadCastService.GetCatalogDetailsList(request);

            foreach (var item in lstCatalog)
            {
                var imageObj = await _broadCastService.GetCatalogDetailsById(item.CatalogId);
                var catalogObj = await _broadCastService.GetCatalogDetailsById(item.CatalogId);

                //item.ImageFile = imageObj.catalogDetails.ImageFile;
                //item.CatalogFile = catalogObj.catalogDetails.CatalogFile;

                if (!string.IsNullOrWhiteSpace(item.ImageSavedFileName))
                {
                    item.ImageFileUrl = host + _fileManager.GetCatalogDocumentsFile(item.ImageSavedFileName);
                }

                if (!string.IsNullOrWhiteSpace(item.CatalogSavedFileName))
                {
                    item.CatalogFileUrl = host + _fileManager.GetCatalogDocumentsFile(item.CatalogSavedFileName);
                }
            }

            _response.Data = lstCatalog.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveCatalogDetails([FromForm] CatalogRequest parameter)
        {
            int result;
            List<ResponseModel> lstValidationResponse = new List<ResponseModel>();
            ResponseModel? validationResponse;

            if (HttpContext.Request.Form.Files.Count > 0)
            {
                if (string.IsNullOrEmpty(parameter.ImageSavedFileName))
                {
                    parameter.ImageFile = HttpContext.Request.Form.Files["ImageFile"];
                    parameter.ImageFileName = parameter.ImageFile?.FileName;
                }

                if (string.IsNullOrEmpty(parameter.CatalogSavedFileName))
                {
                    parameter.CatalogFile = HttpContext.Request.Form.Files["CatalogFile"];
                    parameter.CatalogFileName = parameter.CatalogFile?.FileName;
                }
            }

            //To validate Main object
            lstValidationResponse.Add(ModelStateHelper.GetValidationErrorsList(parameter));

            validationResponse = lstValidationResponse.Where(v => v.IsSuccess == false).FirstOrDefault();

            if (validationResponse != null && validationResponse.IsSuccess == false)
            {
                return validationResponse;
            }

            //check the duplicate CollectionId
            if (parameter.CatalogId == 0)
            {
                var vcatalogRequest = new SearchCatalogRequest();
                vcatalogRequest.pagination = new PaginationParameters();
                var dupCatalogDetail = _broadCastService.GetCatalogDetailsList(vcatalogRequest).Result.Where(x => x.CollectionId == parameter.CollectionId).ToList();
                if (dupCatalogDetail.Count > 0)
                {
                    _response.IsSuccess = false;
                    _response.Message = "Collection Name is already exists";

                    return _response;
                }
            }

            if (parameter.ImageFile != null)
                parameter.ImageSavedFileName = _fileManager.UploadCatalogDocuments(parameter.ImageFile);

            if (parameter.CatalogFile != null)
                parameter.CatalogSavedFileName = _fileManager.UploadCatalogDocuments(parameter.CatalogFile);

            result = await _broadCastService.SaveCatalogDetails(parameter);
            _response.IsSuccess = false;

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Catalog is already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.IsSuccess = true;
                _response.Message = "Catalog details saved successfully";
            }

            return _response;
        }

        [Route("[action]")]
        [HttpGet]
        public async Task<ResponseModel> GetCatalogDetailsById(long id)
        {
            var host = $"{this.Request.Scheme}://{this.Request.Host}{this.Request.PathBase}";

            CatalogDetailsResponse? catalog;

            if (id <= 0)
            {
                _response.IsSuccess = false;
                _response.Message = ValidationConstants.Id_Required_Msg;
            }
            else
            {
                catalog = await _broadCastService.GetCatalogDetailsById(id);

                _response.Data = catalog;
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetBroadCastCollectionNameList()
        {
            IEnumerable<CollectionResponseModel> lstCollections = await _broadCastService.GetBroadCastCollectionNameList();
            _response.Data = lstCollections.ToList();
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ExportCatalogData()
        {
            _response.IsSuccess = false;
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

            var request = new SearchCatalogRequest();
            request.pagination = new PaginationParameters();

            IEnumerable<CatalogResponse> lstCatalogObj = await _broadCastService.GetCatalogDetailsList(request);

            using (MemoryStream msExportDataFile = new MemoryStream())
            {
                using (ExcelPackage excelExportData = new ExcelPackage())
                {
                    WorkSheet1 = excelExportData.Workbook.Worksheets.Add("Catalog");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "LaunchDate";
                    WorkSheet1.Cells[1, 2].Value = "CollectionName";
                    WorkSheet1.Cells[1, 3].Value = "Remarks";
                    WorkSheet1.Cells[1, 4].Value = "Status";

                    WorkSheet1.Cells[1, 5].Value = "CreatedBy";
                    WorkSheet1.Cells[1, 6].Value = "CreatedDate";

                    recordIndex = 2;

                    foreach (var items in lstCatalogObj)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = items.LaunchDate;
                        WorkSheet1.Cells[recordIndex, 1].Style.Numberformat.Format = DateTimeFormatInfo.CurrentInfo.ShortDatePattern;
                        WorkSheet1.Cells[recordIndex, 2].Value = items.CollectionName;
                        WorkSheet1.Cells[recordIndex, 3].Value = items.Remark;
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
                _response.Message = "Catalog list Exported successfully";
            }

            return _response;
        }

        #endregion

        #region Catalog Related API

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetCatalogRelatedList(SearchCatalogRelatedRequest request)
        {
            var host = $"{this.Request.Scheme}://{this.Request.Host}{this.Request.PathBase}";

            IEnumerable<CatalogRelatedResponse> lstCatalog = await _broadCastService.GetCatalogRelatedList(request);

            foreach (var item in lstCatalog)
            {
                if (!string.IsNullOrWhiteSpace(item.ImageSavedFileName))
                {
                    item.ImageFileUrl = host + _fileManager.GetDesignDcoumentFile(item.ImageSavedFileName);
                }
            }

            _response.Data = lstCatalog.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveCatalogRelatedDetails([FromForm] CatalogRelatedRequest parameter)
        {
            int result;
            List<ResponseModel> lstValidationResponse = new List<ResponseModel>();
            ResponseModel? validationResponse;

            if (HttpContext.Request.Form.Files.Count > 0)
            {
                if (string.IsNullOrEmpty(parameter.ImageSavedFileName))
                {
                    parameter.ImageFile = HttpContext.Request.Form.Files["ImageFile"];
                    parameter.ImageFileName = parameter.ImageFile?.FileName;
                }
            }

            //To validate Main object
            lstValidationResponse.Add(ModelStateHelper.GetValidationErrorsList(parameter));

            validationResponse = lstValidationResponse.Where(v => v.IsSuccess == false).FirstOrDefault();

            if (validationResponse != null && validationResponse.IsSuccess == false)
            {
                return validationResponse;
            }

            if (parameter.ImageFile != null)
                //parameter.ImageSavedFileName = _fileManager.UploadCatalogRelatedDocuments(parameter.ImageFile);
                parameter.ImageSavedFileName = _fileManager.UploadDesignFiles(parameter.ImageFile);


            result = await _broadCastService.SaveCatalogRelatedDetails(parameter);
            _response.IsSuccess = false;

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Catalog is already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.IsSuccess = true;
                _response.Message = "Catalog Related details saved successfully";
            }

            return _response;
        }

        [Route("[action]")]
        [HttpGet]
        public async Task<ResponseModel> GetCatalogRelatedListById(long id)
        {
            CatalogRelatedDetailsResponse? catalog;

            var host = $"{this.Request.Scheme}://{this.Request.Host}{this.Request.PathBase}";

            if (id <= 0)
            {
                _response.IsSuccess = false;
                _response.Message = ValidationConstants.Id_Required_Msg;
            }
            else
            {
                catalog = await _broadCastService.GetCatalogRelatedListById(id);

                _response.Data = catalog;
            }

            return _response;
        }

        #endregion

        #region Project API

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetProjectList(SearchProjectRequest request)
        {
            var host = $"{this.Request.Scheme}://{this.Request.Host}{this.Request.PathBase}";

            IEnumerable<ProjectResponse> lstCatalog = await _broadCastService.GetProjectList(request);

            foreach (var item in lstCatalog)
            {
                if (!string.IsNullOrWhiteSpace(item.ProjectSavedFileName))
                {
                    item.ProjectFileUrl = host + _fileManager.GetProjectDocumentsFile(item.ProjectSavedFileName);
                }
            }

            _response.Data = lstCatalog.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveProject(ProjectRequest parameter)
        {
            //int result;
            //List<ResponseModel> lstValidationResponse = new List<ResponseModel>();
            //ResponseModel? validationResponse;

            //if (HttpContext.Request.Form.Files.Count > 0)
            //{
            //    if (string.IsNullOrEmpty(parameter.ProjectSavedFileName))
            //    {
            //        parameter.ProjectFile = HttpContext.Request.Form.Files["ProjectFile"];
            //        parameter.ProjectFileName = parameter.ProjectFile?.FileName;
            //    }
            //}

            //To validate Main object
            //lstValidationResponse.Add(ModelStateHelper.GetValidationErrorsList(parameter));

            //validationResponse = lstValidationResponse.Where(v => v.IsSuccess == false).FirstOrDefault();

            //if (validationResponse != null && validationResponse.IsSuccess == false)
            //{
            //    return validationResponse;
            //}

            //if (parameter.ProjectFile != null)
            //parameter.ProjectSavedFileName = _fileManager.UploadProjectDocuments(parameter.ProjectFile);

            // Project Image Upload
            if (parameter! != null && !string.IsNullOrWhiteSpace(parameter.Project_Base64))
            {
                var vUploadFile = _fileManager.UploadDocumentsBase64ToFile(parameter.Project_Base64, "\\Uploads\\Project\\", parameter.ProjectFileName);

                if (!string.IsNullOrWhiteSpace(vUploadFile))
                {
                    parameter.ProjectSavedFileName = vUploadFile;
                }
            }

            int result = await _broadCastService.SaveProject(parameter);
            _response.IsSuccess = false;

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Project is already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.IsSuccess = true;
                _response.Message = "Project saved successfully";

                // Add data into case study details
                foreach (var items in parameter.caseStudyList)
                {
                    // Feature Image Upload
                    if (items! != null && !string.IsNullOrWhiteSpace(items.CaseStudy_Base64))
                    {
                        var vUploadFile = _fileManager.UploadDocumentsBase64ToFile(items.CaseStudy_Base64, "\\Uploads\\Project\\CaseStudy\\", items.CaseStudyFileName);

                        if (!string.IsNullOrWhiteSpace(vUploadFile))
                        {
                            items.CaseStudySavedFileName = vUploadFile;
                        }
                    }

                    var vProjectCaseStudy = new ProjectCaseStudyRequest()
                    {
                        ProjectCaseStudyId = items.ProjectCaseStudyId,
                        ProjectId = result,
                        CaseStudyFileName = items.CaseStudyFileName,
                        CaseStudySavedFileName = items.CaseStudySavedFileName,
                        IsActive = items.IsActive,
                    };

                    int resultProjectCaseStudy = await _broadCastService.SaveProjectCaseStudyDetails(vProjectCaseStudy);
                }

                // Add data into clientele details
                foreach (var items in parameter.clienteleList)
                {
                    var vProjectClientele = new ProjectClienteleRequest()
                    {
                        ProjectClienteleId = items.ProjectClienteleId,
                        ProjectId = result,
                        CountryId = items.CountryId,
                        IndustryId = items.IndustryId,
                        IsActive = items.IsActive,
                    };

                    int resultProjectClientele = await _broadCastService.SaveProjectClienteleDetails(vProjectClientele);
                }
            }

            return _response;
        }

        [Route("[action]")]
        [HttpGet]
        public async Task<ResponseModel> GetProjectDetailsById(long id)
        {
            var host = $"{this.Request.Scheme}://{this.Request.Host}{this.Request.PathBase}";

            ProjectDetailsResponse project =new ProjectDetailsResponse();

            if (id <= 0)
            {
                _response.IsSuccess = false;
                _response.Message = ValidationConstants.Id_Required_Msg;
            }
            else
            {
                var list = await _broadCastService.GetProjectDetailsById(id);
                if (list != null)
                {
                    project.ProjectId = list.ProjectId;
                    project.ProjectName = list.ProjectName;
                    project.Description = list.Description;
                    project.CompletionDate = list.CompletionDate;
                    project.ProjectFileName = list.ProjectFileName;
                    project.ProjectSavedFileName = list.ProjectSavedFileName;

                    if (!string.IsNullOrWhiteSpace(list.ProjectSavedFileName))
                    {
                        project.ProjectFileUrl = host + _fileManager.GetProjectDocumentsFile(list.ProjectSavedFileName);
                    }

                    project.IsActive = list.IsActive;
                    project.CreatorName = list.CreatorName;
                    project.CreatedBy = list.CreatedBy;
                    project.CreatedOn = list.CreatedOn;

                    var vSearchRequest = new SearchProjectCaseStudy_ClienteleRequest();
                    vSearchRequest.ProjectId = project.ProjectId;
                    vSearchRequest.pagination = new PaginationParameters();

                    List<ProjectCaseStudyResponse> vCaseStudyList =new List<ProjectCaseStudyResponse>();
                    var vProjectCaseStudy = await _broadCastService.GetProjectCaseStudyList(vSearchRequest);
                    foreach(var item in vProjectCaseStudy)
                    {
                        var caseStudyObj = new ProjectCaseStudyResponse();
                        caseStudyObj.ProjectCaseStudyId = item.ProjectCaseStudyId;
                        caseStudyObj.ProjectId = item.ProjectId;
                        caseStudyObj.CaseStudyFileName = item.CaseStudyFileName;
                        caseStudyObj.CaseStudySavedFileName = item.CaseStudySavedFileName;

                        if (!string.IsNullOrWhiteSpace(item.CaseStudySavedFileName))
                        {
                            caseStudyObj.CaseStudyFileUrl = host + _fileManager.GetProjectCaseStudyFile(item.CaseStudySavedFileName);
                        }
                      
                        caseStudyObj.IsActive = item.IsActive;
                        caseStudyObj.CreatorName = item.CreatorName;
                        caseStudyObj.CreatedBy = item.CreatedBy;
                        caseStudyObj.CreatedOn = item.CreatedOn;

                        vCaseStudyList.Add(caseStudyObj);
                    }

                    List<ProjectClienteleResponse> vClienteleList = new List<ProjectClienteleResponse>();
                    var vProjectClientele = await _broadCastService.GetProjectClienteleList(vSearchRequest);
                    foreach (var item in vProjectClientele)
                    {
                        var clienteleObj = new ProjectClienteleResponse();
                        clienteleObj.ProjectClienteleId = item.ProjectClienteleId;
                        clienteleObj.ProjectId = item.ProjectId;
                        clienteleObj.CountryId = item.CountryId;
                        clienteleObj.CountryName = item.CountryName;
                        clienteleObj.IndustryId = item.IndustryId;
                        clienteleObj.IndustryName = item.IndustryName;
                        clienteleObj.IsActive = item.IsActive;
                        clienteleObj.CreatorName = item.CreatorName;
                        clienteleObj.CreatedBy = item.CreatedBy;
                        clienteleObj.CreatedOn = item.CreatedOn;

                        vClienteleList.Add(clienteleObj);
                    }

                    project.caseStudyList = vCaseStudyList;
                    project.clienteleList = vClienteleList;
                }

                _response.Data = project;
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ExportProjectData()
        {
            _response.IsSuccess = false;
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

            var request = new SearchProjectRequest();
            request.pagination = new PaginationParameters();

            IEnumerable<ProjectResponse> lstProjectObj = await _broadCastService.GetProjectList(request);

            using (MemoryStream msExportDataFile = new MemoryStream())
            {
                using (ExcelPackage excelExportData = new ExcelPackage())
                {
                    WorkSheet1 = excelExportData.Workbook.Worksheets.Add("Project");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "ProjectName";
                    WorkSheet1.Cells[1, 2].Value = "ProjectDescription";
                    WorkSheet1.Cells[1, 3].Value = "CompletionDate";
                    WorkSheet1.Cells[1, 4].Value = "Status";

                    WorkSheet1.Cells[1, 5].Value = "CreatedBy";
                    WorkSheet1.Cells[1, 6].Value = "CreatedDate";

                    recordIndex = 2;

                    foreach (var items in lstProjectObj)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = items.ProjectName;
                        WorkSheet1.Cells[recordIndex, 2].Value = items.Description;
                        WorkSheet1.Cells[recordIndex, 3].Value = items.CompletionDate;
                        WorkSheet1.Cells[recordIndex, 3].Style.Numberformat.Format = DateTimeFormatInfo.CurrentInfo.ShortDatePattern;
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
                _response.Message = "Project list Exported successfully";
            }

            return _response;
        }

        #endregion

        #region BroadCast API

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveBroadCast(BroadCastRequest parameter)
        {
            int result = await _broadCastService.SaveBroadCast(parameter);
            _response.IsSuccess = false;

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "BroadCast is already exists";
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
        public async Task<ResponseModel> GetBroadCastList(SearchBroadCastRequest request)
        {
            IEnumerable<BroadCastResponse> lstCatalog = await _broadCastService.GetBroadCastList(request);

            _response.Data = lstCatalog.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpGet]
        public async Task<ResponseModel> GetBroadCastDetailsById(long id)
        {
            if (id <= 0)
            {
                _response.IsSuccess = false;
                _response.Message = ValidationConstants.Id_Required_Msg;
            }
            else
            {
                var list = await _broadCastService.GetBroadCastDetailsById(id);

                _response.Data = list;
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ExportBroadCastData()
        {
            _response.IsSuccess = false;
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

            var request = new SearchBroadCastRequest();
            request.pagination = new PaginationParameters();

            IEnumerable<BroadCastResponse> lstObj = await _broadCastService.GetBroadCastList(request);

            using (MemoryStream msExportDataFile = new MemoryStream())
            {
                using (ExcelPackage excelExportData = new ExcelPackage())
                {
                    WorkSheet1 = excelExportData.Workbook.Worksheets.Add("BroadCast");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "Message Field";
                    WorkSheet1.Cells[1, 2].Value = "Sequence";
                    WorkSheet1.Cells[1, 3].Value = "Status";

                    WorkSheet1.Cells[1, 4].Value = "CreatedBy";
                    WorkSheet1.Cells[1, 5].Value = "CreatedDate";

                    recordIndex = 2;

                    foreach (var items in lstObj)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = items.MessageName;
                        WorkSheet1.Cells[recordIndex, 2].Value = items.SequenceNo;
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
                _response.Message = "Record Exported successfully";
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> DeleteBroadCastDetailsById(long Id)
        {
            int result = await _broadCastService.DeleteBroadCastDetailsById(Id);
            _response.IsSuccess = false;

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else
            {
                _response.IsSuccess = true;
                _response.Message = "Record deleted successfully";
            }

            return _response;
        }

        #endregion
    }
}
