using Models;

namespace Interfaces.Services
{
    public interface IManageDesignService
    {
        #region Design API Service Interface
        Task<IEnumerable<DesignResponse>> GetDesignesList(SearchDesignRequest request);
        Task<int> SaveDesignDetails(DesignRequest parameter);
        Task<IEnumerable<DesignDataValidationErrors>> ImportDesignsDetails(List<ImportedDesignDetails> request);
        Task<DesignResponse?> GetDesignDetailsById(long id);

        #endregion Design API Service Interface
    }
}
