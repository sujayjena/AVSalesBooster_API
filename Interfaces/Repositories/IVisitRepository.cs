﻿using Models;

namespace Interfaces.Repositories
{
    public interface IVisitRepository
    {
        Task<IEnumerable<VisitsResponse>> GetVisitsList(SearchVisitRequest request);
        Task<int> SaveVisitDetails(VisitsRequest parameters);
        Task<VisitDetailsResponse?> GetVisitDetailsById(long visitId);
        Task<IEnumerable<VisitRemarksResponse>> GetVisitRemarks(long visitId);
        Task<IEnumerable<VisitLogHistoryResponse>> GetVisitLogHistoryList(SearchVisitLogHistoryRequest request);
        Task<IEnumerable<VisitDataValidationErrors>> ImportVisitsDetails(List<ImportedVisitDetails> parameters);
        Task<IEnumerable<VisitPhotosResponse>> GetVisitPhotos(long visitId);
    }
}
