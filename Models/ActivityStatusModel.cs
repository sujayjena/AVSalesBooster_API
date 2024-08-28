using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class ActivityStatusRequest
    {
        public long ActivityStatusId { get; set; }

        [DefaultValue("")]
        public string ActivityStatusName { get; set; }
        public bool IsActive { get; set; }
    }

    public class ActivityStatusResponse : CreationDetails
    {
        public long ActivityStatusId { get; set; }
        public string ActivityStatusName { get; set; }
        public dynamic IsActive { get; set; }

    }
    public class SearchActivityStatusRequest
    {
        public PaginationParameters pagination { get; set; }

        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;
        public bool? IsActive { get; set; }
    }
}
