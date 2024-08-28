using Interfaces.Repositories;
using Interfaces.Services;
using Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Services
{
    public class ManageActivitiesService : IManageActivitiesService
    {
        private IManageActivitiesRepository _manageActivitiesRepository;

        public ManageActivitiesService(IManageActivitiesRepository manageActivitiesRepository)
        {
            _manageActivitiesRepository = manageActivitiesRepository;
        }

        #region Single Activity
        public async Task<int> SaveSingleActivities(SingleActivities_Request request)
        {
            return await _manageActivitiesRepository.SaveSingleActivities(request);
        }
        public async Task<IEnumerable<SingleActivities_Response>> GetSingleActivitiesList(SingleActivities_Search request)
        {
            return await _manageActivitiesRepository.GetSingleActivitiesList(request);
        }
        public async Task<SingleActivities_Response?> GetSingleActivitiesDetailsById(long id)
        {
            return await _manageActivitiesRepository.GetSingleActivitiesDetailsById(id);
        }
        public async Task<int> SaveSingleActivitiesRemarks(SingleActivitiesRemarks_Request request)
        {
            return await _manageActivitiesRepository.SaveSingleActivitiesRemarks(request);
        }
        public async Task<IEnumerable<SingleActivitiesRemarks_Response>> GetSingleActivitiesRemarksList(SingleActivitiesRemarks_Search request)
        {
            return await _manageActivitiesRepository.GetSingleActivitiesRemarksList(request);
        }
        #endregion
    }
}
