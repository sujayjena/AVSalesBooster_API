using Microsoft.AspNetCore.Http;
using Models.Constants;
using Newtonsoft.Json;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace Models
{
    public class DesignRequest
    {
        public long DesignId { get; set; }

        public long? CollectionId { get; set; }

        public string CollectionNameId { get; set; }

        public long? CategoryId { get; set; }

        [Range(1, long.MaxValue, ErrorMessage = ValidationConstants.SizeRequied_Dropdown_Msg)]
        public long SizeId { get; set; }

        [Range(1, long.MaxValue, ErrorMessage = ValidationConstants.SeriesRequied_Dropdown_Msg)]
        public long SeriesId { get; set; }

        [Range(1, long.MaxValue, ErrorMessage = ValidationConstants.BaseDesignRequied_Dropdown_Msg)]
        public long BaseDesignId { get; set; }

        [Required(ErrorMessage = ValidationConstants.DesignCodeRequied_Msg)]
        [RegularExpression(ValidationConstants.DesignCodeRegExp, ErrorMessage = ValidationConstants.DesignCodeRegExp_Msg)]
        [MaxLength(ValidationConstants.DesignCode_MaxLength, ErrorMessage = ValidationConstants.DesignCode_MaxLength_Msg)]
        public string DesignCode { get; set; }

        public bool IsActive { get; set; }

        public long[] DesignImagesIdToDelete { get; set; }

        public IFormFile[] DesignImages { get; set; }
    }

    public class SearchDesignRequest
    {
        public PaginationParameters pagination { get; set; }
        //public string DesignName { get; set; }

        [DefaultValue("")]
        public string SearchValue { get; set; }
        public Nullable<bool> IsActive { get; set; }
    }

    public class DesignResponse : CreationDetails
    {
        public long DesignId { get; set; }
        public long CollectionId { get; set; }
        public string CollectionName { get; set; }
        public string CollectionNameId { get; set; }
        public long CategoryId { get; set; }
        public string CategoryName { get; set; }
        public long SizeId { get; set; }
        public string SizeName { get; set; }
        public long SeriesId { get; set; }
        public string SeriesName { get; set; }
        public long BaseDesignId { get; set; }
        public string BaseDesignName { get; set; }
        public string DesignCode { get; set; }
        public bool IsActive { get; set; }
        public List<DesignMasterImages> DesignImages { get; set; }
    }

    public class ImportedDesignDetails
    {
        public string ProductName { get; set; }
        public string BrandName { get; set; }
        public string SizeName { get; set; }
        public string CategoryName { get; set; }
        public string SeriesName { get; set; }
        public string DesignTypeName { get; set; }
        public string BaseDesignName { get; set; }
        public string DesignName { get; set; }
        public string DesignCode { get; set; }
        public string IsActive { get; set; }
    }

    public class DesignDataValidationErrors
    {
        public string ProductName { get; set; }
        public string BrandName { get; set; }
        public string SizeName { get; set; }
        public string CategoryName { get; set; }
        public string SeriesName { get; set; }
        public string DesignTypeName { get; set; }
        public string BaseDesignName { get; set; }
        public string DesignName { get; set; }
        public string DesignCode { get; set; }
        public string IsActive { get; set; }
        public string ValidationMessage { get; set; }
    }

    public class DesignMasterImages
    {
        public long DesignImageId { get; set; }
        public long DesignId { get; set; }
        public string UploadedFilesName { get; set; }
        public string SavedFilesName { get; set; }
        public bool IsToDeleteImage { get; set; }
        public byte[] DesignFile { get; set; }
        public string DesignFileUrl { get; set; }
    }
}
