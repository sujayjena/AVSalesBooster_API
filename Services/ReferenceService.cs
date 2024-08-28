using Interfaces.Repositories;
using Interfaces.Services;
using Models;

namespace Services
{
    public class ReferenceService : IReferenceService
    {
        private IReferenceRepository _referenceRepository;

        public ReferenceService(IReferenceRepository referenceRepository)
        {
            _referenceRepository = referenceRepository;
        }

        public async Task<IEnumerable<ReferenceResponse>> GetReferencesList(SearchReferenceRequest searchReference)
        {
            return await _referenceRepository.GetReferencesList(searchReference);
        }
        public async Task<int> SaveReferenceDetails(ReferenceRequest referenceRequest)
        {
            return await _referenceRepository.SaveReferenceDetails(referenceRequest);
        }
        public async Task<ReferenceResponse?> GetReferenceDetailsById(long id)
        {
            return await _referenceRepository.GetReferenceDetailsById(id);
        }
        public async Task<IEnumerable<ReferenceDataValidationErrors>> ImportReferencesDetails(List<ImportedReferenceDetails> request)
        {
            return await _referenceRepository.ImportReferencesDetails(request);
        }
    }
}
