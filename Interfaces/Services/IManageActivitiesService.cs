using Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Interfaces.Services
{
    public interface IManageActivitiesService
    {
        #region Single Activity Repository Interface

        Task<IEnumerable<SingleActivities_Response>> GetSingleActivitiesList(SingleActivities_Search request);
        Task<int> SaveSingleActivities(SingleActivities_Request request);
        Task<SingleActivities_Response?> GetSingleActivitiesDetailsById(long id);

        Task<int> SaveSingleActivitiesRemarks(SingleActivitiesRemarks_Request request);
        Task<IEnumerable<SingleActivitiesRemarks_Response>> GetSingleActivitiesRemarksList(SingleActivitiesRemarks_Search request);
        #endregion

        #region Multiple Activity Repository Interface

        Task<IEnumerable<ActivityTemplate_Response>> GetActivityTemplateList(ActivityTemplate_Search request);
        Task<int> SaveActivityTemplate(ActivityTemplate_Request request);
        Task<ActivityTemplate_Response?> GetActivityTemplateDetailsById(long id);

        Task<IEnumerable<MultipleActivities_Response>> GetMultipleActivitiesList(MultipleActivities_Search request);
        Task<int> SaveMultipleActivities(MultipleActivities_Request request);
        Task<MultipleActivities_Response?> GetMultipleActivitiesDetailsById(long id);

        Task<int> SaveMultipleActivitiesRemarks(MultipleActivitiesRemarks_Request request);
        Task<IEnumerable<MultipleActivitiesRemarks_Response>> GetMultipleActivitiesRemarksList(MultipleActivitiesRemarks_Search request);

        #endregion
    }
}
