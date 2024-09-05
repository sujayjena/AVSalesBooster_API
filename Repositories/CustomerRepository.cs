using Dapper;
using Helpers;
using Interfaces.Repositories;
using Microsoft.Extensions.Configuration;
using Models;

namespace Repositories
{
    public class CustomerRepository : BaseRepository, ICustomerRepository
    {
        private IConfiguration _configuration;

        public CustomerRepository(IConfiguration configuration) : base(configuration)
        {
            _configuration = configuration;
        }

        public async Task<IEnumerable<CustomerResponse>> GetCustomersList(SearchCustomerRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@CustomerTypeId", parameters.CustomerTypeId.SanitizeValue());
            queryParameters.Add("@EmployeeId", parameters.EmployeeId.SanitizeValue());
            queryParameters.Add("@StateId", parameters.StateId.SanitizeValue());
            queryParameters.Add("@RegionId", parameters.RegionId.SanitizeValue());
            queryParameters.Add("@SearchValue", parameters.SearchValue.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@FilterType", parameters.FilterType.SanitizeValue());
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<CustomerResponse>("GetCustomers", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        public async Task<int> SaveCustomerDetails(CustomerRequest parameters)
        {
            string xmlContactData, xmlAddressData;
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@CustomerId", parameters.CustomerId);
            queryParameters.Add("@CompanyName", parameters.CompanyName.SanitizeValue());
            queryParameters.Add("@LandlineNo", parameters.LandlineNo.SanitizeValue());
            queryParameters.Add("@MobileNumber", parameters.MobileNumber.SanitizeValue());
            queryParameters.Add("@EmailId", parameters.EmailId.SanitizeValue());
            queryParameters.Add("@CustomerTypeId", parameters.CustomerTypeId);
            queryParameters.Add("@SpecialRemarks", parameters.SpecialRemarks.SanitizeValue());
            queryParameters.Add("@EmployeeRoleId", parameters.EmployeeRoleId);
            queryParameters.Add("@EmployeeId", parameters.EmployeeId);
            queryParameters.Add("@RefPartyName", parameters.RefPartyName);
            queryParameters.Add("@IndustryId", parameters.IndustryId);
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@GstFileName", parameters.GstFileName.SanitizeValue());
            queryParameters.Add("@GstSavedFileName", parameters.GstSavedFileName.SanitizeValue());
            queryParameters.Add("@PanCardFileName", parameters.PanCardFileName.SanitizeValue());
            queryParameters.Add("@PanCardSavedFileName",parameters.PanCardSavedFileName.SanitizeValue());

            xmlContactData = ConvertListToXml(parameters.ContactDetails);
            queryParameters.Add("@XmlContactData", xmlContactData);

            xmlAddressData = ConvertListToXml(parameters.AddressDetails);
            queryParameters.Add("@XmlAddressData", xmlAddressData);

            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            queryParameters.Add("@Password", EncryptDecryptHelper.EncryptString(EncryptDecryptHelper.CreateRandomPassword()));
            return await SaveByStoredProcedure<int>("SaveCustomerDetails", queryParameters);
        }

        public async Task<CustomerResponse?> GetCustomerDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<CustomerResponse>("GetCustomerDetailsById", queryParameters)).FirstOrDefault();
        }
        //public async Task<IEnumerable<CustomerDataValidationErrors>> ImportCustomersDetails(List<ImportedCustomerDetails> parameters)
        //{
        //    DynamicParameters queryParameters = new DynamicParameters();
        //    string xmlCustomerData = ConvertListToXml(parameters);
        //    queryParameters.Add("@XmlCustomerData", xmlCustomerData);
        //    queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
        //    return await ListByStoredProcedure<CustomerDataValidationErrors>("SaveImportCustomerDetails", queryParameters);
        //}


        public async Task<IEnumerable<ContactDetail>> GetCustomerContactDetailsList(SearchContactAddressRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@CustomerId", parameters.CustomerId);
            queryParameters.Add("@SearchValue", parameters.SearchValue.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<ContactDetail>("GetCustomerContactDetailsList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveContactDetails(ContactSaveRequestParameters parameter)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@ContactId", parameter.ContactId);
            queryParameters.Add("@CustomerId", parameter.CustomerId);
            queryParameters.Add("@ContactName", parameter.ContactName);
            queryParameters.Add("@MobileNo", parameter.MobileNo);
            queryParameters.Add("@EmailAddress", parameter.EmailAddress);
            queryParameters.Add("@RefPartyName", parameter.RefPartyName);
            queryParameters.Add("@PanCardSavedFileName", parameter.PanCardSavedFileName);
            queryParameters.Add("@PanCardFileName", parameter.PanCardFileName);
            queryParameters.Add("@AdharCardSavedFileName", parameter.AdharCardSavedFileName);
            queryParameters.Add("@AdharCardFileName", parameter.AdharCardFileName);
            queryParameters.Add("@IsActive",parameter.IsActive);
            queryParameters.Add("@IsDefault", parameter.IsDefault);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            return await SaveByStoredProcedure<int>("SaveContactDetails", queryParameters);
        }

        public async Task<ContactDetail?> GetCustomerContactDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<ContactDetail>("GetCustomerContactDetailsById", queryParameters)).FirstOrDefault();
        }

