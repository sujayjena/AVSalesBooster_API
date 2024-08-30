using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class BroadCastRequest
    {
        public long Id { get; set; }

        [DefaultValue("")]
        public string MessageName { get; set; }
        public int SequenceNo { get; set; }
        public bool IsActive { get; set; }
    }

    public class BroadCastResponse : CreationDetails
    {
        public long Id { get; set; }
        public string MessageName { get; set; }
        public int SequenceNo { get; set; }
        public dynamic IsActive { get; set; }

    }
    public class SearchBroadCastRequest
    {
        public PaginationParameters pagination { get; set; }

        [DefaultValue("")]
        public string ValueForSearch { get; set; } = null;

        [DefaultValue(null)]
        public bool? IsActive { get; set; }
    }

}
