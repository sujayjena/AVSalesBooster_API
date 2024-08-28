using Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Interfaces.Services
{
    public interface IIndustryService
    {
        #region Industry
        Task<int> SaveIndustryDetails(IndustryRequest request);
        Task<IEnumerable<IndustryResponse>> GetIndustryList(SearchIndustryRequest request);
        Task<IndustryResponse?> GetIndustryDetailsById(long Id);
        #endregion

        #region Industry Solution
        Task<int> SaveIndustrySolutionDetails(IndustrySolutionRequest request);
        Task<IEnumerable<IndustrySolutionResponse>> GetIndustrySolutionList(SearchIndustrySolutionRequest request);
        Task<IndustrySolutionResponse?> GetIndustrySolutionDetailsById(long Id);
        #endregion

        #region Solution Feature Image
        Task<int> SaveSolutionFeatureDetails(SolutionFeatureRequest request);
        Task<IEnumerable<SolutionFeatureResponse>> GetSolutionFeatureList(SearchSolutionFeature_Image_YoutubeUrl_Request request);
        #endregion

        #region Solution Image
        Task<int> SaveSolutionImageDetails(SolutionImageRequest request);
        Task<IEnumerable<SolutionImageResponse>> GetSolutionImageList(SearchSolutionFeature_Image_YoutubeUrl_Request request);
        #endregion

        #region Solution Youtube Url
        Task<int> SaveSolutionYoutubeUrlDetails(SolutionYoutubeUrlRequest request);
        Task<IEnumerable<SolutionYoutubeUrlResponse>> GetSolutionYoutubeUrlList(SearchSolutionFeature_Image_YoutubeUrl_Request request);
        #endregion
    }
}
