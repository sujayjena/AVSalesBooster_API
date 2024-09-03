using Models;

namespace Interfaces.Repositories
{
    public interface ICustomerRepository
    {
        Task<IEnumerable<CustomerResponse>> GetCustomersList(SearchCustomerRequest request);
        Task<int> SaveCustomerDetails(CustomerRequest parameters);
        Task<CustomerResponse?> GetCustomerDetailsById(long id);
        //Task<IEnumerable<CustomerDataValidationErrors>> ImportCustomersDetails(List<ImportedCustomerDetails> parameters);

        Task<IEnumerable<ContactDetail>> GetCustomerContactDetailsList(SearchContactAddressRequest request);
        Task<int> SaveContactDetails(ContactSaveRequestParameters parameter);
        Task<ContactDetail?> GetCustomerContactDetailsById(long id);

        Task<IEnumerable<AddressDetail>> GetCustomerAddressDetailsList(SearchContactAddressRequest request);
        Task<int> SaveAddressDetails(AddressSaveRequestParameters parameter);
        Task<AddressDetail?> GetCustomerAddressDetailsById(long id);

        Task<IEnumerable<Customer_ImportDataValidation>> ImportCustomer(List<Customer_ImportData> parameters);
        Task<IEnumerable<Contact_ImportDataValidation>> ImportCustomerContact(List<Contact_ImportData> parameters);
        Task<IEnumerable<Address_ImportDataValidation>> ImportCustomerAddress(List<Address_ImportData> parameters);
    }
}
