using Models;

namespace Interfaces.Services
{
    public interface IAdminService
    {
        Task<IEnumerable<Users>> GetUsersList();

        #region Product API Service Interface
        Task<IEnumerable<ProductResponse>> GetProductsList(SearchProductRequest request);
        Task<int> SaveProduct(ProductRequest productRequest);
        Task<ProductResponse?> GetProductDetailsById(long id);
        Task<IEnumerable<ProductDataValidationErrors>> ImportProductsDetails(List<ImportedProductDetails> request);

        #endregion Product API Service Interface

        #region Brand API Service Interface
        Task<IEnumerable<BrandResponse>> GetBrandsList(SearchBrandRequest request);
        Task<int> SaveBrand(BrandRequest brandRequest);
        Task<BrandResponse?> GetBrandDetailsById(long id);
        Task<IEnumerable<BrandDataValidationErrors>> ImportBrandsDetails(List<ImportedBrandDetails> request);
        #endregion Brand API Service Interface

        #region Category API Service Interface
        Task<IEnumerable<CategoryResponse>> GetCategorysList(SearchCategoryRequest request);

        Task<int> SaveCategory(CategoryRequest categoryRequest);
        Task<CategoryResponse?> GetCategoryDetailsById(long id);
        Task<IEnumerable<CategoryDataValidationErrors>> ImportCategorysDetails(List<ImportedCategoryDetails> request);

        #endregion Category API Service Interface

        #region Size API Service Interface
        Task<IEnumerable<SizeResponse>> GetSizesList(SearchSizeRequest request);
        Task<int> SaveSize(SizeRequest sizeRequest);
        Task<SizeResponse?> GetSizeDetailsById(long id);
        Task<IEnumerable<SizeDataValidationErrors>> ImportSizesDetails(List<ImportedSizeDetails> request);

        #endregion Size API Service Interface

        #region Design Type API Service Interface
        Task<IEnumerable<DesignTypeResponse>> GetDesignTypesList(SearchDesignTypeRequest request);

        Task<int> SaveDesignType(DesignTypeRequest designTypeRequest);
        Task<DesignTypeResponse?> GetDesignTypeDetailsById(long id);
        Task<IEnumerable<DesignTypeDataValidationErrors>> ImportDesignTypesDetails(List<ImportedDesignTypeDetails> request);

        #endregion Design Type API Service Interface

        #region Series API Service Interface
        Task<IEnumerable<SeriesResponse>> GetSeriesList(SearchSeriesRequest request);
        Task<int> SaveSeries(SeriesRequest seriesRequest);
        Task<SeriesResponse?> GetSeriesDetailsById(long id);
        Task<IEnumerable<SeriesDataValidationErrors>> ImportSeriesDetails(List<ImportedSeriesDetails> request);

        #endregion Design Type API Service Interface

        #region Base Design API Service Interface
        Task<IEnumerable<BaseDesignResponse>> GetBaseDesignsList(SearchBaseDesignRequest request);
        Task<int> SaveBaseDesign(BaseDesignRequest seriesRequest);
        Task<BaseDesignResponse?> GetBaseDesignDetailsById(long id);
        Task<IEnumerable<BaseDesignDataValidationErrors>> ImportBaseDesignsDetails(List<ImportedBaseDesignDetails> request);

        #endregion Base Design API Service Interface

        #region Customer Type API Service Interface
        Task<IEnumerable<CustomerTypeResponse>> GetCustomerTypesList(SearchCustomerTypeRequest request);
        Task<int> SaveCustomerType(CustomerTypeRequest customerTypeRequest);
        Task<CustomerTypeResponse?> GetCustomerTypeDetailsById(long id);
        Task<IEnumerable<CustomerTypeDataValidationErrors>> ImportCustomerTypesDetails(List<ImportedCustomerTypeDetails> request);

        #endregion Customer Type API Service Interface

