using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class ServiceDetailsRequest
    {
        public long ServiceId { get; set; }

        [DefaultValue("")]
        public string? ServiceName { get; set; }

        [DefaultValue("")]
        public string? ServiceDesc { get; set; }

        [DefaultValue("")]
        public string? YoutubeLink { get; set; }

        public bool? IsActive { get; set; }
    }

    public class SearchServiceDetailsRequest
    {
        public PaginationParameters pagination { get; set; }
        public string SearchValue { get; set; }
        public Nullable<bool> IsActive { get; set; }
    }

    public class ServiceDetailsResponse : CreationDetails
    {
        public long ServiceId { get; set; }
        public string? ServiceName { get; set; }
        public string? ServiceDesc { get; set; }
        public string? YoutubeLink { get; set; }
        public bool IsActive { get; set; }
    }
}
