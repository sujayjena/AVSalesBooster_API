using Helpers;
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
    public class IndustryService : IIndustryService
    {
        private IIndustryRepository _industryRepository;
        private IFileManager _fileManager;

        public IndustryService(IIndustryRepository industryRepository, IFileManager fileManager)
        {
            _industryRepository = industryRepository;
            _fileManager = fileManager;
        }

        public async Task<int> SaveIndustryDetails(IndustryRequest request)
        {
            return await _industryRepository.SaveIndustryDetails(request);
        }

        public async Task<IEnumerable<IndustryResponse>> GetIndustryList(SearchIndustryRequest request)
        {
            return await _industryRepository.GetIndustryList(request);
        }

        public async Task<IndustryResponse?> GetIndustryDetailsById(long id)
        {
            return await _industryRepository.GetIndustryDetailsById(id);
        }

        public async Task<int> SaveIndustrySolutionDetails(IndustrySolutionRequest request)
        {
            return await _industryRepository.SaveIndustrySolutionDetails(request);
        }

        public async Task<IEnumerable<IndustrySolutionResponse>> GetIndustrySolutionList(SearchIndustrySolutionRequest request)
        {
            return await _industryRepository.GetIndustrySolutionList(request);
        }

        public async Task<IndustrySolutionResponse?> GetIndustrySolutionDetailsById(long id)
        {
            return await _industryRepository.GetIndustrySolutionDetailsById(id);
        }

        public async Task<int> SaveSolutionFeatureDetails(SolutionFeatureRequest request)
        {
            return await _industryRepository.SaveSolutionFeatureDetails(request);
        }

        public async Task<IEnumerable<SolutionFeatureResponse>> GetSolutionFeatureList(SearchSolutionFeature_Image_YoutubeUrl_Request request)
        {
            return await _industryRepository.GetSolutionFeatureList(request);
        }

        public async Task<int> SaveSolutionImageDetails(SolutionImageRequest request)
        {
            return await _industryRepository.SaveSolutionImageDetails(request);
        }

        public async Task<IEnumerable<SolutionImageResponse>> GetSolutionImageList(SearchSolutionFeature_Image_YoutubeUrl_Request request)
        {
            return await _industryRepository.GetSolutionImageList(request);
        }

        public async Task<int> SaveSolutionYoutubeUrlDetails(SolutionYoutubeUrlRequest request)
        {
            return await _industryRepository.SaveSolutionYoutubeUrlDetails(request);
        }

        public async Task<IEnumerable<SolutionYoutubeUrlResponse>> GetSolutionYoutubeUrlList(SearchSolutionFeature_Image_YoutubeUrl_Request request)
        {
            return await _industryRepository.GetSolutionYoutubeUrlList(request);
        }
    }
}
