using Helpers;
using Interfaces.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Models;
using Models.Constants;
using Models.Enums;
using Services;

namespace AVSalesBoosterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class IndustryController : CustomBaseController
    {
        private ResponseModel _response;
        private IIndustryService _industryService;
        private IFileManager _fileManager;

        public IndustryController(IIndustryService industryService, IFileManager fileManager)
        {
            _industryService = industryService;
            _fileManager = fileManager;

            _response = new ResponseModel();
            _response.IsSuccess = true;
        }

        #region Industry Details
        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveIndustryDetails(IndustryRequest parameter)
        {
            int result = await _industryService.SaveIndustryDetails(parameter);
            _response.IsSuccess = false;

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Record is already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.IsSuccess = true;
                _response.Message = "Record saved sucessfully";

                // Add data into Solution details
                //foreach (var items in parameter.solutionList)
                //{
                //    var vIndustrySolution = new IndustrySolutionRequest()
                //    {
                //        IndustrySolutionId = items.IndustrySolutionId,
                //        IndustryId = result,
                //        SolutionName = items.SolutionName,
                //        SolutionDesc = items.SolutionDesc,
                //        IsActive = items.IsActive,
                //    };

                //    int resultIndustrySolution = await _industryService.SaveIndustrySolutionDetails(vIndustrySolution);

                     
                //}
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetIndustryList(SearchIndustryRequest request)
        {
            IEnumerable<IndustryResponse> lstIndustry = await _industryService.GetIndustryList(request);

            _response.Data = lstIndustry.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpGet]
        public async Task<ResponseModel> GetIndustryDetails(long id)
        {
            if (id <= 0)
            {
                _response.IsSuccess = false;
                _response.Message = ValidationConstants.Id_Required_Msg;
            }
            else
            {
                var list = await _industryService.GetIndustryDetailsById(id);

                _response.Data = list;
            }

            return _response;
        }
        #endregion

        #region Industry Solution

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveIndustrySolutionDetails(IndustrySolutionRequest parameter)
        {
            int result = await _industryService.SaveIndustrySolutionDetails(parameter);
            _response.IsSuccess = false;

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Record is already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.IsSuccess = true;
                _response.Message = "Record saved sucessfully";

                // Add data into Solution Fetaure details
                foreach (var items in parameter.solutionFeatureList)
                {
                    // Feature Image Upload
                    if (items! != null && !string.IsNullOrWhiteSpace(items.Feature_Base64))
                    {
                        var vUploadFile = _fileManager.UploadDocumentsBase64ToFile(items.Feature_Base64, "\\Uploads\\Industry\\Feature\\", items.FeatureFileName);

                        if (!string.IsNullOrWhiteSpace(vUploadFile))
                        {
                            items.FeatureSavedFileName = vUploadFile;
                        }
                    }

                    var vSolutionFeature = new SolutionFeatureRequest()
                    {
                        SolutionFeatureId = items.SolutionFeatureId,
                        IndustrySolutionId = result,
                        FeatureFileName = items.FeatureFileName,
                        FeatureSavedFileName = items.FeatureSavedFileName,
                        IsActive = items.IsActive,
                    };

                    int resultSolutionFeature = await _industryService.SaveSolutionFeatureDetails(vSolutionFeature);
                }

                foreach (var items in parameter.solutionImageList)
                {
                    // Image Upload
                    if (items! != null && !string.IsNullOrWhiteSpace(items.Image_Base64))
                    {
                        var vUploadFile = _fileManager.UploadDocumentsBase64ToFile(items.Image_Base64, "\\Uploads\\Industry\\Images\\", items.ImageFileName);

                        if (!string.IsNullOrWhiteSpace(vUploadFile))
                        {
                            items.ImageSavedFileName = vUploadFile;
                        }
                    }

                    var vSolutionImage = new SolutionImageRequest()
                    {
                        SolutionImageId = items.SolutionImageId,
                        IndustrySolutionId = result,
                        ImageFileName = items.ImageFileName,
                        ImageSavedFileName = items.ImageSavedFileName,
                        IsActive = items.IsActive,
                    };

                    int resultSolutionImage = await _industryService.SaveSolutionImageDetails(vSolutionImage);
                }

                foreach (var items in parameter.solutionYoutubeUrlList)
                {
                    var vSolutionYoutubeUrl = new SolutionYoutubeUrlRequest()
                    {
                        SolutionYoutubeUrlId = items.SolutionYoutubeUrlId,
                        IndustrySolutionId = result,
                        YoutubeUrl = items.YoutubeUrl,
                        IsActive = items.IsActive,
                    };

                    int resultSolutionYoutubeUrl = await _industryService.SaveSolutionYoutubeUrlDetails(vSolutionYoutubeUrl);
                }
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetIndustrySolutionList(SearchIndustrySolutionRequest request)
        {
            IEnumerable<IndustrySolutionResponse> list = await _industryService.GetIndustrySolutionList(request);

            _response.Data = list.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }

        [Route("[action]")]
        [HttpGet]
        public async Task<ResponseModel> GetIndustrySolutionDetails(long id)
        {
            if (id <= 0)
            {
                _response.IsSuccess = false;
                _response.Message = ValidationConstants.Id_Required_Msg;
            }
            else
            {
                var list = await _industryService.GetIndustrySolutionDetailsById(id);

                _response.Data = list;
            }

            return _response;
        }
        #endregion

        #region Solution Feature
        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveSolutionFeatureDetails(SolutionFeatureRequest parameter)
        {
            // Feature Image Upload
            if (parameter! != null && !string.IsNullOrWhiteSpace(parameter.Feature_Base64))
            {
                var vUploadFile = _fileManager.UploadDocumentsBase64ToFile(parameter.Feature_Base64, "\\Uploads\\Industry\\Feature\\", parameter.FeatureFileName);

                if (!string.IsNullOrWhiteSpace(vUploadFile))
                {
                    parameter.FeatureSavedFileName = vUploadFile;
                }
            }

            int result = await _industryService.SaveSolutionFeatureDetails(parameter);
            _response.IsSuccess = false;

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Record is already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.IsSuccess = true;
                _response.Message = "Record saved sucessfully";
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetSolutionFeatureList(SearchSolutionFeature_Image_YoutubeUrl_Request request)
        {
            var host = $"{this.Request.Scheme}://{this.Request.Host}{this.Request.PathBase}";

            IEnumerable<SolutionFeatureResponse> list = await _industryService.GetSolutionFeatureList(request);
            foreach (var item in list)
            {
                if (!string.IsNullOrWhiteSpace(item.FeatureSavedFileName))
                {
                    item.FeatureFileUrl = host + _fileManager.GetSolutionFeatureFile(item.FeatureSavedFileName);
                }
            }

            _response.Data = list.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }
        #endregion

        #region Solution Image
        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveSolutionImageDetails(SolutionImageRequest parameter)
        {
            // Feature Image Upload
            if (parameter! != null && !string.IsNullOrWhiteSpace(parameter.Image_Base64))
            {
                var vUploadFile = _fileManager.UploadDocumentsBase64ToFile(parameter.Image_Base64, "\\Uploads\\Industry\\Images\\", parameter.ImageFileName);

                if (!string.IsNullOrWhiteSpace(vUploadFile))
                {
                    parameter.ImageSavedFileName = vUploadFile;
                }
            }

            int result = await _industryService.SaveSolutionImageDetails(parameter);
            _response.IsSuccess = false;

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Record is already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.IsSuccess = true;
                _response.Message = "Record saved sucessfully";
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetSolutionImageList(SearchSolutionFeature_Image_YoutubeUrl_Request request)
        {
            var host = $"{this.Request.Scheme}://{this.Request.Host}{this.Request.PathBase}";

            IEnumerable<SolutionImageResponse> list = await _industryService.GetSolutionImageList(request);
            foreach (var item in list)
            {
                if (!string.IsNullOrWhiteSpace(item.ImageSavedFileName))
                {
                    item.ImageFileUrl = host + _fileManager.GetSolutionImageFile(item.ImageSavedFileName);
                }
            }

            _response.Data = list.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }
        #endregion

        #region Solution Youtube Url
        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> SaveSolutionYoutubeUrlDetails(SolutionYoutubeUrlRequest parameter)
        {
            int result = await _industryService.SaveSolutionYoutubeUrlDetails(parameter);
            _response.IsSuccess = false;

            if (result == (int)SaveEnums.NoRecordExists)
            {
                _response.Message = "No record exists";
            }
            else if (result == (int)SaveEnums.NameExists)
            {
                _response.Message = "Record is already exists";
            }
            else if (result == (int)SaveEnums.NoResult)
            {
                _response.Message = "Something went wrong, please try again";
            }
            else
            {
                _response.IsSuccess = true;
                _response.Message = "Record saved sucessfully";
            }

            return _response;
        }

        [Route("[action]")]
        [HttpPost]
        public async Task<ResponseModel> GetSolutionYoutubeUrlList(SearchSolutionFeature_Image_YoutubeUrl_Request request)
        {
            IEnumerable<SolutionYoutubeUrlResponse> list = await _industryService.GetSolutionYoutubeUrlList(request);

            _response.Data = list.ToList();
            _response.Total = request.pagination.Total;
            return _response;
        }
        #endregion
    }
}
