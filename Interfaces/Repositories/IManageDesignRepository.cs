using Models;

namespace Interfaces.Repositories
{
    public interface IManageDesignRepository
    {
        Task<IEnumerable<DesignResponse>> GetDesignesList(SearchDesignRequest request);
        Task<IEnumerable<DesignMasterImages?>> GetDesignImagesList(long designId);
        Task<int> SaveDesignDetails(DesignRequest parameters, List<DesignMasterImages> lstDesignImages);
        Task<IEnumerable<DesignDataValidationErrors>> ImportDesignsDetails(List<ImportedDesignDetails> parameters);
        Task<DesignResponse?> GetDesignDetailsById(long id);
    }
}
