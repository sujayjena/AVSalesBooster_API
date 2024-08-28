using Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Interfaces.Services
{
    public interface IReferenceService
    {
        Task<IEnumerable<ReferenceResponse>> GetReferencesList(SearchReferenceRequest request);
        Task<int> SaveReferenceDetails(ReferenceRequest referenceRequest);
        Task<ReferenceResponse?> GetReferenceDetailsById(long id);
        Task<IEnumerable<ReferenceDataValidationErrors>> ImportReferencesDetails(List<ImportedReferenceDetails> request);
    }
}
