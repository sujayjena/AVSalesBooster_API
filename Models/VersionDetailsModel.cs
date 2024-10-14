using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class VersionDetailsRequest
    {
        public long Id { get; set; }
        public long? AppVersionNo { get; set; }

        [DefaultValue("")]
        public string? AppVersionName { get; set; }

        [DefaultValue("")]
        public string? UpdateMsg { get; set; }

        [DefaultValue("")]
        public string? PackageName { get; set; }

        [DefaultValue("")]
        public string? UpdateType { get; set; }
        public bool? IsActive { get; set; }
    }

    public class VersionDetailsResponse : CreationDetails
    {
        public long Id { get; set; }
        public long? AppVersionNo { get; set; }
        public string? AppVersionName { get; set; }
        public string? UpdateMsg { get; set; }
        public string? PackageName { get; set; }
        public string? UpdateType { get; set; }
        public dynamic IsActive { get; set; }

    }
    public class SearchVersionDetailsRequest
    {
        public PaginationParameters pagination { get; set; }

        [DefaultValue("")]
        public string? PackageName { get; set; }

        [DefaultValue("")]
        public string? UpdateType { get; set; }

        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;
        public bool? IsActive { get; set; }
    }
}
