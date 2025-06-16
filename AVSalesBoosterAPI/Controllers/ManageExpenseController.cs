using Helpers;
using Interfaces.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Models;
using Models.Enums;
using OfficeOpenXml.Style;
using OfficeOpenXml;
using Services;
using System.Globalization;
using Nancy;

namespace AVSalesBoosterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ManageExpenseController : CustomBaseController
    {
        private ResponseModel _response;
        private IFileManager _fileManager;

        private IManageExpenseService _manageExpenseService;

        public ManageExpenseController(IManageExpenseService manageExpenseService, IFileManager fileManager)
        {
            _fileManager = fileManager;

            _manageExpenseService = manageExpenseService;

            _response = new ResponseModel();
            _response.IsSuccess = true;
        }

        #region Expense

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveExpense(Expense_Request parameters)
        {
            //Save / Update
            int result = await _manageExpenseService.SaveExpense(parameters);

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
                if (parameters.Id > 0)
                {
                    _response.Message = "Record updated successfully";
                }
                else
                {
                    _response.Message = "Record details saved successfully";
                }
            }

            //Add / Update Expense Details
            if (result > 0)
            {
                foreach (var item in parameters.ExpenseDetails)
                {
                    //Image Upload
                    if (!string.IsNullOrWhiteSpace(item.ExpenseImageFile_Base64))
                    {
                        var vUploadFile = _fileManager.UploadDocumentsBase64ToFile(item.ExpenseImageFile_Base64, "\\Uploads\\Expense\\", item.ExpenseImageOriginalFileName);

                        if (!string.IsNullOrWhiteSpace(vUploadFile))
                        {
                            item.ExpenseImageFileName = vUploadFile;
                        }
                    }

                    var vExpenseDetails_Request = new ExpenseDetails_Request()
                    {
                        Id = item.Id,
                        ExpenseId = result,
                        ExpenseDate = item.ExpenseDate,
                        ExpenseTypeId = item.ExpenseTypeId,
                        ExpenseDescription = item.ExpenseDescription,
                        ExpenseAmount = item.ExpenseAmount,
                        ExpenseImageFileName = item.ExpenseImageFileName,
                        ExpenseImageOriginalFileName = item.ExpenseImageOriginalFileName,
                        StatusId = item.StatusId,
                    };

                    int resultExpenseDetails = await _manageExpenseService.SaveExpenseDetails(vExpenseDetails_Request);
                }
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetExpenseList(Expense_Search parameters)
        {
            var objList = await _manageExpenseService.GetExpenseList(parameters);
            _response.Data = objList.ToList();
            _response.Total = parameters.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetExpenseById(int Id)
        {
            var vExpense_Response = new Expense_Response();

            if (Id <= 0)
            {
                _response.Message = "Id is required";
            }
            else
            {
                var vResultObj = await _manageExpenseService.GetExpenseById(Id);
                if (vResultObj != null)
                {
                    vExpense_Response.Id = vResultObj.Id;
                    vExpense_Response.ExpenseNumber = vResultObj.ExpenseNumber;
                    vExpense_Response.WithoutVisit = vResultObj.WithoutVisit;
                    vExpense_Response.VisitId = vResultObj.VisitId;
                    vExpense_Response.VisitNo = vResultObj.VisitNo;
                    vExpense_Response.IsActive = vResultObj.IsActive;

                    vExpense_Response.CreatedBy = vResultObj.CreatedBy;
                    vExpense_Response.CreatedDate = vResultObj.CreatedDate;
                    vExpense_Response.CreatorName = vResultObj.CreatorName;

                    var vExpenseDetails_Search = new ExpenseDetails_Search()
                    {
                        ExpenseId = vResultObj.Id,
                        StatusId = 0,
                        pagination = new PaginationParameters()
                    };

                    var vResultExpenseListObj = await _manageExpenseService.GetExpenseDetailsList(vExpenseDetails_Search);
                    foreach (var item in vResultExpenseListObj)
                    {
                        var vExpenseDetails_Response = new ExpenseDetails_Response()
                        {
                            Id = item.Id,
                            ExpenseId = vResultObj.Id,
                            ExpenseNumber = item.ExpenseNumber,

                            ExpenseDate = item.ExpenseDate,
                            ExpenseTypeId = item.ExpenseTypeId,
                            ExpenseTypeName = item.ExpenseTypeName,

                            ExpenseDescription = item.ExpenseDescription,
                            ExpenseAmount = item.ExpenseAmount,
                            ExpenseImageFileName = item.ExpenseImageFileName,
                            ExpenseImageOriginalFileName = item.ExpenseImageOriginalFileName,
                            ExpenseImageFileURL = item.ExpenseImageFileURL,
                            StatusId = item.StatusId,
                            StatusName = item.StatusName,

                            CreatedBy = item.CreatedBy,
                            CreatorName = item.CreatorName,
                            CreatedDate = item.CreatedDate,
                        };

                        vExpense_Response.ExpenseDetails.Add(vExpenseDetails_Response);
                    }
                }

                _response.Data = vExpense_Response;
            }
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ExportExpenseData()
        {
            _response.IsSuccess = false;
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

            var request = new ExpenseDetails_Search();
            request.pagination = new PaginationParameters();
            request.ExpenseId = 0;
            request.StatusId = 0;

            IEnumerable<ExpenseDetails_Response> lstObj = await _manageExpenseService.GetExpenseDetailsList(request);

            using (MemoryStream msExportDataFile = new MemoryStream())
            {
                using (ExcelPackage excelExportData = new ExcelPackage())
                {
                    WorkSheet1 = excelExportData.Workbook.Worksheets.Add("Expense");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "Expense Number";
                    WorkSheet1.Cells[1, 2].Value = "Without Visit";
                    WorkSheet1.Cells[1, 3].Value = "Expense Date";
                    WorkSheet1.Cells[1, 4].Value = "Expense Type";
                    WorkSheet1.Cells[1, 5].Value = "Description";
                    WorkSheet1.Cells[1, 6].Value = "Amount(Rs)";

                    WorkSheet1.Cells[1, 7].Value = "CreatedBy";
                    WorkSheet1.Cells[1, 8].Value = "CreatedDate";

                    recordIndex = 2;

                    foreach (var items in lstObj.OrderByDescending(x=>x.ExpenseNumber))
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = items.ExpenseNumber;
                        WorkSheet1.Cells[recordIndex, 2].Value = items.VisitNo;
                        WorkSheet1.Cells[recordIndex, 3].Style.Numberformat.Format = DateTimeFormatInfo.CurrentInfo.ShortDatePattern;
                        WorkSheet1.Cells[recordIndex, 3].Value = items.ExpenseDate;
                        WorkSheet1.Cells[recordIndex, 4].Value = items.ExpenseTypeName;
                        WorkSheet1.Cells[recordIndex, 5].Value = items.ExpenseDescription;
                        WorkSheet1.Cells[recordIndex, 6].Value = items.ExpenseAmount;

                        WorkSheet1.Cells[recordIndex, 7].Value = items.CreatorName;
                        WorkSheet1.Cells[recordIndex, 8].Style.Numberformat.Format = DateTimeFormatInfo.CurrentInfo.ShortDatePattern;
                        WorkSheet1.Cells[recordIndex, 8].Value = items.CreatedDate;

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
                _response.Message = "Record Exported successfully";
            }

            return _response;
        }

        #endregion

        #region Expense Details

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveExpenseDetails(ExpenseDetails_Request parameters)
        {
            //Image Upload
            if (!string.IsNullOrWhiteSpace(parameters.ExpenseImageFile_Base64))
            {
                var vUploadFile = _fileManager.UploadDocumentsBase64ToFile(parameters.ExpenseImageFile_Base64, "\\Uploads\\Expense\\", parameters.ExpenseImageOriginalFileName);

                if (!string.IsNullOrWhiteSpace(vUploadFile))
                {
                    parameters.ExpenseImageFileName = vUploadFile;
                }
            }

            //Save / Update
            int result = await _manageExpenseService.SaveExpenseDetails(parameters);

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
                if (parameters.Id > 0)
                {
                    _response.Message = "Record updated successfully";
                }
                else
                {
                    _response.Message = "Record details saved successfully";
                }
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetExpenseDetailsList(ExpenseDetails_Search parameters)
        {
            var objList = await _manageExpenseService.GetExpenseDetailsList(parameters);
            _response.Data = objList.ToList();
            _response.Total = parameters.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetExpenseDetailsById(int Id)
        {
            if (Id <= 0)
            {
                _response.Message = "Id is required";
            }
            else
            {
                var vResultObj = await _manageExpenseService.GetExpenseDetailsById(Id);

                _response.Data = vResultObj;
            }
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ExpenseDetailsApproveNReject(Expense_ApproveNReject parameters)
        {
            if (parameters.Id <= 0)
            {
                _response.Message = "Id is required";
            }
            else
            {
                int resultExpenseDetails = await _manageExpenseService.ExpenseDetailsApproveNReject(parameters);

                if (resultExpenseDetails == (int)SaveEnums.NoRecordExists)
                {
                    _response.Message = "No record exists";
                }
                else if (resultExpenseDetails == (int)SaveEnums.NameExists)
                {
                    _response.Message = "Record is already exists";
                }
                else if (resultExpenseDetails == (int)SaveEnums.NoResult)
                {
                    _response.Message = "Something went wrong, please try again";
                }
                else
                {
                    _response.Message = "Record details saved successfully";
                }
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetExpenseDetailsApproveRejectHistoryList(ExpenseDetailsApproveRejectHistory_Search parameters)
        {
            var objList = await _manageExpenseService.GetExpenseDetailsApproveRejectHistoryList(parameters);
            _response.Data = objList.ToList();
            _response.Total = parameters.pagination.Total;
            return _response;
        }

        #endregion
    }
}
