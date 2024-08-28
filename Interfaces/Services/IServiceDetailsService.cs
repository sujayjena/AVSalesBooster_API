using Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Interfaces.Services
{
    public interface IServiceDetailsService
    {
        Task<int> SaveServiceDetails(ServiceDetailsRequest request);
        Task<IEnumerable<ServiceDetailsResponse>> GetServiceDetailsList(SearchServiceDetailsRequest request);
        Task<ServiceDetailsResponse?> GetServiceDetailsById(long Id);
    }
}
