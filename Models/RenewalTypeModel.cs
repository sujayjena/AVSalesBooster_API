using Models.Constants;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models
{
    public class RenewalTypeRequest
    {
        public long RenewalTypeId { get; set; }
        public string RenewalTypeName { get; set; }
        public bool IsActive { get; set; }
    }

    public class RenewalTypeResponse : CreationDetails
    {
        public long RenewalTypeId { get; set; }
        public string RenewalTypeName { get; set; }
        public bool IsActive { get; set; }

    }

    public class SearchRenewalTypeRequest
    {
        public PaginationParameters pagination { get; set; }
        public string RenewalTypeName { get; set; }
        public Nullable<bool> IsActive { get; set; }
    }
}