        public async Task<IEnumerable<AddressDetail>> GetCustomerAddressDetailsList(SearchContactAddressRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@CustomerId", parameters.CustomerId);
            queryParameters.Add("@SearchValue", parameters.SearchValue.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<AddressDetail>("GetCustomerAddressDetailsList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        public async Task<int> SaveAddressDetails(AddressSaveRequestParameters parameter)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@AddressId", parameter.AddressId);
            queryParameters.Add("@CustomerId", parameter.CustomerId);
            queryParameters.Add("@Address", parameter.Address);
            queryParameters.Add("@AddressLineTwo", parameter.AddressLineTwo);
            queryParameters.Add("@NameForAddress", parameter.NameForAddress);
            queryParameters.Add("@MobileNo", parameter.MobileNo);
            queryParameters.Add("@EmailId", parameter.EmailId);
            queryParameters.Add("@AddressTypeId", parameter.AddressTypeId);
            queryParameters.Add("@StateId", parameter.StateId);
            queryParameters.Add("@RegionId", parameter.RegionId);
            queryParameters.Add("@DistrictId", parameter.DistrictId);
            queryParameters.Add("@AreaId", parameter.AreaId);
            queryParameters.Add("@Pincode", parameter.Pincode);
            queryParameters.Add("@IsActive", parameter.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            return await SaveByStoredProcedure<int>("SaveAddressDetails", queryParameters);
        }

        public async Task<AddressDetail?> GetCustomerAddressDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<AddressDetail>("GetCustomerAddressDetailsById", queryParameters)).FirstOrDefault();
        }

        public async Task<IEnumerable<Customer_ImportDataValidation>> ImportCustomer(List<Customer_ImportData> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlData", xmlData);
            queryParameters.Add("@UserId", SessionManager.LoggedInUserId);

            return await ListByStoredProcedure<Customer_ImportDataValidation>("ImportCustomer", queryParameters);
        }

        public async Task<IEnumerable<Contact_ImportDataValidation>> ImportCustomerContact(List<Contact_ImportData> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlData", xmlData);
            queryParameters.Add("@UserId", SessionManager.LoggedInUserId);

            return await ListByStoredProcedure<Contact_ImportDataValidation>("ImportContact", queryParameters);
        }

        public async Task<IEnumerable<Address_ImportDataValidation>> ImportCustomerAddress(List<Address_ImportData> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlData", xmlData);
            queryParameters.Add("@UserId", SessionManager.LoggedInUserId);

            return await ListByStoredProcedure<Address_ImportDataValidation>("ImportAddress", queryParameters);
        }
    }
}
