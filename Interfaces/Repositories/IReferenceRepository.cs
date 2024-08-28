using Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Interfaces.Repositories
{
    public interface IReferenceRepository
    {
        Task<IEnumerable<ReferenceResponse>> GetReferencesList(SearchReferenceRequest parameters);
        Task<int> SaveReferenceDetails(ReferenceRequest parameters);
        Task<ReferenceResponse?> GetReferenceDetailsById(long id);
        Task<IEnumerable<ReferenceDataValidationErrors>> ImportReferencesDetails(List<ImportedReferenceDetails> parameters);
    }
}
