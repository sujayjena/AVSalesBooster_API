using Models;

namespace Interfaces.Repositories
{
    public interface IAdminRepository
    {
        Task<IEnumerable<Users>> GetUsersList();

        #region Product Repository Interface
        Task<IEnumerable<ProductResponse>> GetProductsList(SearchProductRequest request);
        Task<int> SaveProduct(ProductRequest productRequest);
        Task<ProductResponse?> GetProductDetailsById(long id);
        Task<IEnumerable<ProductDataValidationErrors>> ImportProductsDetails(List<ImportedProductDetails> parameters);


        #endregion Product Repository Interface

        #region Brand Repository Interface

        Task<IEnumerable<BrandResponse>> GetBrandsList(SearchBrandRequest request);
        Task<int> SaveBrand(BrandRequest brandRequest);
        Task<BrandResponse?> GetBrandDetailsById(long id);
        Task<IEnumerable<BrandDataValidationErrors>> ImportBrandsDetails(List<ImportedBrandDetails> parameters);

        #endregion Brand Repository Interface

        #region Category Repository Interface
        Task<IEnumerable<CategoryResponse>> GetCategorysList(SearchCategoryRequest request);
        Task<int> SaveCategory(CategoryRequest categoryRequest);
        Task<CategoryResponse?> GetCategoryDetailsById(long id);
        Task<IEnumerable<CategoryDataValidationErrors>> ImportCategorysDetails(List<ImportedCategoryDetails> parameters);
        #endregion Category Repository Interface

        #region Size Repository Interface
        Task<IEnumerable<SizeResponse>> GetSizesList(SearchSizeRequest request);
        Task<int> SaveSize(SizeRequest sizeRequest);
        Task<SizeResponse?> GetSizeDetailsById(long id);
        Task<IEnumerable<SizeDataValidationErrors>> ImportSizesDetails(List<ImportedSizeDetails> parameters);
        #endregion Size Repository Interface

        #region Design Type Repository Interface
        Task<IEnumerable<DesignTypeResponse>> GetDesignTypesList(SearchDesignTypeRequest request);
        Task<int> SaveDesignType(DesignTypeRequest designTypeRequest);
        Task<DesignTypeResponse?> GetDesignTypeDetailsById(long id);
        Task<IEnumerable<DesignTypeDataValidationErrors>> ImportDesignTypesDetails(List<ImportedDesignTypeDetails> parameters);
        #endregion Design Type Repository Interface

        #region Series Repository Interface
        Task<IEnumerable<SeriesResponse>> GetSeriesList(SearchSeriesRequest request);
        Task<int> SaveSeries(SeriesRequest seriesRequest);
        Task<SeriesResponse?> GetSeriesDetailsById(long id);
        Task<IEnumerable<SeriesDataValidationErrors>> ImportSeriesDetails(List<ImportedSeriesDetails> parameters);
        #endregion Series Repository Interface

        #region Base Design Repository Interface
        Task<IEnumerable<BaseDesignResponse>> GetBaseDesignsList(SearchBaseDesignRequest request);
        Task<int> SaveBaseDesign(BaseDesignRequest baseDesignRequest);
        Task<BaseDesignResponse?> GetBaseDesignDetailsById(long id);
        Task<IEnumerable<BaseDesignDataValidationErrors>> ImportBaseDesignsDetails(List<ImportedBaseDesignDetails> parameters);
        #endregion Base Design Repository Interface

        #region Customer Type Repository Interface
        Task<IEnumerable<CustomerTypeResponse>> GetCustomerTypesList(SearchCustomerTypeRequest request);
        Task<int> SaveCustomerType(CustomerTypeRequest customerTypeRequest);
        Task<CustomerTypeResponse?> GetCustomerTypeDetailsById(long id);
        Task<IEnumerable<CustomerTypeDataValidationErrors>> ImportCustomerTypesDetails(List<ImportedCustomerTypeDetails> parameters);
        #endregion  Customer Type Repository Interface

