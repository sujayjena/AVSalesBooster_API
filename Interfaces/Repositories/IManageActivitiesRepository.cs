using Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Interfaces.Repositories
{
    public interface IManageActivitiesRepository
    {
        #region Single Activity Repository Interface

        Task<IEnumerable<SingleActivities_Response>> GetSingleActivitiesList(SingleActivities_Search request);
        Task<int> SaveSingleActivities(SingleActivities_Request request);
        Task<SingleActivities_Response?> GetSingleActivitiesDetailsById(long id);

        Task<int> SaveSingleActivitiesRemarks(SingleActivitiesRemarks_Request request);
        Task<IEnumerable<SingleActivitiesRemarks_Response>> GetSingleActivitiesRemarksList(SingleActivitiesRemarks_Search request);
        #endregion
    }
}
