using Microsoft.AspNetCore.Http;
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
    public class CatalogRelatedRequest
    {
        public long CatalogRelatedId { get; set; }

        [Required(ErrorMessage = ValidationConstants.CatelogRequied_Msg)]
        [DefaultValue(0)]
        public long CatalogId { get; set; }

        //[Required(ErrorMessage = ValidationConstants.CollectionNameRequied_Msg)]
        [DefaultValue(0)]
        public long CollectionId { get; set; }

        //[Required(ErrorMessage = ValidationConstants.CategoryRequied_Msg)]
        [DefaultValue(0)]
        public long CategoryId { get; set; }

        //[Required(ErrorMessage = ValidationConstants.DesignRequied_Msg)]
        [DefaultValue(0)]
        public long BaseDesignId { get; set; }

        //[Required(ErrorMessage = ValidationConstants.SizeRequied_Msg)]
        [DefaultValue(0)]
        public long SizeId { get; set; }

        //[Required(ErrorMessage = ValidationConstants.SeriesRequied_Msg)]
        [DefaultValue(0)]
        public long SeriesId { get; set; }

        public string DesignCode { get; set; }
        public string DesignSubCode { get; set; }

        public string ImageFileName { get; set; }
        public string ImageSavedFileName { get; set; }
        public IFormFile ImageFile { get; set; }
        public string ImageFileUrl { get; set; }

        public string Status { get; set; }

        public bool IsActive { get; set; }
    }
    public class SearchCatalogRelatedRequest
    {
        public PaginationParameters pagination { get; set; }

        [DefaultValue("")]
        public string SearchValue { get; set; }
        public long CatalogId { get; set; }
        public Nullable<bool> IsActive { get; set; }
    }
    public class CatalogRelatedResponse : CreationDetails
    {
        public long CatalogRelatedId { get; set; }
        public long CatalogId { get; set; }
        public long CollectionId { get; set; }
        public string CollectionName { get; set; }
        public long CategoryId { get; set; }
        public string CategoryName { get; set; }
        public long BaseDesignId { get; set; }
        public string BaseDesignName { get; set; }
        public long SizeId { get; set; }
        public string SizeName { get; set; }
        public long SeriesId { get; set; }
        public string SeriesName { get; set; }
        public string DesignCode { get; set; }
        public string DesignSubCode { get; set; }
        public string ImageFileName { get; set; }
        public string ImageSavedFileName { get; set; }
        public byte[] ImageFile { get; set; }
        public string ImageFileUrl { get; set; }
        public bool IsActive { get; set; }
    }
    public class CatalogRelatedDetailsResponse
    {
        public CatalogRelatedResponse catalogRelatedDetails { get; set; }
    }
}