        #region Leave Type Repository Interface
        Task<IEnumerable<LeaveTypeResponse>> GetLeaveTypesList(SearchLeaveTypeRequest request);
        Task<int> SaveLeaveType(LeaveTypeRequest customTypeRequest);
        Task<LeaveTypeResponse?> GetLeaveTypeDetailsById(long id);
        Task<IEnumerable<LeaveTypeDataValidationErrors>> ImportLeaveTypesDetails(List<ImportedLeaveTypeDetails> parameters);
        #endregion  Leave Type Repository Interface

        #region Master Data
        Task<IEnumerable<SelectListResponse>> GetStatesForSelectList(StatesSelectListRequestModel parameters);
        Task<IEnumerable<SelectListResponse>> GetRegionForSelectList(RegionSelectListRequestModel parameters);
        Task<IEnumerable<SelectListResponse>> GetDistrictForSelectList(DistrictSelectListRequestModel parameters);
        Task<IEnumerable<SelectListResponse>> GetAreaForSelectList(AreaSelectListRequestModel parameters);
        Task<IEnumerable<SelectListResponse>> GetCustomerTypesForSelectList(CommonSelectListRequestModel parameters);
        Task<IEnumerable<SelectListResponse>> GetCustomersForSelectList(CustomerSelectListRequestModel parameters);
        Task<IEnumerable<SelectListResponse>> GetStatusMasterForSelectList(string StatusCode);
        Task<IEnumerable<SelectListResponse>> GetReportingToEmployeeForSelectList(ReportingToEmpListParameters parameters);
        Task<IEnumerable<CustomerContactsListForFields>> GetCustomerContactsListForFields(CustomerContactsListRequest parameters);
        Task<IEnumerable<SelectListResponse>> GetAttendanceEmployeeForSelectList();
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

        #region VisitType Repository Interface
        Task<IEnumerable<VisitTypeResponse>> GetVisitTypeList(SearchVisitTypeRequest request);
        Task<int> SaveVisitType(VisitTypeRequest visitTypeRequest);
        Task<VisitTypeResponse?> GetVisitTypeDetailsById(long id);
        #endregion VisitType Repository Interface

        #region Expense Type
        Task<int> SaveExpenseType(ExpenseTypeRequest parameters);
        Task<IEnumerable<ExpenseTypeResponse>> GetExpenseTypeList(SearchExpenseTypeRequest parameters);
        Task<ExpenseTypeResponse?> GetExpenseTypeDetailsById(long id);

        #endregion

        #region Priority

        Task<int> SavePriority(PriorityRequest parameters);
        Task<IEnumerable<PriorityResponse>> GetPriorityList(SearchPriorityRequest parameters);
        Task<PriorityResponse?> GetPriorityDetailsById(long id);

        #endregion

        #region Activity Type

        Task<int> SaveActivityType(ActivityTypeRequest parameters);
        Task<IEnumerable<ActivityTypeResponse>> GetActivityTypeList(SearchActivityTypeRequest parameters);
        Task<ActivityTypeResponse?> GetActivityTypeDetailsById(long id);

        #endregion

        #region Activity Status

        Task<int> SaveActivityStatus(ActivityStatusRequest parameters);
        Task<IEnumerable<ActivityStatusResponse>> GetActivityStatusList(SearchActivityStatusRequest parameters);
        Task<ActivityStatusResponse?> GetActivityStatusDetailsById(long id);

        #endregion

        #region Version Details

        Task<int> SaveVersionDetails(VersionDetailsRequest parameters);
        Task<IEnumerable<VersionDetailsResponse>> GetVersionDetailsList(SearchVersionDetailsRequest parameters);
        Task<VersionDetailsResponse?> GetVersionDetailsById(long id);

        #endregion

        #region Renewal Type Repository Interface
        Task<IEnumerable<RenewalTypeResponse>> GetRenewalTypeList(SearchRenewalTypeRequest request);
        Task<int> SaveRenewalType(RenewalTypeRequest RenewalTypeRequest);
        Task<RenewalTypeResponse?> GetRenewalTypeById(long id);

        #endregion Renewal Type Repository Interface
    }
}
