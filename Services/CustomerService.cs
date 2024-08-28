using Helpers;
using Interfaces.Repositories;
using Interfaces.Services;
using Models;

namespace Services
{
    public class CustomerService : ICustomerService
    {
        private ICustomerRepository _customerRepository;
        private IFileManager _fileManager;

        public CustomerService(ICustomerRepository customerRepository, IFileManager fileManager)
        {
            _customerRepository = customerRepository;
            _fileManager = fileManager;
        }

        public async Task<IEnumerable<CustomerResponse>> GetCustomersList(SearchCustomerRequest request)
        {
            return await _customerRepository.GetCustomersList(request);
        }

        public async Task<int> SaveCustomerDetails(CustomerRequest customerRequest)
        {
            return await _customerRepository.SaveCustomerDetails(customerRequest);
        }

        public async Task<CustomerDetailsResponse?> GetCustomerDetailsById(long id)
        {
            CustomerDetailsResponse objCustomerDetailsResponse = new CustomerDetailsResponse();
            CustomerResponse? data = await _customerRepository.GetCustomerDetailsById(id);

            if (data != null)
            {
                objCustomerDetailsResponse.customerDetails = data;

                //objCustomerDetailsResponse.customerDetails.GstFile = _fileManager.GetCustomerDocuments(objCustomerDetailsResponse.customerDetails.GstSavedFileName);
                //objCustomerDetailsResponse.customerDetails.PanCard = _fileManager.GetCustomerDocuments(objCustomerDetailsResponse.customerDetails.PanCardSavedFileName);

                SearchContactAddressRequest searchObj = new SearchContactAddressRequest();
                searchObj.pagination = new PaginationParameters();
                searchObj.CustomerId = data.CustomerId;

                objCustomerDetailsResponse.contactDetails = (await _customerRepository.GetCustomerContactDetailsList(searchObj)).ToList();

                //foreach (ContactDetail contact in objCustomerDetailsResponse.contactDetails)
                //{
                //    contact.PanCardFile = _fileManager.GetCustomerDocuments(contact.PanCardSavedFileName);
                //    contact.AdharCardFile = _fileManager.GetCustomerDocuments(contact.AdharCardSavedFileName);
                //}

                objCustomerDetailsResponse.addressDetails = (await _customerRepository.GetCustomerAddressDetailsList(searchObj)).ToList();
            }

            return objCustomerDetailsResponse;
        }

        public async Task<IEnumerable<CustomerDataValidationErrors>> ImportCustomersDetails(List<ImportedCustomerDetails> request)
        {
            return await _customerRepository.ImportCustomersDetails(request);
        }


        public async Task<IEnumerable<ContactDetail>> GetCustomerContactDetailsList(SearchContactAddressRequest request)
        {
            return await _customerRepository.GetCustomerContactDetailsList(request);
        }
        public async Task<int> SaveContactDetails(ContactSaveRequestParameters parameter)
        {
            return await _customerRepository.SaveContactDetails(parameter);
        }
        public async Task<ContactDetail?> GetCustomerContactDetailsById(long id)
        {
            ContactDetail? data = await _customerRepository.GetCustomerContactDetailsById(id);

            //if (data != null)
            //{
            //    data.PanCardFile = _fileManager.GetCustomerDocuments(data.PanCardSavedFileName);
            //    data.AdharCardFile = _fileManager.GetCustomerDocuments(data.AdharCardSavedFileName);
            //}
            return data;
        }

        public async Task<IEnumerable<AddressDetail>> GetCustomerAddressDetailsList(SearchContactAddressRequest request)
        {
            return await _customerRepository.GetCustomerAddressDetailsList(request);
        }
        public async Task<int> SaveAddressDetails(AddressSaveRequestParameters parameter)
        {
            return await _customerRepository.SaveAddressDetails(parameter);
        }

        public async Task<AddressDetail?> GetCustomerAddressDetailsById(long id)
        {
            AddressDetail? data = await _customerRepository.GetCustomerAddressDetailsById(id);

            return data;
        }
    }
}
