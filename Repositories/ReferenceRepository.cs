using Dapper;
using Helpers;
using Interfaces.Repositories;
using Microsoft.Extensions.Configuration;
using Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repositories
{
    public class ReferenceRepository : BaseRepository, IReferenceRepository
    {
        private IConfiguration _configuration;

        public ReferenceRepository(IConfiguration configuration) : base(configuration)
        {
            _configuration = configuration;
        }

        public async Task<IEnumerable<ReferenceResponse>> GetReferencesList(SearchReferenceRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@ReferenceParty", parameters.ReferenceParty.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            return await ListByStoredProcedure<ReferenceResponse>("GetReferences", queryParameters);
        }
        public async Task<int> SaveReferenceDetails(ReferenceRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@ReferenceId", parameters.ReferenceId);
            queryParameters.Add("@PartyName", parameters.ReferenceParty.SanitizeValue());
            queryParameters.Add("@UniqueNumber", parameters.UniqueNumber.SanitizeValue());
            queryParameters.Add("@Address", parameters.Address.SanitizeValue());
            queryParameters.Add("@StateId", parameters.StateId);
            queryParameters.Add("@RegionId", parameters.RegionId);
            queryParameters.Add("@DistrictId", parameters.DistrictId);
            queryParameters.Add("@AreaId", parameters.AreaId);
            queryParameters.Add("@Pincode", parameters.Pincode.SanitizeValue());
            queryParameters.Add("@PhoneNumber", parameters.PhoneNumber.SanitizeValue());
            queryParameters.Add("@MobileNumber", parameters.MobileNumber.SanitizeValue());
            queryParameters.Add("@GSTNumber", parameters.GSTNumber.SanitizeValue());
            queryParameters.Add("@PanNumber", parameters.PanNumber.SanitizeValue());
            queryParameters.Add("@EmailId", parameters.EmailId.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveReferenceDetails", queryParameters);
        }

        public async Task<ReferenceResponse?> GetReferenceDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<ReferenceResponse>("GetReferenceDetailsById", queryParameters)).FirstOrDefault();
        }

        public async Task<IEnumerable<ReferenceDataValidationErrors>> ImportReferencesDetails(List<ImportedReferenceDetails> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlReferenceData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlReferenceData", xmlReferenceData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<ReferenceDataValidationErrors>("SaveImportReferenceDetails", queryParameters);
        }
    }
}
