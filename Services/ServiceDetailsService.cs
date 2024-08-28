using Helpers;
using Interfaces.Repositories;
using Interfaces.Services;
using Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Services
{
    public class ServiceDetailsService : IServiceDetailsService
    {
        private IServiceDetailsRepository _serviceDetailsRepository;

        public ServiceDetailsService(IServiceDetailsRepository serviceDetailsRepository)
        {
            _serviceDetailsRepository = serviceDetailsRepository;
        }

        public async Task<int> SaveServiceDetails(ServiceDetailsRequest request)
        {
            return await _serviceDetailsRepository.SaveServiceDetails(request);
        }

        public async Task<IEnumerable<ServiceDetailsResponse>> GetServiceDetailsList(SearchServiceDetailsRequest request)
        {
            return await _serviceDetailsRepository.GetServiceDetailsList(request);
        }

        public async Task<ServiceDetailsResponse?> GetServiceDetailsById(long id)
        {
            return await _serviceDetailsRepository.GetServiceDetailsById(id);
        }



    }
}
