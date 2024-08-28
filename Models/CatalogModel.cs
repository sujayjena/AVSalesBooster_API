using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Models.Constants;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace Models
{
    public class CatalogRequest
    {
        public long CatalogId { get; set; }

        [Required(ErrorMessage = ValidationConstants.LaunchDateRequied_Msg)]
        public DateTime LaunchDate { get; set; }

        [Required(ErrorMessage = ValidationConstants.CollectionNameRequied_Msg)]
        public long CollectionId { get; set; }

        public string Remark { get; set; }

        public string ImageFileName { get; set; }
        public string ImageSavedFileName { get; set; }
        public IFormFile ImageFile { get; set; }
        public string CatalogFileName { get; set; }
        public string CatalogSavedFileName { get; set; }

        public IFormFile CatalogFile { get; set; }

        public string Status { get; set; }

        public bool IsActive { get; set; }
    }
    public class SearchCatalogRequest
    {
        public PaginationParameters pagination { get; set; }

        [DefaultValue("")]
        public string SearchValue { get; set; }
        //public string CollectionName { get; set; }
        public Nullable<bool> IsActive { get; set; }

        [DefaultValue("W")]
        public string AppType { get; set; }
    }
    public class CatalogResponse : CreationDetails
    {
        public long CatalogId { get; set; }
        public DateTime LaunchDate { get; set; }
        public long CollectionId { get; set; }
        public string CollectionName { get; set; }
        public string Remark { get; set; }
        public string Status { get; set; }
        public string ImageFileName { get; set; }
        public string ImageSavedFileName { get; set; }
        public byte[] ImageFile { get; set; }
        public string ImageFileUrl { get; set; }
        public string CatalogFileName { get; set; }
        public string CatalogSavedFileName { get; set; }
        public byte[] CatalogFile { get; set; }
        public string CatalogFileUrl { get; set; }
        public bool IsActive { get; set; }
    }
    public class CatalogDetailsResponse
    {
        public CatalogResponse catalogDetails { get; set; }
    }
}
