using Interfaces.Repositories;
using Interfaces.Services;
using Models;

namespace Services
{
    public class AdminService : IAdminService
    {
        private IAdminRepository _adminRepository;

        public AdminService(IAdminRepository adminRepository)
        {
            _adminRepository = adminRepository;
        }

        public async Task<IEnumerable<Users>> GetUsersList()
        {
            return await _adminRepository.GetUsersList();
        }

        #region Product API Service
        public async Task<IEnumerable<ProductResponse>> GetProductsList(SearchProductRequest request)
        {
            return await _adminRepository.GetProductsList(request);
        }

        public async Task<int> SaveProduct(ProductRequest productRequest)
        { 
            return await _adminRepository.SaveProduct(productRequest);
        }

        public async Task<IEnumerable<ProductDataValidationErrors>> ImportProductsDetails(List<ImportedProductDetails> request)
        {
            return await _adminRepository.ImportProductsDetails(request);
        }

        public async Task<ProductResponse?> GetProductDetailsById(long id)
        {
            return await _adminRepository.GetProductDetailsById(id);
        }
        #endregion Product API Service

        #region Brand API Service
        public async Task<IEnumerable<BrandResponse>> GetBrandsList(SearchBrandRequest request)
        {
            return await _adminRepository.GetBrandsList(request);
        }

        public async Task<int> SaveBrand(BrandRequest brandRequest)
        {
            return await _adminRepository.SaveBrand(brandRequest);

        }

        public async Task<BrandResponse?> GetBrandDetailsById(long id)
        {
            return await _adminRepository.GetBrandDetailsById(id);
        }

        public async Task<IEnumerable<BrandDataValidationErrors>> ImportBrandsDetails(List<ImportedBrandDetails> request)
        {
            return await _adminRepository.ImportBrandsDetails(request);
        }

        #endregion Product API Service

        #region Category API Service
        public async Task<IEnumerable<CategoryResponse>> GetCategorysList(SearchCategoryRequest request)
        {
            return await _adminRepository.GetCategorysList(request);
        }

        public async Task<int> SaveCategory(CategoryRequest categoryRequest)
        {
            return await _adminRepository.SaveCategory(categoryRequest);

        }

        public async Task<CategoryResponse?> GetCategoryDetailsById(long id)
        {
            return await _adminRepository.GetCategoryDetailsById(id);
        }
        public async Task<IEnumerable<CategoryDataValidationErrors>> ImportCategorysDetails(List<ImportedCategoryDetails> request)
        {
            return await _adminRepository.ImportCategorysDetails(request);
        }
        #endregion Category API Service

        #region Size API Service
        public async Task<IEnumerable<SizeResponse>> GetSizesList(SearchSizeRequest request)
        {
            return await _adminRepository.GetSizesList(request);
        }

        public async Task<int> SaveSize(SizeRequest sizeRequest)
        {
            return await _adminRepository.SaveSize(sizeRequest);

        }

        public async Task<SizeResponse?> GetSizeDetailsById(long id)
        {
            return await _adminRepository.GetSizeDetailsById(id);
        }
        public async Task<IEnumerable<SizeDataValidationErrors>> ImportSizesDetails(List<ImportedSizeDetails> request)
        {
            return await _adminRepository.ImportSizesDetails(request);
        }
        #endregion Size API Service

        #region Design Type API Service
        public async Task<IEnumerable<DesignTypeResponse>> GetDesignTypesList(SearchDesignTypeRequest request)
        {
            return await _adminRepository.GetDesignTypesList(request);
        }

        public async Task<int> SaveDesignType(DesignTypeRequest designTypeRequest)
        {
            return await _adminRepository.SaveDesignType(designTypeRequest);

        }
        public async Task<DesignTypeResponse?> GetDesignTypeDetailsById(long id)
        {
            return await _adminRepository.GetDesignTypeDetailsById(id);
        }
        public async Task<IEnumerable<DesignTypeDataValidationErrors>> ImportDesignTypesDetails(List<ImportedDesignTypeDetails> request)
        {
            return await _adminRepository.ImportDesignTypesDetails(request);
        }
        #endregion Design Type API Service

        #region Series API Service
        public async Task<IEnumerable<SeriesResponse>> GetSeriesList(SearchSeriesRequest request)
        {
            return await _adminRepository.GetSeriesList(request);
        }

