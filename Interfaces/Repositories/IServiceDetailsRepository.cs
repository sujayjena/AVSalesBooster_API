using Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Interfaces.Repositories
{
    public interface IServiceDetailsRepository
    {
        Task<int> SaveServiceDetails(ServiceDetailsRequest request);
        Task<IEnumerable<ServiceDetailsResponse>> GetServiceDetailsList(SearchServiceDetailsRequest request);
        Task<ServiceDetailsResponse?> GetServiceDetailsById(long Id);
        Task<IEnumerable<ServiceDetailsDataValidationErrors>> ImportServiceDetails(List<ImportedServiceDetails> parameters);
    }
}
