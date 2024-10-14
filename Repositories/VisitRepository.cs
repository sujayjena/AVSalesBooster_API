using Dapper;
using Helpers;
using Interfaces.Repositories;
using Microsoft.Extensions.Configuration;
using Models;

namespace Repositories
{
    public class VisitRepository : BaseRepository, IVisitRepository
    {
        //private IConfiguration _configuration;

        public VisitRepository(IConfiguration configuration) : base(configuration)
        {
            //_configuration = configuration;
        }

        public async Task<IEnumerable<VisitsResponse>> GetVisitsList(SearchVisitRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@PageSize", parameters.pagination.PageSize); 
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            //queryParameters.Add("@VisitNo", parameters.VisitNo.SanitizeValue());
            queryParameters.Add("@EmployeeId", parameters.EmployeeId.SanitizeValue());
            queryParameters.Add("@CustomerId", parameters.CustomerId.SanitizeValue());
            //queryParameters.Add("@EmployeeName", parameters.EmployeeName.SanitizeValue());
            //queryParameters.Add("@CustomerType", parameters.CustomerType.SanitizeValue());
            //queryParameters.Add("@CustomerName", parameters.CustomerName.SanitizeValue());
            //queryParameters.Add("@ContactPersonName", parameters.ContactPersonName.SanitizeValue());
            //queryParameters.Add("@ContactPersonNumber", parameters.ContactPersonNumber.SanitizeValue());
            //queryParameters.Add("@AreaName", parameters.AreaName.SanitizeValue());
            //queryParameters.Add("@Address", parameters.Address.SanitizeValue());
            queryParameters.Add("@SearchValue", parameters.SearchValue.SanitizeValue());
            queryParameters.Add("@FromVisitDate", parameters.FromVisitDate);
            queryParameters.Add("@ToVisitDate", parameters.ToVisitDate);
            queryParameters.Add("@VisitStatusId", parameters.VisitStatusId.SanitizeValue());
            queryParameters.Add("@FilterType", parameters.FilterType.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            /*
             * Here, @LoggedInUserId filter is needed to apply filter on CreatedBy. Need to pass 0 when User has Role "Superadmin"
             */
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<VisitsResponse>("GetVisits", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        public async Task<int> SaveVisitDetails(VisitsRequest parameters)
        {
            string xmlRemarks, xmlVisitFiles;
            DynamicParameters queryParameters = new DynamicParameters();

            xmlRemarks = ConvertListToXml(parameters.Remarks);
            xmlVisitFiles = ConvertListToXml(parameters.VisitPhotosList);

            queryParameters.Add("@VisitId", parameters.VisitId);
            queryParameters.Add("@EmployeeId", parameters.EmployeeId);
            queryParameters.Add("@VisitDate", parameters.VisitDate);
            queryParameters.Add("@CustomerId", parameters.CustomerId);
            queryParameters.Add("@CustomerTypeId", parameters.CustomerTypeId);
            queryParameters.Add("@ContactId", parameters.ContactId);
            queryParameters.Add("@StateId", parameters.StateId);
            queryParameters.Add("@RegionId", parameters.RegionId);
            queryParameters.Add("@DistrictId", parameters.DistrictId);
            queryParameters.Add("@AreaId", parameters.AreaId);
            queryParameters.Add("@AddressId", parameters.AddressId);
            queryParameters.Add("@Address", parameters.Address.SanitizeValue());
            queryParameters.Add("@NextActionDate", parameters.NextActionDate);
            queryParameters.Add("@HasVisited", parameters.HasVisited);
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@VisitStatusId", parameters.VisitStatusId);
            queryParameters.Add("@IsToCreateNewVisit", parameters.IsToCreateNewVisit);
            queryParameters.Add("@BaseVisitId", parameters.BaseVisitId);
            queryParameters.Add("@VisitTypeId", parameters.VisitTypeId);
            queryParameters.Add("@XmlRemarks", xmlRemarks);
            queryParameters.Add("@XmlVisitFiles", xmlVisitFiles);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            return await SaveByStoredProcedure<int>("SaveVisitDetails", queryParameters);
        }

        public async Task<VisitDetailsResponse?> GetVisitDetailsById(long visitId)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", visitId);

            return (await ListByStoredProcedure<VisitDetailsResponse>("GetVisitDetailsById", queryParameters)).FirstOrDefault();
        }

        public async Task<IEnumerable<VisitLogHistoryResponse>> GetVisitLogHistoryList(SearchVisitLogHistoryRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();

            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@VisitId", parameters.VisitId.SanitizeValue());

            /*
             * Here, @LoggedInUserId filter is needed to apply filter on CreatedBy. Need to pass 0 when User has Role "Superadmin"
             */
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<VisitLogHistoryResponse>("GetVisitLogHistoryList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        public async Task<IEnumerable<VisitRemarksResponse>> GetVisitRemarks(long visitId)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@VisitId", visitId);

            return await ListByStoredProcedure<VisitRemarksResponse>("GetVisitRemarksByVisitId", queryParameters);
        }

        public async Task<IEnumerable<VisitPhotosResponse>> GetVisitPhotos(long visitId)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@VisitId", visitId);

            return await ListByStoredProcedure<VisitPhotosResponse>("GetVisitPhotosByVisitId", queryParameters);
        }

        public async Task<IEnumerable<VisitDataValidationErrors>> ImportVisitsDetails(List<ImportedVisitDetails> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlVisitData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlVisitData", xmlVisitData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<VisitDataValidationErrors>("SaveImportVisitDetails", queryParameters);
        }
    }
}