        public async Task<int> SaveSeries(SeriesRequest seriesRequest)
        {
            return await _adminRepository.SaveSeries(seriesRequest);

        }
        public async Task<SeriesResponse?> GetSeriesDetailsById(long id)
        {
            return await _adminRepository.GetSeriesDetailsById(id);
        }
        public async Task<IEnumerable<SeriesDataValidationErrors>> ImportSeriesDetails(List<ImportedSeriesDetails> request)
        {
            return await _adminRepository.ImportSeriesDetails(request);
        }
        #endregion Series API Service

        #region Base Design API Service
        public async Task<IEnumerable<BaseDesignResponse>> GetBaseDesignsList(SearchBaseDesignRequest request)
        {
            return await _adminRepository.GetBaseDesignsList(request);
        }

        public async Task<int> SaveBaseDesign(BaseDesignRequest baseDesignRequest)
        {
            return await _adminRepository.SaveBaseDesign(baseDesignRequest);

        }
        public async Task<BaseDesignResponse?> GetBaseDesignDetailsById(long id)
        {
            return await _adminRepository.GetBaseDesignDetailsById(id);
        }
        public async Task<IEnumerable<BaseDesignDataValidationErrors>> ImportBaseDesignsDetails(List<ImportedBaseDesignDetails> request)
        {
            return await _adminRepository.ImportBaseDesignsDetails(request);
        }
        #endregion Base Design API Service

        #region Customer Type API Service
        public async Task<IEnumerable<CustomerTypeResponse>> GetCustomerTypesList(SearchCustomerTypeRequest request)
        {
            return await _adminRepository.GetCustomerTypesList(request);
        }

        public async Task<int> SaveCustomerType(CustomerTypeRequest customerTypeRequest)
        {
            return await _adminRepository.SaveCustomerType(customerTypeRequest);
        }
        public async Task<CustomerTypeResponse?> GetCustomerTypeDetailsById(long id)
        {
            return await _adminRepository.GetCustomerTypeDetailsById(id);
        }
        public async Task<IEnumerable<CustomerTypeDataValidationErrors>> ImportCustomerTypesDetails(List<ImportedCustomerTypeDetails> request)
        {
            return await _adminRepository.ImportCustomerTypesDetails(request);
        }
        #endregion Customer Type API Service

        #region Leave Type API Service
        public async Task<IEnumerable<LeaveTypeResponse>> GetLeaveTypesList(SearchLeaveTypeRequest request)
        {
            return await _adminRepository.GetLeaveTypesList(request);
        }

        public async Task<int> SaveLeaveType(LeaveTypeRequest leaveTypeRequest)
        {
            return await _adminRepository.SaveLeaveType(leaveTypeRequest);

        }
        public async Task<LeaveTypeResponse?> GetLeaveTypeDetailsById(long id)
        {
            return await _adminRepository.GetLeaveTypeDetailsById(id);
        }
        public async Task<IEnumerable<LeaveTypeDataValidationErrors>> ImportLeaveTypesDetails(List<ImportedLeaveTypeDetails> request)
        {
            return await _adminRepository.ImportLeaveTypesDetails(request);
        }
        #endregion Leave Type API Service

        #region Master Data
        public async Task<IEnumerable<SelectListResponse>> GetStatesForSelectList(StatesSelectListRequestModel parameters)
        {
            return await _adminRepository.GetStatesForSelectList(parameters);
        }

        public async Task<IEnumerable<SelectListResponse>> GetRegionForSelectList(RegionSelectListRequestModel parameters)
        {
            return await _adminRepository.GetRegionForSelectList(parameters);
        }

        public async Task<IEnumerable<SelectListResponse>> GetDistrictForSelectList(DistrictSelectListRequestModel parameters)
        {
            return await _adminRepository.GetDistrictForSelectList(parameters);
        }

        public async Task<IEnumerable<SelectListResponse>> GetAreaForSelectList(AreaSelectListRequestModel parameters)
        {
            return await _adminRepository.GetAreaForSelectList(parameters);
        }

        public async Task<IEnumerable<SelectListResponse>> GetCustomerTypesForSelectList(CommonSelectListRequestModel parameters)
        {
            return await _adminRepository.GetCustomerTypesForSelectList(parameters);
        }

        public async Task<IEnumerable<SelectListResponse>> GetCustomersForSelectList(CustomerSelectListRequestModel parameters)
        {
            return await _adminRepository.GetCustomersForSelectList(parameters);
        }
        
        public async Task<IEnumerable<SelectListResponse>> GetStatusMasterForSelectList(string statusCode)
        {
            return await _adminRepository.GetStatusMasterForSelectList(statusCode);
        }

