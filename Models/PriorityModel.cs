using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class PriorityRequest
    {
        public long PriorityId { get; set; }

        [DefaultValue("")]
        public string PriorityName { get; set; }
        public bool IsActive { get; set; }
    }

    public class PriorityResponse : CreationDetails
    {
        public long PriorityId { get; set; }
        public string PriorityName { get; set; }
        public dynamic IsActive { get; set; }

    }
    public class SearchPriorityRequest
    {
        public PaginationParameters pagination { get; set; }

        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;
        public bool? IsActive { get; set; }
    }
}