        #region Leave Type API Service Interface
        Task<IEnumerable<LeaveTypeResponse>> GetLeaveTypesList(SearchLeaveTypeRequest request);
        Task<int> SaveLeaveType(LeaveTypeRequest leaveTypeRequest);
        Task<LeaveTypeResponse?> GetLeaveTypeDetailsById(long id);
        Task<IEnumerable<LeaveTypeDataValidationErrors>> ImportLeaveTypesDetails(List<ImportedLeaveTypeDetails> request);

        #endregion Leave Type API Service Interface

        #region Master Data
        Task<IEnumerable<SelectListResponse>> GetStatesForSelectList(StatesSelectListRequestModel parameters);
        Task<IEnumerable<SelectListResponse>> GetRegionForSelectList(RegionSelectListRequestModel parameters);
        Task<IEnumerable<SelectListResponse>> GetDistrictForSelectList(DistrictSelectListRequestModel parameters);
        Task<IEnumerable<SelectListResponse>> GetAreaForSelectList(AreaSelectListRequestModel parameters);
        Task<IEnumerable<SelectListResponse>> GetCustomerTypesForSelectList(CommonSelectListRequestModel parameters);
        Task<IEnumerable<SelectListResponse>> GetCustomersForSelectList(CustomerSelectListRequestModel parameters);
        Task<IEnumerable<SelectListResponse>> GetStatusMasterForSelectList(string statusCode);
        Task<IEnumerable<SelectListResponse>> GetReportingToEmployeeForSelectList(ReportingToEmpListParameters parameters);
        Task<IEnumerable<CustomerContactsListForFields>> GetCustomerContactsListForFields(CustomerContactsListRequest parameters);
        #endregion

        #region Blood Group Master
        Task<int> SaveBloodGroupDetails(BloodGroupRequestModel parameters);
        Task<IEnumerable<BloodGroupResponseModel>> GetBloodGroupList(SearchBloodGroupRequestModel parameters);
        Task<BloodGroupResponseModel?> GetBloodGroupDetails(long id);
        #endregion

        #region Collection Master
        Task<int> SaveCollectionMasterDetails(SaveCollectionRequestModel parameters);
        Task<IEnumerable<CollectionResponseModel>> GetCollectionMasterList(SearchCollectionRequestModel parameters);
        Task<CollectionResponseModel?> GetCollectionMasterDetails(int id);
        Task<IEnumerable<CollectionDataValidationErrors>> ImportCollection(List<ImportedCollection> parameters);
        #endregion

        #region Size API Service Interface
        Task<IEnumerable<VisitTypeResponse>> GetVisitTypeList(SearchVisitTypeRequest request);
        Task<int> SaveVisitType(VisitTypeRequest visitTypeRequest);
        Task<VisitTypeResponse?> GetVisitTypeDetailsById(long id);

        #endregion VisitType API Service Interface

        #region Expense Type

        Task<int> SaveExpenseType(ExpenseTypeRequest request);
        Task<IEnumerable<ExpenseTypeResponse>> GetExpenseTypeList(SearchExpenseTypeRequest request);
        Task<ExpenseTypeResponse?> GetExpenseTypeDetailsById(long id);

        #endregion

        #region Priority

        Task<int> SavePriority(PriorityRequest request);
        Task<IEnumerable<PriorityResponse>> GetPriorityList(SearchPriorityRequest request);
        Task<PriorityResponse?> GetPriorityDetailsById(long id);

        #endregion

        #region Activity Type

        Task<int> SaveActivityType(ActivityTypeRequest request);
        Task<IEnumerable<ActivityTypeResponse>> GetActivityTypeList(SearchActivityTypeRequest request);
        Task<ActivityTypeResponse?> GetActivityTypeDetailsById(long id);

        #endregion

        #region Activity Status

        Task<int> SaveActivityStatus(ActivityStatusRequest request);
        Task<IEnumerable<ActivityStatusResponse>> GetActivityStatusList(SearchActivityStatusRequest request);
        Task<ActivityStatusResponse?> GetActivityStatusDetailsById(long id);

        #endregion
    }
}