        public async Task<IEnumerable<SelectListResponse>> GetReportingToEmployeeForSelectList(ReportingToEmpListParameters parameters)
        {
            return await _adminRepository.GetReportingToEmployeeForSelectList(parameters);
        }

        public async Task<IEnumerable<CustomerContactsListForFields>> GetCustomerContactsListForFields(CustomerContactsListRequest parameters)
        {
            return await _adminRepository.GetCustomerContactsListForFields(parameters);
        }
        #endregion

        #region Blood Group Master
        public async Task<int> SaveBloodGroupDetails(BloodGroupRequestModel parameters)
        {
            return await _adminRepository.SaveBloodGroupDetails(parameters);
        }

        public async Task<IEnumerable<BloodGroupResponseModel>> GetBloodGroupList(SearchBloodGroupRequestModel parameters)
        {
            return await _adminRepository.GetBloodGroupList(parameters);
        }

        public async Task<BloodGroupResponseModel?> GetBloodGroupDetails(long id)
        {
            return await _adminRepository.GetBloodGroupDetails(id);
        }
        #endregion

        #region Collection Master
        public async Task<int> SaveCollectionMasterDetails(SaveCollectionRequestModel parameters)
        {
            return await _adminRepository.SaveCollectionMasterDetails(parameters);
        }

        public async Task<IEnumerable<CollectionResponseModel>> GetCollectionMasterList(SearchCollectionRequestModel parameters)
        {
            return await _adminRepository.GetCollectionMasterList(parameters);
        }

        public async Task<CollectionResponseModel?> GetCollectionMasterDetails(int id)
        {
            return await _adminRepository.GetCollectionMasterDetails(id);
        }
        public async Task<IEnumerable<CollectionDataValidationErrors>> ImportCollection(List<ImportedCollection> request)
        {
            return await _adminRepository.ImportCollection(request);
        }
        #endregion

        #region VisitType API Service
        public async Task<IEnumerable<VisitTypeResponse>> GetVisitTypeList(SearchVisitTypeRequest request)
        {
            return await _adminRepository.GetVisitTypeList(request);
        }

        public async Task<int> SaveVisitType(VisitTypeRequest VisitTypeRequest)
        {
            return await _adminRepository.SaveVisitType(VisitTypeRequest);

        }

        public async Task<VisitTypeResponse?> GetVisitTypeDetailsById(long id)
        {
            return await _adminRepository.GetVisitTypeDetailsById(id);
        }

        #endregion VisitType API Service

        #region Expense Type
        public async Task<int> SaveExpenseType(ExpenseTypeRequest request)
        {
            return await _adminRepository.SaveExpenseType(request);
        }
        public async Task<IEnumerable<ExpenseTypeResponse>> GetExpenseTypeList(SearchExpenseTypeRequest request)
        {
            return await _adminRepository.GetExpenseTypeList(request);
        }
        public async Task<ExpenseTypeResponse?> GetExpenseTypeDetailsById(long id)
        {
            return await _adminRepository.GetExpenseTypeDetailsById(id);
        }
        #endregion

        #region Priority
        public async Task<int> SavePriority(PriorityRequest request)
        {
            return await _adminRepository.SavePriority(request);
        }
        public async Task<IEnumerable<PriorityResponse>> GetPriorityList(SearchPriorityRequest request)
        {
            return await _adminRepository.GetPriorityList(request);
        }
        public async Task<PriorityResponse?> GetPriorityDetailsById(long id)
        {
            return await _adminRepository.GetPriorityDetailsById(id);
        }
        #endregion

        #region Activity Type
        public async Task<int> SaveActivityType(ActivityTypeRequest request)
        {
            return await _adminRepository.SaveActivityType(request);
        }
        public async Task<IEnumerable<ActivityTypeResponse>> GetActivityTypeList(SearchActivityTypeRequest request)
        {
            return await _adminRepository.GetActivityTypeList(request);
        }
        public async Task<ActivityTypeResponse?> GetActivityTypeDetailsById(long id)
        {
            return await _adminRepository.GetActivityTypeDetailsById(id);
        }
        #endregion

        #region Activity Status
        public async Task<int> SaveActivityStatus(ActivityStatusRequest request)
        {
            return await _adminRepository.SaveActivityStatus(request);
        }
        public async Task<IEnumerable<ActivityStatusResponse>> GetActivityStatusList(SearchActivityStatusRequest request)
        {
            return await _adminRepository.GetActivityStatusList(request);
        }
        public async Task<ActivityStatusResponse?> GetActivityStatusDetailsById(long id)
        {
            return await _adminRepository.GetActivityStatusDetailsById(id);
        }
        #endregion
    }
}
