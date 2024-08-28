using Helpers;
using Interfaces.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
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
    public class CustomerController : CustomBaseController
    {
        private ResponseModel _response;
        private ICustomerService _customerService;
        private IFileManager _fileManager;

        public CustomerController(ICustomerService customerService, IFileManager fileManager)
        {
            _customerService = customerService;
            _fileManager = fileManager;

            _response = new ResponseModel();
            _response.IsSuccess = true;
        }

        #region Customer Details
     
        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetCustomersList(SearchCustomerRequest request)
        {
            var host = $"{this.Request.Scheme}://{this.Request.Host}{this.Request.PathBase}";

            IEnumerable<CustomerResponse> lstCustomers = await _customerService.GetCustomersList(request);

            foreach (var item in lstCustomers)
            {
                if (!string.IsNullOrWhiteSpace(item.GstSavedFileName))
                {
                    item.GstFileUrl = host + _fileManager.GetCustomerDocumentsFile(item.GstSavedFileName);
                }

                if (!string.IsNullOrWhiteSpace(item.PanCardSavedFileName))
                {
                    item.PanCardFileUrl = host + _fileManager.GetCustomerDocumentsFile(item.PanCardSavedFileName);
                }
            }

            _response.Data = lstCustomers;
            _response.Total = request.pagination.Total;
            return _response;

            //List<CustomerDetailsResponse> objCustomerDetailsResponse = new List<CustomerDetailsResponse>();

            //IEnumerable<CustomerResponse> lstCustomers = await _customerService.GetCustomersList(request);
            //foreach (var item in lstCustomers.ToList())
            //{
            //    var vContachDetail = await _customerService.GetCustomerDetailsById(item.CustomerId);

            //    objCustomerDetailsResponse.Add(vContachDetail);
            //}

            //_response.Data = objCustomerDetailsResponse.ToList();
            //return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveCustomerDetails([FromForm] CustomerRequest parameter)
        {
            int result;
            List<ResponseModel> lstValidationResponse = new List<ResponseModel>();
            ResponseModel? validationResponse;

            if (HttpContext.Request.Form.Files.Count > 0)
            {
                if (string.IsNullOrEmpty(parameter.GstSavedFileName))
                {
                    parameter.GstFile = HttpContext.Request.Form.Files["GstFile"];
                    parameter.GstFileName = parameter.GstFile?.FileName;
                }

                if (string.IsNullOrEmpty(parameter.PanCardSavedFileName))
                {
                    parameter.Pancard = HttpContext.Request.Form.Files["Pancard"];
                    parameter.PanCardFileName = parameter.Pancard?.FileName;
                }
            }

            //To validate Main object
            lstValidationResponse.Add(ModelStateHelper.GetValidationErrorsList(parameter));

            for (int c = 0; c < parameter.ContactDetails.Count; c++)
            {
                if (string.IsNullOrEmpty(parameter.ContactDetails[c].ContactName))
                {
                    parameter.ContactDetails[c].ContactName = "N/A";
                }


                if (string.IsNullOrEmpty(parameter.ContactDetails[c].PanCardSavedFileName))
                {
                    parameter.ContactDetails[c].Pancard = HttpContext.Request.Form.Files["ContactPancard[" + c + "]"];
                    parameter.ContactDetails[c].PanCardFileName = parameter.ContactDetails[c].Pancard?.FileName.SanitizeValue();
                }

                if (string.IsNullOrEmpty(parameter.ContactDetails[c].AdharCardSavedFileName))
                {
                    parameter.ContactDetails[c].AdharCard = HttpContext.Request.Form.Files["ContactAdharCard[" + c + "]"];
                    parameter.ContactDetails[c].AdharCardFileName = parameter.ContactDetails[c].AdharCard?.FileName.SanitizeValue();
                }

                //To validate Contact Details object
                validationResponse = ModelStateHelper.GetValidationErrorsList(parameter.ContactDetails[c]);
                lstValidationResponse.Add(validationResponse);

                if (validationResponse.IsSuccess)
                {
                    if (parameter.ContactDetails[c].Pancard != null)
                        parameter.ContactDetails[c].PanCardSavedFileName = _fileManager.UploadCustomerDocuments(parameter.ContactDetails[c].Pancard);

                    if (parameter.ContactDetails[c].AdharCard != null)
                        parameter.ContactDetails[c].AdharCardSavedFileName = _fileManager.UploadCustomerDocuments(parameter.ContactDetails[c].AdharCard);
                }
            }

            if (string.IsNullOrEmpty(parameter.AddressDetails[0].Address))
            {
                parameter.AddressDetails[0].Address = "N/A";
                parameter.AddressDetails[0].AddressId = parameter.AddressDetails[0].AddressId == null ? 0 : parameter.AddressDetails[0].AddressId;
                parameter.AddressDetails[0].StateId = parameter.AddressDetails[0].StateId == null ? 0 : parameter.AddressDetails[0].StateId;
                parameter.AddressDetails[0].RegionId = parameter.AddressDetails[0].RegionId == null ? 0 : parameter.AddressDetails[0].RegionId;
                parameter.AddressDetails[0].DistrictId = parameter.AddressDetails[0].DistrictId == null ? 0 : parameter.AddressDetails[0].DistrictId;
                parameter.AddressDetails[0].AreaId = parameter.AddressDetails[0].AreaId == null ? 0 : parameter.AddressDetails[0].AreaId;
                parameter.AddressDetails[0].Pincode = string.IsNullOrEmpty(parameter.AddressDetails[0].Pincode) ? "0" : parameter.AddressDetails[0].Pincode;
            }

            validationResponse = lstValidationResponse.Where(v => v.IsSuccess == false).FirstOrDefault();

            if (validationResponse != null && validationResponse.IsSuccess == false)
            {
                return validationResponse;
            }

            if (parameter.GstFile != null)
                parameter.GstSavedFileName = _fileManager.UploadCustomerDocuments(parameter.GstFile);

            if (parameter.Pancard != null)
                parameter.PanCardSavedFileName = _fileManager.UploadCustomerDocuments(parameter.Pancard);

            result = await _customerService.SaveCustomerDetails(parameter);
            _response.IsSuccess = false;

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Customer Name is already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.IsSuccess = true;
                _response.Message = "Customer details saved sucessfully";
            }

            return _response;
        }

        [Route("[action]")]
        [HttpGet]
        public async Task<ResponseModel> GetCustomerDetails(long id)
        {
            CustomerDetailsResponse? customer;

            if (id <= 0)
            {
                _response.IsSuccess = false;
                _response.Message = ValidationConstants.Id_Required_Msg;
            }
            else
            {
                customer = await _customerService.GetCustomerDetailsById(id);
                _response.Data = customer;
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ImportCustomersData([FromQuery] ImportRequest request)
        {
            _response.IsSuccess = false;
            List<string[]> data = new List<string[]>();
            ExcelWorksheets currentSheet;
            ExcelWorksheet workSheet;
            List<ImportedCustomerDetails> lstImportedCustomerDetails = new List<ImportedCustomerDetails>();
            IEnumerable<CustomerDataValidationErrors> lstCustomersFailedToImport;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
            int noOfCol, noOfRow;

            if (request.FileUpload == null || request.FileUpload.Length == 0)
            {
                _response.Message = "Please upload an excel file to import Customer data";
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

                if (!string.Equals(workSheet.Cells[1, 1].Value.ToString(), "CompanyName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 2].Value.ToString(), "LandlineNo", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 3].Value.ToString(), "MobileNumber", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 4].Value.ToString(), "EmailId", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 5].Value.ToString(), "CustomerTypeName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 6].Value.ToString(), "SpecialRemarks", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 7].Value.ToString(), "EmployeeName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 8].Value.ToString(), "ContactName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 9].Value.ToString(), "MobileNo", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 10].Value.ToString(), "EmailAddress", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 11].Value.ToString(), "RefPartyName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 12].Value.ToString(), "Address", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 13].Value.ToString(), "StateName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 14].Value.ToString(), "RegionName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 15].Value.ToString(), "DistrictName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 16].Value.ToString(), "AreaName", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 17].Value.ToString(), "Pincode", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 18].Value.ToString(), "NameForAddress", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 19].Value.ToString(), "BuyerMobileNo", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 20].Value.ToString(), "BuyerEmailId", StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(workSheet.Cells[1, 21].Value.ToString(), "AddressTypeName", StringComparison.OrdinalIgnoreCase) ||
                   !string.Equals(workSheet.Cells[1, 22].Value.ToString(), "IsActive", StringComparison.OrdinalIgnoreCase)
                   )
                {
                    _response.IsSuccess = false;
                    _response.Message = "Please upload a valid excel file. Please Download Format file for reference";
                    return _response;
                }

                for (int rowIterator = 2; rowIterator <= noOfRow; rowIterator++)
                {

                    lstImportedCustomerDetails.Add(new ImportedCustomerDetails()
                    {
                        CompanyName = workSheet.Cells[rowIterator, 1].Value?.ToString(),
                        LandlineNo = workSheet.Cells[rowIterator, 2].Value?.ToString(),
                        MobileNumber = workSheet.Cells[rowIterator, 3].Value?.ToString(),
                        EmailId = workSheet.Cells[rowIterator, 4].Value?.ToString(),
                        CustomerTypeName = workSheet.Cells[rowIterator, 5].Value?.ToString(),
                        SpecialRemarks = workSheet.Cells[rowIterator, 6].Value?.ToString(),
                        EmployeeName = workSheet.Cells[rowIterator, 7].Value?.ToString(),
                        ContactName = workSheet.Cells[rowIterator, 8].Value?.ToString(),
                        MobileNo = workSheet.Cells[rowIterator, 9].Value?.ToString(),
                        EmailAddress = workSheet.Cells[rowIterator, 10].Value?.ToString(),
                        RefPartyName = workSheet.Cells[rowIterator, 11].Value?.ToString(),
                        Address = workSheet.Cells[rowIterator, 12].Value?.ToString(),
                        StateName = workSheet.Cells[rowIterator, 13].Value?.ToString(),
                        RegionName = workSheet.Cells[rowIterator, 14].Value?.ToString(),
                        DistrictName = workSheet.Cells[rowIterator, 15].Value?.ToString(),
                        AreaName = workSheet.Cells[rowIterator, 16].Value?.ToString(),
                        Pincode = workSheet.Cells[rowIterator, 17].Value?.ToString(),
                        NameForAddress = workSheet.Cells[rowIterator, 18].Value?.ToString(),
                        BuyerMobileNo = workSheet.Cells[rowIterator, 19].Value?.ToString(),
                        BuyerEmailId = workSheet.Cells[rowIterator, 20].Value?.ToString(),
                        AddressTypeName = workSheet.Cells[rowIterator, 21].Value?.ToString(),
                        //contactDetails = importContactDetail,
                        //addressDetails = importAddressDetail,
                        IsActive = workSheet.Cells[rowIterator, 22].Value?.ToString()
                    });
                }
            }

            if (lstImportedCustomerDetails.Count == 0)
            {
                _response.Message = "File does not contains any record(s)";
                return _response;
            }

            lstCustomersFailedToImport = await _customerService.ImportCustomersDetails(lstImportedCustomerDetails);

            _response.IsSuccess = true;
            _response.Message = "Customers list imported successfully";

            #region Generate Excel file for Invalid Data
            if (lstCustomersFailedToImport.ToList().Count > 0)
            {
                _response.Message = "Uploaded file contains invalid records, please check downloaded file for more details";
                _response.Data = GenerateInvalidCustomerDataFile(lstCustomersFailedToImport);

            }
            #endregion

            return _response;
        }

        private byte[] GenerateInvalidCustomerDataFile(IEnumerable<CustomerDataValidationErrors> lstCustomersFailedToImport)
        {
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;

            using (MemoryStream msInvalidDataFile = new MemoryStream())
            {
                using (ExcelPackage excelInvalidData = new ExcelPackage())
                {
                    WorkSheet1 = excelInvalidData.Workbook.Worksheets.Add("Invalid_Customer_Records");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;


                    WorkSheet1.Cells[1, 1].Value = "CompanyName";
                    WorkSheet1.Cells[1, 2].Value = "LandlineNo";
                    WorkSheet1.Cells[1, 3].Value = "MobileNumber";
                    WorkSheet1.Cells[1, 4].Value = "EmailId";
                    WorkSheet1.Cells[1, 5].Value = "CustomerTypeName";
                    WorkSheet1.Cells[1, 6].Value = "SpecialRemarks";
                    WorkSheet1.Cells[1, 7].Value = "EmployeeName";
                    WorkSheet1.Cells[1, 8].Value = "ContactName";
                    WorkSheet1.Cells[1, 9].Value = "MobileNo";
                    WorkSheet1.Cells[1, 10].Value = "EmailAddress";
                    WorkSheet1.Cells[1, 11].Value = "RefPartyName";
                    WorkSheet1.Cells[1, 12].Value = "Address";
                    WorkSheet1.Cells[1, 13].Value = "StateName";
                    WorkSheet1.Cells[1, 14].Value = "RegionName";
                    WorkSheet1.Cells[1, 15].Value = "DistrictName";
                    WorkSheet1.Cells[1, 16].Value = "AreaName";
                    WorkSheet1.Cells[1, 17].Value = "Pincode";
                    WorkSheet1.Cells[1, 18].Value = "NameForAddress";
                    WorkSheet1.Cells[1, 19].Value = "BuyerMobileNo";
                    WorkSheet1.Cells[1, 20].Value = "BuyerEmailId";
                    WorkSheet1.Cells[1, 21].Value = "AddressTypeName";
                    WorkSheet1.Cells[1, 22].Value = "IsActive";
                    WorkSheet1.Cells[1, 23].Value = "ValidationMessage";


                    recordIndex = 2;

                    foreach (CustomerDataValidationErrors record in lstCustomersFailedToImport)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = record.CompanyName;
                        WorkSheet1.Cells[recordIndex, 2].Value = record.LandlineNo;
                        WorkSheet1.Cells[recordIndex, 3].Value = record.MobileNumber;
                        WorkSheet1.Cells[recordIndex, 4].Value = record.EmailId;
                        WorkSheet1.Cells[recordIndex, 5].Value = record.CustomerTypeName;
                        WorkSheet1.Cells[recordIndex, 6].Value = record.SpecialRemarks;
                        WorkSheet1.Cells[recordIndex, 7].Value = record.EmployeeName;
                        WorkSheet1.Cells[recordIndex, 8].Value = record.ContactName;
                        WorkSheet1.Cells[recordIndex, 9].Value = record.MobileNo;
                        WorkSheet1.Cells[recordIndex, 10].Value = record.EmailAddress;
                        WorkSheet1.Cells[recordIndex, 11].Value = record.RefPartyName;
                        WorkSheet1.Cells[recordIndex, 12].Value = record.Address;
                        WorkSheet1.Cells[recordIndex, 13].Value = record.StateName;
                        WorkSheet1.Cells[recordIndex, 14].Value = record.RegionName;
                        WorkSheet1.Cells[recordIndex, 15].Value = record.DistrictName;
                        WorkSheet1.Cells[recordIndex, 16].Value = record.AreaName;
                        WorkSheet1.Cells[recordIndex, 17].Value = record.Pincode;
                        WorkSheet1.Cells[recordIndex, 18].Value = record.NameForAddress;
                        WorkSheet1.Cells[recordIndex, 19].Value = record.BuyerMobileNo;
                        WorkSheet1.Cells[recordIndex, 20].Value = record.BuyerEmailId;
                        WorkSheet1.Cells[recordIndex, 21].Value = record.AddressTypeName;
                        WorkSheet1.Cells[recordIndex, 22].Value = record.IsActive;
                        WorkSheet1.Cells[recordIndex, 23].Value = record.ValidationMessage;
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
                    WorkSheet1.Column(22).AutoFit();
                    WorkSheet1.Column(23).AutoFit();

                    excelInvalidData.SaveAs(msInvalidDataFile);
                    msInvalidDataFile.Position = 0;
                    result = msInvalidDataFile.ToArray();
                }
            }

            return result;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ExportCustomerData()
        {
            _response.IsSuccess = false;
            byte[] result;
            int recordIndex;
            ExcelWorksheet WorkSheet1;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

            var request = new SearchCustomerRequest();
            request.pagination = new PaginationParameters();

            IEnumerable<CustomerResponse> lstCustomerObj = await _customerService.GetCustomersList(request);

            using (MemoryStream msExportDataFile = new MemoryStream())
            {
                using (ExcelPackage excelExportData = new ExcelPackage())
                {
                    WorkSheet1 = excelExportData.Workbook.Worksheets.Add("Customer");
                    WorkSheet1.TabColor = System.Drawing.Color.Black;
                    WorkSheet1.DefaultRowHeight = 12;

                    //Header of table
                    WorkSheet1.Row(1).Height = 20;
                    WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                    WorkSheet1.Row(1).Style.Font.Bold = true;

                    WorkSheet1.Cells[1, 1].Value = "CustomerName";
                    WorkSheet1.Cells[1, 2].Value = "Landline";
                    WorkSheet1.Cells[1, 3].Value = "Mobile No.";
                    WorkSheet1.Cells[1, 4].Value = "Email";
                    WorkSheet1.Cells[1, 5].Value = "CustomerType";
                    WorkSheet1.Cells[1, 6].Value = "Special Remarks";
                    WorkSheet1.Cells[1, 7].Value = "EmployeeRole";
                    WorkSheet1.Cells[1, 8].Value = "EmployeeName";
                    WorkSheet1.Cells[1, 9].Value = "CompanyAddress";
                    WorkSheet1.Cells[1, 10].Value = "State";
                    WorkSheet1.Cells[1, 11].Value = "Region";
                    WorkSheet1.Cells[1, 12].Value = "District";
                    WorkSheet1.Cells[1, 13].Value = "Area";
                    WorkSheet1.Cells[1, 14].Value = "Status";

                    WorkSheet1.Cells[1, 15].Value = "CreatedBy";
                    WorkSheet1.Cells[1, 16].Value = "CreatedDate";

                    recordIndex = 2;

                    foreach (var items in lstCustomerObj)
                    {
                        WorkSheet1.Cells[recordIndex, 1].Value = items.CompanyName;
                        WorkSheet1.Cells[recordIndex, 2].Value = items.LandlineNo;
                        WorkSheet1.Cells[recordIndex, 3].Value = items.MobileNumber;
                        WorkSheet1.Cells[recordIndex, 4].Value = items.EmailId;
                        WorkSheet1.Cells[recordIndex, 5].Value = items.CustomerTypeName;
                        WorkSheet1.Cells[recordIndex, 6].Value = items.SpecialRemarks;
                        WorkSheet1.Cells[recordIndex, 7].Value = items.EmployeeRole;
                        WorkSheet1.Cells[recordIndex, 8].Value = items.EmployeeName;
                        WorkSheet1.Cells[recordIndex, 9].Value = items.Address;
                        WorkSheet1.Cells[recordIndex, 10].Value = items.StateName;
                        WorkSheet1.Cells[recordIndex, 11].Value = items.RegionName;
                        WorkSheet1.Cells[recordIndex, 12].Value = items.DistrictName;
                        WorkSheet1.Cells[recordIndex, 13].Value = items.AreaName;
                        WorkSheet1.Cells[recordIndex, 14].Value = items.IsActive == true ? "Active" : "Inactive";

                        WorkSheet1.Cells[recordIndex, 15].Value = items.CreatorName;
                        WorkSheet1.Cells[recordIndex, 16].Style.Numberformat.Format = DateTimeFormatInfo.CurrentInfo.ShortDatePattern;
                        WorkSheet1.Cells[recordIndex, 16].Value = items.CreatedOn;

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

                    excelExportData.SaveAs(msExportDataFile);
                    msExportDataFile.Position = 0;
                    result = msExportDataFile.ToArray();
                }
            }

            if (result != null)
            {
                _response.Data = result;
                _response.IsSuccess = true;
                _response.Message = "Customer list Exported successfully";
            }

            return _response;
        }

        #endregion

        #region Contact Details

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetCustomerContactDetailsList(SearchContactAddressRequest request)
        {
            IEnumerable<ContactDetail> lstCustomers = await _customerService.GetCustomerContactDetailsList(request);

            _response.Data = lstCustomers;
            _response.Total = request.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveContactDetails(ContactSaveRequestParameters parameter)
        {
            //pancard Upload
            if (!string.IsNullOrWhiteSpace(parameter.PanCardFile_Base64))
            {
                var vUploadFile = _fileManager.UploadDocumentsBase64ToFile(parameter.PanCardFile_Base64, "\\Uploads\\Customers\\", parameter.PanCardFileName);

                if (!string.IsNullOrWhiteSpace(vUploadFile))
                {
                    parameter.PanCardSavedFileName = vUploadFile;
                }
            }

            //aadharcard Upload
            if (!string.IsNullOrWhiteSpace(parameter.AdharCardFile_Base64))
            {
                var vUploadFile = _fileManager.UploadDocumentsBase64ToFile(parameter.AdharCardFile_Base64, "\\Uploads\\Customers\\", parameter.AdharCardFileName);

                if (!string.IsNullOrWhiteSpace(vUploadFile))
                {
                    parameter.AdharCardSavedFileName = vUploadFile;
                }
            }

            int result = await _customerService.SaveContactDetails(parameter);

            _response.IsSuccess = false;

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Contact Name is already exists";
            }
            else if (result == (int)SaveEnums.MobileNoExists)
            {
                _response.Message = "Mobile Number is already exists";
            }
            else if (result == (int)SaveEnums.EmailAddressExists)
            {
                _response.Message = "Email Address is already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.IsSuccess = true;
                _response.Message = "Contact details saved sucessfully";
            }

            return _response;
        }

        [Route("[action]")]
        [HttpGet]
        public async Task<ResponseModel> GetCustomerContactDetailsById(long id)
        {
            if (id <= 0)
            {
                _response.IsSuccess = false;
                _response.Message = ValidationConstants.Id_Required_Msg;
            }
            else
            {
                var customer = await _customerService.GetCustomerContactDetailsById(id);
                _response.Data = customer;
            }

            return _response;
        }

        #endregion

        #region Address Details

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetCustomerAddressDetailsList(SearchContactAddressRequest request)
        {
            IEnumerable<AddressDetail> lstCustomers = await _customerService.GetCustomerAddressDetailsList(request);

            _response.Data = lstCustomers;
            _response.Total = request.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveAddressDetails(AddressSaveRequestParameters parameter)
        {
            int result = await _customerService.SaveAddressDetails(parameter);

            _response.IsSuccess = false;

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Address is already exists";
            }
            else if (result == (int)SaveEnums.MobileNoExists)
            {
                _response.Message = "Mobile Number is already exists";
            }
            else if (result == (int)SaveEnums.EmailAddressExists)
            {
                _response.Message = "Email Address is already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.IsSuccess = true;
                _response.Message = "Address details saved sucessfully";
            }

            return _response;
        }

        [Route("[action]")]
        [HttpGet]
        public async Task<ResponseModel> GetCustomerAddressDetailsById(long id)
        {
            if (id <= 0)
            {
                _response.IsSuccess = false;
                _response.Message = ValidationConstants.Id_Required_Msg;
            }
            else
            {
                var customer = await _customerService.GetCustomerAddressDetailsById(id);
                _response.Data = customer;
            }

            return _response;
        }
        #endregion

    }
}
