using Models.Constants;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class IndustryRequest
    {
        //public IndustryRequest()
        //{
        //    solutionList = new List<IndustrySolutionRequest>();
        //}
        public long IndustryId { get; set; }

        [DefaultValue("")]
        public string? IndustryName { get; set; }
        public bool? IsActive { get; set; }

        //public List<IndustrySolutionRequest> solutionList { get; set; }
    }
    public class SearchIndustryRequest
    {
        public PaginationParameters pagination { get; set; }
        public string IndustryName { get; set; }
        public Nullable<bool> IsActive { get; set; }

    }

    public class IndustryResponse : CreationDetails
    {
        public long IndustryId { get; set; }
        public string IndustryName { get; set; }
        public bool IsActive { get; set; }
    }

    public class IndustrySolutionRequest
    {
        public IndustrySolutionRequest()
        {
            solutionFeatureList = new List<SolutionFeatureRequest>();
            solutionImageList = new List<SolutionImageRequest>();
            solutionYoutubeUrlList = new List<SolutionYoutubeUrlRequest>();
        }
        public long IndustrySolutionId { get; set; }
        public long IndustryId { get; set; }

        [DefaultValue("")]
        public string? SolutionName { get; set; }

        [DefaultValue("")]
        public string? SolutionDesc { get; set; }
        public bool? IsActive { get; set; }

        public List<SolutionFeatureRequest> solutionFeatureList { get; set; }
        public List<SolutionImageRequest> solutionImageList { get; set; }
        public List<SolutionYoutubeUrlRequest> solutionYoutubeUrlList { get; set; }
    }

    public class SolutionFeatureRequest
    {
        public long SolutionFeatureId { get; set; }
        public long IndustrySolutionId { get; set; }

        [DefaultValue("")]
        public string? FeatureFileName { get; set; }

        [DefaultValue("")]
        public string? FeatureSavedFileName { get; set; }

        [DefaultValue("")]
        public string? Feature_Base64 { get; set; }
        public bool? IsActive { get; set; }
    }

    public class SolutionImageRequest
    {
        public long SolutionImageId { get; set; }
        public long IndustrySolutionId { get; set; }

        [DefaultValue("")]
        public string? ImageFileName { get; set; }

        [DefaultValue("")]
        public string? ImageSavedFileName { get; set; }

        [DefaultValue("")]
        public string? Image_Base64 { get; set; }
        public bool? IsActive { get; set; }
    }

    public class SolutionYoutubeUrlRequest
    {
        public long SolutionYoutubeUrlId { get; set; }
        public long IndustrySolutionId { get; set; }

        [DefaultValue("")]
        public string? YoutubeUrl { get; set; }
        public bool IsActive { get; set; }
    }

    public class SearchIndustrySolutionRequest
    {
        public PaginationParameters pagination { get; set; }
        public string SearchValue { get; set; }
        public Nullable<bool> IsActive { get; set; }
        public long IndustryId { get; set; }
    }

    public class IndustrySolutionResponse : CreationDetails
    {
        public long IndustrySolutionId { get; set; }
        public long IndustryId { get; set; }
        public string SolutionName { get; set; }
        public string SolutionDesc { get; set; }
        public bool IsActive { get; set; }
    }

    public class SearchSolutionFeature_Image_YoutubeUrl_Request
    {
        public PaginationParameters pagination { get; set; }
        public string SearchValue { get; set; }
        public Nullable<bool> IsActive { get; set; }
        public long IndustrySolutionId { get; set; }
    }

    public class SolutionFeatureResponse : CreationDetails
    {
        public long SolutionFeatureId { get; set; }
        public long IndustrySolutionId { get; set; }
        public string FeatureFileName { get; set; }
        public string FeatureSavedFileName { get; set; }
        public string FeatureFileUrl { get; set; }
        public bool IsActive { get; set; }
    }

    public class SolutionImageResponse : CreationDetails
    {
        public long SolutionImageId { get; set; }
        public long IndustrySolutionId { get; set; }
        public string ImageFileName { get; set; }
        public string ImageSavedFileName { get; set; }
        public string ImageFileUrl { get; set; }
        public bool IsActive { get; set; }
    }

    public class SolutionYoutubeUrlResponse : CreationDetails
    {
        public long SolutionYoutubeUrlId { get; set; }
        public long IndustrySolutionId { get; set; }
        public string YoutubeUrl { get; set; }
        public bool IsActive { get; set; }
    }
}
