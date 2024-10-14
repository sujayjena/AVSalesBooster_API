using Dapper;
using Helpers;
using Interfaces.Repositories;
using Microsoft.Extensions.Configuration;
using Models;
using System.Globalization;
using System.Reflection.Metadata;

namespace Repositories
{
    public class AdminRepository : BaseRepository, IAdminRepository
    {
        private IConfiguration _configuration;

        public AdminRepository(IConfiguration configuration) : base(configuration)
        {
            _configuration = configuration;
        }

        public async Task<IEnumerable<Users>> GetUsersList()
        {
            return await ListByStoredProcedure<Users>("");
        }

        #region Product API Repository
        public async Task<IEnumerable<ProductResponse>> GetProductsList(SearchProductRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@ProductName", parameters.ProductName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<ProductResponse>("GetProducts", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveProduct(ProductRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@ProductId", parameters.ProductId);
            queryParameters.Add("@ProductName", parameters.ProductName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveProductDetails", queryParameters);
        }
        public async Task<ProductResponse?> GetProductDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);

            return (await ListByStoredProcedure<ProductResponse>("GetProductDetailsById", queryParameters)).FirstOrDefault();
        }
        public async Task<IEnumerable<ProductDataValidationErrors>> ImportProductsDetails(List<ImportedProductDetails> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlProductData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlProductData", xmlProductData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<ProductDataValidationErrors>("SaveImportProductDetails", queryParameters);
        }
        #endregion Product API Repository

        #region Brand API Repository
        public async Task<IEnumerable<BrandResponse>> GetBrandsList(SearchBrandRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@BrandName", parameters.BrandName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<BrandResponse>("GetBrands", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveBrand(BrandRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@BrandId", parameters.BrandId);
            queryParameters.Add("@BrandName", parameters.BrandName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveBrandDetails", queryParameters);
        }

        public async Task<BrandResponse?> GetBrandDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);

            return (await ListByStoredProcedure<BrandResponse>("GetBrandDetailsById", queryParameters)).FirstOrDefault();
        }
        public async Task<IEnumerable<BrandDataValidationErrors>> ImportBrandsDetails(List<ImportedBrandDetails> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlBrandData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlBrandData", xmlBrandData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<BrandDataValidationErrors>("SaveImportBrandDetails", queryParameters);
        }
        #endregion Product API Repository

        #region Category API Repository
        public async Task<IEnumerable<CategoryResponse>> GetCategorysList(SearchCategoryRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@CategoryName", parameters.CategoryName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<CategoryResponse>("GetCategories", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveCategory(CategoryRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@CategoryId", parameters.CategoryId);
            queryParameters.Add("@CategoryName", parameters.CategoryName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveCategoryDetails", queryParameters);
        }
        public async Task<CategoryResponse?> GetCategoryDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);

            return (await ListByStoredProcedure<CategoryResponse>("GetCategoryDetailsById", queryParameters)).FirstOrDefault();
        }
        public async Task<IEnumerable<CategoryDataValidationErrors>> ImportCategorysDetails(List<ImportedCategoryDetails> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlCategoryData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlCategoryData", xmlCategoryData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<CategoryDataValidationErrors>("SaveImportCategoryDetails", queryParameters);
        }
        #endregion Category API Repository

        #region Size API Repository
        public async Task<IEnumerable<SizeResponse>> GetSizesList(SearchSizeRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@SizeName", parameters.SizeName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<SizeResponse>("GetSizes", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveSize(SizeRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@SizeId", parameters.SizeId);
            queryParameters.Add("@SizeName", parameters.SizeName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveSizeDetails", queryParameters);
        }
        public async Task<SizeResponse?> GetSizeDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);

            return (await ListByStoredProcedure<SizeResponse>("GetSizeDetailsById", queryParameters)).FirstOrDefault();
        }
        public async Task<IEnumerable<SizeDataValidationErrors>> ImportSizesDetails(List<ImportedSizeDetails> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlSizeData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlSizeData", xmlSizeData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<SizeDataValidationErrors>("SaveImportSizeDetails", queryParameters);
        }
        #endregion Size API Repository

        #region Design Type API Repository
        public async Task<IEnumerable<DesignTypeResponse>> GetDesignTypesList(SearchDesignTypeRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@DesignTypeName", parameters.DesignTypeName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<DesignTypeResponse>("GetDesignTypes", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveDesignType(DesignTypeRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@DesignTypeId", parameters.DesignTypeId);
            queryParameters.Add("@DesignTypeName", parameters.DesignTypeName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveDesignTypeDetails", queryParameters);
        }

        public async Task<DesignTypeResponse?> GetDesignTypeDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);

            return (await ListByStoredProcedure<DesignTypeResponse>("GetDesignTypeDetailsById", queryParameters)).FirstOrDefault();
        }
        public async Task<IEnumerable<DesignTypeDataValidationErrors>> ImportDesignTypesDetails(List<ImportedDesignTypeDetails> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlDesignTypeData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlDesignTypeData", xmlDesignTypeData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<DesignTypeDataValidationErrors>("SaveImportDesignTypeDetails", queryParameters);
        }
        #endregion Design Type API Repository

        #region Series API Repository
        public async Task<IEnumerable<SeriesResponse>> GetSeriesList(SearchSeriesRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@SeriesName", parameters.SeriesName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<SeriesResponse>("GetSeriess", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveSeries(SeriesRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@SeriesId", parameters.SeriesId);
            queryParameters.Add("@SeriesName", parameters.SeriesName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveSeriesDetails", queryParameters);
        }

        public async Task<SeriesResponse?> GetSeriesDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<SeriesResponse>("GetSeriesDetailsById", queryParameters)).FirstOrDefault();
        }
        public async Task<IEnumerable<SeriesDataValidationErrors>> ImportSeriesDetails(List<ImportedSeriesDetails> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlSeriesData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlSeriesData", xmlSeriesData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<SeriesDataValidationErrors>("SaveImportSeriesDetails", queryParameters);
        }
        #endregion Series API Repository

        #region Base Design API Repository
        public async Task<IEnumerable<BaseDesignResponse>> GetBaseDesignsList(SearchBaseDesignRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@BaseDesignName", parameters.BaseDesignName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<BaseDesignResponse>("GetBaseDesigns", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveBaseDesign(BaseDesignRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@BaseDesignId", parameters.BaseDesignId);
            queryParameters.Add("@BaseDesignName", parameters.BaseDesignName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveBaseDesignDetails", queryParameters);
        }
        public async Task<BaseDesignResponse?> GetBaseDesignDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<BaseDesignResponse>("GetBaseDesignDetailsById", queryParameters)).FirstOrDefault();
        }
        public async Task<IEnumerable<BaseDesignDataValidationErrors>> ImportBaseDesignsDetails(List<ImportedBaseDesignDetails> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlBaseDesignData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlBaseDesignData", xmlBaseDesignData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<BaseDesignDataValidationErrors>("SaveImportBaseDesignDetails", queryParameters);
        }
        #endregion Base Design API Repository

        #region Customer Type API Repository
        public async Task<IEnumerable<CustomerTypeResponse>> GetCustomerTypesList(SearchCustomerTypeRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@CustomerTypeName", parameters.CustomerTypeName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<CustomerTypeResponse>("GetCustomerTypes", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveCustomerType(CustomerTypeRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@CustomerTypeId", parameters.CustomerTypeId);
            queryParameters.Add("@CustomerTypeName", parameters.CustomerTypeName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveCustomerTypeDetails", queryParameters);
        }
        public async Task<CustomerTypeResponse?> GetCustomerTypeDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<CustomerTypeResponse>("GetCustomerTypeDetailsById", queryParameters)).FirstOrDefault();
        }
        public async Task<IEnumerable<CustomerTypeDataValidationErrors>> ImportCustomerTypesDetails(List<ImportedCustomerTypeDetails> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlCustomerTypeData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlCustomerTypeData", xmlCustomerTypeData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<CustomerTypeDataValidationErrors>("SaveImportCustomerTypeDetails", queryParameters);
        }
        #endregion Customer Type API Repository

        #region Leave Type API Repository
        public async Task<IEnumerable<LeaveTypeResponse>> GetLeaveTypesList(SearchLeaveTypeRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@LeaveTypeName", parameters.LeaveTypeName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<LeaveTypeResponse>("GetLeaveTypes", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveLeaveType(LeaveTypeRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@LeaveTypeId", parameters.LeaveTypeId);
            queryParameters.Add("@LeaveTypeName", parameters.LeaveTypeName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveLeaveTypeDetails", queryParameters);
        }
        public async Task<LeaveTypeResponse?> GetLeaveTypeDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);
            return (await ListByStoredProcedure<LeaveTypeResponse>("GetLeaveTypeDetailsById", queryParameters)).FirstOrDefault();
        }
        public async Task<IEnumerable<LeaveTypeDataValidationErrors>> ImportLeaveTypesDetails(List<ImportedLeaveTypeDetails> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlLeaveTypeData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlLeaveTypeData", xmlLeaveTypeData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<LeaveTypeDataValidationErrors>("SaveImportLeaveTypeDetails", queryParameters);
        }
        #endregion Leave Type API Repository

        #region Master Data
        public async Task<IEnumerable<SelectListResponse>> GetStatesForSelectList(StatesSelectListRequestModel parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@IsActive", parameters.IsActive);
            return await ListByStoredProcedure<SelectListResponse>("GetStatesForSelectList", queryParameters);
        }

        public async Task<IEnumerable<SelectListResponse>> GetRegionForSelectList(RegionSelectListRequestModel parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@StateId", parameters.StateId);
            queryParameters.Add("@IsActive", parameters.IsActive);

            return await ListByStoredProcedure<SelectListResponse>("GetRegionsForSelectList", queryParameters);
        }

        public async Task<IEnumerable<SelectListResponse>> GetDistrictForSelectList(DistrictSelectListRequestModel parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@RegionId", parameters.RegionId);
            queryParameters.Add("@IsActive", parameters.IsActive);

            return await ListByStoredProcedure<SelectListResponse>("GetDistrictsForSelectList", queryParameters);
        }

        public async Task<IEnumerable<SelectListResponse>> GetAreaForSelectList(AreaSelectListRequestModel parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@DistrictId", parameters.DistrictId);
            queryParameters.Add("@IsActive", parameters.IsActive);

            return await ListByStoredProcedure<SelectListResponse>("GetAreasForSelectList", queryParameters);
        }

        public async Task<IEnumerable<SelectListResponse>> GetCustomerTypesForSelectList(CommonSelectListRequestModel parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@IsActive", parameters.IsActive);

            return await ListByStoredProcedure<SelectListResponse>("GetCustomerTypesForSelectList", queryParameters);
        }

        public async Task<IEnumerable<SelectListResponse>> GetCustomersForSelectList(CustomerSelectListRequestModel parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@CustomerTypeId", parameters.CustomerTypeId.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            return await ListByStoredProcedure<SelectListResponse>("GetCustomersForSelectList", queryParameters);
        }

        public async Task<IEnumerable<SelectListResponse>> GetStatusMasterForSelectList(string StatusCode)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@StatusCode", StatusCode);

            return await ListByStoredProcedure<SelectListResponse>("GetStatusMasterList", queryParameters);
        }

        public async Task<IEnumerable<SelectListResponse>> GetReportingToEmployeeForSelectList(ReportingToEmpListParameters parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@RoleId", parameters.RoleId);
            queryParameters.Add("@RegionId", parameters.RegionId.SanitizeValue());

            return await ListByStoredProcedure<SelectListResponse>("GetReportingToEmployeeForSelectList", queryParameters);
        }

        public async Task<IEnumerable<CustomerContactsListForFields>> GetCustomerContactsListForFields(CustomerContactsListRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@CustomerId", parameters.CustomerId);
            queryParameters.Add("@IsActive", parameters.IsActive);

            return await ListByStoredProcedure<CustomerContactsListForFields>("GetCustomerContactsList", queryParameters);
        }
        #endregion

        #region Blood Group Master
        public async Task<int> SaveBloodGroupDetails(BloodGroupRequestModel parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@BloodGroupId", parameters.BloodGroupId);
            queryParameters.Add("@BloodGroup", parameters.BloodGroupName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveBloodGroupDetails", queryParameters);
        }

        public async Task<IEnumerable<BloodGroupResponseModel>> GetBloodGroupList(SearchBloodGroupRequestModel parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            //queryParameters.Add("@Total", parameters.pagination.Total);
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@BloodGroup", parameters.BloodGroup.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<BloodGroupResponseModel>("GetBloodGroupMasterList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        public async Task<BloodGroupResponseModel?> GetBloodGroupDetails(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@BloodGroupId", id);
            return (await ListByStoredProcedure<BloodGroupResponseModel?>("GetBloodGroupDetailsById", queryParameters)).FirstOrDefault();
        }
        #endregion

        #region Collection Master
        public async Task<int> SaveCollectionMasterDetails(SaveCollectionRequestModel parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@CollectionId", parameters.CollectionId);
            queryParameters.Add("@CollectionName", parameters.CollectionName.SanitizeValue());
            queryParameters.Add("@CollectionNameId", parameters.CollectionNameId);
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveCollectionDetails", queryParameters);
        }

        public async Task<IEnumerable<CollectionResponseModel>> GetCollectionMasterList(SearchCollectionRequestModel parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@CollectionName", parameters.CollectionName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<CollectionResponseModel>("GetCollectionsList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }

        public async Task<CollectionResponseModel?> GetCollectionMasterDetails(int id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@CollectionId", id);
            return (await ListByStoredProcedure<CollectionResponseModel?>("GetCollectionDetailsById", queryParameters)).FirstOrDefault();
        }
        public async Task<IEnumerable<CollectionDataValidationErrors>> ImportCollection(List<ImportedCollection> parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            string xmlCategoryData = ConvertListToXml(parameters);
            queryParameters.Add("@XmlCategoryData", xmlCategoryData);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await ListByStoredProcedure<CollectionDataValidationErrors>("SaveImportCollection", queryParameters);
        }
        #endregion

        #region VisitType API Repository
        public async Task<IEnumerable<VisitTypeResponse>> GetVisitTypeList(SearchVisitTypeRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@VisitTypeName", parameters.VisitTypeName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);

            var result = await ListByStoredProcedure<VisitTypeResponse>("GetVisitTypeList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<int> SaveVisitType(VisitTypeRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@VisitTypeId", parameters.VisitTypeId);
            queryParameters.Add("@VisitTypeName", parameters.VisitTypeName.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveVisitTypeDetails", queryParameters);
        }
        public async Task<VisitTypeResponse?> GetVisitTypeDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);

            return (await ListByStoredProcedure<VisitTypeResponse>("GetVisitTypeDetailsById", queryParameters)).FirstOrDefault();
        }

        #endregion VisitType API Repository

        #region Expense Type
        public async Task<int> SaveExpenseType(ExpenseTypeRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@ExpenseTypeId", parameters.ExpenseTypeId);
            queryParameters.Add("@ExpenseTypeName", parameters.ExpenseTypeName.SanitizeValue().ToUpper());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveExpenseType", queryParameters);
        }
        public async Task<IEnumerable<ExpenseTypeResponse>> GetExpenseTypeList(SearchExpenseTypeRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@ValueForSearch", parameters.ValueForSearch.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<ExpenseTypeResponse>("GetExpenseTypeList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<ExpenseTypeResponse?> GetExpenseTypeDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);

            return (await ListByStoredProcedure<ExpenseTypeResponse>("GetExpenseTypeDetailsById", queryParameters)).FirstOrDefault();
        }
        #endregion

        #region Priority
        public async Task<int> SavePriority(PriorityRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PriorityId", parameters.PriorityId);
            queryParameters.Add("@PriorityName", parameters.PriorityName.SanitizeValue().ToUpper());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SavePriority", queryParameters);
        }
        public async Task<IEnumerable<PriorityResponse>> GetPriorityList(SearchPriorityRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@ValueForSearch", parameters.ValueForSearch.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<PriorityResponse>("GetPriorityList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<PriorityResponse?> GetPriorityDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);

            return (await ListByStoredProcedure<PriorityResponse>("GetPriorityDetailsById", queryParameters)).FirstOrDefault();
        }
        #endregion

        #region Activity Type
        public async Task<int> SaveActivityType(ActivityTypeRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@ActivityTypeId", parameters.ActivityTypeId);
            queryParameters.Add("@ActivityTypeName", parameters.ActivityTypeName.SanitizeValue().ToUpper());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveActivityType", queryParameters);
        }
        public async Task<IEnumerable<ActivityTypeResponse>> GetActivityTypeList(SearchActivityTypeRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@ValueForSearch", parameters.ValueForSearch.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<ActivityTypeResponse>("GetActivityTypeList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<ActivityTypeResponse?> GetActivityTypeDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);

            return (await ListByStoredProcedure<ActivityTypeResponse>("GetActivityTypeDetailsById", queryParameters)).FirstOrDefault();
        }
        #endregion

        #region Activity Status
        public async Task<int> SaveActivityStatus(ActivityStatusRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@ActivityStatusId", parameters.ActivityStatusId);
            queryParameters.Add("@ActivityStatusName", parameters.ActivityStatusName.SanitizeValue().ToUpper());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveActivityStatus", queryParameters);
        }
        public async Task<IEnumerable<ActivityStatusResponse>> GetActivityStatusList(SearchActivityStatusRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@ValueForSearch", parameters.ValueForSearch.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<ActivityStatusResponse>("GetActivityStatusList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<ActivityStatusResponse?> GetActivityStatusDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);

            return (await ListByStoredProcedure<ActivityStatusResponse>("GetActivityStatusDetailsById", queryParameters)).FirstOrDefault();
        }
        #endregion

        #region Version Details
        public async Task<int> SaveVersionDetails(VersionDetailsRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", parameters.Id);
            queryParameters.Add("@AppVersionNo", parameters.AppVersionNo.SanitizeValue());
            queryParameters.Add("@AppVersionName", parameters.AppVersionName.SanitizeValue());
            queryParameters.Add("@UpdateMsg", parameters.UpdateMsg.SanitizeValue());
            queryParameters.Add("@PackageName", parameters.PackageName.SanitizeValue());
            queryParameters.Add("@UpdateType", parameters.UpdateType.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);
            return await SaveByStoredProcedure<int>("SaveVersionDetails", queryParameters);
        }
        public async Task<IEnumerable<VersionDetailsResponse>> GetVersionDetailsList(SearchVersionDetailsRequest parameters)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@PageNo", parameters.pagination.PageNo);
            queryParameters.Add("@PageSize", parameters.pagination.PageSize);
            queryParameters.Add("@Total", parameters.pagination.Total, null, System.Data.ParameterDirection.Output);
            queryParameters.Add("@SortBy", parameters.pagination.SortBy.SanitizeValue());
            queryParameters.Add("@OrderBy", parameters.pagination.OrderBy.SanitizeValue());
            queryParameters.Add("@PackageName", parameters.PackageName);
            queryParameters.Add("@UpdateType", parameters.UpdateType);
            queryParameters.Add("@ValueForSearch", parameters.ValueForSearch.SanitizeValue());
            queryParameters.Add("@IsActive", parameters.IsActive);
            queryParameters.Add("@LoggedInUserId", SessionManager.LoggedInUserId);

            var result = await ListByStoredProcedure<VersionDetailsResponse>("GetVersionDetailsList", queryParameters);
            parameters.pagination.Total = queryParameters.Get<int>("Total");

            return result;
        }
        public async Task<VersionDetailsResponse?> GetVersionDetailsById(long id)
        {
            DynamicParameters queryParameters = new DynamicParameters();
            queryParameters.Add("@Id", id);

            return (await ListByStoredProcedure<VersionDetailsResponse>("GetVersionDetailsById", queryParameters)).FirstOrDefault();
        }
        #endregion
    }
}
