using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class ActivityTypeRequest
    {
        public long ActivityTypeId { get; set; }

        [DefaultValue("")]
        public string ActivityTypeName { get; set; }
        public bool IsActive { get; set; }
    }

    public class ActivityTypeResponse : CreationDetails
    {
        public long ActivityTypeId { get; set; }
        public string ActivityTypeName { get; set; }
        public dynamic IsActive { get; set; }

    }
    public class SearchActivityTypeRequest
    {
        public PaginationParameters pagination { get; set; }

        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;
        public bool? IsActive { get; set; }
    }
}
