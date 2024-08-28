using Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Interfaces.Services
{
    public interface IBroadCastService
    {
        #region Catalog API Service Interface

        Task<IEnumerable<CatalogResponse>> GetCatalogDetailsList(SearchCatalogRequest request);
        Task<int> SaveCatalogDetails(CatalogRequest parameters);
        Task<CatalogDetailsResponse?> GetCatalogDetailsById(long id);
        Task<IEnumerable<CollectionResponseModel>> GetBroadCastCollectionNameList();

        #endregion

        #region Catalog Related API Service Interface

        Task<IEnumerable<CatalogRelatedResponse>> GetCatalogRelatedList(SearchCatalogRelatedRequest request);
        Task<int> SaveCatalogRelatedDetails(CatalogRelatedRequest parameters);
        Task<CatalogRelatedDetailsResponse?> GetCatalogRelatedListById(long id);

        #endregion

        #region Project API Service Interface
        Task<IEnumerable<ProjectResponse>> GetProjectList(SearchProjectRequest request);
        Task<int> SaveProject(ProjectRequest parameters);
        Task<ProjectResponse?> GetProjectDetailsById(long id);

        Task<int> SaveProjectCaseStudyDetails(ProjectCaseStudyRequest parameters);
        Task<IEnumerable<ProjectCaseStudyResponse>> GetProjectCaseStudyList(SearchProjectCaseStudy_ClienteleRequest request);

        Task<int> SaveProjectClienteleDetails(ProjectClienteleRequest parameters);
        Task<IEnumerable<ProjectClienteleResponse>> GetProjectClienteleList(SearchProjectCaseStudy_ClienteleRequest request);
        #endregion

        #region BroadCast API Service Interface
        Task<IEnumerable<BroadCastResponse>> GetBroadCastList(SearchBroadCastRequest request);
        Task<int> SaveBroadCast(BroadCastRequest parameters);
        Task<BroadCastResponse?> GetBroadCastDetailsById(long id);
        #endregion
    }
}
