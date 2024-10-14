using Helpers;
using Interfaces.Repositories;
using Interfaces.Services;
using Models;

namespace Services
{
    public class VisitService : IVisitService
    {
        private IVisitRepository _visitsRepository;
        private IFileManager _fileManager;

        public VisitService(IVisitRepository visitsRepository, IFileManager fileManager)
        {
            _visitsRepository = visitsRepository;
            _fileManager = fileManager;
        }

        public async Task<IEnumerable<VisitsResponse>> GetVisitsList(SearchVisitRequest request)
        {
            return await _visitsRepository.GetVisitsList(request);
        }

        public async Task<int> SaveVisitDetails(VisitsRequest visitsRequest)
        {
            ///<summary>
            ///To create new Visit when requested to create new visit based on Existing visit
            ///Only new VisitMaster record will be created. No Photo and Remark data will be copied from existing one.
            ///If added new remark(s) and Photo(s) then will be saved for newly created Visit
            ///</summary>

            //if (visitsRequest.IsToCreateNewVisit)
            //{
            //    visitsRequest.BaseVisitId = visitsRequest.VisitId;
            //    visitsRequest.VisitId = 0;
            //}

            foreach (VisitPhotosRequest vpr in visitsRequest.VisitPhotosList)
            {
                if (visitsRequest.IsToCreateNewVisit)
                    vpr.VisitPhotoId = 0;
                
                if (vpr.Photo != null)
                {
                    vpr.UploadedFileName = vpr.Photo.FileName;
                    vpr.SavedFileName = _fileManager.UploadVisitDocuments(vpr.Photo);
                }
            }

            return await _visitsRepository.SaveVisitDetails(visitsRequest);
        }

        public async Task<VisitDetailsResponse?> GetVisitDetailsById(long visitId)
        {
            return await _visitsRepository.GetVisitDetailsById(visitId);
        }

        public async Task<IEnumerable<VisitLogHistoryResponse>> GetVisitLogHistoryList(SearchVisitLogHistoryRequest request)
        {
            return await _visitsRepository.GetVisitLogHistoryList(request);
        }

        public async Task<IEnumerable<VisitDataValidationErrors>> ImportVisitsDetails(List<ImportedVisitDetails> request)
        {
            return await _visitsRepository.ImportVisitsDetails(request);
        }
        public async Task<IEnumerable<VisitRemarksResponse>> GetVisitRemarks(long visitId)
        {
            return await _visitsRepository.GetVisitRemarks(visitId);
        }

        public async Task<IEnumerable<VisitPhotosResponse>> GetVisitPhotos(long visitId, string host)
        {
            IEnumerable<VisitPhotosResponse> lstVisitPhotos = await _visitsRepository.GetVisitPhotos(visitId);

            foreach (VisitPhotosResponse item in lstVisitPhotos)
            {
                item.FileContent = host + _fileManager.GetVisitDocumentsFile(item.SavedFileName);
            }

            return lstVisitPhotos;
        }
    }
}
