using Helpers;
using Interfaces.Services;
using Microsoft.IdentityModel.Tokens;
using Models;
using Models.Constants;
using Models.Enums;
using System.Globalization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using OfficeOpenXml.Style;
using OfficeOpenXml;
using System.Data;
using Newtonsoft.Json;
using System;

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
                _response.Message = "Company Name is already exists";
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
        public async Task<ResponseModel> DownloadCustomerTemplate()
        {
            byte[]? formatFile = await Task.Run(() => _fileManager.GetFormatFileFromPath("Template_Customer.xlsx"));

            if (formatFile != null)
            {
                _response.Data = formatFile;
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> ImportCustomersData([FromQuery] ImportRequest request)
        {
            byte[] result;
            _response.IsSuccess = false;

            int noOfColCustomer, noOfRowCustomer, noOfColCustomerContact, noOfRowCustomerContact, noOfColCustomerAddress, noOfRowCustomerAddress;
            bool tableHasNullCustomer = false, tableHasNullCustomerContact = false, tableHasNullCustomerAddress = false;

            List<Customer_ImportData> lstCustomerImportRequestModel = new List<Customer_ImportData>();
            List<Contact_ImportData> lstCustomerContactImportRequestModel = new List<Contact_ImportData>();
            List<Address_ImportData> lstCustomerAddressImportRequestModel = new List<Address_ImportData>();

            DataTable dtCustomerTable;
            DataTable dtCustomerContactTable;
            DataTable dtCustomerAddressTable;

            IEnumerable<Customer_ImportDataValidation> lstCustomer_ImportDataValidation_Result;
            IEnumerable<Contact_ImportDataValidation> lstCustomerContact_ImportDataValidation_Result;
            IEnumerable<Address_ImportDataValidation> lstCustomerAddress_ImportDataValidation_Result;

            ExcelWorksheets currentSheet;
            ExcelWorksheet workSheet;
            ExcelPackage.LicenseContext = OfficeOpenXml.LicenseContext.NonCommercial;

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

                workSheet = currentSheet[0];
                noOfColCustomer = workSheet.Dimension.End.Column;
                noOfRowCustomer = workSheet.Dimension.End.Row;

                for (int rowIterator = 2; rowIterator <= noOfRowCustomer; rowIterator++)
                {
                    if (!string.IsNullOrWhiteSpace(workSheet.Cells[rowIterator, 1].Value?.ToString()) && !string.IsNullOrWhiteSpace(workSheet.Cells[rowIterator, 2].Value?.ToString()))
                    {
                        Customer_ImportData record = new Customer_ImportData();
                        record.CompanyName = workSheet.Cells[rowIterator, 1].Value != null ? workSheet.Cells[rowIterator, 1].Value.ToString() : null;
                        record.LandlineNo = workSheet.Cells[rowIterator, 2].Value != null ? workSheet.Cells[rowIterator, 2].Value.ToString() : null;
                        record.MobileNumber = workSheet.Cells[rowIterator, 3].Value != null ? workSheet.Cells[rowIterator, 3].Value.ToString() : null;
                        record.EmailId = workSheet.Cells[rowIterator, 4].Value != null ? workSheet.Cells[rowIterator, 4].Value.ToString() : null;
                        record.CustomerTypeName = workSheet.Cells[rowIterator, 5].Value != null ? workSheet.Cells[rowIterator, 5].Value.ToString() : null;
                        record.SpecialRemarks = workSheet.Cells[rowIterator, 6].Value != null ? workSheet.Cells[rowIterator, 6].Value.ToString() : null;
                        record.EmployeeName = workSheet.Cells[rowIterator, 7].Value != null ? workSheet.Cells[rowIterator, 7].Value.ToString() : null;
                        record.IsActive = workSheet.Cells[rowIterator, 8].Value != null ? workSheet.Cells[rowIterator, 8].Value.ToString() : null;

                        lstCustomerImportRequestModel.Add(record);
                    }
                }

                workSheet = currentSheet[1];
                noOfColCustomerContact = workSheet.Dimension.End.Column;
                noOfRowCustomerContact = workSheet.Dimension.End.Row;

                for (int rowIterator = 2; rowIterator <= noOfRowCustomerContact; rowIterator++)
                {
                    if (!string.IsNullOrWhiteSpace(workSheet.Cells[rowIterator, 1].Value?.ToString()) && !string.IsNullOrWhiteSpace(workSheet.Cells[rowIterator, 2].Value?.ToString()))
                    {
                        Contact_ImportData record = new Contact_ImportData();
                        record.CompanyName = workSheet.Cells[rowIterator, 1].Value != null ? workSheet.Cells[rowIterator, 1].Value.ToString() : null;
                        record.ContactName = workSheet.Cells[rowIterator, 2].Value != null ? workSheet.Cells[rowIterator, 2].Value.ToString() : null;
                        record.MobileNumber = workSheet.Cells[rowIterator, 3].Value != null ? workSheet.Cells[rowIterator, 3].Value.ToString() : null;
                        record.Email = workSheet.Cells[rowIterator, 4].Value != null ? workSheet.Cells[rowIterator, 4].Value.ToString() : null;
                        record.IsActive = workSheet.Cells[rowIterator, 5].Value != null ? workSheet.Cells[rowIterator, 5].Value.ToString() : null;

                        lstCustomerContactImportRequestModel.Add(record);
                    }
                }

                workSheet = currentSheet[2];
                noOfColCustomerAddress = workSheet.Dimension.End.Column;
                noOfRowCustomerAddress = workSheet.Dimension.End.Row;

                for (int rowIterator = 2; rowIterator <= noOfRowCustomerAddress; rowIterator++)
                {
                    if (!string.IsNullOrWhiteSpace(workSheet.Cells[rowIterator, 1].Value?.ToString()) && !string.IsNullOrWhiteSpace(workSheet.Cells[rowIterator, 2].Value?.ToString()))
                    {
                        Address_ImportData record = new Address_ImportData();
                        record.CompanyName = workSheet.Cells[rowIterator, 1].Value != null ? workSheet.Cells[rowIterator, 1].Value.ToString() : null;
                        record.Address = workSheet.Cells[rowIterator, 2].Value != null ? workSheet.Cells[rowIterator, 2].Value.ToString() : null;
                        record.State = workSheet.Cells[rowIterator, 3].Value != null ? workSheet.Cells[rowIterator, 4].Value.ToString() : null;
                        record.Region = workSheet.Cells[rowIterator, 4].Value != null ? workSheet.Cells[rowIterator, 3].Value.ToString() : null;
                        record.District = workSheet.Cells[rowIterator, 5].Value != null ? workSheet.Cells[rowIterator, 5].Value.ToString() : null;
                        record.Area = workSheet.Cells[rowIterator, 6].Value != null ? workSheet.Cells[rowIterator, 6].Value.ToString() : null;
                        record.PinCode = workSheet.Cells[rowIterator, 7].Value != null ? workSheet.Cells[rowIterator, 7].Value.ToString() : null;
                        record.IsActive = workSheet.Cells[rowIterator, 8].Value != null ? workSheet.Cells[rowIterator, 8].Value.ToString() : null;


                        lstCustomerAddressImportRequestModel.Add(record);
                    }
                }

                if (lstCustomerImportRequestModel.Count == 0)
                {
                    _response.IsSuccess = false;
                    _response.Message = "Uploaded customerfdata file does not contains any record";
                    return _response;
                }

                dtCustomerTable = (DataTable)JsonConvert.DeserializeObject(JsonConvert.SerializeObject(lstCustomerImportRequestModel), typeof(DataTable));
                dtCustomerContactTable = (DataTable)JsonConvert.DeserializeObject(JsonConvert.SerializeObject(lstCustomerContactImportRequestModel), typeof(DataTable));
                dtCustomerAddressTable = (DataTable)JsonConvert.DeserializeObject(JsonConvert.SerializeObject(lstCustomerAddressImportRequestModel), typeof(DataTable));

                //Excel Column Mismatch check. If column name has been changed then it's value will be null;
                foreach (DataRow row in dtCustomerTable.Rows)
                {
                    foreach (DataColumn col in dtCustomerTable.Columns)
                    {
                        if (row[col] == DBNull.Value)
                        {
                            tableHasNullCustomer = true;
                            break;
                        }
                    }
                }

                //Excel Column Mismatch check. If column name has been changed then it's value will be null;
                foreach (DataRow row in dtCustomerContactTable.Rows)
                {
                    foreach (DataColumn col in dtCustomerContactTable.Columns)
                    {
                        if (row[col] == DBNull.Value)
                        {
                            tableHasNullCustomerContact = true;
                            break;
                        }
                    }
                }

                //Excel Column Mismatch check. If column name has been changed then it's value will be null;
                foreach (DataRow row in dtCustomerAddressTable.Rows)
                {
                    foreach (DataColumn col in dtCustomerAddressTable.Columns)
                    {
                        if (row[col] == DBNull.Value)
                        {
                            tableHasNullCustomerAddress = true;
                            break;
                        }
                    }
                }


                //if (tableHasNullCustomer || tableHasNullCustomerContact || tableHasNullCustomerAddress)
                //{
                //    _response.IsSuccess = false;
                //    _response.Message = "Please upload a valid excel file. Please Download Format file for reference.";
                //    return _response;
                //}

                // Import Data
                lstCustomer_ImportDataValidation_Result = await _customerService.ImportCustomer(lstCustomerImportRequestModel);
                lstCustomerContact_ImportDataValidation_Result = await _customerService.ImportCustomerContact(lstCustomerContactImportRequestModel);
                lstCustomerAddress_ImportDataValidation_Result = await _customerService.ImportCustomerAddress(lstCustomerAddressImportRequestModel);

                if (lstCustomer_ImportDataValidation_Result.ToList().Count == 0 && lstCustomerContact_ImportDataValidation_Result.ToList().Count == 0 && lstCustomerAddress_ImportDataValidation_Result.ToList().Count == 0)
                {
                    _response.IsSuccess = true;
                    _response.Message = "Record imported successfully";
                }
                else
                {
                    _response.IsSuccess = true;
                    _response.Message = "Invalid record exist.";
                }

                #region Generate Excel file for Invalid Data

                if (lstCustomer_ImportDataValidation_Result.ToList().Count > 0 || lstCustomerContact_ImportDataValidation_Result.ToList().Count > 0 || lstCustomerAddress_ImportDataValidation_Result.ToList().Count > 0)
                {
                    _response.IsSuccess = false;

                    using (MemoryStream memoryStream = new MemoryStream())
                    {
                        using (ExcelPackage excelInvalidData = new ExcelPackage())
                        {
                            if (lstCustomer_ImportDataValidation_Result.ToList().Count > 0)
                            {
                                ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
                                int recordIndex;
                                ExcelWorksheet WorkSheet1 = excelInvalidData.Workbook.Worksheets.Add("Invalid_Customer_Records");
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
                                WorkSheet1.Cells[1, 8].Value = "IsActive";
                                WorkSheet1.Cells[1, 9].Value = "ErrorMessage";

                                recordIndex = 2;

                                foreach (Customer_ImportDataValidation record in lstCustomer_ImportDataValidation_Result)
                                {
                                    WorkSheet1.Cells[recordIndex, 1].Value = record.CompanyName;
                                    WorkSheet1.Cells[recordIndex, 2].Value = record.LandlineNo;
                                    WorkSheet1.Cells[recordIndex, 3].Value = record.MobileNumber;
                                    WorkSheet1.Cells[recordIndex, 4].Value = record.EmailId;
                                    WorkSheet1.Cells[recordIndex, 5].Value = record.CustomerTypeName;
                                    WorkSheet1.Cells[recordIndex, 6].Value = record.SpecialRemarks;
                                    WorkSheet1.Cells[recordIndex, 7].Value = record.EmployeeName;
                                    WorkSheet1.Cells[recordIndex, 8].Value = record.IsActive;
                                    WorkSheet1.Cells[recordIndex, 9].Value = record.ValidationMessage;

                                    recordIndex += 1;
                                }

                                WorkSheet1.Columns.AutoFit();
                            }

                            if (lstCustomerContact_ImportDataValidation_Result.ToList().Count > 0)
                            {
                                ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
                                int recordIndex;
                                ExcelWorksheet WorkSheet1 = excelInvalidData.Workbook.Worksheets.Add("Invalid_Contact_Records");
                                WorkSheet1.TabColor = System.Drawing.Color.Black;
                                WorkSheet1.DefaultRowHeight = 12;

                                //Header of table
                                WorkSheet1.Row(1).Height = 20;
                                WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                                WorkSheet1.Row(1).Style.Font.Bold = true;

                                WorkSheet1.Cells[1, 1].Value = "CompanyName";
                                WorkSheet1.Cells[1, 2].Value = "ContactName";
                                WorkSheet1.Cells[1, 3].Value = "MobileNumber";
                                WorkSheet1.Cells[1, 4].Value = "Email";
                                WorkSheet1.Cells[1, 5].Value = "IsActive";
                                WorkSheet1.Cells[1, 6].Value = "ErrorMessage";

                                recordIndex = 2;

                                foreach (Contact_ImportDataValidation record in lstCustomerContact_ImportDataValidation_Result)
                                {
                                    WorkSheet1.Cells[recordIndex, 1].Value = record.CompanyName;
                                    WorkSheet1.Cells[recordIndex, 2].Value = record.ContactName;
                                    WorkSheet1.Cells[recordIndex, 3].Value = record.MobileNumber;
                                    WorkSheet1.Cells[recordIndex, 4].Value = record.Email;
                                    WorkSheet1.Cells[recordIndex, 5].Value = record.IsActive;
                                    WorkSheet1.Cells[recordIndex, 6].Value = record.ValidationMessage;

                                    recordIndex += 1;
                                }

                                WorkSheet1.Columns.AutoFit();
                            }

                            if (lstCustomerAddress_ImportDataValidation_Result.ToList().Count > 0)
                            {
                                ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
                                int recordIndex;
                                ExcelWorksheet WorkSheet1 = excelInvalidData.Workbook.Worksheets.Add("Invalid_Address_Records");
                                WorkSheet1.TabColor = System.Drawing.Color.Black;
                                WorkSheet1.DefaultRowHeight = 12;

                                //Header of table
                                WorkSheet1.Row(1).Height = 20;
                                WorkSheet1.Row(1).Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                                WorkSheet1.Row(1).Style.Font.Bold = true;

                                WorkSheet1.Cells[1, 1].Value = "CompanyName";
                                WorkSheet1.Cells[1, 2].Value = "Address";
                                WorkSheet1.Cells[1, 3].Value = "State";
                                WorkSheet1.Cells[1, 4].Value = "Region";
                                WorkSheet1.Cells[1, 5].Value = "District";
                                WorkSheet1.Cells[1, 6].Value = "Area";
                                WorkSheet1.Cells[1, 7].Value = "PinCode";
                                WorkSheet1.Cells[1, 8].Value = "IsActive";
                                WorkSheet1.Cells[1, 9].Value = "ErrorMessage";

                                recordIndex = 2;

                                foreach (Address_ImportDataValidation record in lstCustomerAddress_ImportDataValidation_Result)
                                {
                                    WorkSheet1.Cells[recordIndex, 1].Value = record.CompanyName;
                                    WorkSheet1.Cells[recordIndex, 2].Value = record.Address;
                                    WorkSheet1.Cells[recordIndex, 3].Value = record.State;
                                    WorkSheet1.Cells[recordIndex, 4].Value = record.Region;
                                    WorkSheet1.Cells[recordIndex, 5].Value = record.District;
                                    WorkSheet1.Cells[recordIndex, 6].Value = record.Area;
                                    WorkSheet1.Cells[recordIndex, 7].Value = record.PinCode;
                                    WorkSheet1.Cells[recordIndex, 8].Value = record.IsActive;
                                    WorkSheet1.Cells[recordIndex, 9].Value = record.ValidationMessage;

                                    recordIndex += 1;
                                }

                                WorkSheet1.Columns.AutoFit();
                            }

                            excelInvalidData.SaveAs(memoryStream);
                            memoryStream.Position = 0;
                            result = memoryStream.ToArray();

                            _response.Data = result;
                        }
                    }
                }

                #endregion

                return _response;
            }
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
