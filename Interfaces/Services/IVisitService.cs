using Models;

namespace Interfaces.Services
{
    public interface IVisitService
    {
        Task<IEnumerable<VisitsResponse>> GetVisitsList(SearchVisitRequest request);
        Task<int> SaveVisitDetails(VisitsRequest visitRequest);
        Task<VisitDetailsResponse?> GetVisitDetailsById(long visitId);
        Task<IEnumerable<VisitRemarksResponse>> GetVisitRemarks(long visitId);
        Task<IEnumerable<VisitLogHistoryResponse>> GetVisitLogHistoryList(SearchVisitLogHistoryRequest request);
        Task<IEnumerable<VisitDataValidationErrors>> ImportVisitsDetails(List<ImportedVisitDetails> request);
        Task<IEnumerable<VisitPhotosResponse>> GetVisitPhotos(long visitId, string host);
    }
}
