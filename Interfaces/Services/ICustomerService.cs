using Models;

namespace Interfaces.Services
{
    public interface ICustomerService
    {
        Task<IEnumerable<CustomerResponse>> GetCustomersList(SearchCustomerRequest request);
        Task<int> SaveCustomerDetails(CustomerRequest customerRequest);
        Task<CustomerDetailsResponse?> GetCustomerDetailsById(long id);
        Task<IEnumerable<CustomerDataValidationErrors>> ImportCustomersDetails(List<ImportedCustomerDetails> request);

        Task<IEnumerable<ContactDetail>> GetCustomerContactDetailsList(SearchContactAddressRequest request);
        Task<int> SaveContactDetails(ContactSaveRequestParameters parameter);
        Task<ContactDetail?> GetCustomerContactDetailsById(long id);

        Task<IEnumerable<AddressDetail>> GetCustomerAddressDetailsList(SearchContactAddressRequest request);
        Task<int> SaveAddressDetails(AddressSaveRequestParameters parameter);
        Task<AddressDetail?> GetCustomerAddressDetailsById(long id);
    }
}
